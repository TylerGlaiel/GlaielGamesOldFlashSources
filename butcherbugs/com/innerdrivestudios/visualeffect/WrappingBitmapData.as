package com.innerdrivestudios.visualeffect 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * Can be plugged in a bitmap, turning the bitmap into a wrapped scrolling bitmap, eg:
	 * bitmap.bitmapData = new WrappingBitmapData (bitmap.bitmapData);
	 * 
	 * @author JC Wichman
	 */
	public class WrappingBitmapData extends BitmapData
	{
		private var _wrappingbitmap:WrappingBitmap = null;
		
		public function WrappingBitmapData(pSource:BitmapData) 
		{
			super (pSource.width, pSource.height, pSource.transparent, 0x0);
			
			_wrappingbitmap = new WrappingBitmap (pSource);
			_wrappingbitmap.grab (this);
		}
		
		override public function scroll (x:int, y:int) : void {
			_wrappingbitmap.scroll (x, y);
			_wrappingbitmap.grab(this);
		}
	}

}