-- Headless tests. Run from the repo root:
--   PATH="$PWD/tests/bin:$PATH" nvim --headless --clean -l tests/run.lua
-- The stubs in tests/bin echo their arguments, so we can check the exact argv.

vim.opt.rtp:prepend(vim.fn.getcwd())
vim.g.mapleader = "\\"
vim.cmd("runtime plugin/translate.lua")

local failures, passed = 0, 0
local function check(name, got, want)
    if got == want then
        passed = passed + 1
    else
        failures = failures + 1
        io.stderr:write(("FAIL %s\n  got:  %s\n  want: %s\n"):format(name, tostring(got), tostring(want)))
    end
end

-- Wait for the result window, return its text and close it.
local function result()
    vim.wait(3000, function() return #vim.api.nvim_list_wins() > 1 end)
    if #vim.api.nvim_list_wins() == 1 then return "<no window>" end
    local win = vim.api.nvim_get_current_win()
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    vim.api.nvim_win_close(win, true)
    return text
end

require("translate").setup({
    proxy = "127.0.0.1:2080",
    keymaps = {
        ["<leader>tt"] = "local_translation",
        ["<leader>to"] = "online_translation",
    },
})
local core = require("translate.core")

vim.api.nvim_buf_set_lines(0, 0, -1, false, { [[hello world it's "quoted" `x` $HOME]], "你好 世界" })

-- normal mode keymap, word under cursor
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.api.nvim_feedkeys(vim.keycode("\\tt"), "x", false)
check("local cword", result(), "SDCV [-n] [-e] [-0] [-1] [hello]")

-- visual mode keymap: special characters must reach the tool untouched
vim.api.nvim_feedkeys(vim.keycode("0v$\\to"), "x", false)
check("online visual", result(),
    [=[TRANS [-no-ansi] [-x] [127.0.0.1:2080] [-b] [:zh] [hello world it's "quoted" `x` $HOME]]=])

-- command with CJK text goes to English
vim.cmd("Translate online 你好 世界")
check("online cjk", result(), "TRANS [-no-ansi] [-x] [127.0.0.1:2080] [:en] [你好 世界]")

vim.cmd("Translate sound 你好")
check("sound cjk", result(), "TRANS [-no-ansi] [-x] [127.0.0.1:2080] [-sp] [-d] [:en] [你好]")

-- line range, default engine
vim.cmd("2Translate")
check("range", result(), "SDCV [-n] [-e] [-0] [-1] [你好 世界]")

-- no proxy configured
require("translate").setup({})
vim.cmd("Translate online hi")
check("no proxy", result(), "TRANS [-no-ansi] [-b] [:zh] [hi]")

check("has_cjk ascii", core.has_cjk("abc"), false)
check("has_cjk zh", core.has_cjk("a中"), true)
check("has_cjk ja", core.has_cjk("かな"), true)

print(("%d passed, %d failed"):format(passed, failures))
os.exit(failures == 0 and 0 or 1)
