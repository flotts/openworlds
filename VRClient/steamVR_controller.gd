extends ARVRController

signal controller_activated(controller)
signal controller_deactivated(controller)

var ovr_render_model
var ws = 0

enum ControllerType {HAND_CONTROLLER, BODY_TRACKER}
var controller_type

func _ready():
	# instance our render model object
	ovr_render_model = preload("res://addons/godot-openvr/OpenVRRenderModel.gdns").new()
	
	# hide to begin with
	visible = false

func apply_world_scale():
	var new_ws = ARVRServer.world_scale
	if (ws != new_ws):
		ws = new_ws
		$Controller_mesh.scale = Vector3(ws, ws, ws)

func load_controller_mesh(controller_name):
	if ovr_render_model.load_model(controller_name.substr(0, controller_name.length()-2)):
		return ovr_render_model
	
	if ovr_render_model.load_model("generic_controller"):
		return ovr_render_model
	
	return Mesh.new()

func _process(delta):
	if !get_is_active():
		if visible:
			emit_signal("controller_deactivated", self)
		
		visible = false
		return
	
	# always set our world scale, user may end up changing this
	apply_world_scale()
	
	if visible:
		return
	
	# became active? lets handle it...
	var controller_name = get_controller_name()
	print("[INFO] Controller " + controller_name + " became active")
			
	# attempt to load a mesh for this
	$Controller_mesh.mesh = load_controller_mesh(controller_name)
			
	# make it visible
	visible = true
	emit_signal("controller_activated", self)
