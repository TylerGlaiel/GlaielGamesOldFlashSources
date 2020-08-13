package com.newgrounds 
{
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class AdDisplay extends Sprite
	{
		// removed from stage was only added in 9.0.28. Avoid an error for people using earlier version.
		private static const REMOVED_FROM_STAGE:String = "removedFromStage";
		
		private var _adURLLoader:URLLoader;
		private var _mask:Shape;
		private var _ad:Loader;
		
		private static var _adResetTime:Number = 0;
		private static var _currentAdUrl:URLRequest;
		
		public function AdDisplay(adFeedURL:String) 
		{			
			/*Security.allowDomain("http://server.cpmstar.com");
			Security.allowDomain("http://www.cpmstar.com");
			Security.allowDomain("https://server.cpmstar.com");
			Security.allowDomain("https://www.cpmstar.com");
			Security.allowInsecureDomain("http://server.cpmstar.com");
			Security.allowInsecureDomain("http://www.cpmstar.com");
			Security.allowInsecureDomain("https://server.cpmstar.com");
			Security.allowInsecureDomain("https://www.cpmstar.com");*/
			
			var adRect:Shape = new Shape();
			adRect.graphics.beginFill(0x000000);
			adRect.graphics.moveTo(0,0);
			adRect.graphics.lineTo(300,0);
			adRect.graphics.lineTo(300,250);
			adRect.graphics.lineTo(0,250);
			adRect.graphics.lineTo(0,0);
			adRect.graphics.endFill();
			
			_mask = new Shape();
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.moveTo(0,0);
			_mask.graphics.lineTo(300,0);
			_mask.graphics.lineTo(300,250);
			_mask.graphics.lineTo(0,250);
			_mask.graphics.lineTo(0,0);
			_mask.graphics.endFill();
				
			addChild(adRect);
			addChild(_mask);
						
			_adURLLoader = new URLLoader();
			_adURLLoader.addEventListener(Event.COMPLETE, onAdFeedLoaded);
			_adURLLoader.addEventListener(IOErrorEvent.IO_ERROR, onAdError);
			_adURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onAdError);
			
			if (adFeedURL && hasAdElapsed) {
				// load the ad with a random seed to avoid caching
				if (adFeedURL.indexOf('?') > -1)
					_currentAdUrl = new URLRequest(adFeedURL+"&random="+Math.random());
				 else
					_currentAdUrl = new URLRequest(adFeedURL+ "?random=" + Math.random());
			}
			
			if (_currentAdUrl)
			{
				try
				{
					_adURLLoader.load(_currentAdUrl);
				}
				catch (e:Error)
				{
					onAdError(null);
				}
			}
			else
				trace("[NewgroundsAPI] :: No ad feed URL supplied to Newgrounds API ad!");
			
				
			// REMOVED_FROM_STAGE added in 9.0.28.0. Fail silently in earlier versions
			if (NewgroundsAPI.isFlashVersion(9, 0, 28))
				addEventListener(REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function loadAd(url:String):void
		{
			// cleanup previous ad
			if (_ad)
				removeAd();
				
			_ad = new Loader();
			addChild(_ad);
			_ad.mask = _mask;

			_ad.contentLoaderInfo.addEventListener(Event.COMPLETE, onAdLoaded);
			_ad.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAdError);
			_ad.load(new URLRequest(url));
		}
		
		private function onAdFeedLoaded(e:Event):void
		{
			var loader:URLLoader = URLLoader( e.target );
			
			if (loader.data) {
				loadAd( String(loader.data) );
			} else {
				dispatchEvent( new APIEvent(APIEvent.AD_ATTACHED, false, new APIError("FLASH_ADS_NOT_APPROVED", "Unable to render ad")) );
			}
		}
		
		private function onAdFeedError(e:Event):void	{ trace("[NewgroundsAPI] :: Unable to load ad feed!"); }
		
		private function onAdError(e:Event):void
		{
			dispatchEvent( new APIEvent(APIEvent.AD_ATTACHED, false, new APIError("FLASH_ADS_NOT_APPROVED", "Unable to render ad")) );
			removeAd();
		}
		
		private function onAdLoaded(e:Event):void
		{
			trace("[NewgroundsAPI] :: Ad loaded!");
			dispatchEvent( new APIEvent(APIEvent.AD_ATTACHED, true) );
		}
		
		private function onRemovedFromStage(e:Event):void		{ removeAd(); }
		
		// this is used so requests to the actual ad server only happen once every 5 minutes
		private function get hasAdElapsed():Boolean
		{			
			var d:Date = new Date();
			
			// if the time has expired, update the reset timer and return true
			if (d.getTime() >= _adResetTime) {
				_adResetTime = d.getTime() + (1000*60*5); // 5 minutes
				return true;
			}
			
			// time hasn't expired
			return false;
		}
		
		public function removeAd():void
		{
			removeEventListener(REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if (_adURLLoader)
			{
				try { _adURLLoader.close(); } // close throws an error if loading is done
				catch(e:Error) { }
			}
				
			if (_ad)
			{
				trace("[NewgroundsAPI] :: Ad removed");

				try { _ad.close(); }
				catch(e:Error) { }
				
				// MIKE: unloadAndStop was only added in FP10. Calling it in FP9-targetted Flash results in an undefined function error.
				try { Object(_ad).unloadAndStop(true); }		// cast to Object to avoid compile time error
				catch (e:Error) { _ad.unload(); }			// catch run-time reference errors. Default to unload()
				
				if (_ad.parent)
					_ad.parent.removeChild(_ad);
			}
			
			_ad = null;
		}
		
		
	}
	
}