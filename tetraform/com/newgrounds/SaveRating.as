package com.newgrounds 
{
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SaveRating 
	{
		private var _id:uint;
		private var _name:String;
		private var _minValue:Number;
		private var _maxValue:Number;
		private var _isFloat:Boolean;
		private var _voted:Boolean;
		
		public function SaveRating(id:uint, name:String, isFloat:Boolean, minValue:Number = Number.NEGATIVE_INFINITY, maxValue:Number = Number.POSITIVE_INFINITY)
		{
			_id = id;
			_name = name;
			_isFloat = isFloat;
			_minValue = minValue;
			_maxValue = maxValue;
		}
		
		public function get id():uint			{ return _id; }
		public function get name():String		{ return _name; }
		public function get minValue():Number	{ return _minValue; }
		public function get maxValue():Number	{ return _maxValue; }
		public function get isFloat():Boolean	{ return _isFloat; }
		public function get voted():Boolean		{ return _voted; }
		public function set voted(b:Boolean):void	{ _voted = b; }
		
		public function toString():String		{ return _name; }
		
	}
	
}