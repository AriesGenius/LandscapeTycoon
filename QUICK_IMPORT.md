# 🚀 超简单导入指南（3步完成）

## ⚠️ 重要：先删除旧的失败项目

在 Godot 项目列表中：
1. 找到显示"缺失项目"的两个项目
2. 右键点击 → "移除"（或点击右边的X）
3. 这只是从列表移除，不会删除文件

---

## ✅ 第1步：解压到正确位置

将 `LandscapeTycoon_Fixed.zip` 解压到：

**推荐路径（选一个）**：
- `C:\GameDev\LandscapeTycoon`
- `C:\Projects\LandscapeTycoon`
- `D:\LandscapeTycoon`

**❌ 不要用这些路径**：
- ❌ 桌面
- ❌ 包含空格的路径（如 "LANDSCAPE GAME"）
- ❌ 中文路径
- ❌ OneDrive/Google Drive 同步文件夹

---

## ✅ 第2步：验证文件

打开解压后的文件夹，确认包含：

```
LandscapeTycoon/
├── project.godot  ← 这个文件必须存在！
├── icon.svg
├── README.md
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd
│   │   ├── PlayerData.gd
│   │   └── TaskManager.gd
│   └── ...
└── scenes/
```

**双击 `project.godot`**，用记事本打开，应该看到：
```
; Engine configuration file.
config_version=5
```

如果看到这些内容，说明文件正常！

---

## ✅ 第3步：在 Godot 中导入

### 方法 A：直接双击（最简单）

1. 在文件管理器中，**双击 `project.godot` 文件**
2. 系统会自动用 Godot 打开项目

### 方法 B：从 Godot 导入

1. 打开 Godot Engine
2. 点击右上角 "**导入**"
3. 点击 "**浏览**"
4. 找到项目文件夹
5. **选择 `project.godot` 文件**（不是文件夹！）
6. 点击 "打开"
7. 点击 "导入并编辑"

---

## ✅ 第4步：验证成功

项目打开后，你应该看到：

1. **左下角"文件系统"**：
   - 看到 `scripts` 文件夹
   - 看到 `scenes` 文件夹

2. **打开一个脚本测试**：
   - 双击 `scripts/autoload/PlayerData.gd`
   - 应该能看到代码
   - 没有红色错误

3. **检查 AutoLoad 设置**：
   - 点击菜单：项目 → 项目设置
   - 点击 "AutoLoad" 标签
   - 这里应该是**空的**（这是正常的）
   - 我们会在下一步手动添加

---

## 🎯 第5步：添加 AutoLoad 脚本

项目导入成功后，需要手动添加全局脚本：

1. 在项目设置 → AutoLoad 中
2. 点击 "路径" 旁边的文件夹图标
3. 选择 `res://scripts/autoload/GameManager.gd`
4. 节点名称：GameManager
5. 点击 "添加"

重复以上步骤，添加：
- `PlayerData.gd` → 节点名称：PlayerData
- `TaskManager.gd` → 节点名称：TaskManager

---

## 🐛 还是不行？

### 检查 Godot 版本

点击 Godot 菜单：帮助 → 关于
- 版本必须是 **4.3** 或更高
- 如果版本低于 4.3，需要下载新版本

### 测试最小项目

这个版本是最简化的配置，应该能导入。如果还是失败：

1. **截图给我看**：
   - Godot 的版本信息
   - 导入时的错误提示
   - 文件夹中 project.godot 的内容

2. **告诉我**：
   - 你的操作系统和版本
   - 你解压到的具体路径
   - 双击 project.godot 会发生什么

---

## ✨ 成功的标志

当你成功后，应该看到：

- ✅ Godot 打开，显示 "Landscape Tycoon" 项目
- ✅ 文件系统中有完整的文件夹
- ✅ 可以双击打开 .gd 脚本文件
- ✅ 没有"缺失项目"的红色错误

**下一步**：阅读 `SCENE_SETUP_GUIDE.md` 开始创建场景！

---

## 💡 专业提示

这个版本是**最小化配置**，确保能导入：
- 移除了所有可能导致问题的高级设置
- 使用最基本的 Godot 4.3 配置
- 包含必要的文件结构

导入成功后，你可以：
1. 添加 AutoLoad 脚本
2. 创建场景文件
3. 开始游戏开发

祝你成功！🎮
