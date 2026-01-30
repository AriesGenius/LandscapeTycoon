# 像素资源使用指南

## 📦 包含的图形文件

我已经为你创建了基础的 SVG 图形文件：

| 文件 | 用途 | 大小 | 颜色 |
|------|------|------|------|
| player.svg | 玩家角色 | 32x32 | 绿色 |
| company.svg | 公司建筑 | 64x64 | 蓝色 |
| task_center.svg | 任务中心 | 64x64 | 黄色 |
| client_house.svg | 客户房子 | 64x64 | 红色（带屋顶） |
| grass_tile.svg | 草地地砖 | 16x16 | 浅绿色 |
| road_tile.svg | 道路地砖 | 16x16 | 灰色（带白线） |
| work_area.svg | 工作区域 | 48x48 | 深绿色（杂草） |

---

## 🚀 如何使用

### 1. 导入到 Godot

**方法A：拖放导入**
1. 解压 `BasicSprites.zip`
2. 在文件管理器中打开 `temp_sprites` 文件夹
3. 全选所有 .svg 文件
4. 拖到 Godot 的 FileSystem 面板
5. 拖到 `assets/sprites/` 文件夹

**方法B：直接复制**
1. 解压文件
2. 复制所有 .svg 文件
3. 粘贴到项目的 `assets/sprites/` 文件夹
4. Godot 会自动检测并导入

---

### 2. 在场景中使用

#### 玩家场景（Player.tscn）
1. 选择 Sprite2D 节点
2. Inspector → Texture
3. 点击下拉 → Load
4. 选择 `player.svg`

#### 建筑场景（Building.tscn）
根据建筑类型选择：
- 公司：`company.svg`
- 任务中心：`task_center.svg`
- 客户家：`client_house.svg`

#### TileMap（草地和道路）
1. 创建 TileSet
2. 添加 tile：
   - 草地：`grass_tile.svg`
   - 道路：`road_tile.svg`
3. 绘制地图

#### 工作区域（WorkArea.tscn）
使用 `work_area.svg`

---

## 🎨 SVG vs PNG

**SVG 优势**：
- ✅ 矢量图形，无限缩放不失真
- ✅ 文件小
- ✅ Godot 4 原生支持

**如果需要 PNG**：
1. 在 Godot 中导入 SVG
2. 右键 → "Create PNG"
3. 设置大小
4. 保存

---

## ✏️ 自定义修改

### 在 Godot 中修改颜色
1. 选择使用该纹理的节点
2. Inspector → CanvasItem → Modulate
3. 选择颜色

### 使用外部编辑器
SVG 文件可以用以下工具编辑：
- **Inkscape**（免费）
- **Adobe Illustrator**
- **在线编辑器**：https://vectr.com/

---

## 🎯 快速开始流程

1. **下载并解压** `BasicSprites.zip`
2. **拖入 Godot** 所有文件
3. **创建 Player 场景**：
   - Sprite2D → Texture → player.svg
4. **创建 Building 场景**：
   - Sprite2D → Texture → company.svg
5. **创建 TileMap**：
   - TileSet → 添加 grass_tile.svg 和 road_tile.svg

---

## 🔄 升级到更好的图形

这些是临时占位符图形。当你准备好后，可以：

1. **下载专业资源包**
   - Kenney.nl（免费）
   - OpenGameArt.org
   - itch.io

2. **委托艺术家**
   - Fiverr
   - Upwork
   - Reddit r/gameDevClassifieds

3. **自己创建**
   - Aseprite（付费，专业）
   - Piskel（免费，在线）
   - GIMP（免费）

---

## 💡 提示

### 保持像素艺术清晰
在 Godot 项目设置中：
```
项目 → 项目设置 → Rendering
→ Textures → Canvas Textures
→ Default Texture Filter = Nearest
```

已经在 project.godot 中配置好了！

### 修改 SVG 大小
如果图形太大或太小：
1. 选择 Sprite2D
2. Transform → Scale
3. 调整到合适大小

---

## 🎮 开始游戏开发

有了这些图形，你现在可以：
1. ✅ 创建 Player 场景
2. ✅ 创建 Building 场景
3. ✅ 创建 CityMap 场景
4. ✅ 运行游戏看到效果！

**不需要完美的美术才能开始开发**，先让游戏跑起来，美术可以随时替换！

祝你开发顺利！🎨✨
