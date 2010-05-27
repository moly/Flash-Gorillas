﻿package dee.moly.gamestates {
	
	import dee.moly.gameobjects.Banana;
	import dee.moly.gameobjects.CharChain;
	import dee.moly.gameobjects.CityScape;
	import dee.moly.gameobjects.Gorilla;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import dee.moly.gameobjects.Sun;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * the main level with the gorillas and the buildings and such
	 * @author moly
	 */
	
	public class GameStateLevel extends GameState{
		
		// the game setings for this round
		private var gameSettings:GameSettings;
		
		// the cityscape in the background
		private var cityScape:CityScape;
		
		// two gorillas
		private var gorilla1:Gorilla;
		private var gorilla2:Gorilla;
		
		// names
		private var player1NameText:CharChain;
		private var player2NameText:CharChain;
		
		// score
		private var scoreText:CharChain;
		
		// angle/velocity prompts
		private var angleText:CharChain;
		private var angleInput:CharChain;
		private var velocityText:CharChain;
		private var velocityInput:CharChain;
		private var angle:Number;
		private var velocity:Point;
		
		// the input to add to
		private var currentInput:CharChain;
		
		// which players turn it is
		private var playerTurn:int;
		
		// the projectile
		private var banana:Banana;
		
		// a smiley sun
		private var sun:Sun;
		
		public function GameStateLevel(gameSettings:GameSettings) {
			
			this.gameSettings = gameSettings;
			
			gorilla1 = new Gorilla();
			gorilla2 = new Gorilla();
			
			player1NameText = new CharChain(gameSettings.player1Name, 0, 3);
			player2NameText = new CharChain(gameSettings.player2Name, Main.SCREEN_WIDTH - (gameSettings.player2Name.length * 8) - 8, 3);
			
			scoreText = new CharChain("0>Score<0", 0, Main.SCREEN_HEIGHT - 38);
			scoreText.centre();
			
			angleText = new CharChain("Angle:", 0, 18);
			angleInput = new CharChain("", 0, 18, CharChain.SOLID, CharChain.NUMERIC);
			
			velocityText = new CharChain("Velocity:", 0, 33);
			velocityInput = new CharChain("", 0, 33, CharChain.SOLID, CharChain.NUMERIC);
			
			sun = new Sun();
			
			banana = new Banana();
			
			cityScape = new CityScape();
			
			playerTurn = 1;
			
			newGame();
			
		}
		
		// reset everything, build a new skyline etc
		private function newGame():void {
			
			sun.reset();
			cityScape.buildSkyline();
			cityScape.placeGorillas(gorilla1, gorilla2);
			angleText.x = (playerTurn - 1) * 520;
			currentInput = angleInput;
			currentInput.x = ((playerTurn - 1) * 520) + 50; 
			
		}
		
		// move the banana around
		override public function update(elapsed:Number):void {
			
			if (banana.inMotion == false)
				return;
				
			banana.update(elapsed);
				
		}
		
		// draw everything to the screen
		override public function draw(canvas:BitmapData):void {
			
			canvas.fillRect(canvas.rect, 0xFF0000AD);
			cityScape.draw(canvas);
			player1NameText.draw(canvas);
			player2NameText.draw(canvas);
			canvas.fillRect(new Rectangle(scoreText.x - 3, scoreText.y - 2, (scoreText.length * 8) + 5, 14), 0xFF0000AD);
			scoreText.draw(canvas);
			gorilla1.draw(canvas);
			gorilla2.draw(canvas);
			
			if (!banana.inMotion) {
				angleText.draw(canvas);
				angleInput.draw(canvas);
				if(currentInput == velocityInput){
					velocityText.draw(canvas);
					velocityInput.draw(canvas);
				}
			}else {
				banana.draw(canvas);
			}
			
			sun.draw(canvas);
			
		}
		
		// put the input into the right places
		override public function onKeyDown(e:KeyboardEvent):void {
			
			if (banana.inMotion == true || currentInput.text == "")
				return;
			
			currentInput.addChar(e.charCode);
			
			if (e.keyCode == Keyboard.ENTER)
				nextStep();
				
			if (e.keyCode == Keyboard.BACKSPACE)
				currentInput.backspace();
			
		}
		
		// move on to the next step of the level
		private function nextStep():void {
			
			if (currentInput == angleInput) {
				angleInput.removeCursor();
				currentInput = velocityInput;
				var disp:int = 74;
			}
			
			else if (currentInput == velocityInput) {
				
				var angle:int = int(angleInput.text);
				var velocity:int = int(velocityInput.text);
				
				if (playerTurn == 1){
					var startPoint:Point = new Point(gorilla1.x, gorilla1.y - 7);
				}
				
				if (playerTurn == 2){
					angle = 180 - angle;
					startPoint = new Point(gorilla2.x + 25, gorilla2.y - 7);
				}
				
				banana.doShot(angle, velocity, gameSettings.gravity, cityScape.windSpeed, startPoint);
				playerTurn == 1 ? gorilla1.raiseLeftArm() : gorilla2.raiseRightArm();
				
				currentInput = angleInput;
				angleInput.showCursor();
				
				playerTurn = 3 - playerTurn;
				angleInput.text = "";
				velocityInput.text = "";
				disp = 50;
				
			}
			
			angleText.x = 520 * (playerTurn - 1);
			velocityText.x = 520 * (playerTurn - 1);
			currentInput.x = (520 * (playerTurn - 1)) + disp;
						
		}
		
	}

}