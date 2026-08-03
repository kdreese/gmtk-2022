extends ColorRect


signal credits_exiting

const SCROLL_SPEED := 1000.0

var main_licenses := [
	["Godot Engine", Engine.get_license_text()],
	["Russo One", "Copyright (c) 2011-2012, Jovanny Lemonad (jovanny.ru), with Reserved Font Name \"Russo\"\n\nThis Font Software is licensed under the SIL Open Font License, Version 1.1.\nThis license is copied below, and is also available with a FAQ at:\nhttp://scripts.sil.org/OFL\n\n\n-----------------------------------------------------------\nSIL OPEN FONT LICENSE Version 1.1 - 26 February 2007\n-----------------------------------------------------------\n\nPREAMBLE\nThe goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects, to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework in which fonts may be shared and improved in partnership with others.\n\nThe OFL allows the licensed fonts to be used, studied, modified and redistributed freely as long as they are not sold by themselves. The fonts, including any derivative works, can be bundled, embedded, redistributed and/or sold with any software provided that any reserved names are not used by derivative works. The fonts and derivatives, however, cannot be released under any other type of license. The requirement for fonts to remain under this license does not apply to any document created using the fonts or their derivatives.\n\nDEFINITIONS\n\"Font Software\" refers to the set of files released by the Copyright Holder(s) under this license and clearly marked as such. This may include source files, build scripts and documentation.\n\n\"Reserved Font Name\" refers to any names specified as such after the copyright statement(s).\n\n\"Original Version\" refers to the collection of Font Software components as distributed by the Copyright Holder(s).\n\n\"Modified Version\" refers to any derivative made by adding to, deleting, or substituting -- in part or in whole -- any of the components of the Original Version, by changing formats or by porting the Font Software to a new environment.\n\n\"Author\" refers to any designer, engineer, programmer, technical writer or other person who contributed to the Font Software.\n\nPERMISSION & CONDITIONS\nPermission is hereby granted, free of charge, to any person obtaining a copy of the Font Software, to use, study, copy, merge, embed, modify, redistribute, and sell modified and unmodified copies of the Font Software, subject to the following conditions:\n\n1) Neither the Font Software nor any of its individual components, in Original or Modified Versions, may be sold by itself.\n\n2) Original or Modified Versions of the Font Software may be bundled, redistributed and/or sold with any software, provided that each copy contains the above copyright notice and this license. These can be included either as stand-alone text files, human-readable headers or in the appropriate machine-readable metadata fields within text or binary files as long as those fields can be easily viewed by the user.\n\n3) No Modified Version of the Font Software may use the Reserved Font Name(s) unless explicit written permission is granted by the corresponding Copyright Holder. This restriction only applies to the primary font name as presented to the users.\n\n4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font Software shall not be used to promote, endorse or advertise any Modified Version, except to acknowledge the contribution(s) of the Copyright Holder(s) and the Author(s) or with their explicit written permission.\n\n5) The Font Software, modified or unmodified, in part or in whole, must be distributed entirely under this license, and must not be distributed under any other license. The requirement for fonts to remain under this license does not apply to any document created using the Font Software.\n\nTERMINATION\nThis license becomes null and void if any of the above conditions are not met.\n\nDISCLAIMER\nTHE FONT SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE."],
]

@onready var licenses_label: RichTextLabel = %LicensesLabel


func _process(delta: float) -> void:
	var axis := Input.get_axis("ui_up", "ui_down")
	$V/S.scroll_vertical += int(axis * delta * SCROLL_SPEED)


func show_menu() -> void:
	if licenses_label.text.is_empty():
		licenses_label.parse_bbcode(generate_license_bbcode_text())
	$V/S.scroll_vertical = 0
	show()
	$BackButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
		get_viewport().set_input_as_handled()


func _on_BackButton_pressed() -> void:
	hide()
	emit_signal("credits_exiting")


func generate_license_bbcode_text() -> String:
	var text := "[center][font_size=36]Licenses[/font_size][/center]"

	for license: Array in main_licenses:
		text += "\n\n[center][font_size=20]" + license[0] + "[/font_size][/center]\n\n"
		text += "[font_size=9]" + license[1].strip_edges() + "[/font_size]"

	text += "\n\n[center][font_size=26]All Third-Party Licenses[/font_size][/center]"

	# These engine license/copyright functions are not incredibly obvious how to usefully extract information from.
	# This is similar to how it's done in the "About Godot" -> "Third-party Licenses" -> "All Components" screen
	for info in Engine.get_copyright_info():
		text += "\n\n[center][font_size=18]" + info.name + "[/font_size][/center]\n[font_size=14]"
		for part: Dictionary in info.parts:
			for copyright: String in part.copyright:
				text += "\n(c) " + copyright
			text += "\nLicense: " + part.license
		text += "[/font_size]"

	var engine_licenses := Engine.get_license_info()
	for license: String in engine_licenses:
		text += "\n\n[center][font_size=18]" + license + "[/font_size][/center]\n\n"
		text += "[font_size=8]" + engine_licenses[license] + "[/font_size]"

	return text
