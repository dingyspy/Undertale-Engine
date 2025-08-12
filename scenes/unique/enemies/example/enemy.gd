extends Node2D

var health = 100
var max_health = health
# whether they can be spared. when using spared from the menu, itll spare any enemy with sparable as true
var sparable = true
# formatted: [name, [text0, text1, ...], func_name]
# func_name is used if you want a function to be called when acting
var acts = [
	['Check', ['Testing act messages.', 'If you can see this, it works!'], null],
	['Other', ['Testing act functions!'], 'test_act'],
]

func test_act():
	pass
