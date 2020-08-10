package {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import com.glaiel.util.math.Vec2D;
	import flash.display.DisplayObjectContainer;
	public class LadyBugController {
		private var bugpos:Vector.<BugPos>;
		public var formation:int;
		public var rformation:int;
		private var parent:DisplayObjectContainer;
		private var timer:int = 0;
		private var mwheeldelta:Number;
		public var switchtimer = -30;
		
		const MAXFORM:int = 5;
		public const forspeed:Array = [1, .9, .70, .6, .3, 1.3]
		public function LadyBugController(parent_:DisplayObjectContainer) {
			parent = parent_;
			bugpos = new Vector.<BugPos>();
			for (var i:int = 0; i < 5; i++) {
				bugpos.push(new BugPos(0, i, 0));
			}
			formation = 0;
			rformation = 0;
			
			mwheeldelta = 0;
			parent.stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandeler);
			parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandeler);
		}
		public function update() {
			if (mwheeldelta > 1) {
				mwheeldelta = 0;
				formation++;
			}
			if (mwheeldelta < -1) {
				mwheeldelta  = 0;
				formation--;
			}
			if (formation < 0) formation = MAXFORM;
			if (formation > MAXFORM) formation = 0;
			
			if (switchtimer-- < 0) {
				rformation = formation;
			}
			
			timer++;
			timer = timer % 360;
			
			switch(rformation) {
				case 0:
					bugpos[0].x = parent.mouseX;
					bugpos[0].y = parent.mouseY;
					bugpos[0].rotation = 0;
					
					for (var i:int = 1; i < 5; i++) {
						var A:Number = (i - 1) * 90;
						var v:Vec2D = new Vec2D(0, 30);
						v.rotate(A + timer * 5);
						bugpos[i].rotation = 0;
						bugpos[i].x = bugpos[0].x + v.x;
						bugpos[i].y = bugpos[0].y + v.y;
					}
				break;
				case 1:
					bugpos[0].x = parent.mouseX;
					bugpos[0].y = parent.mouseY;
					bugpos[0].rotation = 0;
					
					for (var i:int = 1; i < 5; i++) {
						bugpos[i].rotation = 0;
						if(i<3){
							bugpos[i].x = bugpos[0].x + (i-1-2)*40;
							bugpos[i].y = bugpos[0].y;
						} else {
							bugpos[i].x = bugpos[0].x + (i-2)*40;
							bugpos[i].y = bugpos[0].y;
						}
					}
				break;
				case 2:
					
					/*if(bugpos[0].x != parent.mouseX || bugpos[0].y != parent.mouseY){
				    	bugpos[0].rotation = Math.atan2(parent.mouseY-bugpos[0].y, parent.mouseX-bugpos[0].x)*180/Math.PI+90;
					}
					bugpos[0].x = parent.mouseX;
					bugpos[0].y = parent.mouseY;*/
					
					bugpos[0].rotation = Math.atan2(parent.mouseY-bugpos[0].y, parent.mouseX-bugpos[0].x)*180/Math.PI+90;
						var distk:Vec2D = new Vec2D(bugpos[0].x - parent.mouseX, bugpos[0].y - parent.mouseY);
						distk.length = 5;
						bugpos[0].x = parent.mouseX+  distk.x;
						bugpos[0].y = parent.mouseY + distk.y;
					
					
					
					for (var i:int = 1; i < 5; i++) {
						bugpos[i].rotation = Math.atan2(bugpos[i-1].y-bugpos[i].y, bugpos[i-1].x-bugpos[i].x)*180/Math.PI+90;
						var dist:Vec2D = new Vec2D(bugpos[i].x - bugpos[i - 1].x, bugpos[i].y - bugpos[i - 1].y);
						dist.length = 40;
						bugpos[i].x = bugpos[i - 1].x + dist.x;
						bugpos[i].y = bugpos[i - 1].y + dist.y;
					}
				break;
				case 3:
					
					bugpos[0].x = parent.mouseX;
					bugpos[0].y = parent.mouseY-20;
					bugpos[0].rotation = 0;
					
					for (var i:int = 1; i < 5; i++) {
						bugpos[i].rotation = 180;
						if(i<3){
							bugpos[i].x = bugpos[0].x + (i-1-2)*50+25;
							bugpos[i].y = bugpos[0].y+40;
						} else {
							bugpos[i].x = bugpos[0].x + (i-2)*50-25;
							bugpos[i].y = bugpos[0].y+40;
						}
					}
				break;
				case 4:
					
					for (var i:int = 0; i < 5; i++) {
						var A:Number = (i - 1) * 360/5;
						var v:Vec2D = new Vec2D(0, 60);
						v.rotate(A + timer * 5);
						bugpos[i].rotation = A+timer*5+180;
						bugpos[i].x = parent.mouseX + v.x;
						bugpos[i].y = parent.mouseY + v.y;
					}
				break;
				case 5:
					
					bugpos[0].x = parent.mouseX;
					bugpos[0].y = parent.mouseY;
					bugpos[0].rotation = 0;
					bugpos[1].x = parent.mouseX-20;
					bugpos[1].y = parent.mouseY-15;
					bugpos[1].rotation = -90;
					bugpos[2].x = parent.mouseX+20;
					bugpos[2].y = parent.mouseY-15;
					bugpos[2].rotation = 90;
					bugpos[3].x = parent.mouseX-20;
					bugpos[3].y = parent.mouseY+15;
					bugpos[3].rotation = -90;
					bugpos[4].x = parent.mouseX+20;
					bugpos[4].y = parent.mouseY+15;
					bugpos[4].rotation = 90;
				break;
			}
		}
		
		public function getPos(id:int) : BugPos {
			return bugpos[id];
		}
		
		public function wheelHandeler(e:MouseEvent) {
			//trace(e.delta);
			mwheeldelta += e.delta;
			switchtimer = 40;
		}
		public function keyHandeler(e:KeyboardEvent) {
			if (e.keyCode >= 49 && e.keyCode <= 49 + MAXFORM) {
				formation = e.keyCode-49;
				switchtimer = 40;
			}
		}
	}
	
	 

}

class BugPos {
		public var x:Number;
		public var y:Number;
		public var rotation:Number;
		public function BugPos(x_:Number, y_:Number, rot_:Number){
			x = x_;
			y = y_;
			rotation = rot_;
		}
	}