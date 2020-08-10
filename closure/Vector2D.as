﻿//COPYRIGHT TYLER GLAIEL 2008//VERSION 2.6package {	import flash.display.MovieClip;	public class Vector2D {		public var x:Number;		public var y:Number;		private static  var convert:Number = Math.PI/180;		public function Vector2D(i:Number, j:Number):void {			x = i;			y = j;		}		public function norm():void {			var l:Number = length;			if (l != 0) {				x /= l;				y /= l;			}		}		public static function add(v:Vector2D, v2:Vector2D):Vector2D {			return new Vector2D(v2.x + v.x,v2.y + v.y);		}		public static function subtract(v:Vector2D, v2:Vector2D):Vector2D {			return new Vector2D(v.x - v2.x,v.y - v2.y);		}		public static function dot(v:Vector2D, v2:Vector2D):Number {			return v2.x * v.x + v2.y * v.y;		}		public static function angle(v:Vector2D, v2:Vector2D):Number {			if (v2.length*v.length==0) {				return 0;			}			return Math.acos(dot(v,v2) / (v2.length * v.length)) / convert;		}		public static function angle2(v:Vector2D, v2:Vector2D):Number {			var dp:Number = angle(v, v2);			if (dp==0) {				return 0;			}			if (comp(v.rotateNew(dp), v2)<.0001) {				return dp;			} else {				return - dp;			}		}		public static function comp(v:Vector2D, v2:Vector2D):Number {			if (v.length*v2.length==0) {				return 0;			}			return Math.abs(v.x / v.length - v2.x / v2.length) + Math.abs(v.y / v.length - v2.y / v2.length);		}		public function get length():Number {			return Math.sqrt(x * x + y * y);		}		public function get length2():Number {			return x * x + y * y;		}		public function set length(len:Number):void {			norm();			scale(len);		}		public function perpendicular(sign:Number = -1):Vector2D {			return new Vector2D(sign * y,- sign * x);		}		public function scale(val:Number):void {			x *= val;			y *= val;		}		public function rotate(degrees:Number):void {			degrees *= convert;			var s:Number = Math.sin(degrees);			var c:Number = Math.cos(degrees);			var tx:Number = x*c-y*s;			var ty:Number = x*s+y*c;			x = tx;			y = ty;		}		public function rotateNew(degrees:Number):Vector2D {			degrees *= convert;			var s:Number = Math.sin(degrees);			var c:Number = Math.cos(degrees);			return new Vector2D(x * c - y * s,x * s + y * c);		}		public function reflect(normal:Vector2D):Vector2D {			var normal2:Vector2D = new Vector2D(normal.x, normal.y);			normal2.norm();			normal2.scale(2*dot(this, normal2));			return subtract(this,normal2);		}		public function constrain(amount:Number, type:String = "Greater") {			if (type == "Greater") {				if (length>amount) {					norm();					scale(amount);				}			}			if (type == "Always") {				norm();				scale(amount);			}			if (type == "Less") {				if (length<amount) {					norm();					scale(amount);				}			}		}		public function render(point:Vector2D, scale:Number, tgt:MovieClip):void {			tgt.graphics.lineStyle(3, 0xFFFFFF, 100);			tgt.graphics.moveTo(point.x, point.y);			tgt.graphics.lineTo(point.x+x*scale, point.y+y*scale);			var nv:Vector2D = new Vector2D(-x, -y);			nv.norm();			nv.scale(7);			nv.rotate(-45);			tgt.graphics.lineTo(point.x+x*scale+nv.x, point.y+y*scale+nv.y);			tgt.graphics.moveTo(point.x+x*scale, point.y+y*scale);			nv.rotate(90);			tgt.graphics.lineTo(point.x+x*scale+nv.x, point.y+y*scale+nv.y);			tgt.graphics.lineStyle(2, 0x000000, 100);			tgt.graphics.moveTo(point.x, point.y);			tgt.graphics.lineTo(point.x+x*scale, point.y+y*scale);			var nv2:Vector2D = new Vector2D(-x, -y);			nv2.norm();			nv2.scale(7);			nv2.rotate(-45);			tgt.graphics.lineTo(point.x+x*scale+nv2.x, point.y+y*scale+nv2.y);			tgt.graphics.moveTo(point.x+x*scale, point.y+y*scale);			nv2.rotate(90);			tgt.graphics.lineTo(point.x+x*scale+nv2.x, point.y+y*scale+nv2.y);		}	}}