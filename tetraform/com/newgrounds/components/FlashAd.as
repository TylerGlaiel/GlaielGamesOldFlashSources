package com.newgrounds.components 
{
	import com.newgrounds.APIEvent;
	import com.newgrounds.NewgroundsAPI;
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public dynamic class FlashAd extends MovieClip
	{
		
		[Inspectable(name="Show Background", defaultValue=true)]
		public var show_background:Boolean = true;
				
		public function FlashAd()
		{
			if (loaderInfo)
			{
				loaderInfo.addEventListener(Event.INIT, onInit);
			}
			else onInit(null);
			
			x = Math.round(x);
			y = Math.round(y);
			scaleX = 1;
			scaleY = 1;			
			//API.reportComponent("FlashAd");
		}
			
		private function onInit(e:Event):void
		{
			if(this.background)
				this.background.visible = show_background;
				
			if (loaderInfo)
				loaderInfo.removeEventListener(Event.INIT, onInit);

			if (NewgroundsAPI.adsApproved)
				onAdsApproved(null);
			else
				NewgroundsAPI.addEventListener(APIEvent.ADS_APPROVED, onAdsApproved, false, 0, true);
		}		
		
		private function onAdsApproved(e:APIEvent):void
		{
			if (e.success)
			{
				addChild( NewgroundsAPI.createAd() );
			}
			
			NewgroundsAPI.removeEventListener(APIEvent.ADS_APPROVED, onAdsApproved, false);
		}
	}

}