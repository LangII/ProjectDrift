extends StaticBody



func _on_GravityFlip_body_entered(body):
	if body.gravity_dir == Vector3.DOWN:  body.gravity_dir = Vector3.FORWARD
	elif body.gravity_dir == Vector3.FORWARD:  body.gravity_dir = Vector3.DOWN
