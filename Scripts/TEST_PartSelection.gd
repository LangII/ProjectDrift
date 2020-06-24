
extends HBoxContainer

onready var option_button = get_node('OptionButton')

func _ready():
    
    for i in range(50):
        option_button.add_item('option %d' % (i + 1))

    var pop_up = option_button.get_popup()
    var scroll = ScrollContainer.new()
    
    option_button.add_child(scroll)
    option_button.remove_child(pop_up)
    scroll.add_child(pop_up)
    
    scroll.rect_size.y = 100


#func _draw():
#
#    var pop_up = option_button.get_popup()
#
#    pop_up.rect_size.y = 100
    





