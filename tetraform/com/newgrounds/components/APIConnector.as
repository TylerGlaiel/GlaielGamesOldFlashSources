package com.newgrounds.components 
{
	import com.newgrounds.APIEvent;
	import com.newgrounds.NewgroundsAPI;
	import com.newgrounds.APIEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public dynamic class APIConnector extends MovieClip
	{
		// avoid use of ADDED_TO_STAGE
		private var _initialized:Boolean;
		
		[Inspectable(name="Movie ID", defaultValue="")]
		public var movie_id:String;
		
		[Inspectable(name="Encryption Key", defaultValue="")]
		public var encryption_key:String;
		
		[Inspectable(name="Movie Version", defaultValue="")]
		public var movie_version:String;
	
		public function APIConnector() 
		{
			visible = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stop();
		}
	
		private function onMovieConnected(event:APIEvent):void
		{
			if (event.success)
			{
				if (NewgroundsAPI.isPublishedHost() && NewgroundsAPI.hasPublisher())
				{
					if (!NewgroundsAPI.hasUserSession() && !NewgroundsAPI.debugMode)
					{
						gotoAndStop("no_login");
						visible = true;
					}
				}
			}
			else
			{
				gotoAndStop("no_connect");
				visible = true;
			}
		}
		
		private function onNewVersionAvailable(event:APIEvent):void
		{
			gotoAndStop("new_version");
			visible = true;
		}
		
		private function onHostBlocked(event:APIEvent):void
		{
			gotoAndStop("bad_host");
			visible = true;
		}
		
		private function onCloseButtonClicked(event:Event):void
		{
			visible = false;
		}
		
		private function onOfficialVersionClicked(event:Event):void
		{
			navigateToURL(new URLRequest(NewgroundsAPI.getOfficialVersionURL()), "_blank");
		}
		
		private function onEnterFrame(event:Event):void
		{				
			if (!_initialized)
			{
				if (root)
				{
					if (stage)
					{
						x = stage.stageWidth / 2;
						y = stage.stageHeight / 2;
					}
					
					NewgroundsAPI.addEventListener(APIEvent.MOVIE_CONNECTED, onMovieConnected);		
					NewgroundsAPI.addEventListener(APIEvent.NEW_VERSION_AVAILABLE, onNewVersionAvailable);
					NewgroundsAPI.addEventListener(APIEvent.HOST_BLOCKED, onHostBlocked);
					
					NewgroundsAPI.setMovieVersion(movie_version);
					NewgroundsAPI.connectMovie(root.loaderInfo, movie_id.toString(), encryption_key);
										
					_initialized = true;
				}
				else return;
			}
			
			if (this.closeButton && !this.closeButton.hasEventListener(MouseEvent.CLICK))
			{
				this.closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			}
			
			if (this.viewLatestButton && !this.viewLatestButton.hasEventListener(MouseEvent.CLICK))
			{
				this.viewLatestButton.addEventListener(MouseEvent.CLICK, onOfficialVersionClicked);
			}
			
			if (this.viewLegalButton && !this.viewLegalButton.hasEventListener(MouseEvent.CLICK))
			{
				this.viewLegalButton.addEventListener(MouseEvent.CLICK, onOfficialVersionClicked);
			}
				
			forceAlwaysOnTop();
		}
		
		private function forceAlwaysOnTop():void
		{
			// force always on top of display list
			if (parent && visible) {
				var myIndex:uint = parent.getChildIndex(this);
				var topIndex:uint = parent.numChildren - 1;
				if (parent && myIndex != topIndex) {
					parent.setChildIndex(this, topIndex);
				}
			}
		}
	}
	
}