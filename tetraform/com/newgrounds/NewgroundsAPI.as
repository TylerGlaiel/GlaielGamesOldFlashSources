package com.newgrounds
{
	import com.adobe.crypto.MD5;
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class NewgroundsAPI
	{				
		// set to true when debugging this class to see all the input/output traced to the output panel.
		private static var do_echo:Boolean = false;
		
		// Dev HTTP Paths
		/*
		private static var GATEWAY_URL:String = "http://staging.newgrounds.com/ngads/gateway_v2.php";
		private static var AD_TERMS_URL:String = "http://staging.newgrounds.com/wiki/flashads/terms/";
		private static var COMMANDS_WIKI_URL:String = "http://staging.newgrounds.com/wiki/flashapi/commands/";
		*/
		
		// HTTP Paths
		
		private static const GATEWAY_URL:String = "http://www.ngads.com/gateway_v2.php";
		private static const AD_TERMS_URL:String = "http://www.newgrounds.com/wiki/flashads/terms/";
		private static const COMMANDS_WIKI_URL:String = "http://www.newgrounds.com/wiki/flashapi/commands/";
		
		
		private static var _initialized:Boolean = false;
		private static var _adsApproved:Boolean = false;
		
		// class variables
		private static var tracker_id:uint, movie_id:String, host:String, encryption_key:String, connected:Boolean, debug:Boolean, version:String, ad_url:String;
		private static var publisher_id:uint, session_id:String, user_email:String, user_name:String, user_id:uint;
		private static var _medals:Array;
		private static var timeoutTimer:Timer = new Timer(8000, 1);
		
		private static var _scoreboards:Array = new Array();

		// savefile vars
		private static var _inSaveQuery:Boolean;
		//private static var _saveQuery:NewgroundsAPISaveGroupQuery;
		private static var _saveFile:SaveFile;
		private static var _saveFilePath:String;
		private static var _saveGroups:Array = [];
		
		private static var root:DisplayObject;
		
		private static var _eventDispatcher:EventDispatcher = new EventDispatcher;
				
		// score vars
		private static var score_page_counts:Object = new Object();
		
		// encoder vars
		private static var compression_radix:String = "/g8236klvBQ#&|;Zb*7CEA59%s`Oue1wziFp$rDVY@TKxUPWytSaGHJ>dmoMR^<0~4qNLhc(I+fjn)X";
		private static var compressor:BaseN = new BaseN(compression_radix);
		
		public static var errors:Dictionary = APIError.init_codes();
		
		// initialize encrypted shared objects container
		private static var sharedObjects:Object = new Object();
		
		// initialize preload values
		private static var _preload:Boolean = true;
		private static var _preloadAssets:Array = [];
				
		private static function assertInitialized():Boolean
		{
			if (!_initialized)
			{
				return false;
			}
			return true;
		}
		
		//=================================== API Configuration ==================================\\
		
		// set the movie version for version control
		public static function setMovieVersion(v:String):void
		{
			if (v && v!="") {
				version = v;
			}
		}
		
		// set the user's email address (only used if there is no session_id)
		public static function setUserEmail(e:String):void
		{
			user_email = e;
		}
		
		public static function get debugMode():Boolean			{ return debug; }
		
		//===================================== Preloader Tools =======================================\\
		public static function get preload():Boolean		{ return _preload; }
		public static function set preload(b:Boolean):void	{ _preload = b; }
		
		public static function get bytesLoaded():uint {
			var bytes:uint = root.loaderInfo.bytesLoaded;
			if (_preload) {
				for each(var loader:* in _preloadAssets)
					bytes += loader.bytesLoaded;
			}
			
			return bytes;
		}
		
		public static function get bytesTotal():uint {
			var bytes:uint = root.loaderInfo.bytesTotal;
			if (_preload) {
				for each(var loader:* in _preloadAssets)
					bytes += Math.max(loader.bytesTotal, 1 );
			}
			
			return bytes;
		}
		
		public static function get percentLoaded():Number {
			return bytesLoaded / bytesTotal;
		}

		internal static function reportNewAsset(asset:*):void {
			_preloadAssets.push( asset );
		}
		
		internal static function reportAssetFailed(asset:*):void {
			for (var i:uint = 0; i < _preloadAssets.length; i++)
				if (asset == _preloadAssets[i]) {
					_preloadAssets.splice(i, 1);
					return;
				}
		}
		
		//========================================== Lookup Functions ==================================\\
		
		// pass the URL that will track a referral and redirect to the official version of this movie
		public static function getOfficialVersionURL():String
		{		
			var o_url:String = GATEWAY_URL+"?tracker_id="+movie_id+"&command_id="+getCommandID('loadOfficalVersion')+"&seed="+Math.random();
			
			if (debug) {
				o_url += "&debug=1";
			}
			return o_url;
		}
		
		public static function get adsApproved():Boolean		{ return _adsApproved; }
		
		// check to see if the hosting site has provided a user session
		public static function hasUserSession():Boolean
		{
			return session_id != null && session_id != "" && publisher_id != 0;
		}
		
		public static function isNewgrounds():Boolean
		{
			return (publisher_id == 1 || getHost().toLowerCase().indexOf("ungrounded.net") > -1);
		}
		
		public static function hasPublisher():Boolean
		{
			return publisher_id != 0;
		}
		
		// check to see if the user has provided an email address
		public static function hasUserEmail():Boolean
		{
			return user_email != null && user_email != "";
		}
		
		//=================================== Gateway Commands ===================================\\
		
		public static function connectionTimeOut(e:Event = null):void
		{
			dispatchEvent(
				new APIEvent(APIEvent.MOVIE_CONNECTED, false, new APIError("CONNECTION_FAILED", "Connection to NewgroundsAPI gateway timed out."))
			);
		}
		
		// this is a quiasi constructor that gets base data about the API entry and loads settings from the API Gateway
		public static function connectMovie(loaderInfo:LoaderInfo, m_id:String, encrypt_key:String):void
		{									
			if (!loaderInfo)
			{
				fatalError("Null loaderInfo paremeter passed in to connectMovie!", "");
				return;
			}

						
			host = loaderInfo.url;
			if (host.indexOf("http://") > -1 || host.indexOf("https://") > -1) {
				host = host.split("/")[2].toLowerCase();	// TODO
			} else {
				host = 'localhost';
			}
			
			var flashVars:Object = loaderInfo.parameters;
			debug = !isPublishedHost();
			if (!debug && flashVars)
			{
				// see if a username was provided.
				if (flashVars.NewgroundsAPI_UserName)
					user_name = flashVars.NewgroundsAPI_UserName;

				// and a user id
				if (flashVars.NewgroundsAPI_UserID)
					user_id = flashVars.NewgroundsAPI_UserID;
				
				if (flashVars.NewgroundsAPI_PublisherID)
					publisher_id = flashVars.NewgroundsAPI_PublisherID;
				
				if (flashVars.NewgroundsAPI_SessionID)
					session_id = flashVars.NewgroundsAPI_SessionID;
					
			}
			else
			{
				publisher_id = 1;
				session_id = "D3bu64p1U53R";
				user_id = 10;
				user_name = "API-Debugger";
			}
						
			// just skip everything if this has already been called
			if (connected) { return; }
			
			timeoutTimer.start();
			
			// if movie_id wasn't provided, the API just can't be used... period
			if (!m_id) {
				fatalError("NewgroundsAPI.connectMovie() - missing required movie_id parameter", 'connectMovie'); 
			}
			
			// make sure the movie id is a string		
			movie_id = String(m_id);
			
			// get the numeric id used to track this movie
			tracker_id = uint(movie_id.substring(0, movie_id.indexOf(":")));
			
			// set the other parameter vars...
			encryption_key = encrypt_key;
				
			// the 'connection' is set to true so we know we have the tracket_id and other pertinant information
			connected = true;
			
			sendCommand('connectMovie', {host:getHost(), movie_version:version});
		}
		
		// figure out what domain the swf is being hosted from		
		private static function getHost():String {
			return host;
		}
		
		// used to deal with automatic debug mode detection
		public static function isPublishedHost():Boolean
		{
			return getHost() != "localhost" && getHost().indexOf("file://") == -1;
		}
		
		// SITE REFERRALS \\
		
		// loads Newgrounds in a new window and tracks the referral
		public static function loadNewgrounds():void
		{
			sendCommand('loadNewgrounds', {host:getHost()}, true);
		}
		
		// loads the author's primary site in a new window and tracks the referral
		public static function loadMySite():void
		{
			sendCommand('loadMySite', {host:getHost()});
		}
		
		// loads the url associated with the link name in a new window and tracks the referral
		public static function loadCustomLink(link:String):void
		{
			sendCommand('loadCustomLink', {host:getHost(), link:link}, true);
		}
		
		// CUSTOM EVENTS \\
		
		// tracks the custom event
		public static function logCustomEvent(event:String):void
		{
			sendCommand('logCustomEvent', {host:getHost(), event:event});
		}
		
		// HIGH SCORES \\
		
		public static function getScoreBoardByName(name:String):ScoreBoard
		{
			for each(var board:ScoreBoard in _scoreboards)
			{
				if (board.name == name)
					return board;
			}
			return null;
		}
		
		public static function getScoreBoardById(id:uint):ScoreBoard
		{
			for each(var board:ScoreBoard in _scoreboards)
			{
				if (board.id == id)
					return board;
			}
			return null;
		}
		
		// posts a high score
		public static function postScore(boardName:String, value:Number, getBest:Boolean = false):void
		{
			if (!boardName || boardName == "" || isNaN(value)) {
				sendError( {command_id:getCommandID('postScore')}, new APIError("MISSING_PARAM", "missing required parameter(s)") );
				return;
			}
			
			sendSecureCommand('postScore', {user_name:user_name, board:boardName, value:value, get_best:getBest, publisher_id:publisher_id});
		}
		
		public static function loadScores(board:ScoreBoard):void
		{
			var command_name:String = 'loadScores';
			
			if (!board.id) {
				sendError( {command_id:getCommandID(command_name)}, new APIError("MISSING_PARAM", "missing required ScoreBoard instance") );
				return;
			}
			
			if (!hasUserSession()) {
				callListener(APIEvent.SCORES_LOADED, false, new APIError("SITE_ID_REQUIRED", "Host '"+getHost()+"' does not have high scores enabled"));
				return;
			}
			
			var params:Object = {};
			params.publisher_id = publisher_id;
			params.period = board.period;
			params.board = board.id;
			params.num_results = board.num_results;
			params.page = board.page;
			
			sendCommand(command_name, params);
		}
		
		
		// MEDALS (Achievements) \\
		
		private static function populateMedals(medal_list:Array):void
		{
			if (_medals === null) {
				_medals = new Array();
				for(var i:uint=0; i<medal_list.length; i++) {
					var m:Object = medal_list[i];
					_medals.push(
						Medal.createFromObject(m)
					);
				}
			}
		}
		
		private static function populateSaveGroups(saveGroupList:Array):void
		{
			_saveGroups = [];
			for (var i:uint = 0; i < saveGroupList.length; i++)
			{
				var saveGroup:SaveGroup = SaveGroup.createFromObject(saveGroupList[i]);
				_saveGroups.push(saveGroup);
			}
		}
		
		private static function populateScoreBoards(scoreBoards:Array):void
		{
			_scoreboards = [];
			for (var i:uint=0; i<scoreBoards.length; i++) {
				_scoreboards.push(new ScoreBoard(scoreBoards[i].id, scoreBoards[i].name));
			}
		}
		
		// defensive copy to prevent fucking our internal array
		public static function get medals():Array		{ return _medals ? _medals.concat() : []; }
		
		public static function getMedalById(medalId:uint):Medal
		{
			for each(var medal:Medal in _medals)
			{
				if (medal.id == medalId)
					return medal;
			}
			
			return null;
		}
		
		public static function getMedalByName(medalName:String):Medal
		{
			for each(var medal:Medal in _medals)
			{
				if (medal.name == medalName)
					return medal;
			}
			
			return null;
		}
		
		public static function unlockMedal(medal:Medal, get_score:Boolean = false):void
		{
			if (!medal)
			{
				sendError( { command_id:getCommandID('unlockMedal') }, new APIError("MISSING_PARAM", "missing required medal name") );
				return;
			}
			
			if (hasUserSession() || debugMode)
			{
				sendMessage("Attempting to unlock '" + medal.name + "'");
				if (medal.unlocked)
				{
					sendWarning("Medal '" + medal.name + "' is already unlocked!");
					return;
				}
				var params:Object = new Object();
				params.medal_id = medal.id;
				if(get_score)
					params.get_score = get_score;
				sendSecureCommand('unlockMedal', params);
			}
			else
			{
				sendMessage("Locally unlocking " + medal.name);
				
				if (medal.unlocked)
				{
					sendWarning("Medal '" + medal.name + "' is already unlocked!");
					return;
				}
				medal.unlocked = true;
				
				var medalsUnlocked:Object = loadLocal("medals_unlocked");
				
				if (!medalsUnlocked)
					medalsUnlocked = new Object();
				
				medalsUnlocked[medal.id.toString()] = true;
				
				saveLocal("medals_unlocked", medalsUnlocked);
				
				// fire the event listener immediately if unlocking locally
				callListener(APIEvent.MEDAL_UNLOCKED, true, medal);
			}
		}
		
		public static function unlockMedalById(medalId:uint, get_score:Boolean = false):void {			
			var medal:Medal = getMedalById(medalId);
			if (medal) {
				unlockMedal(medal, get_score);	
			}
		}
		
		public static function unlockMedalByName(medalName:String, get_score:Boolean = false):void {
			var medal:Medal = getMedalByName(medalName);
			if (medal) {
				unlockMedal(medal, get_score);	
			}
		}
		
		public static function loadMedals():void
		{
			if (_medals) {
				dispatchEvent( new APIEvent(APIEvent.MEDALS_LOADED, true, medals) );
				return;
			}
			
			var params:Object = new Object();
			if (hasUserSession()) {
				params.publisher_id = publisher_id;
				params.user_id = user_id;
			}
			sendCommand('getMedals',params);
		}
		
		// LOCAL SAVES \\
		public static function saveLocal(save_id:String, save_data:Object, size_allocation:uint = 0):void // size allocation?
		{
			try
			{
				var sharedObj:SharedObject;
				if (!sharedObjects[save_id]) {
					sharedObjects[save_id] = SharedObject.getLocal("ng_ap_secure_"+movie_id+"_"+save_id);
				}
				
				sharedObj = sharedObjects[save_id];
				
				sharedObj.data[save_id] = encodeData(save_data);
				sharedObj.flush();
			}
			catch (e:Error)
			{
				sendWarning("saveLocal ERROR: " +e);
			}
		}
		
		public static function loadLocal(save_id:String):*
		{
			try
			{
				var sharedObj:SharedObject;
				
				if (!sharedObjects[save_id]) {
					sharedObjects[save_id] = SharedObject.getLocal("ng_ap_secure_"+movie_id+"_"+save_id);
				}
				sharedObj = sharedObjects[save_id];
				
				if (sharedObj && sharedObj.data && sharedObj.data[save_id]) {
					return decodeData(sharedObj.data[save_id]);
				} else {
					return null;
				}
			}
			catch (e:Error)
			{			
				sendWarning("loadLocal ERROR: " +e);
				return null;
			}
		}
		
		public static function encodeData(data:Object):String
		{
			return compressHex(RC4.encrypt(JSON.encode(data), encryption_key));
		}
		
		public static function decodeData(base:String):*
		{
			
			return JSON.decode(RC4.decrypt(uncompressHex(base), encryption_key));
		}
		
		private static function compressHex(hex_value:String):String
		{
			// our data will ultimately be converted by reading 6-character chunks of hex code and compressing it to 4-char baseN code
			// Because it's unlikely that we'll have an even 6 characters at the end of this code, we need to take a not of what's 
			// really going to be left over.
			var offset:uint = hex_value.length % 6;
			
			// now we can read through our hex string and convert each 6-char chunk to a 4-char baseN format
			var basen_value:String = "";
			for(var i:uint=0; i<hex_value.length; i+=6) {
				basen_value += compressor.encode( uint("0x" + hex_value.substr(i, 6)), 4);
			}
			
			// and now we stick our compressed data to our offset so PHP has all the info it needs
			return offset.toString() + basen_value;
		}
		
		private static function uncompressHex(base_value:String):String
		{
			var offset:uint = uint( base_value.charAt(0) );
			var hex_value:String = "";
			var hl:uint;
			
			for(var i:uint=1; i<base_value.length; i+=4) {
				var chunk:String = base_value.substr(i,4);
				var num:uint = uint( compressor.decode(chunk) );
				var hex:String = num.toString(16);
				
				if (i+4 < base_value.length) {
					hl = 6;
				} else {
					hl = offset;
				}
				while (hex.length < hl) {
					hex = "0"+hex;
				}
				hex_value += hex;
			}
			
			return hex_value;
		}
		
		// FILE SAVES \\
		
		public static function getSaveGroupById(groupId:uint):SaveGroup
		{
			if (!_saveGroups || _saveGroups.length < 1)
			{
				sendWarning("No save groups found");
				return null;
			}
			
			for (var i:uint = 0; i < _saveGroups.length; i++)
			{
				if (_saveGroups[i].id == groupId)
					return _saveGroups[i];
			}
			
			return null;
		}
		
		public static function getSaveGroupByName(groupName:String):SaveGroup
		{
			if (!_saveGroups || _saveGroups.length < 1)
			{
				sendWarning("No save groups found");
				return null;
			}
			
			for (var i:uint = 0; i < _saveGroups.length; i++)
			{
				if (_saveGroups[i].name == groupName)
					return _saveGroups[i];
			}
			
			return null;
		}
		
		public static function createSaveQuery(groupName:String):SaveGroupQuery
		{
			var group:SaveGroup = getSaveGroupByName(groupName);
			if (group)
				return group.createQuery();
			
			return null;
		}
		
		public static function executeSaveQuery(query:SaveGroupQuery):void
		{
			sendCommand(
				"lookupSaveFiles",
				{
					publisher_id:	publisher_id,
					group_id:		query.groupId,
					query:			JSON.encode(query.toObject())
				}, false, null, query
			);
			
			trace(JSON.encode(query.toObject()));
		}
		
		public static function checkFilePrivledges(file:SaveFile):void
		{
			sendCommand("checkFilePrivs", 
				{
					group:			file.groupId,
					filename:		file.name,
					user_id:		user_id ? user_id : 0,
					publisher_id:	publisher_id
				}
			);
		}
		
		public static function newSaveFile(groupName:String):SaveFile
		{
			var group:SaveGroup = getSaveGroupByName(groupName);
			if (group)
			{
				return new SaveFile(group);
			}
			else
			{
				sendError( { command_id:"newSaveFile" }, new APIError("INVALID_SAVE_GROUP", "'" + group + "' is not a valid save group."));
				return null;
			}
		}
		
		public static function saveFile(file:SaveFile, overwrite:Boolean = false):void
		{
			// TODO: should NewgroundsAPISaveFile be in charge of this?
			// params that will get encrypted
			var params:Object = file.toObject();
			params.user_name = user_name;
			
			params.overwrite = overwrite ? 1 : 0;
			
			//if (file.getDuplicateID()) { // TODO
				//params.save_id = file.getDuplicateID();
			//}
			
			/*
				Mike:
				The AS3 API can use the htmlform class to pass multipart form data. You can use that to pass
				the zlib compressed 'file' and png-encoded 'thumbnail' as file attachments rather than
				passing them as encoded strings the way the AS2 version does it.
				
				the gateway looks for $_POST['file'] and $_POST['thumbnail'] for AS2 encoded data
				and $_FILE['file'] and $_FILE['thumbnail'] for AS3 encoded data
			*/
			
			
			// encrypting large file and image data would probably crash flash, so we don't bother with that. If the rest of the 
			// packet passes validation, it's safe to assume this data isn't hacked or anything.
			var byteArray:ByteArray = new ByteArray(); // TODO: maybe move this stuff back into SaveFile
			if (file.contents is ByteArray)
			{
				byteArray.writeByte(0x00);
				byteArray.writeBytes(file.contents);
			}
			else
			{
				byteArray.writeByte(0x01);
				byteArray.writeObject(file.contents);
			}
			byteArray.compress();

			var files:Object = new Object();
			files.file = byteArray;
			
			if (file.thumbnail)
			{
				files.thumbnail = PNGEncoder.encode(file.thumbnail);
			}

			// This is the last step in the process and the command name is passed as 'saveFile' since it's the command that starts all of this stuff
			sendSecureCommand('saveFile', params, null, files, file);
		}
		
		public static function rateSaveFile(file:SaveFile, rating:SaveRating, vote:Number):void
		{
			sendSecureCommand(
				"rateSaveFile",
				{
					group:		file.groupId,
					save_id:	file.id,
					rating_id:	rating.id,
					vote:		vote,
					user_id:	user_id
				}, null, null, file
			);
		}
		
		/*public static function getFiles(folder:String, options:Object = null):void
		{
			var sortOptions:Object =
			{
				name:	1,
				date:	2,
				score:	3
			};
			
			var defaultOptions:Object =
			{
				user_only:			false,
				sort_on:			"date",
				page:				1,
				results_per_page:	20,
				sort_descending:	true
			};
			
			var error:NewgroundsAPIError;
			
			if (options.sort_descending && !sortOptions[options.sort_descending])
			{
				error = new NewgroundsAPIError("MISSING_PARAM", "'"+options.sort_descending+"' is not a valid sort_on value.  Valid values are: " + valid_keys.join(", "));
				sendError({command_id:getCommandID('getFiles')}, error);
				delete options.sort_descending;
			}
			
			if (!options) options = new Object();
			for (var key:String in options)
			{
				if (defaultOptions[key] == null)
				{
					error = new NewgroundsAPIError("MISSING_PARAM", "'"+i+"' is not a valid option.  Valid options are: " + valid_options.join(", "));
					sendError({command_id:getCommandID('getFiles')}, error);
				
					delete options[key];
				}
			}
				
			params = options;
			
			if (hasUserSession())
			{
				params.publisher_id = publisher_id;
				params.user_id = user_id;
			}
			
			params.folder = folder;
			
			sendCommand("getFiles", params);
		}*/
		
		//============================================ EVENT HANDLING =====================================\\
		
		// handle response packets from the API Gateway
		private static function doEvent(e:Object):void
		{
			var msg:String;
			var packet:Object;
			var user:String;
			
			switch (getCommandName(e.command_id)) {
				
				// the primary response is when you run connectMovie.
				// This response handles movie protection, version control AND flash ad permissions.
				case "connectMovie":
				
					timeoutTimer.stop();
					
					// handle base connection
					sendMessage("You have successfully connected to the Newgrounds API Gateway");
					sendMessage("Movie identified as \""+e.movie_name+"\"");
					callListener(APIEvent.MOVIE_CONNECTED, e.success, {movie_name:e.movie_name});
					
					// FLASH ADS \\
					
					var fake_ad:Boolean = false;
					
					// handle responses on movies that were not approved
					if (e.ad_status === -1) {
						msg = "This movie was not approved to run Flash Ads.";
						sendWarning(msg);
						sendWarning("visit "+AD_TERMS_URL+" to view our approval guidelines");
						if (!e.ad_url) {
							callListener(APIEvent.ADS_APPROVED, false, new APIError("FLASH_ADS_NOT_APPROVED",msg));
						} else {
							fake_ad = true;
						}
						
					// handle ads on movies still awaiting approval from NG
					} else if (e.ad_status === 0) {
						msg = "Flash Ads are currently awaiting approval.";
						sendNotice(msg);
						if (!e.ad_url) {
							callListener(APIEvent.ADS_APPROVED, false, new APIError("FLASH_ADS_NOT_APPROVED",msg));
						} else {
							fake_ad = true;
						}
					}
					
					// handle approved flash ads
					if (e.ad_url) {
						ad_url = unescape(e.ad_url);
						if (!fake_ad) {
							sendMessage("This movie has been approved to run Flash Ads!");
						}
						callListener(APIEvent.ADS_APPROVED, true);
						_adsApproved = true;
					} 
					
					// MOVIE PROTECTION \\
					
					if (e.deny_host) {
						msg = getHost()+" does not have permission to run this movie!";
						sendWarning(msg);
						sendWarning("	Update your API configuration to unblock "+getHost());
						callListener(APIEvent.HOST_BLOCKED, true, {movie_url:unescape(e.movie_url), redirect_url:getOfficialVersionURL()});
					}
					
					// VERSION CONTROL \\
					
					if (e.movie_version) {
						sendWarning("According to your API Configuration, this version is out of date.");
						if (version) {
							sendWarning("	The this movie is version "+version);
						}
						sendWarning("	The most current version is "+e.movie_version);
	
						callListener(APIEvent.NEW_VERSION_AVAILABLE, true, {movie_version:e.movie_version, movie_url:unescape(e.movie_url), redirect_url:getOfficialVersionURL()});
					}
					
					// PORTAL SUBMISSION DETECTION \\
					
					if (e.request_portal_url) {
						sendCommand('setPortalID', {portal_url:host}); // TODO: host could be wrong??
					}
					
					if (preload)
						sendCommand("preloadSettings", { publisher_id: publisher_id, user_id: user_id } );
				
					break;
				
				// CHECK FOR PRELOAD \\
				case "preloadSettings":
					if (e.medals)
					{
						populateMedals(e.medals);
						
						if (!hasUserSession() && !debugMode)
						{
							echo("Checking for SharedObject Medals...");
							
							var medalsUnlocked:* = loadLocal("medals_unlocked");
							if (medalsUnlocked)
							{
								for (var medalId:String in medalsUnlocked)
								{
									if (medalsUnlocked[medalId])
									{
										var medal:Medal = getMedalById(uint(medalId));
										echo("Now unlocking " + medal.name);
										medal.unlocked = true;
									}
								}
							}
						}
					}
					if (e.save_groups)
						populateSaveGroups(e.save_groups);
					
					if (e.save_file_path)
						_saveFilePath = e.save_file_path + "/";

					// scoreboards
					if (e.score_boards)
					{
						populateScoreBoards(e.score_boards);
					}
				
					callListener(APIEvent.METADATA_LOADED);
					// TODO: reportAssetLoaded ?
					break;
				// CUSTOM EVENTS \\
				
				case "logCustomEvent":
					if (e.success) {
						sendMessage("Event '"+e.event+"' was logged.");
					}
					callListener(APIEvent.EVENT_LOGGED, e.success, {event:e.event});
					break;
					
				// HIGH SCORES \\
				
				case "postScore":
										
					if (e.success) {
						user = "User";
						
						if (user_email) {
							user = user_email;
						} else if (user_name) {
							user = user_name;
						}
						
						sendMessage(user+" posted "+e.value+" to '"+e.score+"'");
						packet = {score:e.score, value:e.value, username:user};
					}
					
					callListener(APIEvent.SCORE_POSTED, e.success, packet);
					break;
					
				case "loadScores":
				
					packet = new Object();
					
					var board:ScoreBoard = getScoreBoardById(e.board);

					if (board)
					{
						board.setScores(e.scores, e.period, e.page, e.num_results);
					}
					
					callListener(APIEvent.SCORES_LOADED, e.success, board);
					break;
					
				case "unlockMedal":
									
					if (_medals) {
						medal = getMedalByName(e.medal_name);
						medal.unlocked = true;
					}
					//if (medal.unlocked) return;
										
					callListener(APIEvent.MEDAL_UNLOCKED, e.success, medal);
					break;
				
				case "getMedals":
					populateMedals(e.medals);
					callListener(APIEvent.MEDALS_LOADED, e.success, packet);
					
					break;
				
				// SAVE FILES \\
					
				case "lookupSaveFiles":
					var results:Array = [];
					for (var i:uint = 0; i < e.files.length; i++)
					{
						var fileData:Object = e.files[i];
						var file:SaveFile = new SaveFile(getSaveGroupById(e.group_id));
						file.name = fileData.filename;
						file.id = fileData.save_id;
						file.description = fileData.description;
						file.thumbnailUrl = fileData.thumb;
						file.fileUrl = _saveFilePath + fileData.file;

						if(fileData.keys && fileData.keys.length)
							for (var j:uint = 0; j < fileData.keys.length; j++)
							{
								file.setKey(fileData.keys[j].id, fileData.keys[j].value);
							}

						if(fileData.ratings && fileData.ratings.length)
							for (j = 0; j < fileData.ratings.length; j++)
								file.setRating(fileData.ratings[j].id, fileData.ratings[j].votes, fileData.ratings[j].score);

						// permissions
						results.push(file);
					}

					e.owner.dispatchEvent(new APIEvent(APIEvent.QUERY_COMPLETE, e.success, results));
					break;
				
				
				case "rateSaveFile":
					file = e.owner;
					if(e.success)
						file.setRating(e.rating_id, e.votes, e.score);
					file.dispatchEvent(new APIEvent(APIEvent.VOTE_COMPLETE, e.success, e));
					break;
					
				case "saveFile":					
					packet = {
						save_id:e.save_id,
						filename:e.filename,
						file_url:e.file_url,
						thumbnail:e.thumbnail,
						icon:e.icon
					};

					e.owner.dispatchEvent(new APIEvent(APIEvent.FILE_SAVED, e.success, packet));
					break;
				
				case "checkFilePrivs":
					// TODO: FilePrivledges object?
					packet = {
						filename:e.filename,
						folder:e.folder,
						can_read:e.can_read,
						can_write:e.can_write
					};
					 
					callListener(APIEvent.FILE_PRIVS_LOADED, e.success, packet);
					break;
			}
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:uint=0, useWeakReference:Boolean=false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function hasEventListener(type:String):Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		private static function dispatchEvent(event:Event):void
		{
			_eventDispatcher.dispatchEvent(event);
			echo("Fired Event: "+event.type);
		}
		
		// TODO: get rid of this and just go straight thorugh dispatchEvent?
		private static function callListener(type:String, success:Boolean=true, data:*=undefined):void
		{
			dispatchEvent(new APIEvent(type, success, data));
		}
		
		//===================================== Command Indexing =========================================\\
		
		private static function getCommandName(id:String):String
		{
			return(id);
		}
		
		private static function getCommandID(name:String):String
		{
			return(name);
		}
		
		//======================================= Time Aliases & Names ==================================\\
		
		public static var periods:Object = getPeriodAliases();
		
		private static var period_aliases:Object = {
			t:{name:"Today", alias:"TODAY"},
			p:{name:"Yesterday", alias:"YESTERDAY"},
			w:{name:"This Week", alias:"THIS_WEEK"},
			m:{name:"This Month", alias:"THIS_MONTH"},
			y:{name:"This Year", alias:"THIS_YEAR"},
			a:{name:"All-Time", alias:"ALL_TIME"}
		};
		
		private static function getPeriodAliases():Object
		{
			var aliases:Object = new Object();
			for(var i:String in period_aliases) {
				aliases[period_aliases[i].alias] = i;
			}
			return aliases;
		}
		
		public static function getPeriodName(p:String):String
		{
			for(var i:String in period_aliases) {
				if (i == p) {
					return period_aliases[i].name;
				}
			}
			
			return null;
		}
		
		public static function getPeriodAlias(p:String):String
		{
			for(var i:String in period_aliases) {
				if (i == p) {
					return period_aliases[i].alias;
				}
			}
			
			return null;
		}
		
		//====================================== Error Handling ==========================================\\
		
		// if the gateway responds with an error, this function dumps the error so the author can debug their work.
		private static function sendError(c:Object, e:APIError):void
		{
			trace("[NewgroundsAPI ERROR] :: "+getCommandName(c.command_id)+"() - "+e.name+":\n				"+e.message);
		}
		
		// if the gateway responds with an error, this function dumps the error so the author can debug their work.
		private static function sendWarning(m:String,c:String = null):void
		{
			if (c) {
				m += "\n[NewgroundsAPI WARNING] :: 	See "+COMMANDS_WIKI_URL+c.toLowerCase()+" for additional information.";
			}
			
			trace("[NewgroundsAPI WARNING] :: "+m);
		}
		
		// if the gateway responds with an error, this function dumps the error so the author can debug their work.
		private static function sendNotice(m:String,c:String = null):void
		{
			if (c) {
				m += "\n[NewgroundsAPI NOTICE] :: 	See "+COMMANDS_WIKI_URL+c.toLowerCase()+" for additional information.";
			}
			
			trace("[NewgroundsAPI NOTICE] :: "+m);
		}
		
		// if this class is used incorrectly, this function will inform the author.
		private static function fatalError(m:String,c:String):void
		{
			if (c) {
				m += "\n	See "+COMMANDS_WIKI_URL+c.toLowerCase()+" for additional information.";
			}
			// throw the error and kill further script execution
			
			throw new Error("***ERROR*** class=NewgroundsAPI\n\n"+m);
		}
		
		//============================================= Gateway Comminication ======================================================\\
		
		public static function sendSecureCommand(command:String, secure_params:Object, unsecure_params:Object=null, files:Object=null, owner:*=null):void
		{
			if (!debug && !hasUserSession() && !hasUserEmail()) {
				sendError({command_id:getCommandID(command)}, new APIError("IDENTIFICATION_REQUIRED", "You must be logged in or provide an e-mail address ( using NewgroundsAPI.setUserEmail(\"name@domain.com\"); ) to use "+command+"()."));
				return;
			}
			
			if (!command) {
				fatalError("Missing command", "sendSecureCommand");
			}
			if (!secure_params) {
				fatalError("Missing secure_params", "sendSecureCommand");
			}
			
			if (!unsecure_params) {
				unsecure_params = new Object();
			}
			
			// make a random seed for validating the encryption
			var seed:String = "";
			for (var i:uint = 0; i < 16; i++)
			{
				seed += compression_radix.charAt( Math.floor(Math.random()*compression_radix.length) );
			}
			
			// add required data to the secure params
			if (debug && !session_id) {
				secure_params.session_id = "";
			} else {
				secure_params.session_id = session_id;
			}
			secure_params.as_version = 3;
			secure_params.user_email = user_email;
			secure_params.publisher_id = publisher_id;
			secure_params.seed = seed;
			secure_params.command_id = getCommandID(command);
			
			// get the md5 value of our seed.  This is a hex format
			var hash:String = MD5.hash(seed);
			// encode and encrypt our secure params
			var rc4enc:String = RC4.encrypt(JSON.encode(secure_params), encryption_key);
			// Merge the resulting hex string with the md5 hash
			var hex_value:String = hash+rc4enc;
			
			// and now we stick our compressed data to our offset so PHP has all the info it needs
			unsecure_params.secure = compressHex(hex_value);
			
			// run the results as a standard command
			sendCommand('securePacket', unsecure_params, false, files, owner);
		}
		
		private static function onCommandComplete(e:Event):void
		{
			var loader:SmartURLLoader = SmartURLLoader(e.target);
			// when we get input, we can dump it for API developers to debug with
			echo("INPUT: \n" + loader.response + "\n");
						
			for (var i:uint = 0; i < _preloadAssets.length; i++) {
				if (_preloadAssets[i] == loader) {
					_preloadAssets.splice(i, 1);
					break;
				}
			}

			var response:Object;
			if (loader.response) {
				// decode the server response
				response = JSON.decode(loader.response);
			} else {
				response = {success:false};
			}
			
			// if the command was unsuccessful we'll pass the error to the author
			if (!response.success) {
				var error:APIError = new APIError(response.error_code, response.error_msg);
				sendError(response, error);		// TODO: this just send back null 90% of the time
				
			// if all is well, we'll let our event handling take over
			} else {
				response.owner = loader.owner;
				doEvent(response);
			}
		}
		
		private static function onCommandError(e:Event):void
		{
			var loader:SmartURLLoader = SmartURLLoader(e.target);
			for (var i:uint = 0; i < _preloadAssets.length; i++) {
				if (_preloadAssets[i] == loader) {
					_preloadAssets.splice(i, 1);
					break;
				}
			}
		}
		
		// This function passes commands to the API Gateway
		private static function sendCommand(command:String, params:Object, openBrowser:Boolean = false, files:Object = null, owner:* = null):void
		{			
			// make sure connectMovie has been called before any other calls can be sent to the gateway
			if (!connected && command != "connectMovie") {
				var msg:String = "NewgroundsAPI."+command+"() - NewgroundsAPI.connectMovie() must be called before this command can be called\n";
				fatalError(msg,'connectMovie');
			}
			
			var loader:SmartURLLoader = new SmartURLLoader();
			
			loader.addVariable("command_id", getCommandID(command));
			loader.addVariable("tracker_id", movie_id);
			if (debug) loader.addVariable("debug", 1);
			if (command == "connectMovie" && preload)
				loader.addVariable("preload", 1);
				
			if (params)
			{
				for (var key:String in params)
					loader.addVariable(key, params[key]);
			}
			
			// pass data for any files
			if (files)
			{
				for (var name:String in files)
				{
					loader.addFile(name, files[name], name);	// do we have to worry about filename or content-type?
				}
			}
			
			if(openBrowser)
				loader.method = URLRequestMethod.GET;
			else
				loader.method = URLRequestMethod.POST;
			
			// some commands are used to load web pages, so they are passed in a new browser window

			loader.preventCache = true;
			if (openBrowser)
			{
				loader.openBrowser = true;
				loader.method = URLRequestMethod.GET;	// TODO: is this required for navigateToURL?
			}
			else
			{
				loader.addEventListener(Event.COMPLETE, onCommandComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onCommandError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onCommandError);
				loader.method = URLRequestMethod.POST;
			}
			
			loader.owner = owner;
			
			loader.load(GATEWAY_URL);
			
			/*if (command == "connectMovie" && preload)
				reportNewAsset(loader);
			trace(urlRequest.data);*/
		}
		
		public static function isFlashVersion(major:uint, minor:uint = 0, buildNumber:uint = 0, internalBuildNumber:uint = 0):Boolean
		{
			var version:Array = Capabilities.version.split(" ")[1].split(",");
			var requiredVersion:Array = arguments;
			
			for (var i:uint = 0; i < requiredVersion.length; i++)
				version[i] = uint(version[i]);

			for (i = 0; i < requiredVersion.length; i++)
			{
				if (version[i] > requiredVersion[i])
					return true;
				if (version[i] < requiredVersion[i])
					return false;	
			}
			
			return true;
		}
		
		//===================================== Flash Ad Generation ===================================\\
		public static function createAd():AdDisplay
		{
			sendMessage("You may see a security sandbox violation. This is normal!");
			return new AdDisplay(ad_url);
		}
		
		
		public static function sendMessage(m:String, r:Boolean = false):void
		{
			var msg:String = "[NewgroundsAPI] :: "+m;
			trace(msg);
		}
		
		// this function passes information for API Developers if do_echo is true
		private static function echo(m:String):void
		{
			if (do_echo) {
				trace(m);
			}
		}

	}
}