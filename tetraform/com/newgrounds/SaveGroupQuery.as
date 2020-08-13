package com.newgrounds 
{
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SaveGroupQuery extends EventDispatcher
	{
		public static const TABLE_FILES:uint		= 1;
		public static const TABLE_KEYS:uint			= 2;
		public static const TABLE_RATINGS:uint		= 3;
		
		public static const FILE_ID:uint			= 0;
		public static const AUTHOR_ID:uint			= 1;
		public static const AUTHOR_NAME:uint		= 2;
		public static const FILE_NAME:uint			= 3;
		public static const CREATED_ON:uint			= 4;
		public static const UPDATED_ON:uint			= 5;
		public static const TOTAL_VIEWS:uint		= 6;
		public static const FILE_STATUS:uint		= 7;
		
		public static const SCORE:String			= "score";
		public static const TOTAL_VOTES:String		= "votes";
		
		private var _group:SaveGroup;
		
		private var _groupBy:Array;
		private var _lookupKeys:Array;
		private var _lookupRatings:Array;
		
		private var _fileConditions:Array;
		private var _keyConditions:Array;
		private var _ratingConditions:Array;
		private var _sortConditions:Array;
		
		private var _page:uint;
		private var _resultsPerPage:uint;
		private var _randomizeResults:Boolean;
		
		public function SaveGroupQuery(group:SaveGroup) 
		{
			_group = group;
			
			reset();
		}
		
		public function get group():SaveGroup		{ return _group; }
		public function get groupId():uint						{ return _group.id; }
		public function get resultsPerPage():uint				{ return _resultsPerPage; }
		public function set resultsPerPage(n:uint):void			{ _resultsPerPage = n; }
		public function get page():uint							{ return _page; }
		public function set page(n:uint):void					{ _page = n; }
		public function get isRandomized():Boolean				{ return _randomizeResults; }
		public function set isRandomized(b:Boolean):void		{ _randomizeResults = b; }
		
		public function reset():void
		{			
			_fileConditions = [];
			_keyConditions = [];
			_ratingConditions = [];
			_sortConditions = [];
			_groupBy = [];
			_lookupKeys = [];
			_lookupRatings = [];

			_randomizeResults = false;
			_resultsPerPage = 20;
			_page = 1;
		}
				
		public function includeKey(keyName:String):void
		{
			var key:SaveKey = _group.getKeyByName(keyName);
			if(key)
				_lookupKeys.push(key.id);
		}
		
		public function includeRating(ratingName:String):void
		{
			var rating:SaveRating = _group.getRatingByName(ratingName);
			if(rating)
				_lookupRatings.push(rating.id);
		}

		public function excludeKey(keyName:String):void
		{
			var key:SaveKey = _group.getKeyByName(keyName);
			for (var i:uint = 0; i < _lookupKeys.length; i++)
			{
				if (_lookupKeys[i] == key.id)
				{
					_lookupKeys.splice(i, 1);
					return;
				}
			}
		}
		
		public function excludeRating(ratingName:String):void
		{
			var rating:SaveRating = _group.getRatingByName(ratingName);
			for (var i:uint = 0; i < _lookupRatings.length; i++)
			{
				if (_lookupRatings[i] == rating.id)
				{
					_lookupRatings.splice(i, 1);
					return;
				}
			}
		}
		
		public function groupBy(field:uint):void
		{
			_groupBy.push( { table: TABLE_FILES, field: field } );
		}
		
		public function groupByRating(ratingName:String):void
		{
			var rating:SaveRating = _group.getRatingByName(ratingName);
			
			if (!rating)
			{
				// TODO: error
				return;
			}
			
			_groupBy.push( { table: TABLE_RATINGS, field: rating.id } );
		}
		
		public function groupByKey(keyName:String):void
		{
			var key:SaveKey = _group.getKeyByName(keyName);
			
			if (!key)
			{
				// TODO: error
				return;
			}
			
			_groupBy.push( { table: TABLE_KEYS, field: key.id } );
		}
		
		// CONDITIONS
		public function addFileCondition(field:uint, operator:String, value:*):void
		{			
			// TODO: error check
			_fileConditions.push({field:field, operator:operator, value:value});
		}
		
		public function addKeyCondition(keyName:String, operator:String, value:*):void
		{
			var key:SaveKey = _group.getKeyByName(keyName);
			if (!key)
			{
				// ERROR
				return;
			}
			else if (!checkValue(value, key.type))
			{
				// ERROR:
				return;
			}
			else
			{
				_keyConditions.push({key:key.id, operator:operator, value:value});
			}
		}
		
		public function addRatingCondition(ratingName:String, operator:String, value:*, column:String = SCORE):void
		{
			var rating:SaveRating = _group.getRatingByName(ratingName);
			if (!rating)
			{
				// ERROR
				return;
			}
			/*else if (!checkValue(value, rating.))
			{
				// ERROR:
				return;
			}*/
			else
			{
				_ratingConditions.push({rating:rating.id, operator:operator, value:value, column:column});
			}
		}
		
		private function addSortCondition(table:uint, field:uint, sortDescending:Boolean = false, extra:* = null):void
		{			
			var sortCondition:Object =
			{
				table:		table,
				field:		field,
				desc:		sortDescending
			};
			
			if (extra)
				sortCondition.extra = extra;
			
			_sortConditions.push(sortCondition);
		}
		
		public function sortOn(field:uint, sortDescending:Boolean = false):void
		{
			addSortCondition(TABLE_FILES, field, sortDescending);
		}
		
		public function sortOnKey(keyName:String, sortDescending:Boolean = false):void
		{
			addSortCondition(TABLE_KEYS, _group.getKeyByName(keyName).id, sortDescending);
		}
		
		public function sortOnRating(ratingName:String, sortDescending:Boolean = false, column:String = SCORE):void
		{
			addSortCondition(TABLE_RATINGS, _group.getRatingByName(ratingName).id, sortDescending, column);
		}
		
		public function execute():void
		{
			NewgroundsAPI.executeSaveQuery(this);
		}
		
		private function checkValue(obj:*, type:uint):Boolean
		{
			return true;
			
			// TODO
			/*switch(type)
			{
				case :		return obj is String;
				case "integer":		return (obj is int) || (obj is uint);
				case "float":		return (obj is Number) || (obj is int) || (obj is uint);
				case "boolean":		return (obj is Boolean) || (obj is int) || (obj is uint) || (obj is Number);
			}

			return false;*/
		}
		
		override public function toString():String						{ return ""; }
		public function toObject():Object
		{
			var query:Object = { page: _page, num_results: _resultsPerPage };
			if (isRandomized) query.randomize = 1;

			if (_fileConditions && _fileConditions.length > 0)
				query.file_conditions = _fileConditions;
				
			if (_keyConditions && _keyConditions.length > 0)
				query.key_conditions = _keyConditions;
				
			if (_ratingConditions && _ratingConditions.length > 0)
				query.rating_conditions = _ratingConditions;
			
			if (_sortConditions && _sortConditions.length > 0)
				query.sort_conditions = _sortConditions;
				
			if (_lookupKeys && _lookupKeys.length > 0)
				query.lookup_keys = _lookupKeys;
			
			if (_lookupRatings && _lookupRatings.length > 0)
				query.lookup_ratings = _lookupRatings;
				
			if (_groupBy && _groupBy.length > 0)
				query.group_by = _groupBy;
			
			return query;
		}
	}	
}