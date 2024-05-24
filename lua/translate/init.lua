local default_config = require("translate.conf")
local core = require("translate.core")
local test = require("translate.test")
local M = {}
test.begin()
M.info = "hello lua"
function M.setup(opt)
    vim.notify("setup run")
    vim.print("默认配置：")
    vim.print(default_config)
    vim.print("传递参数：")
    vim.print(opt)
    -- code
    local conf = vim.tbl_deep_extend("force", default_config, opt or {})
    vim.print("合并后的配置：")
    core.set_bg(conf.color, conf.style)
    vim.print(conf)
    vim.print("单独打印color：")
    vim.print(conf.color)
    vim.print("单独打印style：")
    vim.print(conf.style)
end

return M
