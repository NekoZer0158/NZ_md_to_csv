# NZ md to csv
Plugin to convert md files to csv files and use them as translations. When you use, for example, Obsidian with md files to have a better workplace for dialogues with different paths for RPGs, you don't need to manually copy-paste everything from it to your Godot project; you can just use this plugin and, in one press of a button, convert all needed md files into csv files. <br>
Should work with any file paths.
Check GitHub, if you want to see different ways of how you can use this plugin.

## Changelog

### 1.5
	You can now remove vault links from exported files.
	Add proper reimport, now you don't need to click outisde Godot to reimport files.
### 1.4
	Add UpdateCSV_resource_canvas - use it to import canvases from Obsidian into Resource_imported_canvas (see example_vault for how it works)
	Add UpdateCSV_info - needed for importing some additional things from the files, that can be used later (ex. for UpdarteCSV_resource_canvas)
	Now you can exclude unnecessary files, just put their names in excluded_file_names in UpdateCSV_resource
	Small change in the documentation
### 1.3
	Fix line number in the output .csv files, now it will not be always 0
	Fix bug that stored all lines from file even if there was less languages than lines
	Line number now can be disabled
	Now you can remove folder name from the output
### 1.2
	Some labels were changed to RichTextLabel
	Improve visuals in UpdateCSV dock
	Now you can see all paths and languages in UpdateCSV when using UpdateCSV_resources
	Update MD_to_CSV_resources and MD_to_CSV_base_resource icons
	The "Update" button is disabled by default now, you need to drag'n'drop a resource to be able to press it
### 1.1
	You can now update mupltiple UpdateCSV_resource files at once using UpdateCSV_resources
