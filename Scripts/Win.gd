
###############################################################################
"""

<> MenuWin.gd <>
Provide player with first introductory title of game and low level basic
options of play.

TODOS:

UPDATES:
2019-09-21 ... display sorted recorded times in fastest order ...
Completion times are recorded, sorted, and displayed.

"""
###############################################################################



												###############################
												###   \/   VARIABLES   \/   ###
												###############################



extends Control

onready var globals = get_node('/root/Globals')

onready var best_times_08 = $BestTimes08
onready var best_times_16 = $BestTimes16



												###############################
												###   \/   FUNCTIONS   \/   ###
												###############################



func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	""" BestTimes display constructor. """
	var times_08 = []
	var times_16 = []
	# Sort through 'globals.time_records'.  Sorting 'time' based on 'count'.
	for record in globals.time_records:
		var count = record[0]
		var time = record[1]
		if count == 8:
			times_08.append(time)
		elif count == 16:
			times_16.append(time)
	# Sort recorded times fastest to slowest.
	times_08.sort()
	times_16.sort()
	# Append top 5 times to label.
	for i in range(times_08.size()):
		if i < 5:
			best_times_08.text += String(times_08[i]) + "\n"
		else:
			break
	for i in range(times_16.size()):
		if i < 5:
			best_times_16.text += String(times_16[i]) + "\n"
		else:
			break



func _on_ButtonReplay_pressed():
	
	get_tree().change_scene('res://Scenes/Menu/Main.tscn')









