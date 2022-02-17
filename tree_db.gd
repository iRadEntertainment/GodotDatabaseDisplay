#======================#
#        UTILITY       #
#      tree_db.gd      #
#======================#
# https://github.com/iRadEntertainment/GodotDatabaseDisplay

extends Control



var database setget _set_database
var database_title : String setget _set_database_title

onready var tree = $vb/mid/tree_display
var root_item
var tree_columns := 3



func _ready():
	tree.hide_root = true

func set_database_and_title(_data, _title):
	self.database = _data
	self.database_title = _title


func _compile_tree_structure():
	tree.clear()
	if database:
		root_item = tree.create_item()
		tree.columns = tree_columns
		_iterate_db(root_item, database)
		
	else:
		print("TREE_DB: Can you please pass me something?")


func _iterate_db(tree_node, data):
	if not data:
		return
	
	#--- DICTIONARY
	if typeof(data) == TYPE_DICTIONARY:
		var dic : Dictionary = data
		var sub_node = tree.create_item(tree_node)
		
		if dic.empty():
			sub_node.set_text(0, "{}.empty()")
			return
		
		for key in dic.keys():
			var value = dic[key]
			sub_node.set_text(0, key as String)
			
			if typeof(value) in [TYPE_DICTIONARY, TYPE_ARRAY]:
				_iterate_db(sub_node, value)
			else:
				sub_node.set_text(1, value as String)
	
	#--- ARRAY
	elif typeof(data) == TYPE_ARRAY:
		var array : Array = data
		
		if array.empty():
			var sub_node = tree.create_item(tree_node)
			sub_node.set_text(0, "[].empty()")
			return
		
		# this solution isn't the best :)
		elif typeof(array[0]) in [TYPE_ARRAY, TYPE_DICTIONARY]:
			var sub_node = tree.create_item(tree_node)
			for element in array:
				_iterate_db(sub_node, element)
		
		else:
			# the ROW PROBLEM!
			var rows_number = ceil( float(array.size()) / float(tree_columns) )
			for row in range(rows_number):
				var sub_node = tree.create_item(tree_node)
				
				# es [0,1,2,|3,4,5,|6,7]
				var begin = rows_number * tree_columns
				var end = min(array.size(), rows_number * tree_columns + tree_columns-1)
				var sub_array = array.slice(begin, end)
				
				for i in range(sub_array.size()):
					sub_node.set_text(i, sub_array[i] as String)
	
	else:
		var sub_node = tree.create_item(tree_node)
		sub_node.set_text(0, data as String)


func _fill_rich_text():
	$vb/mid/text_display.text = database as String


func _set_database(val):
	database = val
	_compile_tree_structure()
	_fill_rich_text()
func _set_database_title(val):
	database_title = val
	$vb/top/hb/title.text = val as String


func _on_btn_hide_pressed():
	$vb/mid/tree_display.visible = !$vb/mid/tree_display.visible
func _on_column_selector_value_changed(val):
	tree_columns = val
	_compile_tree_structure()





