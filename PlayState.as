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
	
	public class PlayState extends FlxState
	{
		//Set the source for the map tiles and level layout
		[Embed(source = "images/map_tiles.png")] private var mapTiles:Class;
		[Embed(source = "map_data.txt", mimeType = "application/octet-stream")] private var map:Class;
		
		//set the source of the hit sounds
		[Embed(source = "sounds/hit1.mp3")] private var hit1Snd:Class;
		[Embed(source = "sounds/hit2.mp3")] private var hit2Snd:Class;
		
		//Set the source of the song
		[Embed(source = "sounds/undiscovered_oceans.mp3")] private var bgMusic:Class;
		
		//Define variables for the map, player, enemies and weapons
		private var level:FlxTilemap, player:Player, enemies:FlxGroup = new FlxGroup(), weapon:FlxGroup = new FlxGroup();
		
		//define variables for the enemy counter and timer
		private var enemyCount:int = 1, newEnemyTimer:FlxDelay = new FlxDelay(60000);
		
		//define variables for the weapon timer
		private var weaponSpawnTimer:FlxDelay = new FlxDelay(30000);
		
		//define variables for score, score text and health text
		private var score:int = 0, scoreText:FlxText, healthText:FlxText;
		
		//define variables for spawn timer
		private var spawnInterval:int = 5000;
		private var enemySpawnTimer:FlxDelay = new FlxDelay(spawnInterval);
		
		override public function create():void 
		{
			//Set the background color
			FlxG.bgColor = 0xff888888;
			
			//Create and add the level
			level = new FlxTilemap();
			level.loadMap(new map, mapTiles, 32, 32);
			add(level);
			
			//Create and add the player
			player = new Player(500, 765);
			add(player);
			
			//Add the enemies and weapons groups so they can be created
			add(enemies);
			add(weapon);
			
			//Make the camera follow the player
			FlxG.camera.width = 400;
			FlxG.camera.height = 300;
			FlxG.camera.setBounds(0, 0, FlxG.width, FlxG.height);
			FlxG.camera.follow(player);
			
			//Create the score text
			scoreText = new FlxText(8, 8, 150, "Score: " + score);
			scoreText.setFormat(null, 15);
			//Set the scrollfactor to 0 so the text will always be visible on the screen
			scoreText.scrollFactor.x = 0;
			scoreText.scrollFactor.y = 0;
			//Add the scrore text as last so it's on top of the sprites
			add(scoreText);
			
			//Create the health text
			healthText = new FlxText(8, 28, 150, "Health: " + player.health);
			healthText.setFormat(null, 15);
			//Set the scrollfactor to 0 so the text will always be visible on the screen
			healthText.scrollFactor.x = 0;
			healthText.scrollFactor.y = 0;
			//add the health text as last so it's on top of all sprites
			add(healthText);
			
			//Start the timers
			enemySpawnTimer.start();
			newEnemyTimer.start();
			weaponSpawnTimer.start();
			
			//play the music
			FlxG.playMusic(bgMusic, 0.4);
		}
		
		override public function update():void 
		{
			super.update();
			
			//Check if anything collides with the level map and prevents them from moving through the map tiles
			levelCollide();
			
			//execute the function for every enemy in the game
			enemies.members.forEach(giveEnemyData);
			
			//Check if certain objects overlap each other
			checkOverlap();
			
			//Add one to the enemy counter when the timer has expired so that that a new enemy type may spawn
			if (newEnemyTimer.hasExpired)
			{
				if (enemyCount < 3)
				{
					enemyCount++;
				}
				
				newEnemyTimer = new FlxDelay(60000);
				newEnemyTimer.start();
			}
			
			//When the spawn time has expired...
			if (enemySpawnTimer.hasExpired)
			{
				//...Add an enemy in the level
				enemies.add(new Enemy((FlxG.random() * (FlxG.width - 128)) + 64, 180, FlxG.random() * enemyCount));
				
				//Reset the spawn timer
				resetSpawnTime();
			}
			
			//spawn a random weapon when the timer has expired
			if (weaponSpawnTimer.hasExpired)
			{
				weapon.add(new Weapons((FlxG.random() * (FlxG.width - 128)) + 64, 180, FlxG.random() * 2));
				
				//reset the timer
				weaponSpawnTimer = new FlxDelay(30000);
				weaponSpawnTimer.start();
			}
			
			//Execute the endGame function when the player has no more health
			if (player.health <= 0)
			{
				endGame();
			}
		}
		
		private function levelCollide():void
		{
			//Check if something collides with the level and prevents them from walking through the tiles
			FlxG.collide(level, player);
			FlxG.collide(level, enemies);
			FlxG.collide(level, weapon);
		}
		
		private function checkOverlap():void
		{
			//Check if the player and enemies overlap each other
			FlxG.overlap(player, enemies, playEnemAtt);
			FlxG.overlap(player, weapon, playWeaponPick);
		}
		
		private function giveEnemyData(element:Enemy, index:int, array:Array):void
		{
			//check if the enemy object isn't empty, undefined or null
			if (element != null)
			{
				//Pass the player's position to the enemy
				element.getData(player.x, player.y, player.width, player.height);
			}
		}
		
		private function playEnemAtt(obj1:Player, obj2:Enemy):void
		{
			//Check if the player and enemy are really colliding by pixel
			//This function has no callback function ability, so that's why the check "has to be done" twice
			if (FlxCollision.pixelPerfectCheck(obj1, obj2))
			{
				//if the player is attacking
				//if (obj1.isAttacking && FlxG.keys.justPressed("SPACE") && ( (obj1.facing == FlxObject.RIGHT && obj2.x > obj1.x + (obj1.width / 2)) || (obj1.facing == FlxObject.LEFT && obj2.x < obj1.x + (obj1.width / 2)) ))
				if (obj1.isAttacking && FlxG.keys.justPressed("SPACE"))
				{
					//Reduce the health of the enemy and player's weapon
					obj2.substractHealth(obj1.attackDamage);
					obj1.weaponHealth -= 1;
					
					//update the score counter and text when the enemy is killed
					if (obj2.currentHealth() <= 0)
					{
						obj2.kill();
						
						score++;
						scoreText.text = "Score: " + score;
					}
					
					//play the hit sound
					FlxG.play(hit1Snd);
				}
				else if(obj2.isAttacking) //Else if the enemy is attacking
				{
					//Reduce the player's health and update the health text
					obj1.health -= obj2.damage();
					healthText.text = "Health: " + obj1.health;
					
					//play the hit sound
					FlxG.play(hit2Snd);
				}
			}
		}
		
		private function playWeaponPick(obj1:Player, obj2:Weapons):void
		{
			//if the down button is pressed, the weapon is picked up
			if (FlxG.keys.justPressed("DOWN"))
			{
				//set the player's weapon to the picked up weapon so we know the player is using a weapon
				obj1.weapon = obj2.name();
				//set the health of the weapon
				obj1.weaponHealth = obj2.durability();
				//set the damage of the weapon
				obj1.attackDamage = obj2.damage();
				
				//destroy the weapon since we won't use it anymore
				obj2.kill();
			}
		}
		
		private function resetSpawnTime():void
		{
			//reset the spawn timer
			enemySpawnTimer = new FlxDelay(spawnInterval);
			
			//lower the new spawn timer by 0.98
			spawnInterval *= 0.98;
			
			//make sure that enemies don't spawn too fast
			if (spawnInterval < 250)
			{
				spawnInterval = 250;
			}
			
			//Start the spawn timer
			enemySpawnTimer.start();
		}
		
		private function endGame():void
		{
			if (player.alive)
			{
				//Show the game over text only once, which is right before the player is killed
				var endText:FlxText = new FlxText(
													FlxG.camera.scroll.x, 
													FlxG.camera.scroll.y + 100,
													400, 
													"Game Over!\n\nPress enter to try again"
												);
				endText.setFormat(null, 15, 0xffffff, "center");
				add(endText);
				
				//kill the player
				player.kill();
			}
			
			//Restart the game if the player is dead and the enter key is pressed
			if (!player.alive && FlxG.keys.justPressed("ENTER"))
			{
				//Fade out before resetting the state
				FlxG.camera.fade(0x00000000, 1, resetState);
			}
		}
		
		private function resetState():void
		{
			//Reset the PlayState
			FlxG.resetState();
		}
	}
}