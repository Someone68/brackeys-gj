extends Node

## one place for every sound: music that follows the game state, and one-shot
## effects fired from wherever they happen.
const MUSIC := {
	"town": "res://sounds/town.wav",
	"tense": "res://sounds/tense.wav",
}
const SFX := {
	"pickup": "res://sounds/pickup.wav",
	"starttrial": "res://sounds/starttrial.wav",
	"verdict": "res://sounds/verdict.wav",
}

var playing := ""

@onready var _music: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music.name = "Music"
	add_child(_music)

## starts the named track, or stops the music when given "". re-asking for the
## track already playing is ignored, so a scene change does not restart it.
func play_music(track: String, volume := 1.0) -> void:
	if track == playing:
		return
	playing = track
	if track == "":
		_music.stop()
		return
	if not MUSIC.has(track):
		push_error("audio: no music '%s'" % track); return
	var stream := load(MUSIC[track])
	# force the loop on the loaded sample: the import setting alone does not
	# survive a fresh import of these files, and background music must not stop
	if stream is AudioStreamWAV and stream.loop_mode == AudioStreamWAV.LOOP_DISABLED:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_music.stream = stream
	_music.volume_db = linear_to_db(volume)
	_music.play()

func stop_music() -> void:
	play_music("")

## one-shot, on its own player, so effects can overlap and never cut the music
func play_sfx(effect: String, volume := 1.0) -> void:
	if not SFX.has(effect):
		push_error("audio: no sound '%s'" % effect); return
	var p := AudioStreamPlayer.new()
	p.stream = load(SFX[effect])
	p.volume_db = linear_to_db(volume)
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()
