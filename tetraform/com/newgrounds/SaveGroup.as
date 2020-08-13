package com.newgrounds 
{
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SaveGroup 
	{		
		public static const TYPE_SYSTEM:uint		= 0;
		public static const TYPE_PRIVATE:uint		= 1;
		public static const TYPE_PUBLIC:uint		= 2;
		public static const TYPE_MODERATED:uint		= 3;
				
		private var _name:String;
		private var _id:uint;
		private var _type:uint;
		
		private var _keys:Array;
		private var _ratings:Array;
		private var _files:Array;
		
		public function SaveGroup(groupId:uint, groupName:String, groupType:uint) 
		{
			_name = groupName;
			_id = groupId;
			_type = groupType;
			
			_ratings = [];
			_keys = [];
			_files = [];
		}
		
		public static function createFromObject(groupData:Object):SaveGroup
		{
			var saveGroup:SaveGroup = new SaveGroup(groupData.group_id, groupData.group_name, groupData.group_type);
			
			for (var i:uint = 0; i < groupData.keys.length; i++)
			{
				var keyData:Object = groupData.keys[i];
				saveGroup.addKey( new SaveKey(keyData.id, keyData.name, keyData.type) );
			}
			
			for (i = 0; i < groupData.ratings.length; i++)
			{
				var ratingData:Object = groupData.ratings[i];
				saveGroup.addRating( new SaveRating(ratingData.id, ratingData.name, ratingData.float, ratingData.min, ratingData.max) );
			}
			
			return saveGroup;
		}
		
		public function get name():String		{ return _name; }
		public function get id():uint			{ return _id; }
		public function get type():uint			{ return _type; }
		public function get keys():Array		{ return _keys.concat(); }
		public function get ratings():Array		{ return _ratings.concat(); }
		
		public function addRating(rating:SaveRating):void
		{
			_ratings.push(rating);
		}
		
		public function getRatingById(ratingId:uint):SaveRating
		{
			for (var i:uint = 0; i < _ratings.length; i++)
				if (_ratings[i].id == ratingId)
					return _ratings[i];
			return null;
		}
		
		public function getRatingByName(ratingName:String):SaveRating
		{
			for (var i:uint = 0; i < _ratings.length; i++)
				if (_ratings[i].name == ratingName)
					return _ratings[i];
			return null;
		}
		
		public function addKey(key:SaveKey):void
		{
			// TODO: check for duplicates
			_keys.push(key);
		}
		
		public function getKeyById(keyId:uint):SaveKey
		{
			for (var i:uint = 0; i < _keys.length; i++)
				if (_keys[i].id == keyId)
					return _keys[i];
			return null;
		}
		
		public function getKeyByName(keyName:String):SaveKey
		{
			for (var i:uint = 0; i < _keys.length; i++)
				if (_keys[i].name == keyName)
					return _keys[i];
			return null;
		}
		
		public function createQuery():SaveGroupQuery
		{
			return new SaveGroupQuery(this);
		}
		
		public function toString():String
		{
			return "SaveGroup { name: " + _name + ", id: " + _id + ", keys: " + _keys + "}";
		}
		
	}
	
}