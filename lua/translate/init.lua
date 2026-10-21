local config = require("translate.config")
local core = require("translate.core")

local M = {}

function M.setup(opts)
    config.setup(opts)
    core.set_keymaps(config.options.keymaps)
end

--- Translate arbitrary text. engine: "local" | "online" | "sound" (optional)
function M.translate(text, engine)
    core.translate(text, engine)
end

--- Translate the word under the cursor / the visual selection.
function M.translate_cursor(engine)
    core.translate(core.get_text(), engine)
end

return M
