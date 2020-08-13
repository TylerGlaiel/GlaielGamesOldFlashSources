package com.newgrounds 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class APIEvent extends Event
	{
		// Event types
		public static const MOVIE_CONNECTED:String			= "movieConnected";
		public static const ADS_APPROVED:String				= "adsApproved";
		public static const AD_ATTACHED:String				= "adAttached";
		public static const HOST_BLOCKED:String				= "hostBlocked";
		public static const NEW_VERSION_AVAILABLE:String	= "newVersionAvailable";
		public static const EVENT_LOGGED:String				= "eventLogged";
		public static const SCORE_POSTED:String				= "scorePosted";
		public static const SCORES_LOADED:String			= "scoresLoaded";
		public static const MEDAL_UNLOCKED:String			= "medalUnlocked";
		public static const MEDALS_LOADED:String			= "medalsLoaded";
		public static const METADATA_LOADED:String			= "metadataLoaded";
		public static const FILE_PRIVS_LOADED:String		= "filePrivsLoaded";
		public static const FILE_SAVED:String				= "fileSaved";
		public static const FILE_LOADED:String				= "fileLoaded";
		public static const QUERY_COMPLETE:String			= "queryComplete";
		public static const VOTE_COMPLETE:String			= "voteComplete";
		
		// Members
		private var _data:*;
		private var _success:Boolean;
		private var _target:*;
		
		// Constructors
		public function APIEvent(type:String, success:Boolean = true, data:* = undefined)
		{
			super(type);
			
			_data = data;
			_success = success;
		}
		
		// Accessors
		public function get success():Boolean	{ return _success; }
		public function get data():*			{ return _data; }
		
	}
	
}