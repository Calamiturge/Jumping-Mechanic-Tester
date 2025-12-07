extends Control

@onready var PlayerRef : PlayerCharacter = get_tree().get_first_node_in_group("Player") #Get reference to the player
@onready var SpeedInput : LineEdit = $Panel/Basic_Attributes/Speed/LineEdit
@onready var JumpInput : LineEdit = $Panel/Basic_Attributes/JumpPower/LineEdit
@onready var AirControlInput : LineEdit = $Panel/Basic_Attributes/AirControl/LineEdit
@onready var DurationJumpLifespanInput : LineEdit = $"Panel/Jumping_Options/Duration Jump Time/LineEdit"
@onready var GravPowerInput : LineEdit = $"Panel/Falling_Options/GravPower/LineEdit"
@onready var JumpSpeedCapInput : LineEdit = $"Panel/Jumping_Options/CapJumpSpeedValue/LineEdit"
@onready var FallSpeedCapInput : LineEdit = $Panel/Falling_Options/FallSpeedCap/LineEdit
@onready var FastFallInput : LineEdit = $"Panel/Falling_Options/FastFallSpeed/LineEdit"
@onready var LowGravJumpInput : LineEdit = $"Panel/Falling_Options/FastAscentPower/LineEdit"
@onready var InputBufferTimeInput : LineEdit = $Panel/Extra_Options/InputBufferTime/LineEdit

@onready var TopTeleLocation : Node2D = get_tree().get_first_node_in_group("TopTeleLoc")
@onready var MidTeleLocation : Node2D = get_tree().get_first_node_in_group("MidTeleLoc")
@onready var LeftTeleLocation : Node2D = get_tree().get_first_node_in_group("LeftTeleLoc")
@onready var LeftestTeleLocation : Node2D = get_tree().get_first_node_in_group("LeftestTeleLoc")
	
@onready var GameSpeedInput : LineEdit = $Panel2/VBoxContainer/GameSpeed/LineEdit

@onready var CalcX : Label = $Panel2/VBoxContainer/CalcX
@onready var CalcY : Label = $Panel2/VBoxContainer/CalcY
@onready var TrueX : Label = $Panel2/VBoxContainer/TrueX
@onready var TrueY : Label = $Panel2/VBoxContainer/TrueY

func _ready():

	
	# Buttons
	$"Panel/Basic_Attributes/Button".pressed.connect(ButtonPressed.bind(1)) #Basic Attributes
	$"Panel/Jumping_Options/Duration Jump Time/Button".pressed.connect(ButtonPressed.bind(2)) #Set Duration Jump Time
	$"Panel/Jumping_Options/CapJumpSpeedValue/Button".pressed.connect(ButtonPressed.bind(3)) #Set Jump Speed Cap
	$"Panel/Falling_Options/GravPower/Button".pressed.connect(ButtonPressed.bind(4)) #Set Gravity Power
	$"Panel/Falling_Options/FallSpeedCap/Button".pressed.connect(ButtonPressed.bind(5)) #Set Fall Speed Cap
	$"Panel/Falling_Options/FastFallSpeed/Button".pressed.connect(ButtonPressed.bind(6)) #Set FastFall Power
	$"Panel/Falling_Options/FastAscentPower/Button".pressed.connect(ButtonPressed.bind(7)) #Set Jump Weak Grav Power
	$Panel/Extra_Options/InputBufferTime/Button.pressed.connect(ButtonPressed.bind(8)) #set input buffer time
	$"Panel/HideButton".pressed.connect(ButtonPressed.bind(9)) #Hide the UI
	$"Showbutton".pressed.connect(ButtonPressed.bind(10)) #Show the UI
	
	$Panel/Teleport_Options/TeleTop.pressed.connect(ButtonPressed.bind(11))
	$Panel/Teleport_Options/TeleMid.pressed.connect(ButtonPressed.bind(12))
	$Panel/Teleport_Options/TeleLeft.pressed.connect(ButtonPressed.bind(13))
	$Panel/Teleport_Options/TeleLeftest.pressed.connect(ButtonPressed.bind(14))
	
	$"Panel2/VBoxContainer/Pause Game Button".pressed.connect(ButtonPressed.bind(15))
	$Panel2/VBoxContainer/GameSpeed/Button.pressed.connect(ButtonPressed.bind(16))
	$Panel2/VBoxContainer/HideButton.pressed.connect(ButtonPressed.bind(17))
	$Showbutton2.pressed.connect(ButtonPressed.bind(18))
	
	#Checkboxes
	$"Panel/Jumping_Options/Impulse/Checkbox".pressed.connect(BoxChecked.bind(1)) #these 3 are unique and cannot overlap and requires min 1
	$"Panel/Jumping_Options/DurationJumpv1/CheckBox".pressed.connect(BoxChecked.bind(2))
	$"Panel/Jumping_Options/DurationJumpv2/CheckBox".pressed.connect(BoxChecked.bind(3))

	#release fall instant and half need to be unique and cannot overlap
	$"Panel/Extra_Options/ReleaseFallInstant/CheckBox".pressed.connect(BoxChecked.bind(11))
	$"Panel/Extra_Options/ReleaseFallHalf/CheckBox".pressed.connect(BoxChecked.bind(12))
	
	#Literally everything else can be toggled on/off all in any combination
	$"Panel/Falling_Options/Gravity/CheckBox".pressed.connect(BoxChecked.bind(4)) 
	$"Panel/Falling_Options/FixedFall/CheckBox".pressed.connect(BoxChecked.bind(5))
	$"Panel/Falling_Options/FastFall/CheckBox".pressed.connect(BoxChecked.bind(6))
	$"Panel/Falling_Options/FastAscent/CheckBox".pressed.connect(BoxChecked.bind(7))
	$"Panel/Extra_Options/DoubleJump/CheckBox".pressed.connect(BoxChecked.bind(8))
	$"Panel/Extra_Options/CoyoteTime/CheckBox".pressed.connect(BoxChecked.bind(9))
	$"Panel/Extra_Options/JumpPeakHover/CheckBox".pressed.connect(BoxChecked.bind(10))
	$"Panel/Extra_Options/CharacterColor/CheckBox".pressed.connect(BoxChecked.bind(13))
	$"Panel/Extra_Options/InputBuffer/CheckBox".pressed.connect(BoxChecked.bind(14))
	#$"Panel/Extra_Options/Momentum/CheckBox".pressed.connect(BoxChecked.bind(15)) #Momentum is cut
	


	
func ButtonPressed(id = -1):
	
	var focus = get_viewport().gui_get_focus_owner()
	if is_instance_valid(focus):
		focus.release_focus()
		
	match id: 
		1: #set basic attributes
			if SpeedInput.text.is_valid_float():
				PlayerRef.SPEED = (SpeedInput.text.to_float())
			else:
				SpeedInput.text = "Error"
			if JumpInput.text.is_valid_float():
				PlayerRef.JUMP_POWER = (JumpInput.text.to_float())
			else:
				JumpInput.text = "Error"
			if AirControlInput.text.is_valid_float():
				PlayerRef.AIR_CONTROL = (AirControlInput.text.to_float())
			else:
				AirControlInput.text = "Error"
		2: #Set Duration Jump Time
			if DurationJumpLifespanInput.text.is_valid_float():
				PlayerRef.DurationJumpLifespan = (DurationJumpLifespanInput.text.to_float())
			else:
				DurationJumpLifespanInput.text = "Error"
		3: #Set Jump Speed Cap
			if JumpSpeedCapInput.text.is_valid_float():
				PlayerRef.Min_Y_Velocity = -(JumpSpeedCapInput.text.to_float())
			else:
				JumpSpeedCapInput.text = "Error"
		4: #Set Gravity Power
			if GravPowerInput.text.is_valid_float():
				PlayerRef.GravityStrength = (GravPowerInput.text.to_float())
			else:
				GravPowerInput.text = "Error"
		5: #Set Fall Speed Cap
			if FallSpeedCapInput.text.is_valid_float():
				PlayerRef.Max_Y_Velocity = (FallSpeedCapInput.text.to_float())
			else:
				FallSpeedCapInput.text = "Error"
		6: #Set FastFall Power
			if FastFallInput.text.is_valid_float():
				PlayerRef.FastFallStrength = (FastFallInput.text.to_float())
			else:
				FastFallInput.text = "Error"
		7: #Set Jump Weak Grav Power
			if LowGravJumpInput.text.is_valid_float():
				PlayerRef.WeakJumpGravityMult = (LowGravJumpInput.text.to_float())
			else:
				LowGravJumpInput.text = "Error"
		8: #set input buffer time
			if InputBufferTimeInput.text.is_valid_float():
				PlayerRef.JumpBufferLifespan = (InputBufferTimeInput.text.to_float())
			else:
				InputBufferTimeInput.text = "Error"
		9: #Hide the UI
			$Panel.visible = false
			$Showbutton.visible = true
		10: #Show the UI
			$Panel.visible = true
			$Showbutton.visible = false
		11:
			PlayerRef.global_position = TopTeleLocation.global_position
		12:
			PlayerRef.global_position = MidTeleLocation.global_position
		13:
			PlayerRef.global_position = LeftTeleLocation.global_position
		14:
			PlayerRef.global_position = LeftestTeleLocation.global_position
		15:
			get_tree().paused = not get_tree().paused 
		16:
			if GameSpeedInput.text.is_valid_float():
				Engine.time_scale = (GameSpeedInput.text.to_float())
			else:
				InputBufferTimeInput.text = "Error"
		17:
			$Panel2.visible = false
			$Showbutton2.visible = true
		18:
			$Panel2.visible = true
			$Showbutton2.visible = false
		_:
			assert(false, "How did this happen? Button Pressed without valid ID")
		


func BoxChecked(id = -1):
	match id:
		1:
			PlayerRef.EnabledJumpMechanic = PlayerRef.JumpMechanic.ImpulseJump
			$"Panel/Jumping_Options/Impulse/Checkbox".button_pressed = true
			$"Panel/Jumping_Options/DurationJumpv1/CheckBox".button_pressed = false
			$"Panel/Jumping_Options/DurationJumpv2/CheckBox".button_pressed = false
		2:
			PlayerRef.EnabledJumpMechanic = PlayerRef.JumpMechanic.DurationJump1
			$"Panel/Jumping_Options/Impulse/Checkbox".button_pressed = false
			$"Panel/Jumping_Options/DurationJumpv1/CheckBox".button_pressed = true
			$"Panel/Jumping_Options/DurationJumpv2/CheckBox".button_pressed = false
		3:
			PlayerRef.EnabledJumpMechanic = PlayerRef.JumpMechanic.DurationJump2
			$"Panel/Jumping_Options/Impulse/Checkbox".button_pressed = false
			$"Panel/Jumping_Options/DurationJumpv1/CheckBox".button_pressed = false
			$"Panel/Jumping_Options/DurationJumpv2/CheckBox".button_pressed = true
		
		11: #Release Fall Instant Toggle
			if PlayerRef.ReleaseFallHalf: #If half is on, we turn that off and turn us on	
				PlayerRef.ReleaseFallInstant = true
				PlayerRef.ReleaseFallHalf = false
				$"Panel/Extra_Options/ReleaseFallInstant/CheckBox".button_pressed = true
				$"Panel/Extra_Options/ReleaseFallHalf/CheckBox".button_pressed = false
			else: #otherwise we just flip the character toggle, and set our own state to character state
				PlayerRef.ReleaseFallInstant = not PlayerRef.ReleaseFallInstant
				$"Panel/Extra_Options/ReleaseFallInstant/CheckBox".button_pressed = PlayerRef.ReleaseFallInstant
		12: #Release Fall Half Toggle
			if PlayerRef.ReleaseFallInstant: 
				PlayerRef.ReleaseFallHalf = true
				PlayerRef.ReleaseFallInstant = false
				$"Panel/Extra_Options/ReleaseFallInstant/CheckBox".button_pressed = false
				$"Panel/Extra_Options/ReleaseFallHalf/CheckBox".button_pressed = true
			else: #otherwise we just flip the character toggle, and set our own state to character state
				PlayerRef.ReleaseFallHalf = not PlayerRef.ReleaseFallHalf
				$"Panel/Extra_Options/ReleaseFallHalf/CheckBox".button_pressed = PlayerRef.ReleaseFallHalf
		
		#Technically, I should have a sanity check to make sure that the toggle is equal to the toggle button position, but like, just doing "val = not val"
		#should work perfectly fine since nothing else is touching these values...??? I think????? I don't think there's any way for these to get desynced???
		4: #Gravity Toggle
			PlayerRef.GravityEnabled = not PlayerRef.GravityEnabled
		5: #Fixed Fall Toggle
			PlayerRef.FixedFallSpeedOn = not PlayerRef.FixedFallSpeedOn
		6: #FastFall Toggle
			PlayerRef.FastFall = not PlayerRef.FastFall
		7: #WeakGravWhenJump Toggle
			PlayerRef.WeakJumpGravityEnabled = not PlayerRef.WeakJumpGravityEnabled
		8: #DoubleJump Toggle
			PlayerRef.DoubleJump = not PlayerRef.DoubleJump
		9: #CoyoteTime Toggle
			PlayerRef.CoyoteTime = not PlayerRef.CoyoteTime
		10: #Jump Peak Hover Toggle
			PlayerRef.PeakHoverOn = not PlayerRef.PeakHoverOn
		13: #Character Color Toggle
			PlayerRef.CanJumpSpriteGreen = not PlayerRef.CanJumpSpriteGreen
		14: #Input Buffer Toggle
			PlayerRef.JumpBufferOptionEnabled = not PlayerRef.JumpBufferOptionEnabled


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var focus = get_viewport().gui_get_focus_owner()
		if is_instance_valid(focus):
			focus.release_focus()

func _physics_process(delta: float) -> void:
	CalcX.text = "Calculated X : " + str(snapped(PlayerRef.Calc_X_Velocity,0.01))
	CalcY.text = "Calculated Y : " + str(snapped(PlayerRef.Calc_Y_Velocity,0.01))
	TrueX.text = "True X : " + str(snapped(PlayerRef.velocity.x,0.01))
	TrueY.text = "True Y : " + str(snapped(PlayerRef.velocity.y,0.01))
