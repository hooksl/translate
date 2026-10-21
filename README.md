# translate.nvim

[English](#english) | 中文

在 Neovim 里直接翻译光标下的单词或选中的文本，结果显示在光标旁的浮动窗口中。支持**本地离线词典**（[sdcv](https://github.com/Dushistov/sdcv) + StarDict 词典）和**在线翻译**（[translate-shell](https://github.com/soimort/translate-shell)），中英文自动识别方向。

<!-- 截图：录一个 GIF 放在这里效果最好，例如 ![demo](https://user-images.githubusercontent.com/...) -->

## 功能

- 普通模式翻译光标下的单词，可视模式翻译选中内容（支持多行）
- 三种引擎：`local`（离线词典）、`online`（在线翻译）、`sound`（在线翻译并朗读）
- 自动判断方向：含中日韩文字 → 英文，其他 → 中文（目标语言可配置）
- 在线翻译可配置代理
- 异步执行，不卡编辑器
- `:checkhealth translate` 检查依赖

## 依赖

- Neovim **0.10+**
- 本地翻译：`sdcv` 和 StarDict 格式词典
- 在线翻译 / 朗读：`translate-shell`（命令 `trans`）；朗读还需要 `mpv`、`mplayer` 等播放器之一

```sh
# Debian / Ubuntu
sudo apt install sdcv translate-shell
# Arch
sudo pacman -S sdcv translate-shell
# macOS
brew install sdcv translate-shell
```

词典放在 `~/.stardict/dic/` 下，每个词典一个文件夹（包含 `.ifo` `.idx` `.dict.dz` 文件）。例如朗道英汉/汉英词典：

```sh
mkdir -p ~/.stardict/dic && cd ~/.stardict/dic
tar xJf stardict-langdao-ec-gb-2.4.2.tar.xz
tar xJf stardict-langdao-ce-gb-2.4.2.tar.xz
sdcv -l   # 列出已安装的词典
```

## 安装

[lazy.nvim](https://github.com/folke/lazy.nvim)：

```lua
{
    "hooksl/translate",
    cmd = "Translate",
    keys = {
        { "<leader>tt", mode = { "n", "x" } },
        { "<leader>to", mode = { "n", "x" } },
        { "<leader>ts", mode = { "n", "x" } },
    },
    opts = {
        keymaps = {
            ["<leader>tt"] = "local_translation",
            ["<leader>to"] = "online_translation",
            ["<leader>ts"] = "sound",
        },
    },
}
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)：

```lua
use {
    "hooksl/translate",
    config = function()
        require("translate").setup({
            keymaps = { ["<leader>tt"] = "local_translation" },
        })
    end,
}
```

## 配置

以下是默认值，只需要写你想改的部分：

```lua
require("translate").setup({
    -- :Translate 不指定引擎时使用："local" | "online" | "sound"
    default_engine = "local",

    -- 在线翻译代理，例如 "127.0.0.1:7890"；nil 表示不使用代理
    proxy = nil,

    -- 在线翻译的目标语言（translate-shell 语言代码）
    languages = {
        to_zh = "zh", -- 非中日韩文本翻译成
        to_en = "en", -- 中日韩文本翻译成
    },

    -- 外部命令路径
    commands = {
        sdcv = "sdcv",
        trans = "trans",
    },

    -- 浮动窗口
    window = {
        max_width = 80,
        max_height = 20,
        border = "rounded",
    },

    -- 快捷键，默认不设置任何快捷键
    -- 可选值："local_translation" | "online_translation" | "sound"
    keymaps = {},
})
```

## 使用

| 操作 | 说明 |
| --- | --- |
| `:Translate` | 用默认引擎翻译光标下的单词 |
| `:Translate online` | 用指定引擎翻译光标下的单词 |
| `:Translate online 你好世界` | 翻译给定文本 |
| `:'<,'>Translate` | 翻译可视选区 |
| `q` / `<Esc>` | 关闭翻译窗口 |

Lua API：

```lua
require("translate").translate("hello", "online")  -- 翻译任意文本
require("translate").translate_cursor("local")     -- 翻译光标下单词 / 选区
```

---

## English

Translate the word under the cursor or the visual selection without leaving Neovim. Results open in a floating window next to the cursor. Supports an **offline dictionary** ([sdcv](https://github.com/Dushistov/sdcv) + StarDict dictionaries) and **online translation** ([translate-shell](https://github.com/soimort/translate-shell)). The direction is detected automatically: text containing CJK characters goes to English, everything else to Chinese (both configurable).

### Requirements

- Neovim **0.10+**
- `sdcv` and StarDict dictionaries in `~/.stardict/dic/` for the `local` engine
- `translate-shell` (`trans`) for the `online` and `sound` engines

### Install (lazy.nvim)

```lua
{
    "hooksl/translate",
    cmd = "Translate",
    opts = {
        keymaps = {
            ["<leader>tt"] = "local_translation",
            ["<leader>to"] = "online_translation",
            ["<leader>ts"] = "sound",
        },
    },
}
```

### Usage

- `:Translate [local|online|sound] [text]` — translate the word under the cursor, the given text, or a range (`:'<,'>Translate`)
- `q` / `<Esc>` closes the window
- `:checkhealth translate` checks the external tools

See the Chinese section above for all options; option names and defaults are the same.

## License

[MIT](LICENSE)
