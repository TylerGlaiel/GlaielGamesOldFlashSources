package {
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.MovieClip	
    import flash.display.Sprite;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.net.URLLoader;
	import flash.events.Event;

	public class NewgroundsAPI {
		
		public static const DENY_HOST:Number = 1;
		public static const NEW_VERSION:Number = 2;
		public static const ADS_APPROVED:Number = 3;

		private static const STAT_MOVIE_VIEWS:Number = 1;
		private static const STAT_AUTHOR_SITE:Number = 2;
		private static const STAT_NEWGROUNDS:Number = 3;
		private static const STAT_NEW_VERSION:Number = 4;
		private static const STAT_CUSTOM_STATS:Number = 50;
		private static const GATEWAY_URL:String = "http://www.ngads.com/gateway.php";
		private static const NEWGROUNDS_URL:String = "http://www.newgrounds.com";

		public static const bridge:Sprite = new Sprite();
		
		private static var tracker_id:Number;
		private static var connected:Boolean;
		private static var host:String;
		private static var debug:Boolean;
		private static var movie_options:Object = new Object();
		private static var custom_events:Object = new Object();
		private static var events:Object = new Object();
		private static var custom_links:Object = new Object();
		private static var version:String;
		private static var linked:Boolean;
		
		public static function linkAPI(movie) {
			movie.addChild(bridge);
			linked = true;
		}

		public static function connectMovie(id:Number) {
			if (!id) {
				SendError("Missing required 'id' parameter in NewgroundsAPI.connectMovie(id:Number)");
			} else if (!linked) {
				SendError("Attempted to call MewgroundsAPI.connectMovie() without first calling NewgroundsAPI.linkAPI(this)");
			} else if (!tracker_id) {
				SendMessage("Connecting to API gateway...");
				tracker_id = id;
				
				var _url:String = bridge.root.loaderInfo.url;
	
				host = _url.split("/")[2].toLowerCase();
				if (host.length < 1) {
					host = 'localhost';
				}
				
				var params = new Object();
				SendEvent(STAT_MOVIE_VIEWS);
			}
		}
		
		public static function setMovieVersion(movie_version) {
			if (!movie_version) {
				SendError("Missing required 'version' in NewgroundsAPI.setMovieVersion(version:String)");
			} else {
				version = String(movie_version);
			}
		}
		
		public static function debugMode() {
			debug = true;
		}
		
		public static function addEventListener(event:Number, callback:Function) {
			events[event] = callback;
		}
		
		public static function addCustomEvent(stat_id:Number, stat_name:String) {
			if (!stat_id) {
				SendError("Missing required 'id' parameter in NewgroundsAPI.AddCustomEvent(id:Number, event_name:String)");
			} else if (!stat_name) {
				SendError("Missing required 'event_name' parameter in NewgroundsAPI.AddCustomEvent(id:Number, event_name:String)");
			} else {
				custom_events[stat_name] = STAT_CUSTOM_STATS + stat_id;
				SendMessage("Created custom event: "+stat_name);
			}
		}
		
		public static function addCustomLink(stat_id:Number, stat_name:String) {
			if (!stat_id) {
				SendError("Missing required 'id' parameter in NewgroundsAPI.AddCustomLink(id:Number, link_name:String)");
			} else if (!stat_name) {
				SendError("Missing required 'link_name' parameter in NewgroundsAPI.AddCustomLink(id:Number, link_name:String)");
			} else {
				custom_links[stat_name] = STAT_CUSTOM_STATS + stat_id;
				SendMessage("Created custom link "+stat_id+": "+stat_name);
			}
		}
		
		public static function loadMySite(event:Event=null) {
			SendLink(STAT_AUTHOR_SITE);
		}
		
		public static function loadNewgrounds(event:Event=null,page:String=null) {
			
			
			
			if (!tracker_id) {
				var request:URLRequest = new URLRequest(NEWGROUNDS_URL+"/"+page);
				navigateToURL(request, '_blank');
			} else {
				var extra=null;
				if (page) {
					extra = new Object();
					extra.page = page;
				}
				SendLink(STAT_NEWGROUNDS,extra);
			}
		}
		
		public static function logCustomEvent(event_name:String) {
			if (!event_name) {
				SendError("Missing required 'event_name' parameter in NewgroundsAPI.logCustomEvent(event_name:String)");
			} else if (!custom_events[event_name]) {
				SendError("Attempted to log undefined custom event: "+event_name);
			} else {
				SendEvent(custom_events[event_name]);
			}
		}
		
		public static function loadCustomLink(link_name:String) {
			if (!link_name) {
				SendError("Missing required 'link_name' parameter in NewgroundsAPI.loadCustomLink(link_name:String)");
			} else if (!custom_links[link_name]) {
				SendError("Attempted to open undefined custom link: "+link_name);
			} else {
				SendLink(custom_links[link_name]);
			}
		}
		
		public static function getAdURL() {
			return(movie_options['ad_url']);
		}
		
		public static function getMovieURL() {
			if (movie_options['movie_url']) {
				return(movie_options['movie_url']);
			} else {
				return("Newgrounds.com");
			}
		}
		
		public static function getNewVersionURL() {
			return(GATEWAY_URL+"?&id="+tracker_id+"&host="+escape(host)+"&stat="+STAT_NEW_VERSION);
		}
		
		private static function SendEvent(id) {
			SendStat(id,false);
		}
		
		private static function SendLink(id,extra=null) {
			SendStat(id,true,extra);
		}
		
		private static function ReadGatewayData(params:Object) {
			
			for(var i in params)
			{
				params[i] = unescape(params[i]);
				movie_options[i] = params[i];
			}
			
			if (params['settings_loaded']) {
				SendMessage("You have successfully connected to the Newgrounds API gateway!");
				SendMessage("Movie Identified as '"+movie_options['movie_name']+"'");
				
				if (movie_options['message']) {
					SendMessage(movie_options['message']);
				}
				
				if (movie_options['ad_url']) {
					SendMessage("Your movie has been approved to run Flash Ads");
					if (events[ADS_APPROVED]) {
						events[ADS_APPROVED](movie_options['ad_url']);
					} else {
						onAdsApproved(movie_options['ad_url']);
					}
				}
				
				if (movie_options['movie_version'] && String(movie_options['movie_version']) != String(version)) {
					SendMessage("WARNING: The movie version configured in your API settings does not match this movie's version!");
					
					if (events[NEW_VERSION]) {
						events[NEW_VERSION]({version:movie_options['movie_version'], real_url:getMovieURL(), redirect_url:getNewVersionURL()});
					} else {
						onNewVersionAvailable(movie_options['movie_version'], getMovieURL(), getNewVersionURL());
					}
				}
				
				if (movie_options['deny_host']) {
					SendMessage("You have blocked 'localHost' in your API settings.");
					SendMessage("If you wish to test your movie you will need to remove this block.");
					
					if (events[DENY_HOST]) {
						events[DENY_HOST]({host:host, real_url:getMovieURL(), redirect_url:getNewVersionURL()});
					} else {
						onDenyHost(host,getMovieURL(),getNewVersionURL());
					}
				}
				
				if (movie_options['request_portal_url']) {
					var _url:String = bridge.root.loaderInfo.url;
					
					var target_url = GATEWAY_URL+"?&id="+tracker_id+"&portal_url="+escape(_url);
					
					var gateway_loader:URLLoader = new URLLoader(new URLRequest(target_url));
				}
				
				if (events[69]) {
					events[69]();
				}

			} else if (!movie_options['settings_loaded']) {
				SendError("Could not establish connection to the API gateway.");
			}
		}
		
		private static function SendStat(stat_id:Number, open_in_browser:Boolean, extra=null) {
			if (!tracker_id) {
				SendError('You must call NewgroundsAPI.connectMovie() with a valid movie id before using API features!');
			} else {
				var target_url = GATEWAY_URL+"?&id="+tracker_id+"&host="+escape(host)+"&stat="+stat_id+addSeed();

				if (extra) {
					for(var x in extra) {
						target_url += "&"+escape(x)+"="+escape(extra[x]);
					}
				}
				
				if (debug) {
					target_url += "&debug=1";
				}
				
				function XML_Loaded(event:Event) {
										
					XML.ignoreWhitespace = true;
					var XML_in:XML = XML(event.target.data);
										
					var ngparams:Object = new Object();
					
					var XML_children:XMLList = XML_in.children();
					for each (var XML_child:XML in XML_children) {
						
						var param_name = XML_child.localName();
						var param_value = XML_child.attribute('value');
						
						if (param_value == Number(param_value))
						{
							param_value = Number(param_value);
						}
						
						ngparams[param_name] = param_value;
					}

					
					ReadGatewayData(ngparams);
				}

				if (open_in_browser) {
					var request:URLRequest = new URLRequest(target_url+addSeed());
					navigateToURL(request, '_blank');
				} else {
					var gateway_loader:URLLoader = new URLLoader(new URLRequest(target_url+addSeed()));
					gateway_loader.addEventListener(Event.COMPLETE,XML_Loaded);
				}
				
			}
		}
		
		private static function addSeed() {
			return ("&seed="+Math.random());
		}
		
		private static function SendError(msg:String) {
			trace("[NEWGROUNDS API ERROR] :: "+msg);
		}
		
		private static function SendMessage(msg:String) {
			trace("[NEWGROUNDS API] :: "+msg);
		}
		
		public static function onNewVersionAvailable(version:String, movie_url:String, redirect_url:String) {
			var sw = bridge.stage.stageWidth;
			var sh = bridge.stage.stageHeight;
			var tw = 350;
			var th = 160;
			var mg = 20;
			
			var _root = bridge.root;
			var overlay:MovieClip = new MovieClip();
			overlay.graphics.beginFill(0x000000, 0.6);
			overlay.graphics.lineStyle(0,0x000000);
			overlay.graphics.drawRect(0,0,sw,sh);
			overlay.graphics.endFill();
			
			var overlay_x = Math.round((sw-tw)/2);
			var overlay_y = Math.round((sh-th)/2);

			overlay.graphics.beginFill(0x000066);
			overlay.graphics.lineStyle(10,0x000000);
			overlay.graphics.drawRect(overlay_x-mg,overlay_y-mg,tw+mg,th+mg);
			overlay.graphics.endFill();
			
			overlay.close = function(event:Event) {
				_root.removeChild(overlay);
			}
			
			var close_x = new MovieClip();
			close_x.graphics.beginFill(0x000000,0.1);
			close_x.graphics.lineStyle(3,0x0055FF);
			close_x.graphics.drawRect(0,0,16,16);
			close_x.graphics.endFill();
			close_x.graphics.moveTo(4,4);
			close_x.graphics.lineTo(13,13);			
			close_x.graphics.moveTo(13,4);
			close_x.graphics.lineTo(4,13);
			
			close_x.x = overlay_x+tw - 26;
			close_x.y = overlay_y-10;
			
			close_x.addEventListener(MouseEvent.CLICK, overlay.close);
			
			var blankarea:TextField = new TextField();
			blankarea.x = overlay_x-mg;
			blankarea.y = overlay_y-mg;
			blankarea.width = tw+mg;
			blankarea.height = th+mg;
			blankarea.selectable = false;
			
			var header:TextField = new TextField();
			header.width = tw;
			header.x = overlay_x;
			header.y = overlay_y;
			header.height = 100;
			header.selectable = false;
			
			var header_format:TextFormat = new TextFormat();
			header_format.font = "Arial Black"
			header_format.color = 0xFFFFFF;
			header_format.size = 20;
			
			header.defaultTextFormat = header_format;
			header.text = "New Version Available!";
			
			var msgtext:TextField = new TextField();
			msgtext.x = overlay_x;
			msgtext.y = overlay_y+70;
			msgtext.width = tw;
			msgtext.height = 60;
			msgtext.selectable = false;
			
			var msgtext_format:TextFormat = new TextFormat();
			msgtext_format.font = "Arial"
			msgtext_format.color = 0xFFFFFF;
			msgtext_format.size = 12;
			msgtext_format.bold = true;
			
			var msgtext_link:TextFormat = new TextFormat();
			msgtext_link.font = "Arial"
			msgtext_link.color = 0xFFFF00;
			msgtext_link.size = 12;
			msgtext_link.bold = true;
			msgtext_link.url = redirect_url;
			msgtext_link.target = "_blank";
			
			if (version) {
				version = "Version "+version;
			} else {
				version = "A new version";
			}
			
			msgtext.defaultTextFormat = msgtext_format;
			msgtext.appendText(version+" is now available");
			
			if (movie_url) {
				msgtext.appendText(" at:\n");
				msgtext.defaultTextFormat = msgtext_link;
				msgtext.appendText(movie_url);
			} else {
				msgtext.appendText("!");
			}
			
			_root.addChild(overlay);
			overlay.addChild(blankarea);
			overlay.addChild(header);
			overlay.addChild(msgtext);
			overlay.addChild(close_x);
		}
		
		public static function onDenyHost(hostname:String, movie_url:String, redirect_url:String) {
			var sw = bridge.stage.stageWidth;
			var sh = bridge.stage.stageHeight;
			var tw = 350;
			var th = 160;
			
			var _root = bridge.root;
			var overlay:MovieClip = new MovieClip();
			overlay.graphics.beginFill(0x660000);
			overlay.graphics.lineStyle(20,0x000000);
			overlay.graphics.drawRect(0,0,sw,sh);
			overlay.graphics.endFill();
			
			var blankarea:TextField = new TextField();
			blankarea.x = 0;
			blankarea.y = 0;
			blankarea.width = sw;
			blankarea.height = sh;
			blankarea.selectable = false;
			
			var header:TextField = new TextField();
			header.x = Math.round((sw-tw)/2);
			header.y = Math.round((sh-th)/2.5);
			header.width = tw;
			header.height = 100;
			header.selectable = false;
			
			var header_format:TextFormat = new TextFormat();
			header_format.font = "Arial Black"
			header_format.color = 0xFF0000;
			header_format.size = 38;
			
			header.defaultTextFormat = header_format;
			header.text = "ERROR!";
			
			var msgtext:TextField = new TextField();
			msgtext.x = Math.round((sw-tw)/2);
			msgtext.y = Math.round((sh-th)/2.5)+80;
			msgtext.width = tw;
			msgtext.height = 80;
			msgtext.selectable = false;
			
			var msgtext_format:TextFormat = new TextFormat();
			msgtext_format.font = "Arial"
			msgtext_format.color = 0xFFFFFF;
			msgtext_format.size = 12;
			msgtext_format.bold = true;
			
			var msgtext_link:TextFormat = new TextFormat();
			msgtext_link.font = "Arial"
			msgtext_link.color = 0xFFFF00;
			msgtext_link.size = 12;
			msgtext_link.bold = true;
			msgtext_link.url = redirect_url;
			msgtext_link.target = "_blank";
			
			msgtext.defaultTextFormat = msgtext_format;
			msgtext.appendText("This movie has not been approved for use on "+hostname+"\n");
			msgtext.appendText("For an approved copy, please visit:\n");
			msgtext.defaultTextFormat = msgtext_link;
			msgtext.appendText(movie_url);

			
			_root.addChild(overlay);
			overlay.addChild(blankarea);
			overlay.addChild(header);
			overlay.addChild(msgtext);
		}
		
		public static function isInstalled() {
			return true;
		}
		
		public static function onAdsApproved(ad_url:String) { }

	}
}