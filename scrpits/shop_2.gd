extends Control

# UI References
@onready var metro_buy_button = $CanvasLayer/TextureRect/buy
@onready var metro_status_label = $CanvasLayer/TextureRect/statusLabel
@onready var currency_label = $CanvasLayer/currencyDisplay/currencyLabel

func _ready():
	# Connect buttons
	if metro_buy_button:
		metro_buy_button.pressed.connect(_on_metro_buy_pressed)
	
	# Connect to Global signals
	Global.currency_changed.connect(_on_currency_changed)
	Global.metro_purchased_signal.connect(_on_metro_purchased_updated)
	
	# Initial UI update
	_update_metro_ui()
	_update_currency_display()

func _on_metro_buy_pressed():
	# Check if already purchased
	if Global.metro_purchased:
		print("Metro power already purchased!")
		return
	
	# Check if player can afford it
	if Global.currency >= Global.METRO_COST:
		Global.currency -= Global.METRO_COST
		Global.metro_purchased = true
		Global.currency_changed.emit(Global.currency)
		Global.metro_purchased_signal.emit()
		print("🚇 Metro power purchased for ", Global.METRO_COST, " gold!")
		_update_metro_ui()
		
		# Save the purchase
		SaveManager.save_game()
	else:
		print("Not enough gold to buy metro power!")

func _on_currency_changed(new_amount: int):
	_update_currency_display()
	_update_metro_ui()

func _on_metro_purchased_updated():
	_update_metro_ui()

func _update_currency_display():
	if currency_label:
		currency_label.text = str(Global.currency)

func _update_metro_ui():
	if not metro_buy_button or not metro_status_label:
		return
	
	if Global.metro_purchased:
		metro_buy_button.disabled = true
		metro_buy_button.text = "PURCHASED"
		metro_buy_button.modulate = Color.GRAY
		metro_status_label.text = "Metro Power: OWNED"
		metro_status_label.modulate = Color.GREEN
	else:
		var can_afford = Global.currency >= Global.METRO_COST
		metro_buy_button.disabled = not can_afford
		metro_buy_button.text = "BUY - " + str(Global.METRO_COST) + " GOLD"
		metro_buy_button.modulate = Color.WHITE if can_afford else Color.GRAY
		metro_status_label.text = "Metro Power: NOT OWNED"
		metro_status_label.modulate = Color.RED

func _on_back_button_pressed():
	SceneTransition.change_scene_with_fade("res://scenes/main_menu.tscn")

func _on_shop_2_button_pressed():
	SceneTransition.change_scene_with_fade("res://scenes/shop_menu.tscn")
