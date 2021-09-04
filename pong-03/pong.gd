extends Node2D

#states
enum GAME_STATE {MENU, SERVE, PLAY}
var isPlayerServe = true

#current state
var currentGameState = GAME_STATE.MENU

#screen values
onready var screenWidth = get_tree().get_root().size.x
onready var screenHeight = get_tree().get_root().size.y
onready var halfScreenHeight = screenHeight / 2
onready var halfScreenWidth = screenWidth / 2

#paddle variables
var paddleColor = Color.white
var paddleSize = Vector2(10.0, 100.0)
var halfPaddleHeight = paddleSize.y / 2
var paddlePadding = 10.0

# ball variables
var ballRadius = 10.0
var ballColor = Color.white

#font variables
var font = DynamicFont.new()
var robotoFile = load("Roboto-Light.ttf")
var fontSize = 24
var halfWidthFont
var heightFont
var stringValue = "Press the space bar to start the game"

#ball variable
onready var startingBallPosition = Vector2(halfScreenWidth, halfScreenHeight)
onready var ballPosition = startingBallPosition

#player paddle
onready var playerPosition = Vector2(paddlePadding, halfScreenHeight - halfPaddleHeight)
onready var playerRectangle = Rect2(playerPosition, paddleSize)

#AI paddle
onready var aiPosition = Vector2(screenWidth - (paddlePadding + paddleSize.x), halfScreenHeight - halfPaddleHeight)
onready var aiRectangle = Rect2(aiPosition , paddleSize)

#string variable
var stringPosition

#delta key
const RESET_DELTA_KEY = 0.0
const MAX_KEY_TIME = 0.3
var deltaKeyPress = RESET_DELTA_KEY

#ball speed
var startingSpeed = Vector2(400.0,0.0)
var ballSpeed = startingSpeed

var playerSpeed = 200.0

#scoring
var playerScore = 0
var playerScoreText = playerScore as String
var playerTextHalfWidth
var playerScorePosition

var aiScore = 0
var aiScoreText = aiScore as String
var aiTextHalfWidth
var aiScorePosition

const MAX_SCORE = 3
var isPlayerWin

func _ready() -> void:
	print(get_tree().get_root().size)
	font.font_data = robotoFile
	font.size = fontSize 
	halfWidthFont = font.get_string_size(stringValue).x / 2
	heightFont = font.get_height()
	stringPosition = Vector2(halfScreenWidth - halfWidthFont, heightFont)
	
	playerTextHalfWidth = font.get_string_size(playerScoreText).x / 2
	playerScorePosition = Vector2(halfScreenWidth - (halfScreenWidth / 2) - playerTextHalfWidth, heightFont + 50)
	aiTextHalfWidth = font.get_string_size(aiScoreText).x / 2
	aiScorePosition = Vector2(halfScreenWidth + (halfScreenWidth / 2) - aiTextHalfWidth, heightFont + 50)

func _physics_process(delta: float) -> void:
	deltaKeyPress += delta
	match currentGameState:
		GAME_STATE.MENU:
			if (isPlayerWin == true):
				changeString("Player wins! Press the space bar to start another round.")
			elif (isPlayerWin == false):
				changeString("AI wins! Press the space bar to start another round.")
				
			if (Input.is_key_pressed(KEY_SPACE) and deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				playerScoreText = playerScore as String
				aiScoreText = aiScore as String
			update()
			
		GAME_STATE.SERVE:
			setStartingPosition()
			
			if (MAX_SCORE == playerScore):
				currentGameState = GAME_STATE.MENU
				playerScore = 0
				aiScore = 0
				isPlayerWin = true
			elif (MAX_SCORE == aiScore):
				currentGameState = GAME_STATE.MENU
				playerScore = 0
				aiScore = 0
				isPlayerWin = false
			
			if isPlayerServe:
				ballSpeed = startingSpeed
				changeString("Player's Serve, press space bar to start")
			else:
				ballSpeed = -startingSpeed
				changeString("AI's Serve, press space bar to start")
				
			if (Input.is_key_pressed(KEY_SPACE) and deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.PLAY
				deltaKeyPress = RESET_DELTA_KEY
			update()
			
		GAME_STATE.PLAY:
			changeString("Play")
			if (Input.is_key_pressed(KEY_SPACE) and deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
			
			ballPosition += ballSpeed * delta
			if ballPosition.x <= 0:
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				isPlayerServe = true
				aiScore += 1
				aiScoreText = aiScore as String
			
			if ballPosition.x >= screenWidth:
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				isPlayerServe = false
				playerScore += 1
				playerScoreText = playerScore as String
			
			if ballPosition.y - ballRadius <= 0.0:
				ballSpeed.y = -ballSpeed.y
			if ballPosition.y + ballRadius >= screenHeight:
				ballSpeed.y = -ballSpeed.y 
			
			if (ballPosition.x - ballRadius >= playerPosition.x and 
			ballPosition.x - ballRadius <= playerPosition.x + paddleSize.x):
				
				var paddleDivide = paddleSize.y / 3
				
				if (ballPosition.y >= playerPosition.y and ballPosition.y <= playerPosition.y + paddleDivide):
					var tempBall = Vector2(-ballSpeed.x, -400.0)
					ballSpeed = tempBall
					
				elif (ballPosition.y >= playerPosition.y and ballPosition.y <= playerPosition.y + paddleDivide * 2):
					var tempBall = Vector2(-ballSpeed.x, 0.0)
					ballSpeed = tempBall
					
				elif (ballPosition.y >= playerPosition.y and ballPosition.y <= playerPosition.y + paddleDivide * 3):
					var tempBall = Vector2(-ballSpeed.x, 400.0)
					ballSpeed = tempBall
				
			if (ballPosition.x + ballRadius >= aiPosition.x and ballPosition.x + ballRadius <= aiPosition.x + paddleSize.x):
				
				var paddleDivide = paddleSize.y / 3
				
				if (ballPosition.y >= aiPosition.y and ballPosition.y <= aiPosition.y + paddleDivide):
					var tempBall = Vector2(-ballSpeed.x, -400.0)
					ballSpeed = -ballSpeed
					
				elif (ballPosition.y >= aiPosition.y and ballPosition.y <= aiPosition.y + paddleDivide * 2):
					var tempBall = Vector2(-ballSpeed.x, 0.0)
					ballSpeed = -ballSpeed
					
				elif (ballPosition.y >= aiPosition.y and ballPosition.y <= aiPosition.y + paddleDivide * 3):
					var tempBall = Vector2(-ballSpeed.x, 400.0)
					ballSpeed = -ballSpeed

			if (Input.is_key_pressed(KEY_W)):
				playerPosition.y += -playerSpeed * delta
				playerPosition.y = clamp(playerPosition.y, 0.0, screenHeight - paddleSize.y)
				playerRectangle = Rect2(playerPosition, paddleSize)
			if (Input.is_key_pressed(KEY_S)):
				playerPosition.y += playerSpeed * delta
				playerPosition.y = clamp(playerPosition.y, 0.0, screenHeight - paddleSize.y)
				playerRectangle = Rect2(playerPosition, paddleSize)
			
			#aiPosition.y = ballPosition.y - paddleSize.y / 2
			if ballPosition.y > aiPosition.y + (paddleSize.y / 2 + 10):
				aiPosition.y += 250 * delta
			if ballPosition.y < aiPosition.y + (paddleSize.y / 2 - 10):
				aiPosition.y -= 250 * delta
				
			aiPosition.y = clamp(aiPosition.y, 0.0, screenHeight - paddleSize.y)
			aiRectangle = Rect2(aiPosition, paddleSize)
			
			update()

func _draw() -> void:
	#draw ball
	draw_circle(ballPosition, ballRadius, ballColor)
	# draw player paddle
	draw_rect(playerRectangle, paddleColor)
	# draw AI paddle
	draw_rect(aiRectangle, paddleColor)
	#draw text to screen
	draw_string(font, stringPosition, stringValue)
	# Scores
	draw_string(font, playerScorePosition, playerScoreText)
	draw_string(font, aiScorePosition, aiScoreText)
	
func setStartingPosition():
	aiPosition = Vector2(screenWidth - (paddlePadding + paddleSize.x),
	halfScreenHeight - halfPaddleHeight)
	aiRectangle = Rect2(aiPosition, paddleSize)
	
	playerPosition = Vector2(paddlePadding, halfScreenHeight - halfPaddleHeight)
	playerRectangle = Rect2(playerPosition, paddleSize)
	
	ballPosition = startingBallPosition
	
func changeString(string):
		stringValue = string
		halfWidthFont = font.get_string_size(stringValue).x / 2
		stringPosition = Vector2(halfScreenWidth - halfWidthFont, heightFont)
		
