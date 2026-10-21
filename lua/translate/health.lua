local M = {}

function M.check()
    local h = vim.health
    local opts = require("translate.config").options

    h.start("translate")

    if vim.fn.has("nvim-0.10") == 1 then
        h.ok("Neovim >= 0.10")
    else
        h.error("Neovim 0.10 or newer is required")
    end

    if vim.fn.executable(opts.commands.sdcv) == 1 then
        h.ok(("`%s` found (local engine)"):format(opts.commands.sdcv))
    else
        h.warn(("`%s` not found, the local engine will not work"):format(opts.commands.sdcv),
            { "Install sdcv, e.g. `sudo apt install sdcv`, and put StarDict dictionaries in ~/.stardict/dic" })
    end

    if vim.fn.executable(opts.commands.trans) == 1 then
        h.ok(("`%s` found (online / sound engines)"):format(opts.commands.trans))
    else
        h.warn(("`%s` not found, the online and sound engines will not work"):format(opts.commands.trans),
            { "Install translate-shell, e.g. `sudo apt install translate-shell`" })
    end

    if opts.proxy then
        h.info("Proxy for online engines: " .. opts.proxy)
    end
end

return M
