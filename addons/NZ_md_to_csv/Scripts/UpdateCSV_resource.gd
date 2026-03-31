@icon("res://addons/NZ_md_to_csv/Icons/MD_to_CSV_resource.svg")
class_name UpdateCSV_resource
extends UpdateCSV_base_resource

@export var main_folder_path : String ## This is a path to a folder with .md files
@export var output_folder_path : String ## This is a path to a folder, in which will be created .csv files
@export var folders : Array[String] ## names of folders to scan
@export var languages : Array[String] ## en, ru, fr, de, etc...
@export var separator : String = "_" ## This will be between folder name, line number and a file name
@export var excluded_file_names : Array[String] ## File with those names (excluding format file from the file name) will not be imported 
@export var include_folder_name : bool = true
@export var include_line_number : bool = false
@export_group("Other")
@export var remove_links : bool = true
@export var character_to_remove : String = "カ" ## When removing links, characters related to the links will be changed to that symbol to quickly remove them later.
@export_group("Info","info_")
@export var info_file_name : String ## Not required.
@export var info_file_path : String ## Not required. Some info might be needed for other stuff, put here the path to a folder, where will be created UpdateCSV_info resource with helpful for later use (ex. when importing a canvas).
@export var info_rfolder_stop_name : String ## Everything before this folder will be removed from the path
