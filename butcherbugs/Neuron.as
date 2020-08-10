package 
{
	import com.glaiel.util.math.Vec2D;
	import flash.display.*;
	public class Neuron extends MovieClip{
		var leftend:MovieClip;
		var rightend:MovieClip;
		public var fiber:MovieClip;
		public var alive:Boolean;
		var introtimer:int;
		public var life:Number;
		public var electro:Boolean;
		
		public var bugside:Vector.<int>;
		
		public function Neuron(electroperc:Number) {
			life = 100;
			
			if(Math.random()<1.0-electroperc){
				leftend = new NeuronEnd();
				rightend = new NeuronEnd();
				fiber = new NeuronFiber();
				electro = false;
			} else {
				leftend = new ElectroNeuronEnd();
				rightend = new ElectroNeuronEnd();
				fiber = new ElectroNeuronFiber();
				electro = true;
			}
			
			addChild(fiber);
			addChild(leftend);
			addChild(rightend);
			
			
			leftend.x = 0;
			leftend.y = Math.random() * 700;
			rightend.x = 600;
			rightend.y = Math.random() * 700;
			
			var rot:Number = Math.atan2(rightend.y - leftend.y, rightend.x - leftend.x) * 180 / Math.PI;
			leftend.rotation = rot;
			rightend.rotation = rot + 180;
			fiber.rotation = rot;
			fiber.x = leftend.x;
			fiber.y = leftend.y;
			
			var dist:Number = Math.sqrt(600 * 600 + (leftend.y - rightend.y) * (leftend.y - rightend.y));
			fiber.scaleX = dist / 100.0;
			
			
			bugside = new Vector.<int>();
			for (var i:int = 0; i < 5; i++) {
				 bugside.push(0);
			}
			
			alive = false;
			introtimer = 100;
			fiber.scaleY = 0;
		}
		
		public function update():Boolean {
			introtimer--;
			if (introtimer < 0 && fiber.scaleY < 1 && life > 0) {
				fiber.scaleY += .1;
				if (fiber.scaleY >= 1) {
					fiber.scaleY = 1;
					alive = true;
				}
			}
			
			if (life <= 0) {
				leftend.play();
				rightend.play();
				alive = false;
				if (fiber.scaleY > 0 ) {
					fiber.scaleY -= .1;
					if (fiber.scaleY <= 0) {
						fiber.scaleY  = 0;
					}
				}
			}
			
			if (leftend.currentFrame == 1 && life <=0) {
				return false;
			}
			
			return true;
		}
		
		public function getSlope():Vec2D {
			return new Vec2D(rightend.x - leftend.x, rightend.y - leftend.y);
		}
		public function getOrigin():Vec2D {
			return new Vec2D(leftend.x, leftend.y);
		}
	}
	
}