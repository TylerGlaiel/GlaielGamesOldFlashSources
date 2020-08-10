package 
{
	import com.glaiel.util.math.Vec2D;
	import flash.display.*;
	dynamic public class MiniGooper extends Gooper 
	{
		public function MiniGooper() {
			super();
			life = 1;
			speed.scale(.75);
		}
	}
	
}