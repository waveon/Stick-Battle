package  
{
	/**
	 * ...
	 * @author Mickey Beijer
	 */
	
	//Import the flixel package
	import org.flixel.*;
	//import the photonstorm power tools plug-in
	import org.flixel.plugin.photonstorm.*;
	 
	public class Enemy extends FlxSprite
	{
		//Set the source of the player sprite sheet
		[Embed(source = "images/enemyFist.png")] private var enemyFistImg:Class;
		[Embed(source = "images/enemyBat.png")] private var enemyBatImg:Class;
		[Embed(source = "images/enemySword.png")] private var enemySwordImg:Class;
		
		//set a public variable for easy use of the maximum speed
		public var maxSpeed:int;
		
		//set public variable to check if the enemy is attacking
		public var isAttacking:Boolean = false;
		
		//Create an attack timer
		private var attackTimer:FlxDelay = new FlxDelay(0);
		
		//Create variables to store the player's data
		private var playerX:int, playerY:int, playerWidth:int, playerHeight:int
		
		//create variable to store what type of enemy is created
		private var type:int;
		
		//create an array to store the known enemies
		private var enemyData:Array = new Array(3);
		
		public function Enemy(X:int, Y:int, newType:int) 
		{
			//Set the initial position of the enemy
			super(X, Y);
			
			createEnemies();
			
			this.type = newType;
			
			//load the sprite sheet of the enemy
  			this.loadGraphic(this.enemyData[this.type][2], true, true, 80, 64);
			
			//Shrink the actual size of the object since the sprites aren't actually 32px wide
			this.width = 25;
			this.offset.x = 27;
			
			//create animations from the sprite sheet
			addAnimation("idle", [0], 0, false);
			addAnimation("run", [0, 1, 2], 10, true);
			addAnimation("attack", [0, 3, 4, 3], 8, true);
			
			//set the maximum moving and fall speed
			this.maxVelocity.x = 150;
			this.maxVelocity.y = 300;
			this.drag.x = this.maxVelocity.x * 4;
			//set the falling speed
			this.acceleration.y = this.maxVelocity.y;
			
			//set the maximum speed in the variable
			this.maxSpeed = this.maxVelocity.x * 4;
			
			//Play an default animation when the game starts
			this.play("run");
			
			//start the attack timer
			this.attackTimer.start();
		}
		
		private function createEnemies():void
		{
			//store the data of each enemy in the array
			//0 = Enemy health
			//1 = Enemy damage
			//2 = Enemy image class
			
			this.enemyData[0] = new Array(3);
			this.enemyData[0][0] = 5;
			this.enemyData[0][1] = 2;
			this.enemyData[0][2] = enemyFistImg;
			
			this.enemyData[1] = new Array(3);
			this.enemyData[1][0] = 10;
			this.enemyData[1][1] = 4;
			this.enemyData[1][2] = enemyBatImg;
			
			this.enemyData[2] = new Array(3);
			this.enemyData[2][0] = 20;
			this.enemyData[2][1] = 8;
			this.enemyData[2][2] = enemySwordImg;
		}
		
		override public function update():void 
		{
			super.update();
			
			//update the walking direction and animation
			this.updateDirection();
			
			//Let the enemy jump when it hits a wall
			if (this.isTouching(FlxObject.WALL) && this.isTouching(FlxObject.FLOOR))
			{
				this.velocity.y = -this.maxVelocity.y / 1.5;
			}
		}
		
		public function getData(playerX:int, playerY:int, playerWidth:int, playerHeight:int):void
		{
			//Save the player's data
			this.playerX = playerX;
			this.playerY = playerY;
			this.playerWidth = playerWidth;
			this.playerHeight = playerHeight;
		}
		
		public function substractHealth(damage:int):void
		{
			this.enemyData[this.type][0] -= damage;
		}
		
		public function currentHealth():int
		{
			return this.enemyData[this.type][0];
		}
		
		public function damage():int
		{
			return this.enemyData[this.type][1];
		}
		
		private function updateDirection():void
		{
			//calculate the X middle point of the player
			var playerMiddleX:int = this.playerX + (this.playerWidth / 2);
			
			
			//If the attack timer has expired and the enemy's distance is about the same height and close to the player...
			if  (
				  ( (this.x < playerMiddleX && this.x > (playerMiddleX - 55)) ||(this.x > playerMiddleX && this.x < (playerMiddleX + 30)) ) &&
				  this.y + this.height >= this.playerY + (3 * (this.playerHeight / 4)) && this.y + this.height <= this.playerY + this.playerHeight
				)
			{
				//the enemy stops moving
				this.acceleration.x = 0;
				
				//Play the attack animation
				this.play("attack");
				
				//Play the correct animation
				checkAttack();
			}
			else
			{
				//Else play the run animation
				this.play("run");
					
				//Make the enemy face and move to the player
				if (this.x > playerMiddleX)
				{
					this.acceleration.x = -this.maxSpeed;
					this.facing = LEFT;
				}
				else if (this.x < playerMiddleX)
				{
					this.acceleration.x = this.maxSpeed;
					this.facing = RIGHT;
				}
			}
		}
		
		private function checkAttack():void
		{
			
				//The attack timer has expired, so the enemy can attack
				if (this.attackTimer.hasExpired)
				{
					//the enemy is attacking
					this.isAttacking = true;
					
					//reset the attack timer
					this.attackTimer = new FlxDelay(1000);
					this.attackTimer.start();
				}
				else
				{
					//The enemy is not attacking
					this.isAttacking = false;
				}
		}
	}
}