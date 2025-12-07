class_name PlayerCharacter extends CharacterBody2D


#region Basic Attributes
var SPEED: float = 300.0
var JUMP_POWER: float = 600.0
var AIR_CONTROL: float = 100
var Calc_Y_Velocity : float = 0
var Calc_X_Velocity : float = 0
var Max_Y_Velocity : float = 9999 #Max in this case is actually falling, so this equates to fall speed cap
var Min_Y_Velocity : float = -9999 #Min in this case is ascending, so this equates to jump speed cap
#endregion

#region "UP" movements
var DurationJumpLifespan: float = .33
var isDurationJumping1: bool = false
var isDurationJumping2: bool = false
@onready var DurationJumpTimer : Timer = $DurationJumpTimer
enum JumpMechanic {ImpulseJump, DurationJump1, DurationJump2, NULL}
var EnabledJumpMechanic = JumpMechanic.ImpulseJump

'''Additional Effects that are "up" based'''
var DoubleJump: bool = false
var DoubleJumpAvailable: bool = false

var CoyoteTime: bool = false
var CoyoteJumpAvailable: bool = true
var CoyoteTimeDuration: float = .15
@onready var CoyoteTimer: Timer = $CoyoteTime

#when reaching the apex of the jump, you "hover" in place slightly - can be combined with releasefall, but releasefall will take prio and cancel the hover
var PeakHoverOn: bool = false
var isHovering:bool = false
var CanHover:bool = false
var hoverpower : float = .5 #higher is more powerful, how little of an arc remains during the hovering
var hovertime : float = .15
@onready var hovertimer : Timer = $HoverTimer

var WeakJumpGravityEnabled: bool = false
var WeakJumpGravityMult: float = .5

var JumpBufferOptionEnabled: bool = false
var JumpBufferAvailable: bool = false
@onready var JumpBufferTimer: Timer = $JumpBufferTimer
var JumpBufferLifespan : float = .15

#endregion

#region "DOWN" movements
#gravity is default
var GravityEnabled: bool = true
var GravityStrength: int = 980 #980 is default with 400 jump str


#weird fixed falling speed, it's like, so not useful
var FixedFallSpeedOn: bool = false

var FastFall:bool = false
var FastFallStrength:float = 2

'''Additional Effects that are "down" based'''
#release fall is whenever you unpress the jump button, you immediately start falling, whatever your falling type is 
var ReleaseFallInstant : bool = false

#same as above, but halves the y velocity instead of instantly falling
var ReleaseFallHalf : bool = false


#endregion

#region Misc Vars
var HeadBonked : bool = false
#endregion

'''
README -

This simulator uses a very basic "calculated" X and Y velocity for all of its values, 
and then turns the calculated X and Y into "actual" x and y velocity at the end.

This is primarily done to allow for the velocity clamping and "overcapping" options.
If your game doesn't need this, you can fairly safely just replace Calc_Y_Velocity/Calc_X_Velocity with velocity.y/velocity.x ("actual values")
respectively and remove the entire clamping operation at the end of the physics process

I also try to break up the physics process into as many distinct functions as I can
'''



func _physics_process(delta: float) -> void:
	
	#This function handles everything to do with falling
	Handle_Falling(delta)

	
	#region Jumping Mechanic Handling
	
	#This function handles managing flags that have to do with jumping
	#Namely mostly coyote time and double jumping
	JumpFunctionality()
			
	
	if Input.is_action_just_pressed("Jump"): 
		AttemptJump()
		
	if JumpBufferAvailable: #if we have the jump input buffer available
		if AttemptJump(false): #we try to jump, it'll return true or false based on if we jumped, we input false to tell the option that we're input buffer jumping and not "real" jumping to not retrigger the input buffer timer
			JumpBufferAvailable = false #if we did jump, we turn input buffer off
			JumpBufferTimer.stop()
	
	
	if isDurationJumping1: #These turn on if Duration jumping is in progress
		Calc_Y_Velocity = -JUMP_POWER
	if isDurationJumping2: #Duration Jump 2
		Calc_Y_Velocity -= JUMP_POWER*delta/.1 #Simply accelerates to JUMP_POWER within .1s 
		Calc_Y_Velocity = clamp(Calc_Y_Velocity,-JUMP_POWER, 9999)
	
	
	
	#This section is essentially for fall release, as that's the only thing that cares about when jump button is released
	if Input.is_action_just_released("Jump"):
		if ReleaseFallHalf: #these two flags are the only ones that care about the jump button being released
			if isDurationJumping1 or isDurationJumping2: #They disable duration jumping if enabled
				DurationJumpEnd()
				DurationJumpTimer.stop() #and turn off the timer too
			if Calc_Y_Velocity < 0: #and then cut the Y velocity in half or to 0 if it's greater than 0 ("going up")
				Calc_Y_Velocity = clamp(Calc_Y_Velocity, -JUMP_POWER, 0) #We do this clamp here in case we have an enormous overcapping of y velocity for whatever reason
				Calc_Y_Velocity /= 2 #and then halve it
		if ReleaseFallInstant: #Nearly the same as above
			if isDurationJumping1 or isDurationJumping2:
				DurationJumpEnd()
				DurationJumpTimer.stop()
			if Calc_Y_Velocity < 0:
				Calc_Y_Velocity = 0 #Except we cut the Y Velocity entirely to 0
	
	#This code here is for "head bonking", hitting our head on the ceiling will kill our momentum for impulse jumps, and turn off duration jumping
	if is_on_ceiling(): #If we hit our head on the ceiling, it's essentially the same thing as if we hit an instant fall release in most cases, so this code will look very similar
		if not HeadBonked: #We only do this once per jump, HeadBonked will reset on a successful jump or if on the ground
			if isDurationJumping1 or isDurationJumping2:
				DurationJumpEnd()
				DurationJumpTimer.stop()
			
			Calc_Y_Velocity = 0
			HeadBonked = true
			CanHover = false
	
	if PeakHoverOn: #This is for the PeakHoverOn option
		if !is_on_floor() and !isHovering and PeakHoverOn and CanHover: #a bunch of checks to see if we CAN hover
			if Calc_Y_Velocity < 0: #checks if we're ascending
				if (Calc_Y_Velocity + GravityStrength*(hovertime/2)) >=0: #and does some math to find if we're near the peak of the jump
					isHovering = true #and if so, turns on the hovering
					GravityStrength /= 4
					hovertimer.start(hovertime) #and starts a timer to stop the hovering
	#endregion
	
	# Handle Moving - This is a very simple left-right input, with very binary yes/no movement
	# A lot of games use more complex physics based movement with acceleration and deceleration everywhere, but this is simple and good enough for 
	# non physics based platformers (think of like meatboy as a physics based platformer, this is closer to like celeste (at least horizontally)
	# The benefits of the system is very responsive controls, there are only 2 states, "GO" or "STOP", you can stop and turn on a time
	# Downsides include lack of realism and might feel awkward to those used to the minor acceleration found in games like mario
	var direction := Input.get_axis("Left", "Right")
	if direction == 1: #If we're pressing right, then we move right
		if is_on_floor():
			Calc_X_Velocity = SPEED #set our speed
		else:
			if (direction * SPEED * AIR_CONTROL/100) > Calc_X_Velocity: #This logic here sees if we're already moving right, and doesn't slow us down if we are
				Calc_X_Velocity = direction * SPEED * AIR_CONTROL/100 #otherwise if we're not already moving right, apply the air control modifier to movespeed
	elif direction == -1: #this is the same as above but for moving left
		if is_on_floor():
			Calc_X_Velocity = -SPEED #with "negative" speed
		else:
			if (direction * SPEED * AIR_CONTROL/100) < Calc_X_Velocity:
				Calc_X_Velocity = -SPEED * AIR_CONTROL/100
	if direction == 0: #if we're holding both or neither button, we don't move horizontally 
		Calc_X_Velocity = 0
		
	
	#The second to last thing we do is set our actual velocity to our calculated velocity
	velocity.x = Calc_X_Velocity
	velocity.y = Calc_Y_Velocity
	
	#Finally, we apply our Y Velocity clamp here as the final step
	velocity.y = clamp(velocity.y,Min_Y_Velocity,Max_Y_Velocity)
	#This is what actually moves our character based off of the velocity value, it's a builtin godot function for character body objects
	move_and_slide()
	#print(Calc_Y_Velocity)
	Handle_Sprite() #This handles the sprite of the character, nothing to see here but a bunch of boilerplate code
	

func Handle_Falling(delta:float) -> void:
	
	#we try to evaluate if we're using fixed falling speed first
	if FixedFallSpeedOn and not is_on_floor() and GravityEnabled: 
		if Calc_Y_Velocity < 0:
			if not WeakJumpGravityEnabled: 
				Calc_Y_Velocity += GravityStrength * delta
			else:
				Calc_Y_Velocity += GravityStrength * WeakJumpGravityMult * delta
		else: 
			if not FastFall: 
				Calc_Y_Velocity = GravityStrength
			else:
				Calc_Y_Velocity = GravityStrength * FastFallStrength
	
	#else we use gravity
	elif not is_on_floor() and GravityEnabled: #This if statement checks to see if we're not on the floor, and we have gravity on. 
		if Calc_Y_Velocity < 0: #Check if the player is ascending
			if !WeakJumpGravityEnabled: # if we are ascending, check if we need to apply weak gravity on ascending
				Calc_Y_Velocity += GravityStrength * delta #if we don't apply standard gravity
			else:
				Calc_Y_Velocity += GravityStrength * WeakJumpGravityMult * delta #otherwise apply modified gravity (supposedly weakened)
		else: #Check if player is descending
			if !FastFall: #if the player is falling, we check for flast fall flag
				Calc_Y_Velocity += GravityStrength * delta #if no flag, we just apply gravity to Y velocity
			else:
				Calc_Y_Velocity += GravityStrength * FastFallStrength * delta #If flag, we add in our fall speed multiplier

	if is_on_floor():
		Calc_Y_Velocity = 0

func JumpFunctionality() -> void:
	if is_on_floor(): #If we're on the floor
		HeadBonked = false
		
		if DoubleJump and !DoubleJumpAvailable: #we reset double jump availability
			DoubleJumpAvailable = true
		if PeakHoverOn and isHovering: #and also stop isHovering if we somehow touch the floor while hovering (such as touching a platform)
			isHovering = false
			hovertimer.stop()
		if PeakHoverOn and !CanHover: #we re-allow hovering as well
			CanHover = true
		
		CoyoteTimer.stop() #also stops coyote time if on floor, always
		if CoyoteTime and !CoyoteJumpAvailable: #reset coyote time after touching floor if not available
			CoyoteJumpAvailable = true
	if !is_on_floor() and CoyoteTimer.is_stopped(): #This SHOULD only happen if coyote time mechanic is even enabled, but the jump itself checks for the flag so this is fine enough
		CoyoteTimer.start(CoyoteTimeDuration) #We start the coyote timer when we leave the floor



func AttemptJump(RealJump:bool = true) -> bool:
	if is_on_floor() or (CoyoteTime and CoyoteJumpAvailable): #see if we can jump with on floor, or coyote time
		Jump() #we do whatever jump mechanic is enabled
		CoyoteJumpAvailable = false #and disable coyote time
		return true
	elif DoubleJump and DoubleJumpAvailable: #If we can't use floor or coyote jump, we check if double jump is available
		Jump()
		DoubleJumpAvailable = false #if double jump is available, we consume it
		return true
		#If neither above conditions are met, we simply do nothing and fail to jump, set input buffer if it's on
	else:
		if RealJump and JumpBufferOptionEnabled:
			JumpBufferAvailable = true #start input buffer
			JumpBufferTimer.start(JumpBufferLifespan)
		return false


func Jump() -> void:
	JumpBufferAvailable = false #if we get to this point we're jumping
	JumpBufferTimer.stop() #regardless of anything, we can safely disable jump buffer availability and the timer
	HeadBonked = false #will also reset Head Bonking 
	
	match EnabledJumpMechanic:
		JumpMechanic.ImpulseJump:
			Calc_Y_Velocity = -JUMP_POWER
		JumpMechanic.DurationJump1:
			isDurationJumping1 = true 
			DurationJumpTimer.start(DurationJumpLifespan)
		JumpMechanic.DurationJump2:
			isDurationJumping2 = true
			DurationJumpTimer.start(DurationJumpLifespan)
		_:
			assert(false, "Somehow jumped without a jump option selected - contact Calam with bug report")



#Pretty standard sprite management function, this is probably better done in a state machine but it's not necessary for something as simple as this
var FacingRight : bool = true
@onready var Sprite : AnimatedSprite2D = $Sprite2D
var CanJumpSpriteGreen : bool = false
func Handle_Sprite() -> void:
	if velocity.x > 0:
		if not FacingRight:
			FacingRight = true
	elif velocity.x < 0:
		if FacingRight:
			FacingRight = false
			
	if is_on_floor():
		if velocity.x > 0:
			Sprite.play("Walk")
		elif velocity.x < 0:
			Sprite.play("Walk")
		else:
			Sprite.play("Idle")
	else:
		if velocity.y > 45:
			Sprite.play("JumpUp")
		elif velocity.y > -45: #This is a super hacky way to have a "mid jump" animation, with fixed values
			Sprite.play("JumpMiddle")
		else:
			Sprite.play("JumpDown")
	
	if FacingRight:
		Sprite.flip_h = false
	else:
		Sprite.flip_h = true
		
	if CanJumpSpriteGreen:
		if is_on_floor() or (CoyoteTime and CoyoteJumpAvailable) or (DoubleJump and DoubleJumpAvailable): #see if we can jump with on floor, or coyote time
			Sprite.modulate = Color.GREEN
		else:
			Sprite.modulate = Color.RED
	else:
		Sprite.modulate = Color.WHITE



#This function is called by a timer which is started by the initial jump, or by release fall
func DurationJumpEnd() -> void:
	isDurationJumping1 = false
	isDurationJumping2 = false

#Called by a timer
func CoyoteTimeout() -> void:
	CoyoteJumpAvailable = false

#Called by a timer
func HoverTimeout() -> void:
	GravityStrength *= 4
	isHovering = false

#Called by a timer
func JumpBufferTimeout() -> void:
	print("we stopped the jump avail")
	JumpBufferAvailable = false



'''
THIS IS AN OLD ATTEMPT JUMP FUNCTION THAT WAS REWRITTEN FOR CLARITY, I kept this in here for my own reference in case something goes wrong in the future
Feel free to puruse it to see how the function was simplified to be much more readable

The AttemptJump function looks complicated, but it's just because there's a lot of options to parse through
First off, this is one of the few functions that takes a parameter and has a return, which is indicated by 
AttemptJump(RealJump: bool = true) -> bool
Where RealJump: bool = true means it can take a boolean for its param, and -> bool (instead of the usual -> void) means the function is expected to return a bool as well

RealJump = true means that if there is no param entered, it will default the param to True, the purpose of this param is to tell the function whether we're jumping because
of a player's input, or because of an input buffer

The return value is to basically say whether or not a jump was successfully executed

The format of this function goes as follows

Match EnabledJumpMechanic -> This means we pick one of the routes based on which jump mechanic is enabled, the 3 we have right now are Impulse Jump, Duration Jump, and Duration Jump 2

From there, all 3 have a 2 branch structure where
Check if we're on the floor OR we have coyote jump enabled and a coyote jump is available
	-> If so, then we jump, and turn off coyote jump available (standard or coyote jump), and return true
Otherwise, we see if double jumping is enabled, and we have a double jump available
	-> if so, we do the jump, and disable double jump available, and return true
If both the above checks are false, then we failed to jump

If we fail to jump, then we check if the input was a "real jump" done by the player, and we have JumpBufferOptionEnabled, if we do, we turn on the jump buffer option (which will buffer a jump)
and turn on the timer which will disable jumpbuffer after it runs out (basically the buffer only exists for .15s after the jump press)

Regardless of the above check, we then return false because we failed to jump
Again, all 3 jump mechanics follow the above format, they just do something slightly to actually "jump" based on the enabled jump mechanic
'''

'''THIS IS AN OLD ATTEMPT JUMP FUNCTION THAT WAS REWRITTEN FOR CLARITY, I kept this in here for my own reference in case something goes wrong in the future
Feel free to puruse it to see how the function was simplified to be much more readable'''
func AttemptJump_OLD(RealJump: bool = true) -> bool: #returns if we jumped or not
	match EnabledJumpMechanic: #we check what jump mechanic is enabled 
		JumpMechanic.ImpulseJump: #Impulse Jump
			if is_on_floor() or (CoyoteTime and CoyoteJumpAvailable): #see if we can jump with on floor, or coyote time
				Calc_Y_Velocity = -JUMP_POWER #we simply set negative Y Velocity
				CoyoteJumpAvailable = false #and disable coyote time
				return true
			elif DoubleJump and DoubleJumpAvailable: #If we can't use floor or coyote jump, we check if double jump is available
				Calc_Y_Velocity = -JUMP_POWER
				DoubleJumpAvailable = false #if double jump is available, we consume it
				return true
			#If neither above conditions are met, we simply do nothing and fail to jump, set input buffer if it's on
			if RealJump and JumpBufferOptionEnabled:
				JumpBufferAvailable = true
				JumpBufferTimer.start(JumpBufferLifespan)
			return false
		JumpMechanic.DurationJump1: #For duration jump it's the same as above but we simply set the DurationJumping flag instead of modifying Y Velocity directly
			if is_on_floor() or (CoyoteTime and CoyoteJumpAvailable): 
				isDurationJumping1 = true #we set duration jumping flag instead of modifying velocity, the flag will activate code that modifies velocity elsewhere
				DurationJumpTimer.start(DurationJumpLifespan)
				CoyoteJumpAvailable = false
				return true
			elif DoubleJump and DoubleJumpAvailable:
				isDurationJumping1 = true
				DurationJumpTimer.start(DurationJumpLifespan)
				DoubleJumpAvailable = false
				return true
			if RealJump and JumpBufferOptionEnabled:
				JumpBufferAvailable = true
				JumpBufferTimer.start(JumpBufferLifespan)
			return false
		JumpMechanic.DurationJump2:
			if is_on_floor() or (CoyoteTime and CoyoteJumpAvailable):
				CoyoteJumpAvailable = false
				isDurationJumping2 = true
				DurationJumpTimer.start(DurationJumpLifespan)
				return true
			elif DoubleJump and DoubleJumpAvailable:
				isDurationJumping2 = true
				DurationJumpTimer.start(DurationJumpLifespan)
				DoubleJumpAvailable = false
				Calc_Y_Velocity = 0 #This being here is... up to taste really but too lazy to add another option in
				#Basically, since duration jump 2 accelerates you up to the jump speed, this resets your y velocity to 0 at the double jump
				#to give a better "feel"
				#The reason I don't have this in durationjump1 is because there would be no effect anyways, since duration jump 1 auto sets the jump vertical speed with no acceleration
				return true
			if RealJump and JumpBufferOptionEnabled:
				JumpBufferAvailable = true
				JumpBufferTimer.start(JumpBufferLifespan)
			return false
		_:
			push_error("Somehow jumped without a jump option selected - contact Calam with bug report")
			return false
