package com.newgrounds 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Medal 
	{
		private static const DEFAULT_ICON:BitmapData = new BitmapData(50, 50, false, 0);// = new NewgroundsAPIDefaultMedalIcon(0, 0); TODO
		
		private var _id:uint;
		private var _name:String;
		private var _value:uint;
		private var _difficultyId:uint;
		private var _unlocked:Boolean = false;
	
		private var _iconUrl:URLRequest;
		private var _iconLoader:Loader;
		private var _icon:BitmapData = DEFAULT_ICON;
		
		private static const DIFFICULT_NAMES:Array =
			[
				null,
				"Easy",
				"Moderate",
				"Challenging",
				"Difficult",
				"Brutal"
			];
	
		// CONSTRUCTORS
		
		public function Medal(id:uint, name:String, value:uint, difficulty:uint, unlocked:Boolean, iconUrl:String) {
			_id = id;
			_name = name;
			_value = value;
			_difficultyId = difficulty;
			_unlocked = unlocked;

			if (iconUrl)
			{
				_iconUrl = new URLRequest(iconUrl);
						
				_iconLoader = new Loader();
				_iconLoader.contentLoaderInfo.addEventListener(Event.INIT, onIconLoaderInit);
				_iconLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIconLoaderError);
				_iconLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIconLoaderError);
				_iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconLoaderComplete);
				try
				{
					_iconLoader.load(_iconUrl, new LoaderContext(true));
				}
				catch(e:Error)
				{
					onIconLoaderError(null);
				}
			}
		}
		
		public static function createFromObject(medalData:Object):Medal
		{
			return new Medal(medalData.medal_id, medalData.medal_name, medalData.medal_value, medalData.medal_difficulty, medalData.medal_unlocked, medalData.medal_icon);
		}
		
		// GETTERS/SETTERS
		public function get difficulty():String			{ return DIFFICULT_NAMES[_difficultyId]; }
		public function get difficultyId():uint			{ return _difficultyId; }
		public function get icon():BitmapData			{ return _icon; }
		public function get id():uint					{ return _id; }
		public function get name():String				{ return _name; }
		public function get unlocked():Boolean			{ return _unlocked; }
		public function set unlocked(b:Boolean):void	{ _unlocked = b; }
		public function get value():uint				{ return _value; }
		
		public function get bytesLoaded():uint			{ return _iconLoader ? _iconLoader.contentLoaderInfo.bytesLoaded : 0; }
		public function get bytesTotal():uint			{ return _iconLoader ? _iconLoader.contentLoaderInfo.bytesTotal : 0; }
		
		
		// EVENT HANDLERS
		
		
		private function onIconLoaderInit(e:Event):void {
			trace("[NewgroundsAPI] :: Loading medal icon for "+name+" ("+_iconUrl.url.split("/").pop()+")");
		}
		
		private function onIconLoaderError(e:IOErrorEvent):void {
			trace("[NewgroundsAPI WARNING] :: Failed to load medal icon for "+name+" ("+_iconUrl.url.split("/").pop()+")");
			_iconLoader.unload();
			_iconLoader = null;
		}
		
		private function onIconLoaderComplete(e:Event):void {
			trace("[NewgroundsAPI] :: Successfully loaded medal icon for "+name+" ("+_iconUrl.url.split("/").pop()+")");
			var bitmap:Bitmap = _iconLoader.content as Bitmap;
			_icon = bitmap.bitmapData;
			_iconLoader.unload();
			_iconLoader = null;
		}
		
		// MISC
		
		public function unlock():void {
			if (!_unlocked)
				NewgroundsAPI.unlockMedal(this);
		}
		
		public function createIconBitmap():Bitmap {
			return new Bitmap(icon);
		}
		
		public function toString():String
		{
			return _name;
		}
	}
	
}