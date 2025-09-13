@tool
extends EditorPlugin

var update_csv : Control

func _enter_tree() -> void:
	update_csv = load("res://addons/NZ_md_to_csv/Scenes/UpdateCSV.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR,update_csv)
	set_dock_tab_icon(update_csv,preload("res://addons/NZ_md_to_csv/Icons/MD_to_CSV.svg"))

func _exit_tree() -> void:
	remove_control_from_docks(update_csv)
