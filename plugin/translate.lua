if vim.g.loaded_translate then
    return
end
vim.g.loaded_translate = true

local engines = { "local", "online", "sound" }

-- :Translate [engine] [text]
--   :Translate                 word under cursor, default engine
--   :Translate online          word under cursor, online engine
--   :Translate online hello    the given text
--   :'<,'>Translate online     the visual selection
vim.api.nvim_create_user_command("Translate", function(cmd)
    local core = require("translate.core")
    local args = cmd.fargs
    local engine = nil
    if args[1] and vim.tbl_contains(engines, args[1]) then
        engine = table.remove(args, 1)
    end

    local text
    if #args > 0 then
        text = table.concat(args, " ")
    elseif cmd.range > 0 then
        text = core.get_range_text(cmd.line1, cmd.line2)
    else
        text = vim.fn.expand("<cword>")
    end
    core.translate(text, engine)
end, {
    nargs = "*",
    range = true,
    desc = "Translate word, selection or text",
    complete = function(arglead, cmdline)
        if #vim.split(cmdline, "%s+") > 2 then
            return {}
        end
        return vim.tbl_filter(function(e)
            return e:find(arglead, 1, true) == 1
        end, engines)
    end,
})
