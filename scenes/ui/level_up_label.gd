extends Label


func play_in():
	modulate = Color.TRANSPARENT
	$AnimationPlayer.play("in")

func play_out():
	$AnimationPlayer.play("out")
