package  
{
	/**
	 * ...
	 * @author Mickey Beijer
	 */
	
	//Import the flixel package
	import org.flixel.*;
	//Import the photonstorm power tools plugin
	import org.flixel.plugin.photonstorm.*;
	
	public class Player extends FlxSprite
	{
		//Set the source of the player sprite sheet
		[Embed(source = "images/player.png")] private var playerImg:Class;
		
		//Create a public variable to check if the player is attacking
		public var isAttacking:Boolean = false;
		//Create a public variable to check which weapon the player is using
		public var weapon:String = "fists";
		//create a public variable to check the weapon's health
		public var weaponHealth:int = 0;
		//create a public variable that stores how much damage the player can deal
		public var attackDamage:int = 1;
		
		//create variable to check which attack animation has to be performed
		private var attAnimCounter:uint = 0;
		//create variable for the delay before the attack animation resets
		private var attAnimDelay:FlxDelay = new FlxDelay(0);
		//Create a variable that delays the player's ability to attack
		private var attackDelay:FlxDelay = new FlxDelay(200);
		
		public function Player(X:int, Y:int) 
		{
			//Set the initial position of the player
			super(X, Y);
			
			//Load the sprite sheet of the player
			this.loadGraphic(playerImg, true, true, 80, 64);
			
			//Shrink the actual size of the object since the sprites aren't actually 80px wide
			this.width = 25;
			this.offset.x = 27;
			
			//create animations from the sprite sheet
			createAnimations();
			
			//Play an default animation when the game starts
			this.play(weapon + "_idle");
			
			//Add the FlxControl plugin
			if (FlxG.getPlugin(FlxControl) == null) 
			{
				FlxG.addPlugin(new FlxControl);
			}
			
			//Create a controler for player 1, which is the player itself
			FlxControl.create(this, FlxControlHandler.MOVEMENT_ACCELERATES, FlxControlHandler.STOPPING_DECELERATES, 1, true, false);
			//Set which arrows keys can be used to move, which is left and right
			FlxControl.player1.setCursorControl(false, false, true, true);
			//Let the player jump when the up arrow is pressed, this is handled differently than just moving up
			FlxControl.player1.setJumpButton("UP", FlxControlHandler.KEYMODE_PRESSED, 300, FlxObject.FLOOR, 250, 200);
			//Set the speed of the player's movement
			FlxControl.player1.setMovementSpeed(800, 0, 200, 280, 800, 0);
			//Set the gravity so that the player always moves down
			FlxControl.player1.setGravity(0, 400);
			
			//Set the player's health to 100
			this.health = 100;
			
			//Start the attack delay
			this.attackDelay.start();
		}
		
		private function createAnimations():void
		{
			//create standard player animations
			this.addAnimation("fists_idle", [0], 0, false);
			this.addAnimation("fists_run", [0, 1, 2], 10, true);
			this.addAnimation("fists_jump", [3], 0, false);
			this.addAnimation("fists_attack1", [4, 5, 4, 0], 10, false);
			this.addAnimation("fists_attack2", [6, 7, 6, 0], 10, false);
			this.addAnimation("fists_airKick", [8, 9, 3], 8, false);
			
			//create player animations with bat
			this.addAnimation("bat_idle", [10], 0, false);
			this.addAnimation("bat_run", [10, 11, 12], 10, true);
			this.addAnimation("bat_jump", [13], 0, false);
			this.addAnimation("bat_attack", [14, 15, 10], 7, false);
			this.addAnimation("bat_airKick", [18, 19, 13], 9, false);
			
			//create player animations with sword
			this.addAnimation("sword_idle", [20], 0, false);
			this.addAnimation("sword_run", [20, 21, 22], 10, true);
			this.addAnimation("sword_jump", [23], 0, false);
			this.addAnimation("sword_attack", [24, 25, 20], 7, false);
			this.addAnimation("sword_airKick", [28, 29, 23], 9, false);
		}
		
		override public function update():void 
		{
			super.update();
			
			//switch back to fists as weapon when the weapon is broken
			if (this.weaponHealth <= 0)
			{
				this.weapon = "fists";
				this.weaponHealth = 0;
				this.attackDamage = 1;
			}
			
			//check which animation has to be played
			this.checkAnimations();
		}
		
		private function checkAnimations():void
		{
			//check if the player is attacking
			this.attackAnim();
			
			//When the player is standing on the ground...
			if (this.isTouching(FlxObject.FLOOR) && !FlxG.keys.pressed("UP"))
			{
				//Reset the height
				//See the else part of this if-else statement for explanation
				this.height = 64;
				
				//Move the player a bit up when it lands after a jump
				//This prevents the player from getting stuck in the ground
				if (this._curAnim.name == weapon + "_jump" || this._curAnim.name == weapon + "_airKick")
				{
					this.y -= 24;
				}
				
				//Play the correct ground animation
				this.floorAnim();
			}
			//Else if the player is jumping...
			else if (FlxG.keys.pressed("UP"))
			{
				//Change the height since the jumping sprite is smaller, 
				//this way the hitbox is smaller and no "ghost collision" will occur
				this.height = 40;
				
				//Play the correct jump animation
				this.jumpAnim();
			}
		}
		
		private function attackAnim():void
		{
			//If the player is pressing the space bar and the attack delay has expired...
			if (FlxG.keys.justPressed("SPACE") && attackDelay.hasExpired)
			{
				//The player performs an attack, so set the variable on false
				this.isAttacking = true;
				
				//add one to the counter since an attack animation has to be played
				this.attAnimCounter++;
				
				//set the counter to the first animation when it's over the maximum available attack animations
				if (this.attAnimCounter > 2)
				{
					this.attAnimCounter = 1;
				}
				
				//Set the timer before the attack animation is reset to the first one
				this.attAnimDelay = new FlxDelay(300);
				this.attAnimDelay.start();
				
				//Set the delay for when the player can attack
				this.attackDelay = new FlxDelay(100);
				this.attackDelay.start();
			}
			
			//Reset the attack animation when the timer has expired
			if (this.attAnimDelay.hasExpired)
			{
				this.isAttacking = false;
				this.attAnimCounter = 0;
			}
		}
		
		private function floorAnim():void
		{
			if (this.isAttacking)
			{
				//if the player is attacking, play the attack animation
				if (this.weapon == "fists")
				{
					this.play(weapon + "_attack" + this.attAnimCounter);
				}
				else
				{
					this.play(weapon + "_attack");
				}
			}
			else if (this.acceleration.x == 0)
			{
				//if the player is standing still, play the walking animation
				this.play(weapon + "_idle");
			}
			else
			{
				//Else the player is walking, so play the walking animation
				this.play(weapon + "_run");
			}
		}
		
		private function jumpAnim():void
		{
			if (this.isAttacking)
			{
				//if the player is attacking, play the attack animation
				this.play(weapon + "_airKick");
			}
			else
			{
				//Else the player is not attacking, play the jump animation
				this.play(weapon + "_jump");
			}
		}
	}
}