@tool
@icon("res://addons/NZ_md_to_csv/Icons/MD_to_CSV.svg")
extends Control

@onready var label_update_csv_resource: Label = $LabelUpdateCSV_resource
@onready var label_main_folder: Label = $LabelMainFolder
@onready var label_output_folder: Label = $LabelOutputFolder
@onready var label_languages: Label = $LabelLanguages

var debug : bool = false
var updateCSV_r : UpdateCSV_base_resource

func _update_csv(resource:UpdateCSV_resource) -> void:
	var local_main_folder_path : String
	local_main_folder_path = resource.main_folder_path.replace("\\","/")
	if debug:
		print(local_main_folder_path)
	for i in resource.folders:
		var cur_files_path : String = local_main_folder_path
		if !cur_files_path.ends_with("/"):
			cur_files_path = local_main_folder_path+"/"+i
			if debug:
				print(cur_files_path)
		else:
			cur_files_path = local_main_folder_path+i
		var file_paths := get_files_from_dir(cur_files_path)
		var line_number : int = 0
		var cur_translation_fiile := FileAccess.open(resource.output_folder_path+i+".csv",FileAccess.WRITE)
		var local_languages := resource.languages.duplicate(true)
		local_languages.push_front("keys")
		cur_translation_fiile.store_csv_line(local_languages)
		for j in file_paths:
			if debug:
				print(j)
			var translations_for_one_line : PackedStringArray = [i+resource.separator+str(line_number)+resource.separator+j.get_slice(".",0)]
			var cur_file := FileAccess.open(cur_files_path+"/"+j,FileAccess.READ)
			if cur_file != null:
				while cur_file.get_position() < cur_file.get_length():
					translations_for_one_line.append(cur_file.get_line())
				cur_translation_fiile.store_csv_line(translations_for_one_line)
			else:
				push_error("Can't open file")

func get_files_from_dir(dir_path:String) -> PackedStringArray:
	var file_paths := DirAccess.get_files_at(dir_path)
	if debug:
		print(file_paths)
	return file_paths

func _on_button_pressed() -> void:
	if updateCSV_r is UpdateCSV_resource:
		if !check_update_CSV_resource(updateCSV_r):
			return
		_update_csv(updateCSV_r)
	elif updateCSV_r is UpdateCSV_resources:
		for i in updateCSV_r.resources:
			if !check_update_CSV_resource(i):
				return
			_update_csv(i)

func check_update_CSV_resource(resource:UpdateCSV_resource) -> bool:
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
	if resource_instance is UpdateCSV_resource or resource_instance is UpdateCSV_resources:
		updateCSV_r = resource_instance
		label_update_csv_resource.text = _get_resource_name(updateCSV_r)
		if resource_instance is UpdateCSV_resource:
			label_main_folder.text = "Main folder\n"+updateCSV_r.main_folder_path
			label_output_folder.text = "Output folder\n"+updateCSV_r.output_folder_path
			var all_languages : String
			for i in updateCSV_r.languages:
				all_languages += i+" "
			label_languages.text = "Languages\n"+all_languages
		else:
			label_main_folder.text = "Main folder\nThere are multiple files"
			label_output_folder.text = "Output folder\nThere are multiple files"
			label_languages.text = "..."
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
