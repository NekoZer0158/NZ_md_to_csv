@icon("res://addons/NZ_md_to_csv/Icons/UpdateCSV_resource_canvas.svg")
class_name UpdateCSV_resource_canvas
extends UpdateCSV_base_resource

## Turn your canvas with dialogue trees into a resource with a dictionary [br]
## How to use it:[br]
## 1) Update csv file using UpdateCSV_resource with filled: info_file_name, info_file_path and info_rfolder_stop_name[br]
## 2) Open your UpdateCSV_resource_canvas file and put a path to the info file in info_file_path (including file name and format)[br]
## 3) Put your UpdateCSV_resource_canvas in UpdateCSV dock and press "Update"

@export var main_folder_path : String ## This is a path to a folder with .canvas files
@export var output_file_name : String
@export var output_folder_path : String ## This is a path to a folder, in which will be created Resource_imported_canvas resource files
@export var canvas_names : Array[String]
@export var separator : String = "_" ## This will be between folder name and a file name
@export var info_file_path : String
