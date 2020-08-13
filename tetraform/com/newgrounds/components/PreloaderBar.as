package com.newgrounds.components 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author Mike Welsh
	 */
	
	public dynamic class PreloaderBar extends MovieClip
	{
		[Inspectable(name="Auto Play on Load", defaultValue=false)]
		public var autoPlay:Boolean = false;

		public var bar:MovieClip;
	
		public function PreloaderBar() 
		{
			gotoAndStop("LOAD");
			if (bar)
				bar.scaleX = 0;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (root && root.loaderInfo)
			{
				if (root is MovieClip)
					MovieClip(root).stop();
					
				var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
				
				if (bar) bar.scaleX = percent;
				
				if (percent == 1)
				{
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
								
					if (autoPlay) startMovie();
					else gotoAndPlay("COMPLETE_STOP");
				}
			}
		}
		
		private function startMovie():void
		{
			if (root && root is MovieClip)
				MovieClip(root).play();
				
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}