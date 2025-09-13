@icon("res://addons/NZ_md_to_csv/Icons/MD_to_CSV_resource.svg")
class_name UpdateCSV_resource
extends Resource

@export var main_folder_path : String ## This is a path to a folder with md files
@export var output_folder_path : String ## This is a path to a folder, in which will be created csv files
@export var folders : Array[String] ## names of a folders to scan
@export var languages : Array[String] ## en, ru, fr, de, etc...
@export var separator : String = "_" ## This will be between folder name, global line number and a file name
