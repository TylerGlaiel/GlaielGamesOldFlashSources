package {
	import flash.display.MovieClip;
	public class Vec2D {
		public var x:Number;
		public var y:Number;
		private static  var convert:Number = Math.PI/180;
		public function Vec2D(i:Number, j:Number):void {
			x = i;
			y = j;
		}
		public function norm():void {
			var l:Number = length;
			if(l != 0){
				x /= l;
				y /= l;
			}
		}
		public static function add(v:Vec2D, v2:Vec2D):Vec2D {
			return new Vec2D(v2.x + v.x,v2.y + v.y);
		}
		public static function subtract(v:Vec2D, v2:Vec2D):Vec2D {
			return new Vec2D(v.x - v2.x,v.y - v2.y);
		}
		public static function dot(v:Vec2D, v2:Vec2D):Number {
			return v2.x * v.x + v2.y * v.y;
		}
		public static function angle(v:Vec2D, v2:Vec2D):Number {
			return Math.acos(dot(v,v2) / (v2.length * v.length)) / convert;
		}
		public static function angle2(v:Vec2D, v2:Vec2D):Number {
			var dp:Number = angle(v, v2);
			if (comp(v.rotateNew(dp), v2)<.0001) {
				return dp;
			} else {
				return - dp;
			}
		}
		public static function comp(v:Vec2D, v2:Vec2D):Number {
			return Math.abs(v.x / v.length - v2.x / v2.length) + Math.abs(v.y / v.length - v2.y / v2.length);
		}
		public function get length():Number {
			return Math.sqrt(x * x + y * y);
		}
		public function perpendicular():Vec2D {
			return new Vec2D(- y,x);
		}
		public function scale(val:Number):void {
			x *= val;
			y *= val;
		}
		public function rotate(degrees:Number):void {
			degrees *= convert;
			var s:Number = Math.sin(degrees);
			var c:Number = Math.cos(degrees);
			var tx:Number = x*c-y*s;
			var ty:Number = x*s+y*c;
			x = tx;
			y = ty;
		}
		public function rotateNew(degrees:Number):Vec2D {
			degrees *= convert;
			var s:Number = Math.sin(degrees);
			var c:Number = Math.cos(degrees);
			return new Vec2D(x * c - y * s,x * s + y * c);
		}
		public function reflect(normal:Vec2D):Vec2D {
			var normal2:Vec2D = new Vec2D(normal.x, normal.y);
			normal2.norm();
			normal2.scale(2*dot(this, normal2));
			return subtract(this,normal2);
		}
		public function draw(point:Vec2D, scale:Number, tgt:MovieClip):void {
			tgt.graphics.lineStyle(3, 0xFFFFFF, 100);
			tgt.graphics.moveTo(point.x, point.y);
			tgt.graphics.lineTo(point.x+x*scale, point.y+y*scale);
			var nv:Vec2D = new Vec2D(-x, -y);
			nv.norm();
			nv.scale(7);
			nv.rotate(-45);
			tgt.graphics.lineTo(point.x+x+nv.x, point.y+y+nv.y);
			tgt.graphics.moveTo(point.x+x*scale, point.y+y*scale);
			nv.rotate(90);
			tgt.graphics.lineTo(point.x+x+nv.x, point.y+y+nv.y);
			tgt.graphics.lineStyle(2, 0x000000, 100);
			tgt.graphics.moveTo(point.x, point.y);
			tgt.graphics.lineTo(point.x+x*scale, point.y+y*scale);
			var nv2:Vec2D = new Vec2D(-x, -y);
			nv2.norm();
			nv2.scale(7);
			nv2.rotate(-45);
			tgt.graphics.lineTo(point.x+x+nv2.x, point.y+y+nv2.y);
			tgt.graphics.moveTo(point.x+x*scale, point.y+y*scale);
			nv2.rotate(90);
			tgt.graphics.lineTo(point.x+x+nv2.x, point.y+y+nv2.y);
		}
	}
}