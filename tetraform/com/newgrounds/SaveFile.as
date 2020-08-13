package com.newgrounds 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SaveFile extends EventDispatcher
	{
		private var _filename:String;
		private var _id:uint;
		private var _description:String;
		private var _contents:*;
		private var _group:SaveGroup;
		private var _keys:Dictionary;
		private var _ratings:Dictionary;
		private var _fileUrl:String;
		private var _thumbnail:BitmapData;
		private var _thumbnailUrl:String;
		
		private var _status:uint;
		
		public function SaveFile(group:SaveGroup) 
		{
			_keys = new Dictionary();
			_ratings = new Dictionary();
			_group = group;
			_description = "";
		}
		
		public function get name():String				{ return _filename; }
		public function set name(s:String):void			{ _filename = s; }
		public function get id():uint					{ return _id; }
		public function set id(i:uint):void				{ _id = i; }
		public function get description():String		{ return _description; }
		public function set description(s:String):void	{ _description = s; }
		public function get contents():*				{ return _contents; }
		public function set contents(o:*):void			{ _contents = o; }
		public function get thumbnailUrl():String		{ return _thumbnailUrl; }
		public function set thumbnailUrl(s:String):void	{ _thumbnailUrl = s; }
		public function get fileUrl():String			{ return _fileUrl; }
		public function set fileUrl(s:String):void		{ _fileUrl = s; }
		public function get thumbnail():BitmapData		{ return _thumbnail; }
		
		public function get groupId():uint				{ return _group.id; }
		public function get groupName():String			{ return _group.name; }
		public function get groupType():uint			{ return _group.type; }
		
		public function get shared():Boolean			{ return true; }	// TODO

		public function setKey(key:*, value:*):void
		{
			var k:SaveKey;
			if (k is String)
				k = _group.getKeyByName(key);
			else 
				k = _group.getKeyById(key);

			/// TODO: error check
			if (k)
			{
			//	if(k.isValueValid(value))
					_keys[k] = {id: k.id, val:value};
			}
		}
		
		public function getKey(key:*):*
		{
			var k:SaveKey;
			if (k is String)
				k = _group.getKeyByName(key);
			else 
				k = _group.getKeyById(key);
				
			if(k)
				return _keys[k];
			
			return null;
		}
		
		public function setRating(rating:*, votes:Number, score:Number):void
		{
			var r:SaveRating;
			if (rating is String)
				r = _group.getRatingByName(rating);
			else 
				r = _group.getRatingById(rating);
			
			/// TODO: error check
			if (r)
			{
				_ratings[r] = {
					id:r.id,
					name:r.name,
					votes:votes,
					score:score
				};
			}
		}
		
		public function getRating(rating:*):Object
		{
			var r:SaveRating;
			if (rating is String)
				r = _group.getRatingByName(rating);
			else 
				r = _group.getRatingById(rating);
				
			if(r)
				return _ratings[r];

			return null;
		}
		
		public function sendRating(rating:String, vote:Number):void
		{
			var ratingObject:SaveRating = _group.getRatingByName(rating);
			
			if (!ratingObject)
			{
				trace("[NewgroundsAPISaveFile] " + rating + " is not a recognized save file");
				return;
			}
			
			if (vote < ratingObject.minValue || vote > ratingObject.maxValue)
			{
				trace("[NewgroundsAPISaveFile] Vote must be between " + ratingObject.minValue + " and " + ratingObject.maxValue);
				return;
			}
			
			ratingObject.voted = true;
			
			NewgroundsAPI.rateSaveFile(this, ratingObject, vote);
		}
		
		override public function toString():String
		{
			var str:String = "Save File " + _filename + "   ID: " + _id + "\n  " + _description + "\n";
			for each(var key:Object in _keys)
				str += "  " + _group.getKeyById(key.id).name + ": " + key.val + "\n";
			for each(var rating:Object in _ratings)
				str += "  " + _group.getRatingById(rating.id).name + "\n    Score: " + rating.score + " Votes: " + rating.votes + "\n";
			return str;
		}
		
		public function toObject():Object
		{
			var obj:Object = {
					group:			groupId,
					filename:		name,
					description:	description,
					shared:			true
			};
			
			obj.keys = [];
			for each(var key:Object in _keys)
			{
				obj.push( { id:key.id, value:key.val } );
			}
			
			return obj;
		}
		
		public function save():void
		{
			NewgroundsAPI.saveFile(this);
		}
		
		public function loadContents():void
		{
			if (_fileUrl)
			{
				var loader:SmartURLLoader = new SmartURLLoader();
				loader.responseFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, onContentsLoaded);
				loader.load(_fileUrl);
			}
		}
		
		private function onContentsLoaded(e:Event):void
		{
			var byteArray:ByteArray = e.target.response;
			byteArray.uncompress();
			var tag:uint = byteArray.readUnsignedByte();
			if (tag == 0x00)
			{
				_contents = new ByteArray();
				_contents.writeBytes(byteArray, 1);
			}
			else
			{
				_contents = byteArray.readObject();
			}

			dispatchEvent(new APIEvent(APIEvent.FILE_LOADED, true, contents));
		}
		
	}
	
}