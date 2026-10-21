local config = require("translate.config")

local M = {}

-- Engine name -> internal id. Old mapping names are kept for compatibility.
M.engine_alias = {
    ["local"] = "local",
    local_translation = "local",
    online = "online",
    online_translation = "online",
    sound = "sound",
}

--- Does the text contain CJK characters?
function M.has_cjk(text)
    for _, cp in ipairs(vim.fn.str2list(text)) do
        if (cp >= 0x4E00 and cp <= 0x9FFF) -- CJK Unified Ideographs
            or (cp >= 0x3400 and cp <= 0x4DBF) -- Extension A
            or (cp >= 0x3040 and cp <= 0x30FF) -- Hiragana / Katakana
            or (cp >= 0xAC00 and cp <= 0xD7AF) -- Hangul
        then
            return true
        end
    end
    return false
end

--- Text under the cursor (normal mode) or the current visual selection.
function M.get_text()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "\22" then
        local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
        return table.concat(lines, " ")
    end
    return vim.fn.expand("<cword>")
end

--- Text covered by a command range (:'<,'>Translate)
function M.get_range_text(line1, line2)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    -- Use the exact visual selection when the range matches it, otherwise whole lines.
    if start_pos[2] == line1 and end_pos[2] == line2 then
        local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.visualmode() })
        return table.concat(lines, " ")
    end
    return table.concat(vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false), " ")
end

--- Build the argv list for an engine. Arguments are passed as a list,
--- so no shell quoting/escaping is involved.
function M.build_cmd(engine, text)
    local opts = config.options
    if engine == "local" then
        -- -n non-interactive, -e exact match, -0/-1 force UTF-8 output/input
        return { opts.commands.sdcv, "-n", "-e", "-0", "-1", text }
    end

    local cmd = { opts.commands.trans, "-no-ansi" }
    if opts.proxy and opts.proxy ~= "" then
        vim.list_extend(cmd, { "-x", opts.proxy })
    end
    if engine == "sound" then
        table.insert(cmd, "-sp")
    end
    if M.has_cjk(text) then
        -- Chinese -> English: show the detailed dictionary output
        if engine == "sound" then table.insert(cmd, "-d") end
        table.insert(cmd, ":" .. opts.languages.to_en)
    else
        table.insert(cmd, "-b")
        table.insert(cmd, ":" .. opts.languages.to_zh)
    end
    table.insert(cmd, text)
    return cmd
end

--- Show lines in a floating window next to the cursor.
function M.open_float(lines)
    local wopts = config.options.window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "translate"

    local width = 1
    for _, l in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(l))
    end
    width = math.min(width, wopts.max_width, vim.o.columns - 4)
    local height = math.min(#lines, wopts.max_height, vim.o.lines - 4)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = math.max(width, 1),
        height = math.max(height, 1),
        border = wopts.border,
        style = "minimal",
    })
    vim.wo[win].wrap = true

    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
    vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
    return win, buf
end

local function to_lines(s)
    local lines = {}
    for row in (s or ""):gmatch("[^\n]+") do
        table.insert(lines, row)
    end
    return lines
end

--- Translate `text` with `engine` and show the result.
function M.translate(text, engine)
    engine = M.engine_alias[engine or config.options.default_engine]
    if not engine then
        vim.notify("translate: unknown engine", vim.log.levels.ERROR)
        return
    end
    text = vim.trim(((text or ""):gsub("%s+", " ")))
    if text == "" then
        vim.notify("translate: nothing to translate", vim.log.levels.WARN)
        return
    end

    local cmd = M.build_cmd(engine, text)
    if vim.fn.executable(cmd[1]) ~= 1 then
        vim.notify(("translate: `%s` not found, run :checkhealth translate"):format(cmd[1]),
            vim.log.levels.ERROR)
        return
    end

    vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
        local out = res.stdout or ""
        if res.code ~= 0 and vim.trim(out) == "" then
            out = res.stderr or ""
        end
        local lines = to_lines(out)
        if #lines == 0 then
            lines = { "No result for: " .. text }
        end
        M.open_float(lines)
    end))
end

function M.set_keymaps(keymaps)
    for lhs, name in pairs(keymaps or {}) do
        local engine = M.engine_alias[name]
        if engine then
            vim.keymap.set({ "n", "x" }, lhs, function()
                M.translate(M.get_text(), engine)
            end, { silent = true, desc = "Translate (" .. engine .. ")" })
        else
            vim.notify(("translate: unknown keymap action %q for %s"):format(name, lhs),
                vim.log.levels.WARN)
        end
    end
end

return M
