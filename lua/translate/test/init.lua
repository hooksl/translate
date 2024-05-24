local M = {}

local function reload_plugin()
    for plugin_name, _ in pairs(package.loaded) do
        if (plugin_name:match("fanyi")) then
            package.loaded[plugin_name] = nil
        end
    end
    require("fanyi").setup()
end

function M.begin()
    vim.keymap.set('n', "<leader>pt", reload_plugin, {
        desc = "quick reload plugin",
    })
end

return M
