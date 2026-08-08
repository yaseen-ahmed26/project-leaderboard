extends Node

var runtime_stats: Dictionary = {
	"cookies": 0
}

func add_cookies():
	runtime_stats["cookies"] += 1
	Signals.stats_changed.emit(runtime_stats)
