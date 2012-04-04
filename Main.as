package 
{
	/**
	 * ...
	 * @author Mickey Beijer
	 */
	
	//Import the flixel package
	import org.flixel.*;
	
	//Set the background color and dimension of the screen
	[SWF(width = "800", height = "600", backgroundColor = "#888888")]
	
	public class Main extends FlxGame 
	{
		public function Main() 
		{
			//Set the size of the level with a zoom level of 2x
			//Go to the title screen
			super(960, 928, Title, 2);
		}
	}
}