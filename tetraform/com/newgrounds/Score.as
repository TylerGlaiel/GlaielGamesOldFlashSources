package com.newgrounds 
{
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class Score
	{
		private var _board:ScoreBoard;
		private var _position:uint;
		private var _username:String;
		private var _value:String;
		private var _numeric_value:Number;
	
		function Score(board:ScoreBoard, position:Number, username:String, value:String, numeric_value:Number)
		{
			_board = board;
			_position = position;
			_username = username;
			_value = value;
			_numeric_value = numeric_value;
	}	
		
		public function get board():ScoreBoard {
			return _board;
		}

		public function get position():uint {
			return _position;
		}

		public function get username():String {
			return _username;
		}

		public function get value():String {
			return _value;
		}

		public function get numeric_value():Number {
			return _numeric_value;
		}
	}

}