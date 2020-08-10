﻿package {	import flash.display.*;	import flash.geom.*;	import flash.filters.*;	public class Displacer {		private var w:int;		private var h:int;		public var strength:int;		private var target:DisplayObject;		private var map:DisplayObject;		private var bmpdata:BitmapData;		private var dismap:BitmapData;		public var bmp:Bitmap;		public function Displacer(x:int,y:int,clip1:DisplayObject,clip2:DisplayObject,str:int):void {			w=x;			h=y;			strength=str;			target=clip1;			map=clip2;			bmpdata=new BitmapData(w,h);			dismap=new BitmapData(w,h);			bmp=new Bitmap(bmpdata);			dismap.draw(map);			MovieClip(target).addChild(bmp);			bmp.visible=false;		}		public function topLevel():void {			MovieClip(target).addChild(bmp);		}		public function turnOn():void {			bmp.visible=true;			render();		}		public function turnOff():void {			bmp.visible=false;		}		public function render():void {			bmpdata.fillRect(new Rectangle(0,0,w,h),0x00FFFFFF);			bmpdata.draw(target);			dismap.draw(map);			if (strength > 0) {				var dmapfilter:BitmapFilter=new DisplacementMapFilter(dismap,new Point(0,0),BitmapDataChannel.RED,BitmapDataChannel.GREEN,strength,strength,DisplacementMapFilterMode.CLAMP,0,0);				bmpdata.applyFilter(bmpdata,new Rectangle(0,0,w,h),new Point(0,0),dmapfilter);			}		}	}}