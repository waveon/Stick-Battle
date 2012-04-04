package  
{
	/**
	 * ...
	 * @author Mickey Beijer
	 */
	
	//Import the flixel package
	import org.flixel.*;
	
	public class Title extends FlxState
	{
		//create variables for the texts
		public var startText:FlxText, authorText:FlxText, instructions:FlxText, version:FlxText, credits:FlxText;
		
		public function Title() 
		{
			//Show the title
			var startText:FlxText = new FlxText(8, 30, 400, "Stick Battle");
			startText.setFormat(null, 24, 0xffffff, "center");
			add(startText);
			
			//Show the author
			var authorText:FlxText = new FlxText(8, 65, 400, "A game by Mickey Beijer");
			authorText.setFormat(null, 8, 0xffffff, "center");
			add(authorText);
			
			//Show instructions
			var instructions:FlxText = new FlxText(8, 150, 400, "Left/Right = Move left and right\nDown = Pick up weapon\nUp = Jump\nSpace = Attack\n\nPress enter to start");
			instructions.setFormat(null, 12, 0xffffff, "center");
			add(instructions);
			
			//Show version
			var version:FlxText = new FlxText(8, 280, 400, "Version 1.0");
			version.setFormat(null, 7.5, 0xffffff, "left");
			add(version);
			
			//Show song credits
			var credits:FlxText = new FlxText(0, 270, 400, "music by\ndanosongs.com");
			credits.setFormat(null, 7.5, 0xffffff, "right");
			add(credits);
		}
		
		override public function update():void
		{
			super.update();
			
			if (FlxG.keys.justPressed("ENTER"))
			{
				//Fade out before switching to the playState
				FlxG.camera.fade(0x00000000, 1, changeState);
			}
		}
		
		private function changeState():void
		{
			//Switch to PlayState when enter has been pressed, thus starting the game
			FlxG.switchState(new PlayState());
		}
		
	}

}