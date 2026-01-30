# Landscape Tycoon - 快速启动检查清单

使用这个检查清单确保你的项目正确设置并能够运行。

## ✅ 第一步：项目导入

- [ ] Godot 4.3+ 已安装
- [ ] 项目文件夹已下载完整
- [ ] 在 Godot 中成功导入项目
- [ ] 可以看到项目文件结构

## ✅ 第二步：验证脚本文件

检查以下脚本是否存在：

### AutoLoad 脚本
- [ ] `scripts/autoload/GameManager.gd`
- [ ] `scripts/autoload/PlayerData.gd`
- [ ] `scripts/autoload/TaskManager.gd`

### 玩家脚本
- [ ] `scripts/player/PlayerController.gd`

### 城市脚本
- [ ] `scripts/city/CityMap.gd`
- [ ] `scripts/city/Building.gd`

### UI 脚本
- [ ] `scripts/ui/HUD.gd`
- [ ] `scripts/ui/TaskPanel.gd`
- [ ] `scripts/ui/TaskItem.gd`
- [ ] `scripts/ui/InteractionPrompt.gd`
- [ ] `scripts/ui/WorkUI.gd`
- [ ] `scripts/ui/TaskResultPanel.gd`

### 工作场景脚本
- [ ] `scripts/work_sites/WorkSite.gd`
- [ ] `scripts/work_sites/WorkArea.gd`

## ✅ 第三步：创建场景（按顺序）

### 3.1 基础场景
- [ ] **Player.tscn** 已创建（参考 SCENE_SETUP_GUIDE.md 第1节）
  - [ ] CharacterBody2D 根节点
  - [ ] 已附加 PlayerController.gd 脚本
  - [ ] Sprite2D (临时绿色方块)
  - [ ] CollisionShape2D (16x24)
  - [ ] Camera2D (Zoom: 2, 2)

- [ ] **Building.tscn** 已创建（参考第2节）
  - [ ] Area2D 根节点
  - [ ] 已附加 Building.gd 脚本
  - [ ] Sprite2D (彩色方块)
  - [ ] CollisionShape2D
  - [ ] Label

### 3.2 建筑变体
- [ ] **PlayerCompany** (继承 Building)
  - [ ] building_name = "你的公司"
  - [ ] building_type = "company"
  - [ ] 蓝色 Sprite

- [ ] **TaskCenter** (继承 Building)
  - [ ] building_name = "任务中心"
  - [ ] building_type = "task_center"
  - [ ] 黄色 Sprite

- [ ] **ClientHouse** (继承 Building)
  - [ ] building_name = "客户家"
  - [ ] building_type = "client"
  - [ ] 红色 Sprite

### 3.3 UI 场景
- [ ] **HUD.tscn** 已创建（参考第4节）
  - [ ] CanvasLayer → Panel → VBoxContainer
  - [ ] 已附加 HUD.gd
  - [ ] 所有 Label 节点已添加

- [ ] **InteractionPrompt.tscn** 已创建（参考第5节）
  - [ ] CanvasLayer → CenterContainer → Panel
  - [ ] 已附加 InteractionPrompt.gd

- [ ] **TaskItem.tscn** 已创建（参考第7节）
  - [ ] PanelContainer → VBoxContainer
  - [ ] 已附加 TaskItem.gd
  - [ ] 所有信息标签已添加

- [ ] **TaskPanel.tscn** 已创建（参考第6节）
  - [ ] CanvasLayer → CenterContainer → Panel
  - [ ] 已附加 TaskPanel.gd
  - [ ] ScrollContainer → TaskList
  - [ ] 已正确引用 TaskItem 场景

### 3.4 城市场景
- [ ] **CityMap.tscn** 已创建（参考第3节）
  - [ ] Node2D 根节点
  - [ ] 已附加 CityMap.gd
  - [ ] TileMap 已创建并绘制
  - [ ] Buildings 容器已添加
  - [ ] 3个建筑已实例化并定位
  - [ ] Player 已实例化
  - [ ] HUD 已实例化
  - [ ] InteractionPrompt 已实例化
  - [ ] TaskPanel 已实例化

### 3.5 工作场景
- [ ] **WorkArea.tscn** 已创建（参考第9节）
  - [ ] Area2D → Sprite, Collision, ProgressBar, Label
  - [ ] 已附加 WorkArea.gd

- [ ] **WorkUI.tscn** 已创建（参考第10节）
  - [ ] CanvasLayer → Panel → VBoxContainer
  - [ ] 已附加 WorkUI.gd

- [ ] **TaskResultPanel.tscn** 已创建（参考第11节）
  - [ ] CanvasLayer → CenterContainer → Panel
  - [ ] 已附加 TaskResultPanel.gd

- [ ] **WorkSite.tscn** 已创建（参考第8节）
  - [ ] Node2D 根节点
  - [ ] 已附加 WorkSite.gd
  - [ ] Background sprite
  - [ ] WorkAreas 容器
  - [ ] 3个 WorkArea 已实例化
  - [ ] Player 已实例化
  - [ ] WorkUI 已实例化
  - [ ] TaskResultPanel 已实例化

## ✅ 第四步：项目设置验证

### 4.1 检查 AutoLoad 设置
打开 Project → Project Settings → Autoload

- [ ] GameManager: `res://scripts/autoload/GameManager.gd` (优先级: 0)
- [ ] PlayerData: `res://scripts/autoload/PlayerData.gd` (优先级: 1)
- [ ] TaskManager: `res://scripts/autoload/TaskManager.gd` (优先级: 2)

### 4.2 检查输入映射
打开 Project → Project Settings → Input Map

- [ ] move_up: W, ↑
- [ ] move_down: S, ↓
- [ ] move_left: A, ←
- [ ] move_right: D, →
- [ ] interact: E, Space
- [ ] menu: ESC

### 4.3 检查渲染设置
Project → Project Settings → Rendering

- [ ] Textures → Canvas Textures → Default Texture Filter = **Nearest**
  （这很重要，确保像素艺术清晰）

### 4.4 设置主场景
- [ ] Project → Project Settings → Application → Run
- [ ] Main Scene: `res://scenes/city/CityMap.tscn`

## ✅ 第五步：首次运行测试

### 5.1 基础测试
- [ ] 按 F5 运行项目
- [ ] 游戏启动无错误
- [ ] 可以看到城市地图
- [ ] HUD 显示在左上角

### 5.2 移动测试
- [ ] WASD 或方向键可以移动玩家
- [ ] 移动流畅，无卡顿
- [ ] 相机跟随玩家
- [ ] 玩家不会穿过建筑物

### 5.3 交互测试
- [ ] 走近黄色建筑（任务中心）
- [ ] 屏幕底部显示 "按 E 进入任务中心"
- [ ] 按 E 打开任务面板
- [ ] 可以看到任务列表
- [ ] 关闭按钮工作正常

### 5.4 任务测试
- [ ] 在任务面板接取一个任务（如"清理垃圾"）
- [ ] 任务面板关闭
- [ ] HUD 显示当前金币减少（材料费）
- [ ] 走到红色建筑（客户家）
- [ ] 按 E 进入工作场景

### 5.5 工作测试
- [ ] 工作场景加载成功
- [ ] 可以看到3个绿色工作区域
- [ ] 屏幕上方显示任务信息和计时器
- [ ] 走到工作区域，按 E 开始工作
- [ ] 进度条增长
- [ ] 完成一个区域后，进度更新
- [ ] 完成所有区域后显示结果面板

### 5.6 结果测试
- [ ] 结果面板显示评分（星级）
- [ ] 显示获得的金币、声望、经验
- [ ] 点击"返回城市"
- [ ] 返回城市地图
- [ ] HUD 显示更新的数据

### 5.7 升级测试（需要多次任务）
- [ ] 完成多个任务积累经验
- [ ] 达到升级条件时控制台输出升级信息
- [ ] HUD 显示新的等级
- [ ] HUD 显示可分配属性点

## ✅ 第六步：控制台检查

运行游戏时，控制台应该显示类似输出：

```
GameManager initialized
PlayerData initialized
Starting gold: 500
TaskManager initialized
Generated 3 tasks
HUD initialized
InteractionPrompt initialized
CityMap loaded
Active task: None
Generated initial tasks: 3
Player ready! Speed: 150
```

- [ ] 无红色错误信息
- [ ] 所有管理器成功初始化
- [ ] 任务成功生成

## ✅ 第七步：常见问题排查

如果遇到问题，检查以下内容：

### 场景加载失败
- [ ] 场景文件路径正确
- [ ] 场景文件已保存
- [ ] 场景引用使用 `res://` 前缀

### 脚本错误
- [ ] 脚本附加到正确的节点
- [ ] @onready 变量的节点路径匹配
- [ ] 所有必需的节点都已创建

### UI不显示
- [ ] CanvasLayer 的 Visible 属性为 true
- [ ] UI 节点的 Layer 设置正确
- [ ] Panel 的大小和位置正确

### 碰撞问题
- [ ] CollisionShape2D 有正确的 Shape
- [ ] Shape 的大小合适
- [ ] 父节点是物理节点（CharacterBody2D, Area2D）

### 信号连接失败
- [ ] 信号名称拼写正确
- [ ] 连接的方法存在
- [ ] 使用正确的连接语法

## 🎉 完成！

如果所有检查项都通过，恭喜你！游戏已经可以正常运行了。

### 下一步
1. 尝试完成几个任务，体验游戏循环
2. 调整数值（工作时间、报酬等）
3. 添加更多工作区域
4. 优化UI布局
5. 准备添加新功能（商店、小游戏等）

### 需要帮助？
- 查看 `SCENE_SETUP_GUIDE.md` 获取详细场景配置
- 查看 `landscape_tycoon_design.md` 了解游戏设计
- 查看 `README.md` 了解项目整体情况

## 📊 进度追踪

当前完成度：____ / 60 项

记录完成日期：________

遇到的主要问题：
1. ___________________
2. ___________________
3. ___________________

---

**祝你开发顺利！** 🚀
