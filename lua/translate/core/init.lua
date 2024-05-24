local M = {}

local opts = {
    noremap = true, -- non-recursive
    silent = true,  -- do not show message
}

M.opts = {
    trans_opts = "",
    line_n = 1
}

function M.get_words()
    local words = ''
    if vim.fn.mode() == 'n' then
        words = vim.fn.expand("<cword>")
        M.opts.line_n = 1
    elseif vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
        vim.cmd([[
            execute 'normal! "9y'
        ]])
        words = vim.fn.getreg('9')
        words, M.opts.line_n = string.gsub(words, "\n", " ")
        words = string.gsub(words, '"', "'")
        words = string.gsub(words, '`', "'")
    else
        words = ''
    end
    return words
end

function M.trans()
    local words = '"' .. M.get_words() .. '"'
    local m = ""
    local proxy = "-x 127.0.0.1:2080 "
    if M.opts.trans_opts == "onlive" then
        if string.byte(words, 2) > 127 then
            m = vim.fn.system("trans -no-ansi :en " .. proxy .. words)
        else
            m = vim.fn.system("trans -no-ansi -b :zh " .. proxy .. words)
        end
    elseif M.opts.trans_opts == "sp" then
        if string.byte(words, 2) > 127 then
            m = vim.fn.system("trans -no-ansi -sp -d :en " .. proxy .. words)
        else
            m = vim.fn.system("trans -no-ansi -sp -b :zh " .. proxy .. words)
        end
    else
        m = vim.fn.system("sdcv -e " .. words)
    end
    return m
end

function M.floatwin(otps)
    local words_table = {}
    M.opts.trans_opts = otps
    local m = M.trans()
    local f_buf = vim.api.nvim_create_buf(false, true)
    for row in string.gmatch(m, "[^\n]+") do table.insert(words_table, row) end -- 分割行并写入表
    vim.api.nvim_buf_set_lines(f_buf, 0, -1, true, words_table)
    local win_id = vim.api.nvim_open_win(f_buf, true,
        {
            relative = 'cursor',
            width = 80,
            height = 15,
            col = 0,
            row = M.opts.line_n,
            border = 'single',
            anchor = 'NW',
            style = 'minimal'
        })
    vim.api.nvim_win_set_option(win_id, "wrap", true)
    local win_hl = vim.api.nvim_win_get_option(0, 'winhighlight')
    vim.api.nvim_win_set_option(win_id, 'winhighlight', win_hl)
    vim.api.nvim_buf_set_keymap(f_buf, 'n', 'q', ":close<CR>", opts)
    vim.api.nvim_buf_set_keymap(f_buf, 'n', '<esc>', ":close<CR>", opts)
end

function M.mappings()
    vim.keymap.set({ 'n', 'v' }, 'tt', function() M.floatwin(" ") end, opts)
    vim.keymap.set({ 'n', 'v' }, 'to', function() M.floatwin("onlive") end, opts)
    vim.keymap.set({ 'n', 'v' }, 'ts', function() M.floatwin("sp") end, opts)
end

return M
