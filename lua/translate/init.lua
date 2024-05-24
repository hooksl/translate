local default_config = require("translate.conf")
local core = require("translate.core")
local test = require("translate.test")
local M = {}
test.begin()
function M.setup(opt)
    -- vim.notify("setup run")
    -- vim.print("默认配置：")
    -- vim.print(default_config)
    -- vim.print("传递参数：")
    -- vim.print(opt)
    local conf = vim.tbl_deep_extend("force", default_config, opt or {})
    -- vim.print("合并后的配置：")
    -- vim.print(conf)
    core.mappings(conf)
end

return M
