# C Coding Style

> 来源：new_C_Coding_Style.docx  
> 缓存时间：2026-04-17（更新版）

---

## 1. Introduction

为了解决代码后续 coding 过程中的风格不一致问题，将逐渐推行统一的 Coding Style。统一风格有助于代码沟通顺畅，也凝聚了前辈多年积累的经验，能提高代码质量，减少意外出错的可能。

条款分两种：
- **Rule（规则）**：强制执行，所有人必须遵守
- **Suggestion（建议）**：推荐遵循，不强制要求

---

## 2. Key Rules & Examples

### 2.1 Rule 1 — Structure & Local Variable Definition

```c
/***********************************************************************
rule 1: structure typedef & local variable
1-1. new structure name use uppercase letters.
     (the following is the same with local variable)
1-2. bit segment, prefixed with 'bs'
1-3. uint8_t/uint16_t/uint32_t/uint64_t, prefixed with 'uc'/'us'/'ul'/'ull'
1-4. enum variable, prefixed with 'e'
1-5. array variable, prefixed with 'a'
1-6. structure variable, prefixed with 't'
1-7. pointer variable, prefixed with 'p'
***********************************************************************/
typedef struct _NEW_STRUCT
{
    uint8_t bsXxx : 1;
    uint8_t bsYyy : 7;
    uint8_t ucParamChar;
    uint16_t usParamShort;
    uint32_t ulParamLong;
    uint64_t ullParamDoubleWord;
    float fParamFloat;
    double dParamDouble;
    uint8_t aNewArray[32];
    enum _NEW_ENUM eEnumPara;
    OLD_STRUCT tOldStruct;
    struct _NEW_STRUCT *pNewStruct;
    union _NEW_UNION unNewUnion;
}NEW_STRUCT;
```

### 2.2 Rule 2 — Function Definition

```c
/***********************************************************************
rule 2: function definition
2-1. function name: MODULE_FunctionName
     module name: uppercase abbreviation
     function name: each word capitalized (PascalCase)
2-2. only one '_' in function name
2-3. LOCAL modifier for module-internal functions (not called by other modules)
2-4. INPUT modifier for pointer params whose pointed content is input-only
2-5. void for no parameters; void for no return value
***********************************************************************/
LOCAL void MODULE_FunctionName(INPUT uint8_t *pucParam, uint8_t ucLen)
{
    /* function body */
}
```

### 2.3 Rule 3 — Local Variable

```c
/***********************************************************************
rule 3: local variable
(prefix rules same as structure member)
***********************************************************************/
void MODULE_Example(void)
{
    uint8_t  ucLocalVar;
    uint16_t usLocalVar;
    uint32_t ulLocalVar;
    uint64_t udLocalVar;
    bool     bLocalVar;
    uint8_t  aLocalArray[32];
    uint8_t *pucLocalPtr;
    STRUCT_TYPE tLocalStruct;
}
```

### 2.4 Rule 4 — Global Variable

```c
/***********************************************************************
rule 4: global variable
g_  prefix: accessible from other modules (use GLOBAL modifier)
l_  prefix: only accessible within this module (use LOCAL modifier)
(suffix naming rules same as local variable)
***********************************************************************/
GLOBAL uint8_t  g_ucGlobalVar;    /* global variable — must have detailed comment */
LOCAL  uint8_t  l_ucLocalGlobal;  /* module-level global — must have detailed comment */
```

### 2.5 Other Rules — Spacing & Formatting

```c
/***********************************************************************
rule 5: spacing, indentation, braces
- keyword + space + '('  : if (, for (, while (, switch (
- binary operators: space before and after (=, ==, <, >, !=, ...)
- ';' followed by space; no space after '(' or before ')'
- indent: 4 spaces
- '{' and '}' each on their own line (except struct/enum/union closing '}')
- constant on left in equality check: if (0 != ucVar)
- always use '{}' even for single-line if/for/while body
***********************************************************************/
if (0 != ucVar)
{
    for (ucI = 0; ucI < MAX_LEN; ucI++)
    {
        ulResult = ulA + ulB;
    }
}
```

---

## 3. Rules Summary

### 3.1 Summary of the Example Rules

#### 局部变量命名前缀
| 类型 | 前缀 |
|------|------|
| `uint8_t` | `uc` |
| `uint16_t` | `us` |
| `uint32_t` | `ul` |
| `uint64_t` | `ud` |
| `bool` | `b` |
| 数组 | `a` |
| 指针 | `p`（`*` 紧挨 `p` 之前，`p` 后不再加其他前缀） |
| 结构体 | `t` |
| 结构体指针 | `p` |

#### 全局变量
- 前缀 `g_`（外部）或 `l_`（模块内），后续同局部变量规则
- 全局变量要有详细注释

#### 结构体定义
- 新名称全大写，用下划线连接
- 用 `typedef`，`}` 后跟新名称，`{` 前跟 `_` + 新名称
- 参数命名同局部变量
- 结构体定义要有详细注释

#### 函数命名
- `模块名称缩写（全大写）` + `_` + `函数功能名称（单词首字母大写）`；下划线只出现一次
- 模块内部函数（不需被其他模块调用）加前缀 `LOCAL`

#### 函数入参
- 命名同局部变量
- 指针变量若指向内容仅作为函数输入，需加 `INPUT` 修饰
- 无参数时必须加 `void`；无返回值时返回值类型也要加 `void`

#### 宏与表达式
- 有具体意义的数字定义成宏，避免魔鬼数字（magic number）
- `if`、`for`、`while`、`switch` 与后面 `(` 之间加空格，突出关键字
- 二元操作符（`=`、`==`、`<` 等）前后加空格；`;` 后面加空格；`(` 右边和 `)` 左边不跟空格
- 宏定义操作，每个参数必须用一对括号 `()` 包含

#### 缩进与格式
- 程序块采用缩进风格，缩进 4 个空格
- 注释与所描述内容同样缩排；注释与其上面代码用空行隔开
- `if`、`for` 等语句自占一行，执行语句部分无论多少都要加 `{}`
- `{` 和 `}` 各自独立占一行（定义 `struct`/`enum`/`union` 等类型时的 `}` 除外）
- `typedef struct` 的第一个 `{` 独占一行

#### 条件判断
- 用 `==` 判断时，常量放左边，变量放右边（如 `if (0 != xxx)`）
- 用括号明确表达式的操作顺序，避免使用默认优先级
- 判断条件（`if` 等）括号内必须是表达式，如 `if (0 != xxx)`，而不是 `if (xxx)`

#### 其他强制规则
- 禁止在 `.h` 中定义变量
- 跨度较大的 `#if #else #endif` 必须有注释
- 函数头注释写在 `.c`，不写在 `.h`
- 函数外定义变量必须用 `GLOBAL` / `LOCAL` 修饰

---

### 3.2 Other Rules

- 除循环变量外，不定义单字符变量（如 `i`、`j`、`k`）
- `switch` 语句必须有 `default` 分支
- 不允许多个短语句写在一行，一行只写一条语句
- 严禁使用未经初始化的变量作为右值
- 一个变量只有一个功能，不能用作多种用途
- 不可在 `for` 循环体内修改循环变量，防止失控
- 文件名与函数名命名：模块名 + `_` + 描述（驼峰式，每个单词首字母大写）；下划线只出现一次；模块名按 FW 代码划分用一级目录名称

---

### 3.3 Suggestions（建议，不强制）

- 尽量编写简单清晰的代码，非必要不使用高技巧性语句
- 不要使用 `goto` 语句
- 注意防止差 1 错误（`<=` 与 `<`，`>=` 与 `>`，尤其在循环中）
- 注释格式尽量统一，建议使用 `/* …… */`
- 除非必要，不用数字或奇怪字符定义标识符
- 尽量少用全局变量，减少代码间耦合
- 尽量使循环内操作减少/简单
- 定义一组函数操作同一个对象时，用"对象 + 动作"顺序定义函数名称
- 不建议在 `if{}`/`while{}` 块内定义局部变量

---

## 4. Controversial Styles（争议条款）

### 声明变量时是否需要初始化
- **全局变量 / 静态变量**：声明时必须赋初始值（`0` 或 `NULL`）
- **局部变量**：出于 performance 需要，可不赋初值，但必须保证在任何分支中变量使用前都已赋值

### 对外函数接口，入参是指针时是否需要判空
- firmware 代码出于 performance 需要，在确认不可能是空指针的情况下可不判断
- 但在 simulation 环境中需要判断并充分验证

---

## 5. Skills

### 5.1 Convert Tab to Space

代码编辑工具向 VS Code 统一；使用 VS Code 将 tab 转换为空格。
