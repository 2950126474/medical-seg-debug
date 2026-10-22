# Medical Seg Debug

一个帮助 Codex 排查 PyTorch / MONAI 医学图像分割训练问题的 skill。

A Codex skill for evidence-led debugging of PyTorch/MONAI segmentation environments and training runs. Includes an optional read-only Bash diagnostic helper.

## 能做什么

- 区分本机、WSL、远程服务器和容器，定位实际运行的 Python 环境。
- 排查 CUDA 不可见、依赖缺失、NIfTI 读取、权重路径和训练日志问题。
- 先验证可能原因，再做针对性修复；避免默认升级整个环境。
- 区分警告与真正的异常，以及冒烟测试与正式研究结果。

这不是医学诊断工具，也不是完整的实验设计或自动训练框架。它不自带远程连接能力，需要当前 Codex 环境能访问目标主机；无法访问时会指导你收集必要信息。

## 安装

在支持技能安装的 Codex 中输入：

> 请用 skill-installer 安装 GitHub 仓库 2950126474/medical-seg-debug 中的 skills/medical-seg-debug。

也可以下载仓库，把 `skills/medical-seg-debug` 整个文件夹放入 `$CODEX_HOME/skills/`；没有设置 CODEX_HOME 时，默认是 `~/.codex/skills/`。如果已有同名 skill，请先比较并备份，不要直接覆盖自己的修改。

安装后新开一个对话使用。这个仓库是独立公开版本，不会自动同步作者的自用版本。

## 使用示例

直接描述问题并附上必要的报错：

> 用 $medical-seg-debug 帮我排查：远程 Linux 上 nvidia-smi 正常，但训练用的 Python 里 torch.cuda.is_available() 是 False。先确认原因。

> 我的 MONAI DataLoader 在第一批数据前卡住了。请结合训练代码和日志定位，先不要调整全部依赖。

> 报错说预训练权重不存在，但磁盘上有这个文件。请检查实际解析的路径和命令行参数。

普通相关提问也可以触发 skill；是否自动选中取决于当前客户端与上下文。

## 可选诊断脚本

在目标 Linux/WSL 的 Bash 中、激活训练使用的环境后运行：

```bash
bash /path/to/medical-seg-debug/scripts/env_check.sh
```

脚本只收集 conda、Python、GPU、PyTorch 和部分包信息，不安装依赖、不启动训练。缺少命令时仍会继续，因此退出码为 0 不等于环境正常。它不测试 GPU 运算、模型训练、数据质量或网络存储持久性。不要把这个 Bash 脚本直接当作 PowerShell 脚本执行。

## 验证范围

公开版本通过技能格式校验和 Bash 语法检查；诊断脚本使用隔离的模拟命令检查正常输出与缺少依赖时的继续执行。触发、非触发和边界场景经过人工规则审查，未进行独立模型行为评测，也未在真实 CUDA 训练环境中完成端到端验证。

VoCo 相关案例仅用于说明一种历史参数解析问题，不代表所有版本通用；必须先检查当前源码。

## 反馈

欢迎到 [Issues](https://github.com/2950126474/medical-seg-debug/issues) 提交问题、使用体验或改进建议。请描述预期行为、实际行为和最小复现信息；分享日志前移除凭据、服务器地址、私人路径及患者信息。无需上传原始医学影像。

## 许可

[MIT](LICENSE)
