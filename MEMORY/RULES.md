# AI Rules — 项目记忆系统

> 本文件定义 Claude Code 如何与项目记忆交互。
> 在 CLAUDE.md 中通过 `@MEMORY/RULES.md` 引用加载。

---

## 首次会话 — 自动检查 Hook

每次会话开始时，检查 `.git/hooks/pre-commit` 是否包含 `memory-hook` 调用。如果没有，按以下顺序执行：

1. 检查 skill 仓库是否存在于 `~/.claude/skills/project-memory-skill/scripts/memory-hook.py`
2. 如果不存在，自动克隆并安装：
   ```bash
   git clone -b master https://gitee.com/switchbot/project-memory-skill.git ~/.claude/skills/project-memory-skill
   python3 ~/.claude/skills/project-memory-skill/install.py
   ```
3. 安装 pre-commit hook：
   ```bash
   python3 ~/.claude/skills/project-memory-skill/scripts/deploy.py --target . --skill-dir ~/.claude/skills/project-memory-skill/MEMORY --mode upgrade
   ```
4. 告知用户："已自动配置 pre-commit hook，后续 git commit 时会自动提取对话中的关键决策。"

**错误处理：** 任何步骤失败时，用中文提示用户具体哪一步出错及可能原因：
- clone 失败 → "skill 仓库克隆失败，请检查网络连接或 Git 权限。"
- install.py 失败 → "skill 安装脚本执行失败，请确认 Python 已安装且在 PATH 中。"
- deploy.py 失败 → "pre-commit hook 安装失败，请手动运行上述 deploy.py 命令重试。"

---

## 禁止事项

1. **禁止在本仓库（project-memory-skill）中运行 /project-memory 命令或 memory-hook.py。** 本仓库是 skill 模板源，MEMORY/ 下的文件是部署模板而非实际项目记忆，运行 skill 会污染模板文件。

2. **禁止主动提交或推送代码。** AI 不得自行执行 `git commit`、`git push` 等操作，除非用户明确下达口令（如"提交"、"推送"、"提交并推送"）。仅修改文件不等于授权提交。

---

## 记忆读取

1. 每次会话开始时，阅读 `MEMORY/PROJECT_MEMORY.md`（索引）
2. 当前任务与索引中某条相关时，Read `MEMORY/conclusions.md` 查看对应结论
3. 结论不够详细时，再 Read 对应的分类文件获取完整上下文：
   - 决策详情 → `MEMORY/decisions.md`
   - 踩坑经验 → `MEMORY/learnings.md`
   - 约定规范 → `MEMORY/conventions.md`
   - 背景信息 → `MEMORY/context.md`
4. 如果 `MEMORY/CODING_STYLE.md` 存在且包含规范内容，写代码时严格遵守其中定义的风格规范
5. 优先参考已有决策和背景，避免重新讨论已决事项
6. 如果记忆中的信息与当前代码不一致，提醒用户确认

## 决策追问

在建议写入记忆之前，如果用户正在讨论一个重要决策但尚未想清楚，**逐一追问**直到达成共识：

- 每次只问一个问题，并给出你的推荐答案
- 沿决策树逐层展开：先问"选什么"，再问"为什么"，再问"有什么后果"
- 如果问题能通过阅读代码回答，先读代码再提问
- 达成共识后，再提议写入记忆

触发条件：用户在讨论架构选型、技术路线、重要约定，但理由或影响尚不明确时。

## 记忆更新

4. 当对话中产生以下类型信息时，**主动提议**"要不要更新到项目记忆？"，用户确认后再写入：
   - 技术路线 / 架构选型变更（为什么选 A 不选 B）
   - 影响全局的约定（通信协议、数据格式、分支策略…）
   - 项目背景变化（需求变更、硬件更换、平台迁移…）
   - 重要的 Trade-off 和约束条件

5. 更新格式：
   - 条目标签格式：`[作者, 日期, v版本]`，版本号**必须从 `MEMORY/.version` 文件读取**，禁止从其他来源推断
   - 新决策：添加到 Architecture Decisions，包含 Status / Context / Decision / Consequences
   - 推翻旧决策：标记 `[SUPERSEDED by: 新标题]`，不删除原条目
   - Conventions 只记影响全局的约定

6. **不记录：**
   - 普通 bug 修复、小的代码改动
   - 调试过程中的中间步骤（只记最终定位到的根因和解法，不记"试了 A 不行又试了 B"）
   - 讨论过但最终未采纳的方案（除非弃选理由本身有参考价值，如"X 方案因内存超限放弃"）
   - 个人习惯或偏好（如编辑器设置、个人 alias），只记经团队确认的共识约定

## 手动触发整理

用户说"整理记忆"、"扫描对话"等指令时，执行：

```
/project-memory scan
```

## 冲突避免

7. 只追加或修改自己相关的条目，不重写整个文件
8. 发现矛盾信息时，询问用户确认后再更新

## 文件标记

9. 所有由 AI 生成或修改的文件，必须在文件顶部添加注释，注释以 `From AI` 开头
10. 注释格式根据文件类型选择对应语法：
    - Python: `# From AI — <简述用途>`
    - Markdown: `<!-- From AI — <简述用途> -->`
    - C/C++: `/* From AI — <简述用途> */`
    - Shell/Bash: `# From AI — <简述用途>`
    - JSON: 不支持注释，跳过

## 提交记录

11. 提交信息简洁明了，描述本次提交的主要修改
12. 注释和提交记录全部使用中文
13. 遵循格式：`<type>: <subject>`（英文冒号，冒号后有空格）
    - `feat` — 新功能
    - `fix` — 修复 bug
    - `docs` — 文档
    - `style` — 格式化代码
    - `refactor` — 重构
    - `test` — 测试代码
    - `chore` — 构建工具
    - 示例：`feat: 添加I2C驱动`
14. AI 生成或修改的代码提交时，使用 `Co-authored-by` trailer 将 AI 标记为协作人：
    ```
    feat: 添加I2C驱动

    Co-authored-by: Claude <claude@anthropic.com>
    ```
15. 如果一次 commit 包含多个 AI 辅助修改，在 commit body 中逐条列出变更点
