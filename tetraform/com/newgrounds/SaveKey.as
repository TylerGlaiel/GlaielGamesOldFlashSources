package com.newgrounds 
{
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SaveKey 
	{
		private var _id:uint;
		private var _name:String;
		private var _type:uint;
		
		public static const TYPE_FLOAT:uint			= 1;
		public static const TYPE_INTEGER:uint		= 2;
		public static const TYPE_STRING:uint		= 3;
		public static const TYPE_BOOLEAN:uint		= 4;
		
		public function SaveKey(id:uint, name:String, type:uint) 
		{
			_id = id;
			_name = name;
			_type = type;
		}
		
		public function get id():uint		{ return _id; }
		public function get name():String	{ return _name; }
		public function get type():uint		{ return _type; }
		
		public function isValueValid(value:*):Boolean
		{
			if (_type == TYPE_INTEGER)
			{
				return (value is int) || (value is uint);
			}
			if (_type == TYPE_FLOAT)
			{
				return (value is int) || (value is uint) || (value is Number);
			}
			if (_type == TYPE_STRING)
			{
				return value is String;
			}
			if (_type == TYPE_BOOLEAN)
			{
				return (value is Boolean) || (value === 0) || (value === 1) || (value == "");
			}
			
			return false;
		}
		
		public function toString():String	{ return _name; }
	}
	
}