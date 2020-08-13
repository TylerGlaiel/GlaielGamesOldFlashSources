package com.newgrounds.components 
{
	import com.newgrounds.APIError;
	import com.newgrounds.APIEvent;
	import com.newgrounds.NewgroundsAPI;
	import com.newgrounds.ScoreBoard;
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public dynamic class ScoreTable extends MovieClip
	{
		[Inspectable(name="Board Name", defaultValue="High Scores")]
		public var board_name:String = "High Scores";
		
		[Inspectable(name="Default Period", enumeration="Today,Yesterday,This Week,This Month,This Year,All-Time", defaultValue="Today")]
		public var period:String = "Today";
				
		private var _board:ScoreBoard;
	
		public function ScoreTable() 
		{			
			clearBoard();
			stop();
			
			if (loaderInfo)
			{
				loaderInfo.addEventListener(Event.INIT, onInit);
			}
			else onInit(null);
		}
		
		private function onInit(e:Event):void
		{
			if (loaderInfo)
				loaderInfo.removeEventListener(Event.INIT, onInit);
		
			if (!board_name || board_name == "")
			{
				trace("No board name specified!");
			}
			
			_board = NewgroundsAPI.getScoreBoardByName(board_name);
			if (!_board)
			{
				trace("[WARNING] :: Could not initialize the scoreboard for '"+board_name+"'.");
			}
			else
			{
				if(this.boardNameText) 	this.boardNameText.text = _board.name;
				if(this.period_select)	this.period_select.period = period;
			}
		}
		
		private function clearBoard():void
		{
			for (var i:uint = 0; i < 10; i++) // TODO
			{
				var row:MovieClip = this['score_row_' + i];
				if (row)
				{
					row.gotoAndStop(i % 2 == 0?1:2);
					if (row.positionText) row.positionText.text = "";
					if (row.usernameText) row.usernameText.text = "";
					if (row.scoreText) row.scoreText.text = "";
				}
			}
		}
		
		public function loadScores(num_results:uint, p:String):void
		{
			if (!_board)
			{
				_board = NewgroundsAPI.getScoreBoardByName(board_name);
				if (!_board) return; // TODO
				
				if(this.boardNameText) 		this.boardNameText.text = _board.name;
			}
			
			period = p;		

			clearBoard();
			
			if (_board)
			{
				_board.loadScores(period, 1, num_results);
				NewgroundsAPI.addEventListener(APIEvent.SCORES_LOADED, onScoresLoaded, false, 0, true);
			}
		}
		
		public function onScoresLoaded(e:APIEvent):void
		{
			NewgroundsAPI.removeEventListener(APIEvent.SCORES_LOADED, onScoresLoaded);
			
			if (!_board || !_board.scores)
			{
				clearBoard();
				return;
			}
			
			for (var i:uint = 0; i < _board.num_results; i++)
			{
				var row:MovieClip = this['score_row_' + i];
				if (row)
				{
					if (_board.scores[i])
					{
						if (row.positionText) row.positionText.text = _board.scores[i].position.toString() + ":";
						if (row.usernameText) row.usernameText.text =_board.scores[i].username;
						if (row.scoreText) row.scoreText.text = _board.scores[i].value.toString();
					}
					else {
						if (row.positionText) row.positionText.text = "";
						if (row.usernameText) row.usernameText.text = "";
						if (row.scoreText) row.scoreText.text = "";
					}
				}
			}
		}
	}

}