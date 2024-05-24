local M = {}

function M.set_bg(color, style)
    vim.print("set_bg run")
    vim.print("set_bg end")
    vim.api.nvim_set_hl(0, "Normal", {
        bg = color,
        unpack(style),
    })
end

return M
