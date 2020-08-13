package com.newgrounds 
{
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class ScoreBoard extends EventDispatcher
	{
		private var _name:String;
		private var _id:uint;
		private var _scores:Array;
		private var _period:String		= "Today";
		private var _num_results:uint	= 10;
		private var _page:uint			= 1;
		
		public function ScoreBoard(id:uint, name:String)
		{
			_name = name;
			_id = id;
			_scores = [];
		}
		
		public function exists():Boolean
		{
			return _id > 0;
		}
		
		public function get id():Number				{ return _id; }
		public function get name():String			{ return _name; }
		public function get period():String			{ return _period; }
		public function get page():uint				{ return _page; }
		public function get num_results():uint		{ return _num_results; }
		public function get scores():Array			{ return _scores; }
	
		public function postScore(value:Number, get_best:Boolean):void
		{
			NewgroundsAPI.postScore(_name, value, get_best);
		}
		
		public function loadScores(period:String, page:uint, num_results:uint):void
		{
			_period = period;
			if (!_period || _period == "")
				_period = "Today";
			_page = page;
			_num_results = num_results;
			
			NewgroundsAPI.loadScores(this);
		}
		
		internal function setScores(scores:Array, period:String, page:Number, num_results:Number):void
		{
			_period = period;
			_page = page;
			_num_results = num_results;
			
			_scores = [];
			
			for (var i:uint = 0; i < scores.length; i++)
			{
				var position:uint = (_num_results * (_page-1)) + 1 + i;
				_scores.push(new Score(this, position, scores[i].username, scores[i].value, scores[i].numeric_value));
			}
		}
		
	}

}