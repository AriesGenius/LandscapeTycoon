# Landscape Tycoon - 完整场景配置指南

这个文档包含所有场景的详细配置说明。按照这些步骤在 Godot 中创建场景。

## 目录
1. [Player 场景](#player)
2. [Building 场景](#building)
3. [CityMap 场景](#citymap)
4. [HUD 场景](#hud)
5. [InteractionPrompt 场景](#interactionprompt)
6. [TaskPanel 场景](#taskpanel)
7. [TaskItem 场景](#taskitem)
8. [WorkSite 场景](#worksite)
9. [WorkArea 场景](#workarea)
10. [WorkUI 场景](#workui)
11. [TaskResultPanel 场景](#taskresultpanel)

---

## <a name="player"></a>1. Player 场景

**路径**: `res://scenes/player/Player.tscn`

### 场景树
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── Camera2D
```

### 配置步骤

1. 创建新场景，根节点选择 CharacterBody2D，命名为 Player
2. 附加脚本: `res://scripts/player/PlayerController.gd`
3. 添加 Sprite2D 子节点：
   - 临时使用 ColorRect 或纯色方块
   - Size: 32x32
   - Color: 绿色 (#00ff00)
4. 添加 CollisionShape2D：
   - Shape: RectangleShape2D
   - Size: Vector2(16, 24)
5. 添加 Camera2D：
   - Enabled: true
   - Zoom: Vector2(2, 2)
   - Position Smoothing Enabled: true
   - Speed: 5.0

---

## <a name="building"></a>2. Building 场景（模板）

**路径**: `res://scenes/city/Building.tscn`

### 场景树
```
Building (Area2D)
├── Sprite2D
├── CollisionShape2D
└── Label
```

### 配置步骤

1. 创建新场景，根节点选择 Area2D，命名为 Building
2. 附加脚本: `res://scripts/city/Building.gd`
3. 添加 Sprite2D：
   - 临时使用彩色方块 (64x64)
   - 不同建筑用不同颜色
4. 添加 CollisionShape2D：
   - Shape: RectangleShape2D
   - Size: Vector2(64, 64)
5. 添加 Label：
   - Position: Vector2(-30, -40) # 建筑上方
   - Text: "建筑"
   - Visible: false (默认隐藏)

### 导出变量（在 Inspector 中设置）
- building_name: "建筑名称"
- building_type: 选择类型（company / shop / task_center / client）

### 创建变体

基于这个模板，创建以下实例：

**PlayerCompany** (继承 Building):
- building_name: "你的公司"
- building_type: company
- Sprite Color: 蓝色

**TaskCenter** (继承 Building):
- building_name: "任务中心"
- building_type: task_center
- Sprite Color: 黄色

**ClientHouse** (继承 Building):
- building_name: "客户家"
- building_type: client
- Sprite Color: 红色

---

## <a name="citymap"></a>3. CityMap 场景

**路径**: `res://scenes/city/CityMap.tscn`

### 场景树
```
CityMap (Node2D)
├── TileMap (地面)
├── Buildings (Node2D 容器)
│   ├── PlayerCompany (Building 实例)
│   ├── TaskCenter (Building 实例)
│   └── ClientHouse01 (Building 实例)
├── Player (Player 实例)
├── HUD (HUD 实例)
└── InteractionPrompt (InteractionPrompt 实例)
```

### 配置步骤

1. 创建 Node2D 根节点，命名为 CityMap
2. 附加脚本: `res://scripts/city/CityMap.gd`

#### TileMap 设置
1. 添加 TileMap 节点
2. 创建 TileSet：
   - 添加 3 种 tile（草地、道路、人行道）
   - 使用纯色方块作为临时图块 (32x32)
     - 草地: 浅绿色 (#90ee90)
     - 道路: 灰色 (#808080)
     - 人行道: 米黄色 (#f5deb3)
3. 绘制地图布局（约 30x30 tiles）
   - 中心道路
   - 周围草地
   - 建筑位置留空

#### Buildings 容器
1. 创建 Node2D 命名为 Buildings
2. 实例化 3 个建筑：
   - PlayerCompany: 位置 (-300, 200)
   - TaskCenter: 位置 (0, 0)
   - ClientHouse01: 位置 (300, -200)

#### Player
1. 实例化 Player 场景
2. Position: (0, 100) # 起始位置

#### UI
1. 实例化 HUD 场景
2. 实例化 InteractionPrompt 场景

---

## <a name="hud"></a>4. HUD 场景

**路径**: `res://scenes/ui/HUD.tscn`

### 场景树
```
HUD (CanvasLayer)
└── Panel
    └── MarginContainer (margin: 10)
        └── VBoxContainer (separation: 5)
            ├── PlayerNameLabel
            ├── GoldLabel
            ├── ReputationLabel
            ├── LevelLabel
            ├── AttributePointsLabel
            └── AttributesContainer (HBoxContainer)
                ├── StrengthLabel
                ├── AgilityLabel
                └── DexterityLabel
```

### 配置步骤

1. 创建 CanvasLayer 根节点，命名为 HUD
2. 附加脚本: `res://scripts/ui/HUD.gd`
3. 添加 Panel：
   - Anchors: Top Left
   - Position: (10, 10)
   - Size: (250, 220)
   - 背景: 半透明黑色
4. 添加 MarginContainer，设置 margin 为 10
5. 添加 VBoxContainer，separation 为 5
6. 添加所有 Label 节点，设置初始文本：
   - PlayerNameLabel: "玩家: Alex"
   - GoldLabel: "💰 金币: 500"
   - ReputationLabel: "⭐ 声望: 0 (新手)"
   - LevelLabel: "📊 等级: 1"
   - AttributePointsLabel: "🎯 可分配: 0" (默认 Visible: false)
7. 添加 AttributesContainer (HBoxContainer)
8. 在其中添加三个 Label：
   - StrengthLabel: "💪 力量: 10"
   - AgilityLabel: "⚡ 敏捷: 10"
   - DexterityLabel: "✋ 灵巧: 10"

---

## <a name="interactionprompt"></a>5. InteractionPrompt 场景

**路径**: `res://scenes/ui/InteractionPrompt.tscn`

### 场景树
```
InteractionPrompt (CanvasLayer)
└── CenterContainer
    └── PanelContainer
        └── MarginContainer
            └── Label
```

### 配置步骤

1. 创建 CanvasLayer 根节点
2. 附加脚本: `res://scripts/ui/InteractionPrompt.gd`
3. 添加 CenterContainer：
   - Anchors: Bottom (屏幕下方)
   - Grow Direction: Begin (向上增长)
   - Offset Top: -100
4. 添加 PanelContainer（半透明背景）
5. 添加 MarginContainer (margin: 10)
6. 添加 Label：
   - Text: "按 E 交互"
   - Horizontal Alignment: Center
   - Font Size: 16

---

## <a name="taskpanel"></a>6. TaskPanel 场景

**路径**: `res://scenes/ui/TaskPanel.tscn`

### 场景树
```
TaskPanel (CanvasLayer)
└── CenterContainer
    └── Panel
        └── MarginContainer
            └── VBoxContainer
                ├── TitleLabel
                ├── ScrollContainer
                │   └── TaskList (VBoxContainer)
                └── CloseButton
```

### 配置步骤

1. 创建 CanvasLayer 根节点
2. 附加脚本: `res://scripts/ui/TaskPanel.gd`
3. 添加 CenterContainer (填充整个屏幕)
4. 添加 Panel：
   - Size: (600, 500)
5. 添加 MarginContainer (margin: 20)
6. 添加 VBoxContainer
7. 添加 TitleLabel：
   - Text: "可接取任务"
   - Font Size: 20
8. 添加 ScrollContainer：
   - Vertical Scroll: Show Always
   - Size Flags: Expand Fill
9. 在 ScrollContainer 中添加 VBoxContainer 命名为 TaskList
10. 添加 CloseButton：
    - Text: "关闭"

---

## <a name="taskitem"></a>7. TaskItem 场景

**路径**: `res://scenes/ui/TaskItem.tscn`

### 场景树
```
TaskItem (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── TaskNameLabel
        ├── ClientLabel
        ├── InfoContainer (HBoxContainer)
        │   ├── RewardLabel
        │   ├── DifficultyLabel
        │   └── TimeLabel
        ├── MaterialLabel
        └── AcceptButton
```

### 配置步骤

1. 创建 PanelContainer 根节点
2. 附加脚本: `res://scripts/ui/TaskItem.gd`
3. 添加 MarginContainer (margin: 10)
4. 添加 VBoxContainer (separation: 5)
5. 添加 Label 节点：
   - TaskNameLabel: "任务名称"
   - ClientLabel: "客户: XXX"
   - MaterialLabel: "材料费: 100金"
6. 添加 InfoContainer (HBoxContainer)
7. 在其中添加：
   - RewardLabel: "💰 200金"
   - DifficultyLabel: "⭐⭐"
   - TimeLabel: "⏱️ 5分钟"
8. 添加 AcceptButton：
   - Text: "接取任务"

---

## <a name="worksite"></a>8. WorkSite 场景

**路径**: `res://scenes/work_sites/WorkSite.tscn`

### 场景树
```
WorkSite (Node2D)
├── Background (Sprite2D)
├── WorkAreas (Node2D)
│   ├── WorkArea1 (WorkArea 实例)
│   ├── WorkArea2 (WorkArea 实例)
│   └── WorkArea3 (WorkArea 实例)
├── Player (Player 实例)
├── WorkUI (WorkUI 实例)
└── TaskResultPanel (TaskResultPanel 实例)
```

### 配置步骤

1. 创建 Node2D 根节点
2. 附加脚本: `res://scripts/work_sites/WorkSite.gd`
3. 添加 Background (Sprite2D)：
   - 使用浅绿色大矩形作为草坪背景
   - Size: 800x600
4. 添加 WorkAreas 容器 (Node2D)
5. 实例化 3 个 WorkArea，分散位置：
   - WorkArea1: (-200, 0)
   - WorkArea2: (200, 0)
   - WorkArea3: (0, -150)
6. 实例化 Player (起始位置: (0, 200))
7. 实例化 WorkUI
8. 实例化 TaskResultPanel

---

## <a name="workarea"></a>9. WorkArea 场景

**路径**: `res://scenes/work_sites/WorkArea.tscn`

### 场景树
```
WorkArea (Area2D)
├── Sprite2D
├── CollisionShape2D
├── ProgressBar
└── Label
```

### 配置步骤

1. 创建 Area2D 根节点
2. 附加脚本: `res://scripts/work_sites/WorkArea.gd`
3. 添加 Sprite2D：
   - 深绿色方块 (48x48) 表示杂草/工作区域
4. 添加 CollisionShape2D：
   - Shape: RectangleShape2D
   - Size: (48, 48)
5. 添加 ProgressBar：
   - Position: (-24, -40) # 在区域上方
   - Size: (48, 8)
   - Max Value: 100
6. 添加 Label：
   - Position: (-30, -50)
   - Text: "按E开始工作"
   - Visible: false

---

## <a name="workui"></a>10. WorkUI 场景

**路径**: `res://scenes/ui/WorkUI.tscn`

### 场景树
```
WorkUI (CanvasLayer)
└── Panel
    └── MarginContainer
        └── VBoxContainer
            ├── TaskNameLabel
            ├── ProgressLabel
            ├── TimerLabel
            └── QualityLabel
```

### 配置步骤

1. 创建 CanvasLayer 根节点
2. 附加脚本: `res://scripts/ui/WorkUI.gd`
3. 添加 Panel：
   - Anchors: Top Center
   - Position: (-150, 10)
   - Size: (300, 120)
4. 添加 MarginContainer (margin: 10)
5. 添加 VBoxContainer
6. 添加 Label 节点：
   - TaskNameLabel: "任务: XXX"
   - ProgressLabel: "0/3 区域完成"
   - TimerLabel: "剩余时间: 3:00"
   - QualityLabel: "完成度: 0%"

---

## <a name="taskresultpanel"></a>11. TaskResultPanel 场景

**路径**: `res://scenes/ui/TaskResultPanel.tscn`

### 场景树
```
TaskResultPanel (CanvasLayer)
└── CenterContainer
    └── Panel
        └── MarginContainer
            └── VBoxContainer
                ├── TitleLabel
                ├── RatingLabel
                ├── RewardLabel
                ├── ReputationLabel
                ├── ExperienceLabel
                └── ContinueButton
```

### 配置步骤

1. 创建 CanvasLayer 根节点
2. 附加脚本: `res://scripts/ui/TaskResultPanel.gd`
3. 添加 CenterContainer
4. 添加 Panel (Size: 400x300)
5. 添加 MarginContainer (margin: 20)
6. 添加 VBoxContainer (separation: 10)
7. 添加 Label 节点：
   - TitleLabel: "任务完成！" (Font Size: 24)
   - RatingLabel: "评分: ⭐⭐⭐⭐⭐"
   - RewardLabel: "💰 获得: 150 金"
   - ReputationLabel: "⭐ 声望: +10"
   - ExperienceLabel: "📊 经验: +50"
8. 添加 ContinueButton：
   - Text: "返回城市"

---

## 快速设置顺序建议

1. **首先创建基础场景**：
   - Player
   - Building (作为模板)

2. **创建UI场景**：
   - HUD
   - InteractionPrompt

3. **创建城市场景**：
   - CityMap (使用上面创建的场景)

4. **测试城市场景**：
   - 运行游戏，确保移动和HUD工作正常

5. **创建任务系统UI**：
   - TaskItem
   - TaskPanel

6. **测试任务接取**：
   - 在任务中心接取任务

7. **创建工作场景**：
   - WorkArea
   - WorkUI
   - TaskResultPanel
   - WorkSite (使用上面的场景)

8. **完整测试**：
   - 从接取任务到完成工作的完整流程

---

## 临时美术资源

在快速原型阶段，使用以下简单图形：

### 颜色方案
- 玩家: 绿色 (#00ff00)
- 公司: 蓝色 (#0000ff)
- 任务中心: 黄色 (#ffff00)
- 客户家: 红色 (#ff0000)
- 草地: 浅绿色 (#90ee90)
- 道路: 灰色 (#808080)
- 工作区域: 深绿色 (#006400)

### 创建临时图片

可以使用以下工具快速创建：
1. Godot 内置的 ColorRect
2. 在线像素编辑器 (如 Piskel)
3. 简单的图片编辑器 (Paint, GIMP)

每个方块只需要纯色填充即可，大小 32x32 或 64x64 像素。

---

## 常见问题

### Q: 场景文件无法加载脚本？
A: 确保脚本路径正确，检查 `res://` 前缀

### Q: 节点找不到？
A: 检查 @onready 变量的节点路径是否匹配场景树结构

### Q: UI 不显示？
A: 检查 CanvasLayer 的 Layer 属性，确保 UI 在正确的层级

### Q: 碰撞不工作？
A: 确保 CollisionShape2D 有正确的 Shape，且父节点是物理节点

---

## 下一步

场景创建完成后：
1. 运行 CityMap 场景测试基本功能
2. 检查控制台输出，确认所有系统初始化
3. 测试完整游戏循环
4. 根据需要调整数值和布局

祝开发顺利！🎮
