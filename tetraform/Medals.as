package  {
	import flash.net.SharedObject;
	import flash.display.MovieClip;
	import flash.events.*
	import flash.events.Event;
	import com.newgrounds.NewgroundsAPI;
	
	public class Medals {
		static public var ROOT:MovieClip;
		
		static public const GAMEWON:int = 0;
		static public const GAMEWON_NO_CONTINUES:int = 1;
		static public const FULLPLANET:int = 2;
		static public const SIDEKICK:int = 3;
		static public const HIROSHIMA:int = 4;
		static public const COMBO:int = 5;
		static public const EARS:int = 6
		static public const COMBOBREAKER:int = 7;
		static public const STRAGGLER:int = 8;
		static public const USA:int = 9;
		static public const HUMANITARIAN:int = 10;
		static public const NO_MOON:int = 11;
		static public const FORCE:int = 12;
		static public const PENTAFORCE:int = 13;
		static public const BOSSMULTI:int = 14;
		
		static private var unlocked:Vector.<Boolean>;
		static private var stack:Vector.<int>;
		
		public function Medals() { }
		
		static private var initiated:Boolean = false;
		static private var count:int = 0;
		
	    private static var SO:SharedObject;
		
		static private var mstrings:Array = [
					   "YOU'RE A WINNER!",
					   "YOU'RE A REAL WINNER",
					   "AL GORE WOULD BE PROUD",
					   "SIDEKICK",
					   "HIROSHIMA",
					   "C-C-C-C-COMBO!",
					   "MY EARS!",
					   "C-C-C-C-COMBO BREAKER!",
					   "STRAGGLER",
					   "USA! USA!",
					   "HUMANITARIAN",
					   "THAT'S NO MOON",
					   "USE THE FORCE!",
					   "PENTAFORCE",
					   "DOUBLE WHAMMY"
					  ];
		static private var mofuns:Array = [
					   "you_re_a_winner_",
					   "you_re_a_real_winner",
					   "al_gore_would_be_proud",
					   "sidekick",
					   "hiroshima",
					   "c_c_c_c_combo_",
					   "my_ears_",
					   "c_c_c_c_combo_breaker_",
					   "straggler",
					   "usa_usa_",
					   "humanitarian",
					   "that_s_no_moon",
					   "use_the_force_",
					   "pentaforce",
					   "double_whammy"
					  ];
		
		static public function init(){
			if(!initiated){
				initiated = true;
				
				SO = SharedObject.getLocal("tetraform-medals-0.1.5");
				
				if(SO.data.saved != undefined){
					unlocked = new Vector.<Boolean>();
					SO.data.saved = true;
					for(var i:int = 0; i<15; i++){
						unlocked.push(SO.data.unlocked[i]);
						if(unlocked[i]){
							NewgroundsAPI.unlockMedalByName(mstrings[i]);
							/*if (MovieClip(ROOT).kongregate.connected ){
								MovieClip(ROOT).kongregate.stats.submit ("stat"+i, 1); 
							}*/
						}
					}
				} else {
					unlocked = new Vector.<Boolean>();
					for(var i:int = 0; i<15; i++){
						unlocked.push(false);
					}
					SO.data.saved = true;
					SO.data.unlocked = new Vector.<Boolean>();
					SO.data.unlocked = unlocked;
				}
				
				stack = new Vector.<int>();
				ROOT.addEventListener(Event.ENTER_FRAME, updateee);
				count = 0;
			}
		}
		
		static public function updateee(e:Event){
			if(!initiated) return;
			count++;
			if(count > 1500){
				for(var i:int = 0; i<15; i++){
					if(unlocked[i]){
						NewgroundsAPI.unlockMedalByName(mstrings[i]);
					}
				}
				count = 0;
			}
		}
		
		static public function unlock(i:int){
			if(!initiated) return;
			if(!unlocked[i]){
				unlocked[i] = true;
				trace("Medal Get! "+
					  mstrings[i]);
				
				/*if (kongregate.connected ){
					kongregate.stats.submit ("stat"+i, 1); 
				}*/
				//stack.push(i);
				SO.data.unlocked = unlocked;
				NewgroundsAPI.unlockMedalByName(mstrings[i]);
				
				/*if (MovieClip(ROOT).kongregate.connected ){
					MovieClip(ROOT).kongregate.stats.submit ("stat"+i, 1); 
				}*/
				
				//AchievementLoaderAS3.getAPI().success(mofuns[i]);
				
				count = 0;
			}
		}
	
		
	}
	
}