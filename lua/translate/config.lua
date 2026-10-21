---@class TranslateConfig
local M = {}

M.defaults = {
    -- Engine used by :Translate when none is given: "local" | "online" | "sound"
    default_engine = "local",

    -- HTTP/SOCKS proxy for online engines, e.g. "127.0.0.1:7890". nil = no proxy.
    proxy = nil,

    -- Target languages for the online engine (translate-shell language codes).
    -- Text containing CJK characters is translated to `to_en`, everything else to `to_zh`.
    languages = {
        to_zh = "zh",
        to_en = "en",
    },

    -- External commands. Change these if the tools live somewhere else.
    commands = {
        sdcv = "sdcv",
        trans = "trans",
    },

    -- Floating window options
    window = {
        max_width = 80,
        max_height = 20,
        border = "rounded",
    },

    -- Key mappings, e.g.
    -- keymaps = {
    --     ["<leader>tt"] = "local_translation",
    --     ["<leader>to"] = "online_translation",
    --     ["<leader>ts"] = "sound",
    -- }
    keymaps = {},
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
    return M.options
end

return M
