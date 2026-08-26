extends Node
class_name EnvironmentController

@export var sun_light: DirectionalLight3D
@export var world_environment: WorldEnvironment
@export var transition_duration: float = 3.0

var sky_material: ProceduralSkyMaterial
var active_tween: Tween

class PhasePreset:
	var sun_rotation: Vector3
	var sun_color: Color
	var sun_energy: float
	var sky_top_color: Color
	var sky_horizon_color: Color
	var ground_bottom_color: Color
	var ground_horizon_color: Color
	var ambient_energy: float

	func _init(
		_sun_rot: Vector3, _sun_col: Color, _sun_e: float,
		_sky_top: Color, _sky_horiz: Color,
		_gnd_bot: Color, _gnd_horiz: Color,
		_amb_e: float
	) -> void:
		sun_rotation = _sun_rot
		sun_color = _sun_col
		sun_energy = _sun_e
		sky_top_color = _sky_top
		sky_horizon_color = _sky_horiz
		ground_bottom_color = _gnd_bot
		ground_horizon_color = _gnd_horiz
		ambient_energy = _amb_e

var preset_morning: PhasePreset
var preset_afternoon_start: PhasePreset
var preset_afternoon_dusk: PhasePreset
var preset_night: PhasePreset

func _ready() -> void:
	if world_environment and world_environment.environment and world_environment.environment.sky:
		sky_material = world_environment.environment.sky.sky_material as ProceduralSkyMaterial

	_setup_presets()
	Signals.phase_changed.connect(transition_to_phase)
	apply_preset_instant(preset_night)

func _setup_presets() -> void:
	# 1. MORNING: Sunrise in the East
	preset_morning = PhasePreset.new(
		Vector3(-25.0, 45.0, 0.0),
		Color("ffd299"),
		1.1,
		Color("4a7ba7"),
		Color("e0a57b"),
		Color("241d1a"),
		Color("735645"),
		0.85
	)

	# 2. AFTERNOON (Start): High midday sun
	preset_afternoon_start = PhasePreset.new(
		Vector3(-65.0, -20.0, 0.0),
		Color("fff6e8"),
		1.35,
		Color("2f6ea6"),
		Color("a0c9e6"),
		Color("1e2920"),
		Color("4c634f"),
		1.0
	)

	# 3. AFTERNOON (Dusk): Sun low on western horizon
	preset_afternoon_dusk = PhasePreset.new(
		Vector3(-5.0, -85.0, 0.0),
		Color("d96b43"),
		0.5,
		Color("1f2f45"),
		Color("8c4836"),
		Color("121118"),
		Color("382020"),
		0.45
	)

	# 4. NIGHT (Midnight): Cool moonlight high in opposite sky
	preset_night = PhasePreset.new(
		Vector3(-45.0, 160.0, 0.0),
		Color("88a4d4"),
		0.2,
		Color("050811"),
		Color("101726"),
		Color("030406"),
		Color("080d14"),
		0.25
	)

func transition_to_phase(phase: Constants.Phase) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()

	match phase:
		Constants.Phase.MORNING:
			_transition_to_morning()

		Constants.Phase.AFTERNOON:
			_run_afternoon_decay()

		Constants.Phase.NIGHT:
			_transition_to_night()

func _transition_to_night() -> void:
	var half_time := transition_duration * 0.5
	active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 1. Sky & ambient smoothly fade into night
	_tween_sky_and_ambient(preset_night, transition_duration)

	# 2. Sun dips below horizon and fades to 0
	if sun_light:
		active_tween.tween_property(sun_light, "rotation_degrees:x", 15.0, half_time)
		active_tween.tween_property(sun_light, "light_energy", 0.0, half_time)
		
		# 3. Once fully set and dark, swap position to moon under the horizon and rise
		active_tween.chain().tween_callback(func():
			sun_light.rotation_degrees = Vector3(15.0, preset_night.sun_rotation.y, 0.0)
			sun_light.light_color = preset_night.sun_color
		)
		active_tween.tween_property(sun_light, "rotation_degrees:x", preset_night.sun_rotation.x, half_time)
		active_tween.tween_property(sun_light, "light_energy", preset_night.sun_energy, half_time)

func _transition_to_morning() -> void:
	var half_time := transition_duration * 0.5
	active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 1. Sky & ambient fade to morning
	_tween_sky_and_ambient(preset_morning, transition_duration)

	# 2. Moon sets below horizon and fades out
	if sun_light:
		active_tween.tween_property(sun_light, "rotation_degrees:x", 15.0, half_time)
		active_tween.tween_property(sun_light, "light_energy", 0.0, half_time)
		
		# 3. Swap to sunrise side below horizon and rise up
		active_tween.chain().tween_callback(func():
			sun_light.rotation_degrees = Vector3(15.0, preset_morning.sun_rotation.y, 0.0)
			sun_light.light_color = preset_morning.sun_color
		)
		active_tween.tween_property(sun_light, "rotation_degrees:x", preset_morning.sun_rotation.x, half_time)
		active_tween.tween_property(sun_light, "light_energy", preset_morning.sun_energy, half_time)

func _run_afternoon_decay() -> void:
	var t1 = _tween_to_preset(preset_afternoon_start, transition_duration)
	var decay_time = maxf(1.0, Constants.AFTERNOON_LENGTH - transition_duration)
	t1.finished.connect(func():
		_tween_to_preset(preset_afternoon_dusk, decay_time, Tween.TRANS_LINEAR)
	, CONNECT_ONE_SHOT)

func _tween_to_preset(p: PhasePreset, duration: float, trans_type: Tween.TransitionType = Tween.TRANS_SINE) -> Tween:
	active_tween = create_tween().set_parallel(true).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)

	if sun_light:
		active_tween.tween_property(sun_light, "rotation_degrees", p.sun_rotation, duration)
		active_tween.tween_property(sun_light, "light_color", p.sun_color, duration)
		active_tween.tween_property(sun_light, "light_energy", p.sun_energy, duration)

	_tween_sky_and_ambient(p, duration)
	return active_tween

func _tween_sky_and_ambient(p: PhasePreset, duration: float) -> void:
	if sky_material:
		active_tween.tween_property(sky_material, "sky_top_color", p.sky_top_color, duration)
		active_tween.tween_property(sky_material, "sky_horizon_color", p.sky_horizon_color, duration)
		active_tween.tween_property(sky_material, "ground_bottom_color", p.ground_bottom_color, duration)
		active_tween.tween_property(sky_material, "ground_horizon_color", p.ground_horizon_color, duration)

	if world_environment and world_environment.environment:
		active_tween.tween_property(world_environment.environment, "ambient_light_energy", p.ambient_energy, duration)

func apply_preset_instant(p: PhasePreset) -> void:
	if sun_light:
		sun_light.rotation_degrees = p.sun_rotation
		sun_light.light_color = p.sun_color
		sun_light.light_energy = p.sun_energy

	if sky_material:
		sky_material.sky_top_color = p.sky_top_color
		sky_material.sky_horizon_color = p.sky_horizon_color
		sky_material.ground_bottom_color = p.ground_bottom_color
		sky_material.ground_horizon_color = p.ground_horizon_color

	if world_environment and world_environment.environment:
		world_environment.environment.ambient_light_energy = p.ambient_energy
