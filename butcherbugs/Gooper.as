package 
{
	import com.glaiel.util.math.Vec2D;
	import flash.display.*;

	dynamic public class Gooper extends MovieClip {
		
		public var life:Number;
		public var speed:Vec2D;
		public var rpos:Vec2D;
		public var sintimer:Number = 0;
		public var alive:Boolean;
		
		public function Gooper() {
			alive = true;
			life = 10;
			
			var side:int = Math.random() * 4;
			if (side == 0) {
				y = -50;
				x = Math.random() * 600;
				speed = new Vec2D(Math.random() * 10 - 5, Math.random() * 3 + 2);
				
			} else if (side == 1) {
				x = -50;
				y = Math.random() * 700;
				speed = new Vec2D(Math.random() * 3 + 2, Math.random() * 10 - 5);
			} else if (side == 2) {
				x = 650;
				y = Math.random() * 700;
				speed = new Vec2D(-(Math.random() * 3 + 2), Math.random() * 10 - 5);
			} else {
				y = 750;
				x = Math.random() * 600;
				speed = new Vec2D(Math.random() * 10 - 5, -(Math.random() * 3 + 2));
			}
			
			
			rpos = new Vec2D(x, y);
		}
		
		

		
		public function shoot() {
			if(parent && parent.parent && parent.parent.parent){
				MovieClip(parent.parent.parent).eshoot(this);
			}
		}
		
		public function update() {
			rpos.x += speed.x*.25;
			rpos.y += speed.y*.25;
			sintimer += Math.random() * .03;
			
			x = rpos.x - speed.y * Math.sin(sintimer) * 50;
			y = rpos.y + speed.x * Math.sin(sintimer) * 50;
			
			if (x > 700 || x <= -100 || y<-100 || y > 800) return false;
			if (life <= 0) {
				return false;
			}
			return true;
		}
	}
	
}