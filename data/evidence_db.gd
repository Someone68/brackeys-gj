extends Node
class_name EvidenceDB

const FALLBACK_ICON := "res://sprites/scroll_ui.png"

const ITEMS := {
	"placeholder_evidence": {
		"label": "test evidence",
		"desc": "this is some test evidence",
		"icon": "res://sprites/scroll_ui.png",
	},
	"knives": {
		"label": "Knives",
		"desc": "The bar's knife rack, one knife short.",
		"icon": "res://sprites/knives.png",
		"implicates": ["ace"],
	},
	"blood_spatter_green": {
		"label": "Blood splatter (Green's house)",
		"desc": "Dried blood on the wall outside Green's house. Nowhere near the bar.",
		"icon": "res://sprites/blood_splatter2.png",
	},
	"blood_splatter_cs": {
		"label": "Blood splatter (mart)",
		"desc": "Dried blood on the wall by the convenience store. Nowhere near the bar.",
		"icon": "res://sprites/blood_splatter3.png",
	},
	"blood_splatter_bar": {
		"label": "Blood splatter",
		"desc": "Dried blood sprayed across the wall of the alley behind the bar.",
		"icon": "res://sprites/blood_splatter.png",
		"implicates": ["ace"],
	},
	"drugs_and_money": {
		"label": "Drugs and money",
		"desc": "Narcotics and cash, found in the back room of the convenience store.",
		"icon": "res://sprites/drugs_money.png",
		"implicates": ["mrken"],
	},
	"drugs": {
		"label": "Drugs",
		"desc": "Methamphetamine, found splattered behind the convenience store.",
		"icon": "res://sprites/drugs.png",
		"implicates": ["mrken"],
	},
}

static func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})

static func get_label(id: String) -> String:
	return ITEMS.get(id, {}).get("label", id)

static func get_icon(id: String) -> Texture2D:
	return load(ITEMS.get(id, {}).get("icon", FALLBACK_ICON))
