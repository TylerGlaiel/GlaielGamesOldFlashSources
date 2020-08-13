package com.newgrounds.components 
{
	import com.newgrounds.NewgroundsAPI;
	import com.newgrounds.APIError;
	import com.newgrounds.APIEvent;
	import com.newgrounds.SaveFile;
	import com.newgrounds.SaveGroupQuery;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class TestSaveViewer extends Sprite
	{
		private var _query:SaveGroupQuery;
		private var _queryResults:Array = [];
		
		private var _loadingText:TextField;
		
		private var _saveList:Sprite;
		private var _saveTexts:Array;
		
		private var _idText:TextField;
		private var _ratingText:TextField;
		private var _descriptionText:TextField;
		private var _dataText:TextField;
		
		private var _nextPage:TextField;
		private var _loadData:TextField;
		private var _makeNewSave:TextField;
		private var _voteFive:TextField;
		
		private var _selectedFile:SaveFile;
		
		public function TestSaveViewer()
		{
			trace("Initializing...");
			
			_query =NewgroundsAPI.createSaveQuery("Levels");
			
			_query.includeKey("bool key");
			_query.includeKey("float key");
			_query.includeKey("int key");
			_query.includeKey("string key");
			_query.includeRating("Difficulty");
			_query.includeRating("Overall Fun");
			_query.resultsPerPage = 10;
			_query.addEventListener(APIEvent.QUERY_COMPLETE, onQueryComplete);

			// bad ui
			_loadingText = new TextField();
			_loadingText.text = "Loading...";
			_loadingText.x = 10;
			addChild(_loadingText);

			_saveList = new Sprite();
			_saveTexts = [];
			for (var i:uint = 0; i < 10; i++)
			{
				var tf:TextField = new TextField();
				tf.y = 14 * i;
				_saveTexts.push(tf);
				_saveList.addChild(tf);
				
				tf.addEventListener(MouseEvent.CLICK, changeSelectedFile );
			}
			_saveList.y = 20;
			addChild(_saveList);
			
			_idText = new TextField();
			_idText.x = 200;
			addChild(_idText);
			
			_ratingText = new TextField();
			_ratingText.x = 200;
			_ratingText.y = 14;
			addChild(_ratingText);
			
			_descriptionText = new TextField();
			_descriptionText.x = 200;
			_descriptionText.y = 28;
			addChild(_descriptionText);
			
			_dataText = new TextField();
			_dataText.x = 200;
			_dataText.y = 42;
			addChild(_dataText);
			
			_nextPage = new TextField();
			_nextPage.x = 10;
			_nextPage.y = 300;
			_nextPage.text = "Next page";
			_nextPage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { page++; } );
			addChild(_nextPage);
			
			_loadData = new TextField();
			_loadData.x = 100;
			_loadData.y = 300;
			_loadData.text = "Load Data";
			_loadData.addEventListener(MouseEvent.CLICK, doLoadData);
			addChild(_loadData);
			
			_makeNewSave = new TextField();
			_makeNewSave.x = 200;
			_makeNewSave.y = 300;
			_makeNewSave.text = "New Save";
			_makeNewSave.addEventListener(MouseEvent.CLICK, doNewSave);
			addChild(_makeNewSave);
			
			_voteFive = new TextField();
			_voteFive.x = 10;
			_voteFive.y = 328;
			_voteFive.text = "Submit Rating";
			_voteFive.addEventListener(MouseEvent.CLICK, submitRating);
			addChild(_voteFive);
			
			_query.page = 1;
			//_query.sortOnRating("Difficulty");
			_query.sortOn(SaveGroupQuery.FILE_NAME);
//			_query.isRandomized = true;
			
			loadPage();
		}
		
		public function changeSelectedFile(e:MouseEvent):void
		{
			selectedFile = _queryResults[_saveTexts.indexOf(e.currentTarget)];
		}
		public function get page():uint			{ return _query.page; }
		public function set page(n:uint):void	{ _query.page = n; loadPage();  }
		
		public function get selectedFile():SaveFile		{ return _selectedFile; }
		public function set selectedFile(s:SaveFile):void
		{
			_selectedFile = s;
			_loadData.visible = false;
			_voteFive.visible = false;
			if (s)
			{
				_loadData.visible = true;
				_voteFive.visible = true;
				_idText.text = "ID: " + s.id;
				_descriptionText.text = s.description;
				if(s.getRating("Difficulty"))
					_ratingText.text = s.getRating("Difficulty").score;
				_dataText.text = "";
			}
		}
		
		private function loadPage():void
		{
			selectedFile = null;
			_loadingText.text = "Loading...";
			_loadingText.visible = true;
			_query.execute();
		}
		
		private function onQueryComplete(e:APIEvent):void
		{
			_loadingText.visible = false;
			_queryResults = e.data;
			for (var i:uint = 0; i < _queryResults.length; i++)
			{
				var file:SaveFile = e.data[i];
				if(file)
					_saveTexts[i].text = file.name;
				else
					_saveTexts[i].text = file.name;
			}
		}
		
		private function doLoadData(e:MouseEvent):void
		{
			selectedFile.addEventListener(APIEvent.FILE_LOADED, onFileLoaded);
			selectedFile.loadContents();
		}
		
		private function onFileLoaded(e:APIEvent):void
		{
			selectedFile.removeEventListener(APIEvent.FILE_LOADED, onFileLoaded);
			trace("R");
			_dataText.text = e.data.toString();
		}
		
		private function doNewSave(e:MouseEvent):void
		{
			var file:SaveFile = NewgroundsAPI.newSaveFile("Levels");
			file.name = "Testy " + uint(Math.random() * 100);
			file.description = "FFFFF " + Math.random();
			file.contents = "TESTETTWETR";
			file.save();
			file.addEventListener(APIEvent.FILE_SAVED, onFileSaved);
			selectedFile = file;
		}
		
		private function onFileSaved(e:APIEvent):void
		{
			selectedFile.removeEventListener(APIEvent.FILE_SAVED, onFileSaved);
			trace("fileid: " + e.data.save_id);
		}
		
		private function submitRating(e:MouseEvent):void
		{
			selectedFile.addEventListener(APIEvent.VOTE_COMPLETE, onVoteComplete);
			selectedFile.sendRating("Difficulty", 5);
		}
		
		private function onVoteComplete(e:APIEvent):void
		{
			trace("Rating done!");
			// reload stuff
			selectedFile.removeEventListener(APIEvent.VOTE_COMPLETE, onVoteComplete);
			selectedFile = selectedFile;
		}
		
	}
	
}