package 
{
	import com.glaiel.util.math.Vec2D;
	import flash.display.*;
	dynamic public class  LadyBug extends MovieClip {
		private var tgt:MovieClip;
		private var id:int;
		public var alive:Boolean = true;
		public var invincibility:int;
		
		public function LadyBug(tgt_:MovieClip, id_:int) {
			tgt = tgt_;
			id = id_;
			invincibility = 0;
		}
		public function update(neurons:Vector.<Neuron>) {
			if (!alive) visible = false; else visible = true;
			
			var oldpos:Vec2D = new Vec2D(x, y);
			
			//x += (tgt.x - x) * .5;
			//y += (tgt.y - y) * .5;
			var dir:Vec2D = new Vec2D(tgt.x - x, tgt.y - y);
			//var l:Number = dir.length;
			if (dir.length > 10.0) dir.length = 10.0;
			x += dir.x;
			y += dir.y;
			
			rotation = tgt.rotation;
			
			
			x += (tgt.x - x) * .05;
			y += (tgt.y - y) * .05;
			
			
		    if (x < 15) x = 15;
			if (x > 600 - 15) x = 600 - 15;
			if (y < 15) y = 15;
			if (y > 700 - 15) y = 700 - 15;
			
			var newpos:Vec2D = new Vec2D(x, y);
			
			
			for (var i:int = 0; i < neurons.length; i++) {
				
				if (!alive) {
					neurons[i].bugside[id] = 0;
				} else {
				
					if(neurons[i].alive){
					
						var clipline_p:Vec2D = neurons[i].getOrigin();
						
						var sss:Number = neurons[i].bugside[id] * -15;
						
						var clipline_v:Vec2D = neurons[i].getSlope();
						clipline_v.norm();
						
						clipline_p.x += clipline_v.y * -sss;
						clipline_p.y += clipline_v.x * sss;
						
						var p2:Vec2D = Vec2D.subtract(newpos, clipline_p);
						
						var cross:Number = Vec2D.cross(p2, clipline_v);
						var side:int = cross > 0?1:-1;
						
						if (neurons[i].bugside[id] == 0) {
							neurons[i].bugside[id] = side;
						} else {
							if(neurons[i].bugside[id] != side){
								p2 = new Vec2D(newpos.x-clipline_p.x, newpos.y-clipline_p.y);
								var t:Number = Vec2D.dot(p2, clipline_v);
								x = clipline_p.x + t * clipline_v.x;
								y = clipline_p.y + t * clipline_v.y;
								newpos.x = x;
								newpos.y = y;
								
								if (neurons[i].electro && invincibility == 0) {
									alive = false;
								}
							}
						}
					}
				}
			}
			
			
		
			
			if (invincibility > 0) {
				invincibility--;
				if (alive) {
					visible = (invincibility >> 1) % 2;
				}
			} else {
				if (alive) {
					visible = true;
				}
			}
		}
	}
	
}