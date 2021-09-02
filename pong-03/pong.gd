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
var stringValue = "Hello World!"

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

func _ready() -> void:
	print(get_tree().get_root().size)
	font.font_data = robotoFile
	font.size = fontSize 
	halfWidthFont = font.get_string_size(stringValue).x / 2
	heightFont = font.get_height()
	stringPosition = Vector2(halfScreenWidth - halfWidthFont, heightFont)

func _physics_process(delta: float) -> void:
	deltaKeyPress += delta
	match currentGameState:
		GAME_STATE.MENU:
			changeString("Menu")
			if (Input.is_key_pressed(KEY_SPACE) and deltaKeyPress > MAX_KEY_TIME):
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
			update()
		GAME_STATE.SERVE:
			ballPosition = startingBallPosition
			changeString("Serve!")
			
			if isPlayerServe:
				ballSpeed = startingSpeed
				changeString("Player's Serve")
			else:
				ballSpeed = -startingSpeed
				changeString("AI's Serve")
				
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
			
			if ballPosition.x >= screenWidth:
				currentGameState = GAME_STATE.SERVE
				deltaKeyPress = RESET_DELTA_KEY
				isPlayerServe = false
			
			
			update()

func _draw() -> void:
	setStartingPosition()
	
func setStartingPosition():
	#draw ball
	draw_circle(ballPosition, ballRadius, ballColor)
	# draw player paddle
	draw_rect(playerRectangle, paddleColor)
	# draw AI paddle
	draw_rect(aiRectangle, paddleColor)
	#draw text to screen
	draw_string(font, stringPosition, stringValue)
	
func changeString(string):
		stringValue = string
		halfWidthFont = font.get_string_size(stringValue).x / 2
		stringPosition = Vector2(halfScreenWidth - halfWidthFont, heightFont)
		
