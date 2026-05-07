# code2lean

```
░█▀▀░█▀█░█▀▄░█▀▀░▀▀▄░█░░░█▀▀░█▀█░█▀█
░█░░░█░█░█░█░█▀▀░▄▀░░█░░░█▀▀░█▀█░█░█
░▀▀▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀░▀
```

> 源代码 → LLM 提议 → Lean 4 验证 → 多重门禁校验。
>
> *Lean 是验证者,LLM 只是提议者。*

[English](README.md) · [简体中文](README.zh-Hans.md)

一条流水线:输入一段源代码函数,让 LLM 把它翻译成 Lean 4 *并* 同时
提出一个正确性定理,然后通过五个相互独立的门禁
—— 静态扫描、Lean 编译、公理白名单、与原始源代码的差分测试、以及
第二个 LLM 担任评审 —— 来决定是否信任这次结果。

重点不在翻译,而在门禁。LLM 完全可以写一句
`theorem foo : P := sorry` 然后宣称"已验证"。整套设计的目的就是让
这种谎言暴露出来。

## 项目缘起

一个定理在**形式上是正确的**,这并不意味着它所描述的实现就是
**安全的**。本仓库的种子例子是 HMAC 标签比较:

- `source/token_verify_vulnerable.py` —— 提前返回的逐字节循环;
  功能正确,但存在时序泄漏。
- `source/token_verify_fixed.py` —— 使用 `hmac.compare_digest`,
  恒定时间。
- `RepoVerify/TokenVerify.lean` —— 同时给出**功能性定理**(对两种
  实现都成立)和**代价定理**(只对修复版成立)。
- `source/attack_demo.py` —— 一个确定性的比较代价预言机,
  能够从有漏洞的实现中恢复出秘密 HMAC 标签。

运行攻击:

```bash
python source/attack_demo.py
```

恢复出来的标签和真实标签一致。教训:只证明功能性定理的验证器
会"放行"那个有漏洞的实现。要获得真正的安全保证,需要*更强的*
定理,并且必须主动追问"我证明的定理是否正确"。

通用流水线 (`verify/`) 把这个问题一般化了:对于任意提取出来的
函数,提议出来的 Lean 定理是否真的刻画了函数的行为?还是只是一个
任何错误实现也都满足的空洞重述?

## 快速上手

### 安装

需要 Lean 4 / Lake(通过
[`elan`](https://github.com/leanprover/elan) 安装),以及
Python ≥ 3.10:

```bash
git clone https://github.com/phunterlau/code2lean.git
cd code2lean
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
lake build
```

### 验证手写 Lean 基线

```bash
lake build
```

会对 `RepoVerify/TokenVerify.lean` 做类型检查(原始 HMAC 例子的形式
化模型:漏洞版与修复版相等性、各自的功能性定理、漏洞版的泄漏反例,
以及修复版的恒定时间代价定理)。

### 在某个示例上运行流水线

设置任意一个 LLM 的 API key,然后运行:

```bash
export OPENAI_API_KEY=...        # 用于 --provider openai
export GEMINI_API_KEY=...        # 用于 --provider gemini
export ANTHROPIC_API_KEY=...     # 用于 --provider claude

python -m verify.pipeline \
  --example examples/01_insecure_compare \
  --provider gemini \
  --critic openai \
  --max-repair 3
```

流水线:

1. 用 AST 从 `source.py` 中抽取指定函数。
2. 让提议者写出一份 Lean 4 文件(函数定义 + 定理 + 证明)。
3. 用 `lake env lean` 编译。失败则进入修复循环。
4. 用 `#print axioms` 校验依赖的公理(白名单:`propext`、
   `Classical.choice`、`Quot.sound`)。
5. 把 Lean 的 `#eval` 结果与对应 Python 调用做差分测试,逐个
   fixture case 比对。
6. 可选:让第二个 LLM 评审定理本身(`PASS / WEAK / FAIL`)。

退出码:

- `0` —— 所有门禁通过
- `1` —— 静态扫描 / Lean / 公理 / 差分测试任一失败
- `2` —— 评审给出 `WEAK` / `FAIL` / `PARSE_ERROR`

### 运行原始 HMAC 攻击演示

```bash
python -m pytest                              # 功能性 + 攻击恢复测试
python source/attack_demo.py                  # 确定性时序泄漏攻击
```

## 工作原理(一张图)

```
[source.py] ─► AST 抽取 ─► 提议者(LLM) ─► Lean 文件
                                                     │
                                                     ▼
                                           门禁 A:静态扫描
                                           门禁 B:lake env lean ──修复循环──► 提议者
                                           门禁 C:公理白名单
                                           门禁 D:差分测试(Python ↔ Lean)
                                           门禁 E:评审(第二个 LLM)
                                                     │
                                                     ▼
                                              PASS / 失败
```

`A`–`D` 是机械式门禁,验证路径上不需要 LLM 做判断。`E` 是流水线
里**唯一**依赖 LLM 判断的环节,它的存在是为了抓**空洞定理**
(对 `bit_count8` 来说,`result ≤ 8` 对一个永远返回零的实现也成立;
Lean 会接受它;评审会指出来)。背后的动机见
[docs/architecture.md](docs/architecture.md),具体实现见
[docs/pipeline.md](docs/pipeline.md)。

## 基准测试一览

同一组 10 个较难样例,三种提议者/评审者组合:

| 提议者 | 评审者 | Lean 通过率 | 定理 PASS 率 | 总耗时 |
|--------|--------|-------------|--------------|--------|
| Gemini 3.1 Pro | GPT-5.5 | **10/10** | 0/10 | ~38.5 分钟 |
| Claude Opus 4.7 | GPT-5.5 | 8/10 | 2/10 | **~8.5 分钟** |
| GPT-5.5 | Claude Opus 4.7 | 9/10 | **6/10** | ~30.3 分钟 |

**Lean 通过率**（证明是否成功闭合）与**定理强度**（评审者是否认可）是两个独立信号。
Gemini 最善于闭合证明;GPT 所写定理最强;Claude 速度最快,适合快速扫描大批示例。
四个样例在三种提议者下均为 WEAK —— 瓶颈在提示词本身,而非模型。
完整分析见 [docs/benchmarks.md](docs/benchmarks.md)。

## 适用范围

`code2lean` 在架构上对任何具备 AST 库且类型系统能映射到 Lean 的源
语言都适用。当前的适配层是 Python,但架构本身是语言无关的。

**当前 Python 适配层接受:**

- 模块级单个函数(不支持类的方法)
- 纯函数 / 全函数 / 必终止
- 类型:`bool`、`int`(有符号或无符号)、`bytes`、`str`、
  `list[T]`、`tuple[A, B]`

**不支持**类、装饰器、生成器、`async`、浮点、字典、集合、numpy /
外部库、文件 / 网络 I/O、异常、随机性,也不支持依赖模块级
辅助函数的函数。

详细说明、以及如何扩展到 Rust / TypeScript / Go,见
[docs/scope-and-limits.md](docs/scope-and-limits.md)。

## 示例

`examples/` 目录下有 80 个小型 Python 函数(字节/列表操作、
算术、Boolean 谓词、密码学相关原语),每个都配有用于差分测试的
fixture。历史运行产物
(`last_lean_<provider>.lean`、`last_proposer_<provider>.txt`、
`last_critic_<critic>.txt`、`pipeline_*.log`)被一并提交,可作为
样本参考。完整列表和 `--example` 用法见
[examples/README.md](examples/README.md)。

## 目录结构

```
verify/
  pipeline.py                 # 编排器 —— 门禁 A–D + 修复循环
  extract.py                  # AST 抽取 → FunctionSpec
  llm.py                      # OpenAI / Gemini / Claude 统一抽象
  critic.py                   # 门禁 E —— Phase-1 评审(PASS/WEAK/FAIL)
  gpt_to_lean_security.py     # 早期单文件 GPT→Lean 演示(种子版本)
RepoVerify/
  TokenVerify.lean            # 手写 Lean 基线(安全演示)
  Autogen.lean                # 流水线写入目标 —— 每次运行覆盖
  AutogenFromGPT.lean         # gpt_to_lean_security.py 的目标文件
source/                       # 原始 HMAC 演示的 Python 代码
tests/                        # 原始演示的 pytest
examples/                     # 80 个函数 × fixture + 运行产物
docs/                         # 设计文档、单例走查、跨模型对比、路线图
```

## 文档

| 文件 | 用途 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 设计思路:信任模型、提议者/验证者分离、五个门禁、防伪日志 |
| [docs/pipeline.md](docs/pipeline.md) | 端到端流水线参考 |
| [docs/example-walkthrough.md](docs/example-walkthrough.md) | 单例走查(`34_parity_xor`),逐门禁过一遍 |
| [docs/benchmarks.md](docs/benchmarks.md) | Gemini/Claude/GPT 三方提议者对比及注意事项 |
| [docs/scope-and-limits.md](docs/scope-and-limits.md) | 当前能验证什么;如何扩展到其他语言 |
| [docs/roadmap.md](docs/roadmap.md) | Mutation-kill、pass@k、可区分性、漏洞挖掘 |

## 博客文章

[LLM 能对你的代码做形式化验证吗?可行性研究](https://toooold.com/2026/05/07/code-to-lean.html) —— 动机介绍、`insecure_compare` 全流程走查、基准测试分析及后续方向。

## License

MIT 许可证,详见 `LICENSE`。
