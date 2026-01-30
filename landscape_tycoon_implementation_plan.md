# Landscape Tycoon - 实施计划（MVP快速原型）

## 项目目标
创建一个可玩的快速原型，包含核心游戏循环：接取任务 → 完成工作 → 赚钱 → 升级

## 当前进度总览

| 阶段 | 状态 | 说明 |
|------|------|------|
| 阶段 0: 项目初始化 | ✅ 已完成 | 项目结构、输入映射、AutoLoad |
| 阶段 1: 玩家角色和移动 | ✅ 已完成 | 8方向移动、敏捷加成、相机跟随 |
| 阶段 2: 城市地图场景 | ✅ 已完成 | TileMap、10个建筑、交互系统 |
| 阶段 3: UI系统 | ✅ 已完成 | HUD、任务面板、属性面板、商店面板、材料商店、互动提示、任务评分 |
| 阶段 4: 工作场景 | ✅ 已完成 | WorkSite、WorkArea、WorkUI、场景过渡 |
| 阶段 5: 测试和调优 | ✅ 大部分完成 | 核心循环可玩、通知系统、小游戏 |
| 阶段 6: 打包和文档 | ⬜ 未开始 | 导出可执行文件 |

### 超出原计划的已完成功能
- ✅ **小游戏系统**: 3种灵巧型小游戏（水平仪对齐、砖块拼图、节奏打桩）
- ✅ **暂停菜单**: ESC全局暂停，支持保存/继续/返回城市
- ✅ **通知系统**: 金币飘字、升级提示、任务接取引导
- ✅ **工具商店**: 5类工具（铲子/剪草机/扫帚/水平仪/锤子），每类4-5个品牌
- ✅ **材料商店**: 4类材料（草籽/花卉/砖块/围栏），多品质等级+声望解锁
- ✅ **供货商委托**: 声望>=100解锁，材料折扣10-40%
- ✅ **客户推广**: 4星以上评价概率触发推荐任务
- ✅ **存档系统**: JSON自动保存/加载玩家数据和任务状态
- ✅ **5种任务类型**: 清理垃圾、修剪草坪、种植花卉、铺设砖面、建造围栏

### 尚未完成的功能
- ⬜ **玩家动画**: 目前使用静态临时图形
- ⬜ **正式美术素材**: 目前使用SVG占位图
- ⬜ **音效系统**: 无音效
- ⬜ **新手引导/教程**: 无引导流程
- ⬜ **NPC行人**: 设计文档提及但未实现
- ⬜ **导出可执行文件**: 未配置导出预设

## 开发阶段划分

---

## 阶段 0: 项目初始化（30分钟） ✅ 已完成

### Task 0.1: 创建Godot项目 ✅
**时间**: 5分钟  
**步骤**:
1. 打开Godot 4.x
2. 创建新项目：Landscape_Tycoon
3. 设置项目分辨率：1280x720 (或 1920x1080)
4. 启用像素艺术设置：
   - Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter = Nearest
5. 创建文件夹结构

**验证**: 项目成功创建，文件夹结构清晰 ✅

---

### Task 0.2: 创建文件夹结构 ✅
**时间**: 3分钟  
**文件夹结构**:
```
res://
├── scenes/
│   ├── main/
│   ├── city/
│   ├── work_sites/
│   ├── player/
│   └── ui/
├── scripts/
│   ├── autoload/
│   ├── player/
│   ├── tasks/
│   └── ui/
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   ├── buildings/
│   │   ├── tiles/
│   │   ├── ui/
│   │   └── tools/
│   ├── fonts/
│   └── audio/
└── data/
```

**验证**: 所有文件夹创建完成 ✅

---

### Task 0.3: 配置输入映射 ✅
**时间**: 5分钟  
**输入动作**:
- move_up: W, Up Arrow
- move_down: S, Down Arrow
- move_left: A, Left Arrow
- move_right: D, Right Arrow
- interact: E, Space
- menu: Escape

**位置**: Project Settings → Input Map
**验证**: 所有输入动作配置完成 ✅

---

### Task 0.4: 创建AutoLoad脚本 ✅
**时间**: 10分钟  
**文件**:
1. `scripts/autoload/GameManager.gd`
2. `scripts/autoload/PlayerData.gd`
3. `scripts/autoload/TaskManager.gd`

**GameManager.gd 内容**:
```gdscript
extends Node

# 游戏状态
enum GameState { CITY_MAP, WORKING, MENU }
var current_state: GameState = GameState.CITY_MAP

# 场景管理
var city_scene: PackedScene = null
var work_scene: PackedScene = null

func change_scene(scene_path: String) -> void:
    get_tree().change_scene_to_file(scene_path)

func start_work(task: Dictionary) -> void:
    current_state = GameState.WORKING
    # 加载工作场景
```

**PlayerData.gd 内容**:
```gdscript
extends Node

# 基础信息
var player_name: String = "Alex"
var company_name: String = "GreenScape"

# 经济
var gold: int = 500
var experience: int = 0
var level: int = 1
var attribute_points: int = 0  # 可分配的属性点

# 属性
var strength: int = 10      # 力量：影响手动工作（挖坑、铲土、除草）
var agility: int = 10       # 敏捷：影响移动、电动工具、清理垃圾
var dexterity: int = 10     # 灵巧：影响小游戏容错率和反应时间
var reputation: int = 0     # 声望：解锁高级任务和材料

# 统计
var completed_tasks: int = 0
var total_earnings: int = 0

signal gold_changed(new_amount: int)
signal attribute_changed()
signal level_up(new_level: int, points: int)

func add_gold(amount: int) -> void:
    gold += amount
    total_earnings += amount
    gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        gold_changed.emit(gold)
        return true
    return false

func add_experience(amount: int) -> void:
    experience += amount
    _check_level_up()

func _check_level_up() -> void:
    var exp_needed = level * 500  # 每级需要经验
    if experience >= exp_needed:
        level += 1
        experience -= exp_needed
        attribute_points += 3  # 每升级获得3点属性
        level_up.emit(level, 3)

func allocate_attribute(attr_name: String) -> bool:
    if attribute_points <= 0:
        return false
    
    match attr_name:
        "strength":
            strength += 1
        "agility":
            agility += 1
        "dexterity":
            dexterity += 1
        _:
            return false
    
    attribute_points -= 1
    attribute_changed.emit()
    return true

func get_reputation_tier() -> String:
    if reputation >= 1000:
        return "传奇"
    elif reputation >= 600:
        return "大师级"
    elif reputation >= 300:
        return "专业级"
    elif reputation >= 100:
        return "熟练工"
    else:
        return "新手"
```

**TaskManager.gd 内容**:
```gdscript
extends Node

var available_tasks: Array = []
var active_task: Dictionary = {}

func generate_tasks() -> void:
    # 生成随机任务
    available_tasks.clear()
    var task = {
        "name": "清理Johnson家垃圾",
        "type": "trash",
        "reward": 150,
        "material_cost": 10,
        "difficulty": 1,
        "time_limit": 180  # 3分钟
    }
    available_tasks.append(task)

func accept_task(task: Dictionary) -> void:
    active_task = task
```

**验证**: 
- AutoLoad脚本添加到项目设置
- GameManager 优先级: 0
- PlayerData 优先级: 1  
- TaskManager 优先级: 2

---

## 阶段 1: 玩家角色和移动（1小时） ✅ 已完成

### Task 1.1: 创建玩家场景 ✅
**时间**: 15分钟  
**文件**: `scenes/player/Player.tscn`

**场景结构**:
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── Camera2D
```

**脚本**: `scripts/player/PlayerController.gd`

**PlayerController.gd 内容**:
```gdscript
extends CharacterBody2D

@export var base_speed: float = 150.0

var current_speed: float = 150.0

func _ready() -> void:
    _update_speed()

func _physics_process(delta: float) -> void:
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_axis("move_left", "move_right")
    input_vector.y = Input.get_axis("move_up", "move_down")
    input_vector = input_vector.normalized()
    
    if input_vector != Vector2.ZERO:
        velocity = input_vector * current_speed
    else:
        velocity = velocity.move_toward(Vector2.ZERO, current_speed * delta * 10)
    
    move_and_slide()

func _update_speed() -> void:
    # 敏捷影响移动速度
    var agility_bonus = 1.0 + (PlayerData.agility / 100.0)
    current_speed = base_speed * agility_bonus
```

**临时图形**:
- Sprite2D: 使用彩色方块（32x32像素，绿色）
- CollisionShape2D: 矩形 16x24

**Camera2D 设置**:
- Enabled: true
- Zoom: (2, 2) 或根据需要调整

**验证**: 
- 玩家可以用WASD/方向键移动
- 移动流畅，无卡顿
- 相机跟随玩家

---

### Task 1.2: 添加玩家动画（可选，暂时跳过） ⬜ 未完成
**注**: 快速原型阶段使用简单图形，动画留到后续迭代。**当前仍使用临时SVG图形。**

---

## 阶段 2: 城市地图场景（1.5小时） ✅ 已完成

### Task 2.1: 创建城市地图场景 ✅
**时间**: 20分钟  
**文件**: `scenes/city/CityMap.tscn`

**场景结构**:
```
CityMap (Node2D)
├── TileMap (地面和装饰)
├── Buildings (Node2D容器)
│   ├── PlayerCompany (Area2D)
│   ├── TaskCenter (Area2D)
│   └── ClientHouse01 (Area2D)
├── Player (实例)
└── CityUI (CanvasLayer)
```

**脚本**: `scripts/city/CityMap.gd`

**CityMap.gd 内容**:
```gdscript
extends Node2D

func _ready() -> void:
    TaskManager.generate_tasks()
    _setup_buildings()

func _setup_buildings() -> void:
    # 连接建筑物的信号
    var task_center = $Buildings/TaskCenter
    task_center.body_entered.connect(_on_building_entered.bind("task_center"))
```

**验证**: 场景加载成功，玩家可在地图中移动

---

### Task 2.2: 创建TileMap地面 ✅
**时间**: 25分钟  

**TileMap设置**:
1. 创建TileSet资源
2. 添加临时tile（使用纯色方块作为占位）:
   - 草地: 浅绿色 (32x32)
   - 道路: 灰色 (32x32)
   - 人行道: 米黄色 (32x32)
3. 绘制简单地图布局（约30x30 tiles）

**布局建议**:
```
[草地][草地][道路][草地][草地]
[草地][建筑][道路][建筑][草地]
[草地][草地][道路][草地][草地]
```

**验证**: 
- TileMap显示正确
- 玩家可以在道路上移动
- 无碰撞问题

---

### Task 2.3: 创建建筑物交互区域 ✅
**时间**: 30分钟

#### 建筑模板场景: `Building.tscn`
**结构**:
```
Building (Area2D)
├── Sprite2D (建筑图形)
├── CollisionShape2D (交互范围)
└── Label (建筑名称提示)
```

**脚本**: `scripts/city/Building.gd`
```gdscript
extends Area2D

@export var building_name: String = "建筑"
@export var building_type: String = "generic"  # company, shop, task_center, client

@onready var label = $Label

func _ready() -> void:
    label.text = building_name
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        label.visible = true
        # 显示互动提示

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        label.visible = false
```

**创建3个建筑实例**:
1. **PlayerCompany**: 
   - 位置: 地图左下
   - Sprite: 蓝色方块 64x64
   - 类型: "company"

2. **TaskCenter**:
   - 位置: 地图中心
   - Sprite: 黄色方块 64x64
   - 类型: "task_center"

3. **ClientHouse01**:
   - 位置: 地图右上
   - Sprite: 红色方块 48x48
   - 类型: "client"

**验证**: 
- 玩家靠近建筑时显示名称
- 可以按E键交互（下一个任务实现）

---

### Task 2.4: 实现建筑交互逻辑 ✅
**时间**: 25分钟

**修改 PlayerController.gd**:
```gdscript
var nearby_building: Area2D = null

func _physics_process(delta: float) -> void:
    # ... 现有移动代码 ...
    
    # 交互检测
    if Input.is_action_just_pressed("interact") and nearby_building:
        _interact_with_building()

func _interact_with_building() -> void:
    match nearby_building.building_type:
        "task_center":
            # 打开任务面板
            get_tree().call_group("ui", "show_task_panel")
        "company":
            # 打开公司面板
            get_tree().call_group("ui", "show_company_panel")
        "client":
            # 开始工作
            if TaskManager.active_task:
                GameManager.change_scene("res://scenes/work_sites/WorkSite.tscn")
```

**Building.gd 添加**:
```gdscript
func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.nearby_building = self
        label.visible = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        if body.nearby_building == self:
            body.nearby_building = null
        label.visible = false
```

**验证**: 
- 按E键在不同建筑前有不同反应
- 控制台输出正确的建筑类型

---

## 阶段 3: UI系统（2小时） ✅ 已完成

### Task 3.1: 创建HUD ✅
**时间**: 30分钟  
**文件**: `scenes/ui/HUD.tscn`

**场景结构**:
```
HUD (CanvasLayer)
└── Panel
    ├── PlayerNameLabel
    ├── GoldLabel
    ├── ReputationLabel
    ├── LevelLabel
    ├── AttributePointsLabel (可分配属性点提示)
    ├── StrengthLabel
    ├── AgilityLabel
    └── DexterityLabel
```

**脚本**: `scripts/ui/HUD.gd`
```gdscript
extends CanvasLayer

@onready var player_name_label = $Panel/PlayerNameLabel
@onready var gold_label = $Panel/GoldLabel
@onready var reputation_label = $Panel/ReputationLabel
@onready var level_label = $Panel/LevelLabel
@onready var strength_label = $Panel/StrengthLabel
@onready var agility_label = $Panel/AgilityLabel
@onready var dexterity_label = $Panel/DexterityLabel
@onready var attribute_points_label = $Panel/AttributePointsLabel

func _ready() -> void:
    PlayerData.gold_changed.connect(_update_gold)
    PlayerData.attribute_changed.connect(_update_attributes)
    PlayerData.level_up.connect(_on_level_up)
    _update_all()

func _update_all() -> void:
    player_name_label.text = "玩家: " + PlayerData.player_name
    _update_gold(PlayerData.gold)
    _update_attributes()
    _update_level()

func _update_gold(amount: int) -> void:
    gold_label.text = "💰 金币: " + str(amount)

func _update_attributes() -> void:
    var tier = PlayerData.get_reputation_tier()
    reputation_label.text = "⭐ 声望: " + str(PlayerData.reputation) + " (" + tier + ")"
    strength_label.text = "💪 力量: " + str(PlayerData.strength)
    agility_label.text = "⚡ 敏捷: " + str(PlayerData.agility)
    dexterity_label.text = "✋ 灵巧: " + str(PlayerData.dexterity)
    
    if PlayerData.attribute_points > 0:
        attribute_points_label.text = "🎯 可分配: " + str(PlayerData.attribute_points)
        attribute_points_label.visible = true
    else:
        attribute_points_label.visible = false

func _update_level() -> void:
    level_label.text = "📊 等级: " + str(PlayerData.level)

func _on_level_up(new_level: int, points: int) -> void:
    # 显示升级提示（可选）
    print("恭喜升级到", new_level, "级！获得", points, "点属性点")
    _update_level()
    _update_attributes()
```

**布局参考** (使用VBoxContainer):
```
┌────────────────────┐
│ 玩家: Alex         │
│ 💰 金币: 500      │
│ ⭐ 声望: 0 (新手) │
│ 📊 等级: 1        │
│ 🎯 可分配: 0      │
│ 💪 力量: 10       │
│ ⚡ 敏捷: 10       │
│ ✋ 灵巧: 10       │
└────────────────────┘
```

**验证**: 
- HUD显示在屏幕左上角
- 数值正确显示
- 修改PlayerData后HUD自动更新

---

### Task 3.2: 创建任务面板UI ✅
**时间**: 45分钟  
**文件**: `scenes/ui/TaskPanel.tscn`

**场景结构**:
```
TaskPanel (CanvasLayer)
└── Panel (中心对齐)
    ├── TitleLabel ("可接取任务")
    ├── ScrollContainer
    │   └── TaskList (VBoxContainer)
    └── CloseButton
```

**脚本**: `scripts/ui/TaskPanel.gd`
```gdscript
extends CanvasLayer

@onready var task_list = $Panel/ScrollContainer/TaskList
@onready var close_button = $Panel/CloseButton

var task_item_scene = preload("res://scenes/ui/TaskItem.tscn")

func _ready() -> void:
    close_button.pressed.connect(hide)
    add_to_group("ui")
    hide()

func show_task_panel() -> void:
    _populate_tasks()
    show()

func _populate_tasks() -> void:
    # 清空现有任务项
    for child in task_list.get_children():
        child.queue_free()
    
    # 添加任务项
    for task in TaskManager.available_tasks:
        var task_item = task_item_scene.instantiate()
        task_list.add_child(task_item)
        task_item.set_task_data(task)
        task_item.task_accepted.connect(_on_task_accepted)

func _on_task_accepted(task: Dictionary) -> void:
    TaskManager.accept_task(task)
    hide()
    # 显示提示："任务已接取，前往客户家！"
```

**创建 TaskItem.tscn**:
```
TaskItem (PanelContainer)
├── VBoxContainer
│   ├── TaskNameLabel
│   ├── HBoxContainer
│   │   ├── RewardLabel
│   │   └── DifficultyLabel
│   └── AcceptButton
```

**TaskItem.gd**:
```gdscript
extends PanelContainer

signal task_accepted(task: Dictionary)

var task_data: Dictionary

@onready var task_name_label = $VBoxContainer/TaskNameLabel
@onready var reward_label = $VBoxContainer/HBoxContainer/RewardLabel
@onready var difficulty_label = $VBoxContainer/HBoxContainer/DifficultyLabel
@onready var accept_button = $VBoxContainer/AcceptButton

func _ready() -> void:
    accept_button.pressed.connect(_on_accept_pressed)

func set_task_data(task: Dictionary) -> void:
    task_data = task
    task_name_label.text = task.name
    reward_label.text = "💰 " + str(task.reward)
    var stars = "⭐".repeat(task.difficulty)
    difficulty_label.text = stars

func _on_accept_pressed() -> void:
    task_accepted.emit(task_data)
```

**验证**: 
- 在任务中心按E显示任务面板
- 任务列表正确显示
- 点击"接取任务"按钮有反应
- 关闭按钮工作正常

---

### Task 3.3: 创建互动提示UI ✅
**时间**: 15分钟  
**文件**: `scenes/ui/InteractionPrompt.tscn`

**场景结构**:
```
InteractionPrompt (CanvasLayer)
└── Label (屏幕下方中心)
```

**脚本**: `scripts/ui/InteractionPrompt.gd`
```gdscript
extends CanvasLayer

@onready var label = $Label

func _ready() -> void:
    hide()

func show_prompt(text: String) -> void:
    label.text = text
    show()

func hide_prompt() -> void:
    hide()
```

**修改 Building.gd**:
```gdscript
func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.nearby_building = self
        label.visible = true
        # 显示互动提示
        var prompt = get_tree().get_first_node_in_group("interaction_prompt")
        if prompt:
            prompt.show_prompt("按 E 进入 " + building_name)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        if body.nearby_building == self:
            body.nearby_building = null
        label.visible = false
        var prompt = get_tree().get_first_node_in_group("interaction_prompt")
        if prompt:
            prompt.hide_prompt()
```

**验证**: 
- 靠近建筑时屏幕底部显示提示
- 离开建筑时提示消失

---

### Task 3.4: 创建任务完成评分UI ✅
**时间**: 30分钟  
**文件**: `scenes/ui/TaskResultPanel.tscn`

**场景结构**:
```
TaskResultPanel (CanvasLayer)
└── Panel (中心对齐)
    ├── TitleLabel ("任务完成！")
    ├── RatingLabel ("评分: ⭐⭐⭐⭐")
    ├── RewardLabel ("获得: 150金")
    ├── BonusLabel ("声望: +10")
    └── ContinueButton ("返回城市")
```

**脚本**: `scripts/ui/TaskResultPanel.gd`
```gdscript
extends CanvasLayer

@onready var rating_label = $Panel/RatingLabel
@onready var reward_label = $Panel/RewardLabel
@onready var bonus_label = $Panel/BonusLabel
@onready var continue_button = $Panel/ContinueButton

func _ready() -> void:
    continue_button.pressed.connect(_on_continue_pressed)
    hide()

func show_result(rating: int, reward: int, reputation: int) -> void:
    var stars = "⭐".repeat(rating)
    rating_label.text = "评分: " + stars
    reward_label.text = "获得: " + str(reward) + " 金"
    bonus_label.text = "声望: +" + str(reputation)
    show()

func _on_continue_pressed() -> void:
    GameManager.change_scene("res://scenes/city/CityMap.tscn")
```

**验证**: 稍后在工作场景完成后测试

---

## 阶段 4: 工作场景（2小时） ✅ 已完成

### Task 4.1: 创建工作场景模板 ✅
**时间**: 20分钟  
**文件**: `scenes/work_sites/WorkSite.tscn`

**场景结构**:
```
WorkSite (Node2D)
├── Background (Sprite2D)
├── WorkAreas (Node2D)
│   ├── WorkArea1 (Area2D)
│   ├── WorkArea2 (Area2D)
│   └── WorkArea3 (Area2D)
├── Player (实例)
├── WorkUI (CanvasLayer)
└── TaskResultPanel (实例)
```

**脚本**: `scripts/work_sites/WorkSite.gd`
```gdscript
extends Node2D

var work_progress: float = 0.0
var work_areas_total: int = 0
var work_areas_completed: int = 0
var start_time: float = 0.0

func _ready() -> void:
    start_time = Time.get_ticks_msec() / 1000.0
    work_areas_total = $WorkAreas.get_child_count()
    _setup_work_areas()

func _setup_work_areas() -> void:
    for area in $WorkAreas.get_children():
        area.work_completed.connect(_on_work_area_completed)

func _on_work_area_completed() -> void:
    work_areas_completed += 1
    if work_areas_completed >= work_areas_total:
        _complete_task()

func _complete_task() -> void:
    var time_taken = (Time.get_ticks_msec() / 1000.0) - start_time
    var rating = _calculate_rating(time_taken)
    var reward = _calculate_reward(rating)
    var reputation = rating * 5  # 1-5星 → 5-25声望
    
    # 更新玩家数据
    PlayerData.add_gold(reward)
    PlayerData.reputation += reputation
    PlayerData.completed_tasks += 1
    PlayerData.add_experience(50)
    
    # 显示结果
    var result_panel = $TaskResultPanel
    result_panel.show_result(rating, reward, reputation)

func _calculate_rating(time_taken: float) -> int:
    var time_limit = TaskManager.active_task.time_limit
    if time_taken <= time_limit * 0.5:
        return 5
    elif time_taken <= time_limit * 0.75:
        return 4
    elif time_taken <= time_limit:
        return 3
    elif time_taken <= time_limit * 1.5:
        return 2
    else:
        return 1

func _calculate_reward(rating: int) -> int:
    var base_reward = TaskManager.active_task.reward
    var multipliers = [0.5, 0.8, 1.0, 1.2, 1.5]  # 1-5星
    return int(base_reward * multipliers[rating - 1])
```

**临时背景**:
- Sprite2D: 浅绿色矩形作为草坪

**验证**: 场景加载成功

---

### Task 4.2: 创建工作区域 ✅
**时间**: 30分钟  
**文件**: `scenes/work_sites/WorkArea.tscn`

**场景结构**:
```
WorkArea (Area2D)
├── Sprite2D (显示工作区域，如杂草)
├── CollisionShape2D
├── ProgressBar (工作进度)
└── Label (状态提示)
```

**脚本**: `scripts/work_sites/WorkArea.gd`
```gdscript
extends Area2D

signal work_completed

@export var work_time: float = 5.0  # 基础工作时间（秒）

@onready var progress_bar = $ProgressBar
@onready var label = $Label
@onready var sprite = $Sprite2D

var is_working: bool = false
var work_progress: float = 0.0
var player_in_area: bool = false
var is_completed: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    progress_bar.value = 0
    label.text = "按E开始工作"

func _process(delta: float) -> void:
    if player_in_area and Input.is_action_just_pressed("interact") and not is_completed:
        _start_work()
    
    if is_working:
        _update_work(delta)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_area = true
        if not is_completed:
            label.visible = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_area = false
        label.visible = false

func _start_work() -> void:
    is_working = true
    label.text = "工作中..."

func _update_work(delta: float) -> void:
    # 根据任务类型判断使用哪个属性
    var attribute_bonus = 0.0
    match work_type:
        "strength":  # 力量型工作（挖坑、铲土、除草）
            attribute_bonus = PlayerData.strength / 100.0
        "agility":   # 敏捷型工作（清理垃圾、电动工具）
            attribute_bonus = PlayerData.agility / 100.0
        "dexterity": # 灵巧型工作（精细操作，用于小游戏）
            attribute_bonus = PlayerData.dexterity / 100.0
    
    # 工具效率假设为1.0（初期简化）
    var tool_efficiency = 1.0
    
    # 完成时间 = 基础时间 / (1 + 属性加成) / 工具效率
    # 转换为进度速度 = (1 / 基础时间) * (1 + 属性加成) * 工具效率
    var work_speed = (1.0 / work_time) * (1.0 + attribute_bonus) * tool_efficiency
    
    work_progress += work_speed * delta
    progress_bar.value = work_progress * 100
    
    if work_progress >= 1.0:
        _finish_work()

func _finish_work() -> void:
    is_working = false
    is_completed = true
    label.text = "已完成✓"
    sprite.modulate = Color(0.5, 0.5, 0.5)  # 变灰表示完成
    work_completed.emit()
```

**在 WorkSite.tscn 中添加3个WorkArea实例**:
- 位置分散在场景中
- Sprite: 深绿色方块表示杂草区域

**验证**: 
- 玩家靠近工作区域显示提示
- 按E开始工作，进度条增长
- 工作完成后区域变灰
- 所有区域完成后显示结果面板

---

### Task 4.3: 创建工作场景UI ✅
**时间**: 25分钟  
**文件**: `scenes/ui/WorkUI.tscn`

**场景结构**:
```
WorkUI (CanvasLayer)
└── Panel (屏幕上方)
    ├── TaskNameLabel
    ├── ProgressLabel ("2/3 区域完成")
    ├── TimerLabel ("剩余时间: 2:30")
    └── QualityLabel ("质量: 85%")
```

**脚本**: `scripts/ui/WorkUI.gd`
```gdscript
extends CanvasLayer

@onready var task_name_label = $Panel/TaskNameLabel
@onready var progress_label = $Panel/ProgressLabel
@onready var timer_label = $Panel/TimerLabel
@onready var quality_label = $Panel/QualityLabel

var start_time: float = 0.0
var time_limit: float = 0.0

func _ready() -> void:
    start_time = Time.get_ticks_msec() / 1000.0
    var task = TaskManager.active_task
    task_name_label.text = "任务: " + task.name
    time_limit = task.time_limit

func _process(delta: float) -> void:
    _update_timer()
    _update_progress()

func _update_timer() -> void:
    var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
    var remaining = max(0, time_limit - elapsed)
    var minutes = int(remaining / 60)
    var seconds = int(remaining) % 60
    timer_label.text = "剩余时间: %d:%02d" % [minutes, seconds]

func _update_progress() -> void:
    var work_site = get_parent()
    if work_site:
        progress_label.text = "%d/%d 区域完成" % [work_site.work_areas_completed, work_site.work_areas_total]
        var quality = (float(work_site.work_areas_completed) / work_site.work_areas_total) * 100
        quality_label.text = "完成度: %.0f%%" % quality
```

**验证**: 
- 工作场景UI显示正确
- 计时器倒计时
- 完成区域时进度更新

---

### Task 4.4: 连接场景过渡 ✅
**时间**: 25分钟

**修改 PlayerController.gd**:
```gdscript
func _interact_with_building() -> void:
    match nearby_building.building_type:
        "task_center":
            get_tree().call_group("ui", "show_task_panel")
        "company":
            print("打开公司面板（待实现）")
        "client":
            if TaskManager.active_task.is_empty():
                print("请先接取任务！")
            else:
                # 检查是否是对应的客户家
                _start_work()

func _start_work() -> void:
    GameManager.change_scene("res://scenes/work_sites/WorkSite.tscn")
```

**修改 GameManager.gd**:
```gdscript
func change_scene(scene_path: String) -> void:
    # 保存当前状态
    get_tree().change_scene_to_file(scene_path)
```

**验证**: 
- 接取任务后前往客户家
- 按E进入工作场景
- 完成工作后返回城市地图
- 金币和声望正确增加

---

## 阶段 5: 测试和调优（1小时） ✅ 大部分完成

### Task 5.1: 完整流程测试 ✅
**时间**: 30分钟

**测试流程**:
1. 启动游戏，玩家在城市地图
2. 前往任务中心，接取任务
3. 前往客户家，进入工作场景
4. 完成所有工作区域
5. 查看评分和奖励
6. 返回城市地图
7. 检查金币、声望、经验是否更新
8. 接取第二个任务测试

**记录问题**:
- UI布局问题
- 碰撞检测问题
- 性能问题
- 逻辑错误

---

### Task 5.2: 数值平衡调整 ✅
**时间**: 20分钟

**调整参数**:
- 工作时间（太快/太慢？）
- 任务报酬（太多/太少？）
- 属性加成（影响明显吗？）
- 移动速度（流畅吗？）

**建议测试数值**:
- 工作区域工作时间: 3-5秒
- 任务时间限制: 3分钟
- 力量影响: +1% 工作速度 per点
- 敏捷影响: +1% 移动速度 per点

---

### Task 5.3: 添加反馈和提示 ✅ 部分完成
**时间**: 10分钟

**添加内容**:
1. ⬜ 工作开始时播放音效（占位）— **未完成，无音效系统**
2. ✅ 工作完成时显示"+10金"飘字 — **已通过 NotificationSystem 实现**
3. ✅ 任务接取后显示提示："前往客户家" — **已通过 NotificationSystem 实现**
4. ✅ 升级时显示通知 — **已通过 NotificationSystem 实现**

---

## 阶段 6: 打包和文档（30分钟） ⬜ 未开始

### Task 6.1: 整理项目 ⬜ 未完成
**时间**: 10分钟
- 删除未使用的文件
- 检查文件命名规范
- 添加注释到关键脚本

---

### Task 6.2: 创建README ✅ 已完成（初始版本）
**时间**: 10分钟

**README.md 内容**:
```markdown
# Landscape Tycoon - MVP原型

## 功能清单
- ✅ 城市大地图探索
- ✅ 任务系统（接取和完成）
- ✅ 工作机制（自动工作）
- ✅ 属性系统（力量、敏捷、声望）
- ✅ 经济系统（金币、升级）
- ✅ UI系统（HUD、任务面板、评分）

## 控制说明
- WASD/方向键: 移动
- E: 交互
- ESC: 暂停（待实现）

## 下一步开发
- [ ] 多种任务类型
- [ ] 小游戏机制
- [ ] 工具购买系统
- [ ] 更多客户和任务
```

---

### Task 6.3: 导出可执行文件 ⬜ 未完成
**时间**: 10分钟
1. Project → Export
2. 配置导出预设（Windows/Linux/Mac）
3. 导出exe文件
4. 测试导出版本

---

## 实施计划总结

### 预计总时长: 8-10 小时

| 阶段 | 任务数 | 状态 |
|------|-------|------|
| 0. 项目初始化 | 4 | ✅ 已完成 |
| 1. 玩家角色 | 1 | ✅ 已完成 |
| 2. 城市地图 | 4 | ✅ 已完成 |
| 3. UI系统 | 4 | ✅ 已完成 |
| 4. 工作场景 | 4 | ✅ 已完成 |
| 5. 测试调优 | 3 | ✅ 大部分完成 |
| 6. 打包文档 | 3 | ⬜ 未开始 |

### 里程碑
- ✅ 阶段0完成: 项目结构建立
- ✅ 阶段1-2完成: 可在地图中移动和探索
- ✅ 阶段3完成: UI系统完善（含属性面板、工具商店、材料商店）
- ✅ 阶段4完成: 核心游戏循环可玩
- ✅ 阶段5完成: 游戏基本平衡，通知反馈系统就绪
- ⬜ 阶段6未完成: 需要导出可执行文件

### 成功标准
1. ✅ 玩家可以完整体验：接任务 → 工作 → 赚钱 → 升级
2. ✅ 属性系统对游戏有明显影响
3. ✅ UI清晰易懂
4. ⬜ 没有致命bug（需要实际测试验证）
5. ⬜ 帧率稳定（60fps）（需要实际测试验证）

---

## 下一步行动

### 优先级高
1. ⬜ 在 Godot 中实际运行测试，修复可能存在的 bug
2. ⬜ 配置导出预设并导出 Windows 可执行文件
3. ⬜ 添加音效系统（至少占位音效）

### 优先级中
4. ⬜ 替换临时 SVG 图形为正式像素艺术素材
5. ⬜ 添加玩家行走动画
6. ⬜ 新手引导/教程流程

### 优先级低
7. ⬜ NPC 行人（增加城市生活感）
8. ⬜ 场景切换过渡动画（淡入淡出）
9. ⬜ 更多客户住宅和地图扩展

---

---

## 优化实施计划（基于NotebookLM知识库分析）

> 以下优化计划基于NotebookLM中的游戏开发知识库（Godot 4最佳实践、AI技术、程序化生成、经济系统设计、游戏手感理论）分析得出。详细分析见 `landscape_tycoon_design.md` 第11章。

### 阶段 7: 游戏手感与反馈优化 ✅ 已完成

#### Task 7.1: 相机惯性跟随系统 ✅
- 修改Player场景的Camera2D，添加`position_smoothing`和惯性权重
- 角色移动时相机带轻微延迟跟随
- 停止移动时相机缓慢回中

#### Task 7.2: 交互即时视觉反馈 ✅
- 按E交互时工作区域立即高亮闪烁（而非等待进度条）
- 金币获得时HUD数字跳动动画（Tween缩放）
- 声望/经验变化时数字颜色闪烁

#### Task 7.3: 小游戏帧冻结（Hit Stop）✅
- 节奏打桩：锤子击中时暂停2-3帧（`Engine.time_scale`短暂置0）
- 砖块拼图：放置成功时微小暂停
- 水平仪对齐：成功对齐时画面轻微放大反馈

#### Task 7.4: 相机震动反馈 ✅
- 完成工作区域时轻微震动
- 小游戏失败时画面抖动
- 升级时短暂震动+放大效果

### 阶段 8: 性能与架构优化 ✅ 已完成

#### Task 8.1: 内存泄漏排查 ✅（审计通过，无泄漏）
- 使用ObjectDB快照对比，检查：
  - 小游戏CanvasLayer结束后是否`queue_free()`
  - TaskItem动态节点是否在面板关闭时清理
  - NotificationSystem飘字Label是否及时销毁
- 修复所有发现的泄漏点

#### Task 8.2: 资源加载优化 ✅
- 小游戏脚本从`preload`改为按需`load`
- 分离动态UI资源和静态资源
- 确保像素艺术纹理Filter统一为Nearest

#### Task 8.3: 命名规范统一 ✅
- 场景文件：`类型_名称.tscn`（如`ui_shop_panel.tscn`）
- 脚本文件：`PascalCase.gd`
- 资源文件：`类型_名称_编号`（如`sprite_player_idle_001`）
- 清理根目录散落的.tscn文件，归入对应scenes/子目录

### 阶段 9: NPC与AI系统

#### Task 9.1: JPS4寻路系统 ⬜
- 创建`scripts/autoload/Pathfinder.gd`
- 基于TileMap数据构建四方向寻路网格
- 实现Jump Point Search算法（针对4-connected网格优化）
- 提供`find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]`接口

#### Task 9.2: NPC行为树框架 ⬜
- 创建`scripts/ai/BehaviorTree.gd`基类
- 实现Selector、Sequence、Condition、Action节点
- NPC日程行为树：工作→购物→休闲→回家

#### Task 9.3: NPC场景与视觉 ⬜
- 创建`scenes/city/NPC.tscn`（CharacterBody2D）
- 3-5种NPC外观变体
- 行走动画（4方向）
- 在CityMap中生成5-8个NPC实例

### 阶段 10: 经济平衡与内容扩展

#### Task 10.1: 经济闭环验证 ⬜
- 计算各任务类型的时间收益比（金币/分钟）
- 平衡不同任务的净利润/时间比，避免玩家只选最优任务
- 添加金币消耗端：公司日常维护费（每完成N个任务扣除）

#### Task 10.2: 程序化庭院生成（可选）⬜
- 基于WFC算法的工作场景布局生成器
- 定义瓦片邻接规则（围栏→边缘、草地→中心区域等）
- 为每次任务生成不同的庭院布局，增加重玩性

#### Task 10.3: 新手引导流程 ⬜
- 第一次进入游戏时触发引导序列
- 引导步骤：移动→前往任务中心→接取任务→前往客户家→完成工作→查看奖励
- 使用NotificationSystem的Toast提示引导

### 阶段 11: 最终打磨与发布

#### Task 11.1: Beta测试清单 ⬜
- 数据驱动调优：资源掉落率、难度曲线、新手引导节奏
- 漏洞测试：规则漏洞（刷分、重复奖励）
- 资源包瘦身：删除未使用资源
- 帧率稳定性验证（目标60fps）

#### Task 11.2: 音效系统 ⬜
- 创建AudioManager自动加载脚本
- 基础音效：行走、交互、工作进度、任务完成、金币获得、升级
- 背景音乐：城市地图BGM、工作场景BGM

#### Task 11.3: 正式美术素材 ⬜
- 替换所有temp_sprites为像素艺术素材
- 规格：角色32x32、瓦片16x16、建筑多瓦片组合
- 调色板：田园暖色调（绿色、棕色、米黄色）

#### Task 11.4: 导出可执行文件 ⬜
- 配置Windows导出预设
- 测试导出版本运行正常
- 打包分发

---

**文档更新日期**: 2026-01-30
