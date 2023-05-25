# ##############################################################################
#
# This holds all the configuratoin values for GUT.  It can load and save values
# to a json file.  It is also responsible for applying these settings to GUT.
#
# ##############################################################################
var Gut = load('res://addons/gut/gut.gd')


var valid_fonts = ['AnonymousPro', 'CourierPro', 'LobsterTwo', 'Default']
var default_options = {
	background_color = Color(.15, .15, .15, 1).to_html(),
	config_file = 'res://.gutconfig.json',
	dirs = [],
	disable_colors = false,
	# double strategy can be the name of the enum value, the enum value or
	# lowercase name with spaces:  0/SCRIPT_ONLY/script only
	# The GUI gut config expects the value to be the enum value and not a string
	# when saved.
	double_strategy = 'SCRIPT_ONLY',
	font_color = Color(.8, .8, .8, 1).to_html(),
	font_name = 'CourierPrime',
	font_size = 16,
	hide_orphans = false,
	ignore_pause = false,
	include_subdirs = false,
	inner_class = '',
	junit_xml_file = '',
	junit_xml_timestamp = false,
	log_level = 1,
	opacity = 100,
	paint_after = .1,
	post_run_script = '',
	pre_run_script = '',
	prefix = 'test_',
	selected = '',
	should_exit = false,
	should_exit_on_success = false,
	should_maximize = false,
	compact_mode = false,
	show_help = false,
	suffix = '.gd',
	tests = [],
	unit_test_name = '',

	gut_on_top = true,
}

var default_panel_options = {
	font_name = 'CourierPrime',
	font_size = 16,
	output_font_name = 'CourierPrime',
	output_font_size = 30,
	hide_result_tree = false,
	hide_output_text = false,
	hide_settings = false,
	use_colors = true
}

var options = default_options.duplicate()
var json = JSON.new()


func _null_copy(h):
	var new_hash = {}
	for key in h:
		new_hash[key] = null
	return new_hash


func _load_options_from_config_file(file_path, into):
	# SHORTCIRCUIT
	if(!FileAccess.file_exists(file_path)):
		if(file_path != 'res://.gutconfig.json'):
			print('ERROR:  Config File "', file_path, '" does not exist.')
			return -1
		else:
			return 1

	var f = FileAccess.open(file_path, FileAccess.READ)
	if(f == null):
		var result = FileAccess.get_open_error()
		push_error(str("Could not load data ", file_path, ' ', result))
		return result

	var json = f.get_as_text()
	f = null # close file

	var test_json_conv = JSON.new()
	test_json_conv.parse(json)
	var results = test_json_conv.get_data()
	# SHORTCIRCUIT
	if(results == null):
		print("\n\n",'!! ERROR parsing file:  ', file_path)
		print('    at line ', results.error_line, ':')
		print('    ', results.error_string)
		return -1

	# Get all the options out of the config file using the option name.  The
	# options hash is now the default source of truth for the name of an option.
	_load_dict_into(results, into)

	return 1

func _load_dict_into(source, dest):
	for key in dest:
		if(source.has(key)):
			if(source[key] != null):
				if(typeof(source[key]) == TYPE_DICTIONARY):
					_load_dict_into(source[key], dest[key])
				else:
					dest[key] = source[key]


# Apply all the options specified to _tester.  This is where the rubber meets
# the road.
func _apply_options(opts, _tester):
	_tester.include_subdirectories = opts.include_subdirs

	if(opts.inner_class != ''):
		_tester.inner_class_name = opts.inner_class
	_tester.log_level = opts.log_level
	_tester.ignore_pause_before_teardown = opts.ignore_pause

	_tester.select_script(opts.selected)

	for i in range(opts.dirs.size()):
		_tester.add_directory(opts.dirs[i], opts.prefix, opts.suffix)

	for i in range(opts.tests.size()):
		_tester.add_script(opts.tests[i])

	# Sometimes it is the index, sometimes it's a string.  This sets it regardless
	_tester.double_strategy = GutUtils.get_enum_value(
		opts.double_strategy, GutUtils.DOUBLE_STRATEGY,
		GutUtils.DOUBLE_STRATEGY.INCLUDE_NATIVE)

	_tester.unit_test_name = opts.unit_test_name
	_tester.pre_run_script = opts.pre_run_script
	_tester.post_run_script = opts.post_run_script
	_tester.color_output = !opts.disable_colors
	_tester.show_orphans(!opts.hide_orphans)
	_tester.junit_xml_file = opts.junit_xml_file
	_tester.junit_xml_timestamp = opts.junit_xml_timestamp
	_tester.paint_after = str(opts.paint_after).to_float()

	return _tester

# --------------------------
# Public
# --------------------------
func write_options(path):
	var content = json.stringify(options, ' ')

	var f = FileAccess.open(path, FileAccess.WRITE)
	var result = FileAccess.get_open_error()
	if(f != null):
		f.store_string(content)
		f = null # closes file
	else:
		print('ERROR:  could not open file ', path, ' ', result)
	return result


func load_options(path):
	return _load_options_from_config_file(path, options)


func load_panel_options(path):
	options['panel_options'] = default_panel_options.duplicate()
	return _load_options_from_config_file(path, options)


func load_options_no_defaults(path):
	options = _null_copy(default_options)
	return _load_options_from_config_file(path, options)


func apply_options(gut):
	_apply_options(options, gut)




# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2023 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################
