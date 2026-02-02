extends CanvasLayer

@onready var score_label: Label = get_node_or_null("ScoreLabel")
@onready var best_label: Label = get_node_or_null("BestLabel")
@onready var heat_bar: Range = get_node_or_null("HeatBar")
@onready var overheat_label: CanvasItem = get_node_or_null("OverheatLabel")
@onready var game_over_label: CanvasItem = get_node_or_null("GameOverLabel")

func set_score(value: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % value

func set_best(value: int) -> void:
	if best_label:
		best_label.text = "Best: %d" % value

func set_heat(current: float, max_value: float, overheated: bool) -> void:
	if heat_bar:
		heat_bar.max_value = max_value
		heat_bar.value = current
	if overheat_label:
		overheat_label.visible = overheated

func show_game_over(show: bool) -> void:
	if game_over_label:
		game_over_label.visible = show
