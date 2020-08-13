package com.newgrounds.components 
{
	import com.newgrounds.APIEvent;
	import com.newgrounds.Medal;
	import com.newgrounds.NewgroundsAPI;
	import com.newgrounds.APIEvent;
	import com.newgrounds.Medal;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public dynamic class MedalPopup extends MovieClip
	{
		private const MEDAL_POPUP_TIME:uint = 3000;
		
		private var _initialized:Boolean;
		private var _medal:Medal
		private var _medalIcon:Bitmap;
		private var _medalQueue:Array = [];
		
		private var _popDelay:Timer;
		
		public function MedalPopup() {
			visible = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stop();
		}
		
		private function initialize():void {
			_initialized = true;

			NewgroundsAPI.addEventListener(APIEvent.MEDAL_UNLOCKED, onMedalUnlocked);

			_popDelay = new Timer(MEDAL_POPUP_TIME, 1);
			_popDelay.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (!_initialized && stage)
				initialize();
				
			if (_medalQueue.length && !visible)
			{
				_medal = _medalQueue.pop();
				_popDelay.start();
				gotoAndPlay("medal_show");
				visible = true;
			}
			
			// force always on top
			if (visible && parent) {
				var myIndex:uint = parent.getChildIndex(this);
				var topIndex:uint = parent.numChildren - 1;
				if (myIndex != topIndex)
					parent.setChildIndex(this, topIndex);
			}
		}
		
		private function onMedalUnlocked(e:APIEvent):void {
			if(e.success && e.data && e.data is Medal)
				_medalQueue.push(Medal(e.data));
		}
		
		private function showMedalIcon(container:DisplayObjectContainer):void
		{
			if (!_medal) return;
			
			_medalIcon = _medal.createIconBitmap();
			container.addChild(_medalIcon);
		}
		
		private function onTimer(e:TimerEvent):void {
			if (_medalIcon && _medalIcon.parent)
			{
				_medalIcon.parent.removeChild(_medalIcon);
				_medalIcon = null;
			}

			gotoAndPlay("medal_hide");
			_popDelay.stop();
		}
	}
}