class_name NPCProfile extends Resource

@export var id: String
@export var display_name: String
@export var dialogue: NPCDialogue

## options that the player has to confront the NPC.
## the second option will start the confrontation sequence. Use %d if you want to show how many confrontations the player has remaining.
## the other 3 options are empty slots where you can add small talk.
## remember you are limited to ONE line of space, so you can't write much.
@export var confront_options : Array[String] = ["See ya later", "What do you know about [case]?", "slot 1 for random convo", "slot 2 for random convo"]
@export_multiline var slot_1_response : Array[String] = ["slot 1 response"]
@export_multiline var slot_2_response : Array[String] = ["slot 2 response"]
@export_multiline var leave_response : Array[String] = ["bye"]
