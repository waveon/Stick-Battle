package  
{
	/**
	 * ...
	 * @author Mickey Beijer
	 */
	
	//Import the flixel package
	import org.flixel.*;
	
	public class Weapons extends FlxSprite
	{
		//Set the source of the weapon sprites
		[Embed(source = "images/bat.png")] private var batImg:Class;
		[Embed(source = "images/sword.png")] private var swordImg:Class;
		
		//create an array to store the known weapons
		private var weaponsData:Array = new Array(2);
		
		//create a variable to store the chosen weapon type
		private var weaponType:int;
		
		public function Weapons(X:int, Y:int, type:int) 
		{
			//Set the initial position of the weapon
			super(X, Y);
			
			//create the weapons
			createWeapons();
			
			//store the chosen weapon type
			this.weaponType = type;
			
			//load the sprite of the weapon
			this.loadGraphic(this.weaponsData[this.weaponType][3], false, true, 24, 24);
			
			//create the falling speed of the weapon so it falls to the ground
			this.maxVelocity.y = 250;
			this.acceleration.y = 400;
		}
		
		private function createWeapons():void
		{
			//store the data of each weapon in the array
			//0 = weapon name
			//1 = weapon's durability
			//2 = weapon damage
			//3 = weapon image class
			
			this.weaponsData[0] = new Array(4);
			this.weaponsData[0][0] = "bat";
			this.weaponsData[0][1] = 25;
			this.weaponsData[0][2] = 2;
			this.weaponsData[0][3] = batImg;
			
			this.weaponsData[1] = new Array(4);
			this.weaponsData[1][0] = "sword";
			this.weaponsData[1][1] = 50;
			this.weaponsData[1][2] = 4;
			this.weaponsData[1][3] = swordImg;
		}
		
		public function name():String
		{
			return this.weaponsData[this.weaponType][0];
		}
		
		public function durability():int
		{
			return this.weaponsData[this.weaponType][1];
		}
		
		public function damage():int
		{
			return this.weaponsData[this.weaponType][2];
		}
	}
}