@tool
@icon("res://addons/NZ_md_to_csv/Icons/MD_to_CSV.svg")
extends Control

@onready var label_update_csv_resource: Label = $LabelUpdateCSV_resource
@onready var label_main_folder: RichTextLabel = $RichTextLabelMainFolder
@onready var label_output_folder: RichTextLabel = $RichTextLabelOutputFolder
@onready var label_languages: RichTextLabel = $RichTextLabelLanguages
@onready var label_info_path: RichTextLabel = $RichTextLabelInfoPath
@onready var button_update: Button = $ButtonUpdate

var debug : bool = false
var updateCSV_r : UpdateCSV_base_resource

const NO_INFO_PATH_LINE := "[b]Info path[/b]\nThere is no info path"

func _update_csv(resource:UpdateCSV_resource) -> void:
	var local_main_folder_path : String
	var can_create_info_file : bool = !resource.info_file_name.is_empty() and !resource.info_file_path.is_empty()
	var info_file := UpdateCSV_info.new()
	var all_imported_file_paths : PackedStringArray
	local_main_folder_path = resource.main_folder_path.replace("\\","/")
	if debug:
		print("can_create_info_file: ",can_create_info_file)
		print("local_main_folder_path: ",local_main_folder_path)
	for folder_name in resource.folders:
		var cur_files_path : String = local_main_folder_path
		if !cur_files_path.ends_with("/"):
			cur_files_path = local_main_folder_path+"/"+folder_name
			if debug:
				print(cur_files_path)
		else:
			cur_files_path = local_main_folder_path+folder_name
		var file_paths := get_files_from_dir(cur_files_path)
		var line_number : int = 0
		var translation_file_path = resource.output_folder_path+folder_name+".csv"
		all_imported_file_paths.append(translation_file_path)
		var cur_translation_fiile := FileAccess.open(translation_file_path,FileAccess.WRITE)
		var local_languages := resource.languages.duplicate(true)
		var local_languages_size := local_languages.size()
		local_languages.push_front("keys")
		cur_translation_fiile.store_csv_line(local_languages)
		for j in file_paths:
			if debug:
				print("file name: ",j)
			var file_name_without_format : String = j.get_slice(".",0)
			if file_name_without_format in resource.excluded_file_names:
				if debug:
					print("file ",j," is skipped")
				continue
			var translations_for_one_line : PackedStringArray = [""]
			if resource.include_folder_name:
				translations_for_one_line[0] = folder_name+resource.separator
			if resource.include_line_number:
				translations_for_one_line[0] += str(line_number)+resource.separator
			translations_for_one_line[0] += file_name_without_format
			var cur_file_path := cur_files_path+"/"+j
			var cur_file := FileAccess.open(cur_file_path,FileAccess.READ)
			var added_lines : int = 0
			if cur_file != null:
				var file_length := cur_file.get_length()
				while cur_file.get_position() < file_length:
					if added_lines == local_languages_size:
						break
					translations_for_one_line.append(cur_file.get_line())
					added_lines += 1
				if debug:
					print("cur_file_path: ",cur_file_path," | translations_for_one_line:",translations_for_one_line)
				_other_changes_for_one_line(resource,translations_for_one_line)
				cur_translation_fiile.store_csv_line(translations_for_one_line)
			else:
				push_error("Can't open file")
			if resource.include_line_number:
				line_number += 1
			if can_create_info_file:
				info_file.og_file_paths[translations_for_one_line[0]] = resource.info_rfolder_stop_name+cur_file_path.reverse().get_slice(resource.info_rfolder_stop_name.reverse(),0).reverse()
		cur_translation_fiile.close()
	if debug:
		print("info_file.og_file_paths: ",info_file.og_file_paths)
	if can_create_info_file:
		info_file.resource_name = resource.info_file_name
		_fill_info_file_and_save(info_file,resource)
	_reimport_files(all_imported_file_paths,true)

func _other_changes_for_one_line(resource:UpdateCSV_resource,cur_translations:PackedStringArray) -> void:
	if resource.remove_links:
		for i in range(1,cur_translations.size()):
			var one_translation = cur_translations[i]
			if debug:
				print("one_translation: ",one_translation)
			var remove_vertical_bar : bool = false
			var before_vertical_bar : bool = false
			for j in range(0,one_translation.length()):
				match one_translation[j]:
					"[":
						remove_vertical_bar = true
						before_vertical_bar = true
						one_translation[j] = resource.character_to_remove
					"]":
						remove_vertical_bar = false
						one_translation[j] = resource.character_to_remove
					"|":
						before_vertical_bar = false
						if remove_vertical_bar:
							one_translation[j] = resource.character_to_remove
					_:
						if before_vertical_bar:
							one_translation[j] = resource.character_to_remove
			var character_to_remove_code : int = ord(resource.character_to_remove)
			cur_translations[i] = one_translation.remove_char(character_to_remove_code)

func _fill_info_file_and_save(info_file:UpdateCSV_info,updateCSV_resource:UpdateCSV_resource) -> void:
	var resource_path : String = updateCSV_resource.info_file_path+"/"+info_file.resource_name+".tres"
	if ResourceLoader.exists(resource_path):
		var old_resource : UpdateCSV_info = ResourceLoader.load(resource_path)
		old_resource.og_file_paths = info_file.og_file_paths
		info_file = old_resource
	info_file.take_over_path(resource_path)
	if ResourceSaver.save(info_file,resource_path):
		push_error("Something is wrong when saving info_file")
	elif debug:
		print("info file is successfully created")
	_reimport_files([resource_path])

func _turn_canvas_into_resource(resource:UpdateCSV_resource_canvas) -> void:
	var local_main_folder_path : String
	local_main_folder_path = resource.main_folder_path.replace("\\","/")
	if debug:
		print(local_main_folder_path)
	var new_resource_imported_canvas := Resource_imported_canvas.new()
	var updateCSV_info : UpdateCSV_info = ResourceLoader.load(resource.info_file_path)
	for i in resource.canvas_names:
		var canvas_file := FileAccess.open(local_main_folder_path+"/"+i+".canvas",FileAccess.READ)
		var json_string : String
		var json_data : Dictionary
		var id_and_name_in_canvas : Dictionary[String,String]
		while canvas_file.get_position() < canvas_file.get_length():
			json_string += canvas_file.get_line()
		canvas_file.close()
		json_data = JSON.parse_string(json_string)
		if debug:
			const NODES_USELESS_KEYS := ["type","x","y","width","height","color"]
			const EDGES_USELESS_KEYS := ["id","toSide","fromSide"]
			for j : String in json_data:
				for k : Dictionary in json_data[j]:
					if j == "nodes":
						for useless_key in NODES_USELESS_KEYS:
							k.erase(useless_key)
					else:
						for useless_key in EDGES_USELESS_KEYS:
							k.erase(useless_key)
			print("json_data: ",json_data)
		for j : Dictionary in json_data["nodes"]:
			var index_with_right_name : int = -1
			var right_string : String = ""
			for k : String in updateCSV_info.og_file_paths:
				index_with_right_name = updateCSV_info.og_file_paths[k].find(j["file"])
				if index_with_right_name != -1:
					right_string = k
					break
			if index_with_right_name == -1:
				push_error("There is no such name in the info: ",j["file"])
				return
			id_and_name_in_canvas[j["id"]] = right_string
		if debug:
			print("id_and_name_in_canvas: ",id_and_name_in_canvas)
		new_resource_imported_canvas.dialogue_tree[i] = {}
		for j : Dictionary in json_data["edges"]:
			var cur_translation_name := id_and_name_in_canvas[j["fromNode"]]
			if not cur_translation_name in new_resource_imported_canvas.dialogue_tree[i]:
				new_resource_imported_canvas.dialogue_tree[i][cur_translation_name] = []
			new_resource_imported_canvas.dialogue_tree[i][cur_translation_name].append(id_and_name_in_canvas[j["toNode"]])
	var imported_canvas_path := resource.output_folder_path+"/"+resource.output_file_name+".tres"
	if ResourceLoader.exists(imported_canvas_path):
		var old_resource : Resource_imported_canvas = ResourceLoader.load(resource.output_folder_path+"/"+resource.output_file_name+".tres")
		old_resource.dialogue_tree = new_resource_imported_canvas.dialogue_tree
		new_resource_imported_canvas = old_resource
		new_resource_imported_canvas.take_over_path(imported_canvas_path)
	ResourceSaver.save(new_resource_imported_canvas,imported_canvas_path)
	_reimport_files([imported_canvas_path])

func get_files_from_dir(dir_path:String) -> PackedStringArray:
	var file_paths := DirAccess.get_files_at(dir_path)
	if debug:
		print(file_paths)
	return file_paths

func _on_button_pressed() -> void:
	if updateCSV_r is UpdateCSV_resource:
		if !_check_update_CSV_resource(updateCSV_r):
			return
		_update_csv(updateCSV_r)
	elif updateCSV_r is UpdateCSV_resources:
		if updateCSV_r.resources.is_empty():
			push_error(updateCSV_r.resource_name,": ","No resources")
			return
		for i in updateCSV_r.resources:
			if !_check_update_CSV_resource(i):
				return
			_update_csv(i)
	elif updateCSV_r is UpdateCSV_resource_canvas:
		if !_check_update_CSV_resource_canvas(updateCSV_r):
			return
		_turn_canvas_into_resource(updateCSV_r)

func _reimport_files(file_paths:PackedStringArray,update_file:bool=false) -> void:
	var cur_filesystem := EditorInterface.get_resource_filesystem()
	if !update_file:
		for i in file_paths:
			cur_filesystem.update_file(i)
	else:
		cur_filesystem.reimport_files(file_paths)

func _check_update_CSV_resource_canvas(resource:UpdateCSV_resource_canvas) -> bool:
	if resource.main_folder_path.is_empty():
		push_error(resource.resource_name,": ","No main folder")
		return false
	if resource.output_folder_path.is_empty():
		push_error(resource.resource_name,": ","No output folder")
		return false
	if resource.canvas_names.is_empty():
		push_error(resource.resource_name,": ","No canvas_names")
		return false
	return true

func _check_update_CSV_resource(resource:UpdateCSV_resource) -> bool:
	if resource.main_folder_path.is_empty():
		push_error(resource.resource_name,": ","No main folder")
		return false
	if resource.output_folder_path.is_empty():
		push_error(resource.resource_name,": ","No output folder")
		return false
	if resource.folders.is_empty():
		push_error(resource.resource_name,": ","No folders")
		return false
	if resource.languages.is_empty():
		push_error(resource.resource_name,": ","No languages")
		return false
	return true

func _load_resource(resource_path:String) -> void:
	var resource_instance := load(resource_path)
	if resource_instance is UpdateCSV_resource or resource_instance is UpdateCSV_resources or resource_instance is UpdateCSV_resource_canvas:
		button_update.disabled = false
		updateCSV_r = resource_instance
		label_update_csv_resource.text = _get_resource_name(updateCSV_r)
		if resource_instance is UpdateCSV_resource:
			label_main_folder.text = "[b]Main folder[/b]\n"+updateCSV_r.main_folder_path
			label_output_folder.text = "[b]Output folder[/b]\n"+updateCSV_r.output_folder_path
			var all_languages : String
			for i in updateCSV_r.languages:
				all_languages += i+" "
			label_languages.text = "[b]Languages[/b]\n"+all_languages
			if !resource_instance.info_file_name.is_empty() and !resource_instance.info_file_path.is_empty():
				label_info_path.text = "[b]Info path[/b]\n"+resource_instance.info_file_name+": "+resource_instance.info_file_path
			else:
				label_info_path.text = NO_INFO_PATH_LINE
		elif resource_instance is UpdateCSV_resources:
			label_main_folder.text = "[b]Main folders[/b]\n"
			label_output_folder.text = "[b]Output folders[/b]\n"
			label_languages.text = "[b]Languages[/b]\n"
			label_info_path.text = "[b]Info paths[/b]\n"
			for i in range(0,updateCSV_r.resources.size()):
				label_main_folder.text += str(i)+") "+updateCSV_r.resources[i].main_folder_path+"\n"
				label_output_folder.text += str(i)+") "+updateCSV_r.resources[i].output_folder_path+"\n"
				label_languages.text += str(i)+") "
				for j in updateCSV_r.resources[i].languages:
					label_languages.text += j+" "
				label_languages.text += "\n"
				if !updateCSV_r.resources[i].info_file_name.is_empty() and !updateCSV_r.resources[i].info_file_path.is_empty():
					label_info_path.text += str(i)+") "+updateCSV_r.resources[i].info_file_name+": "+updateCSV_r.resources[i].info_file_path+"\n"
				else:
					label_info_path.text += str(i)+") "+NO_INFO_PATH_LINE.get_slice("\n",1)+"\n"
		elif resource_instance is UpdateCSV_resource_canvas: # TODO
			label_main_folder.text = "[b]Main folder[/b]\n"+updateCSV_r.main_folder_path
			label_output_folder.text = "[b]Output folder[/b]\n"+updateCSV_r.output_folder_path
			label_languages.text = "[b]Canvas names[/b]\n"
			for i in updateCSV_r.canvas_names:
				label_languages.text += i+" "
			if !resource_instance.info_file_path.is_empty():
				label_info_path.text = "[b]Info path[/b]\n"+resource_instance.info_file_path
			else:
				label_info_path.text = "[color=red]INFO WILL BE REQUIRED FOR THIS. FILL info_file_path IN UpdateCSV_resource_canvas TO USE IT[/color]"
				button_update.disabled = true
	else:
		push_error("Wrong type of resource")

func _get_resource_name(resource:UpdateCSV_base_resource) -> String:
	return resource.resource_path.rsplit("/",true,1)[1].get_slice(".",0)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if _are_files_resources(data["files"]):
		_load_resource(data["files"][0])

func _are_files_resources(files:Array) -> bool:
	for i in files:
		if !i.ends_with(".tres"):
			return false
	return true

func _on_check_button_debug_toggled(toggled_on: bool) -> void:
	debug = toggled_on
