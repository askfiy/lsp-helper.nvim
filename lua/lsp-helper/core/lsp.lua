local config = require("lsp-helper.config")
local float = require("lsp-helper.core.float")

local M = {}

--- The first time to open, the second time to exit
--- @param user_config? vim.lsp.buf.signature_help.Opts
function M.signature_help(user_config)
    local winner, bufnr = float.get_lsp_float({
        signatureHelp = true,
    })

    if bufnr or winner then
        vim.api.nvim_win_close(winner, false)
        return
    end

    user_config = vim.tbl_deep_extend("keep", user_config or {}, {
        border = config.float.border,
    })

    vim.lsp.buf.signature_help(user_config)
end

-- The first time to open, the second time to enter, the third time to exit
--- @param user_config? vim.lsp.buf.hover.Opts
function M.hover(user_config)
    local winner, bufnr = float.get_lsp_float({
        hover = true,
    })

    if (bufnr or winner) and vim.api.nvim_get_current_win() == winner then
        vim.api.nvim_win_close(winner, false)
        return
    end

    user_config = vim.tbl_deep_extend("keep", user_config or {}, {
        border = config.float.border,
    })

    user_config = vim.tbl_deep_extend("keep", user_config or {}, {
        border = config.float.border,
    })
    vim.lsp.buf.hover(user_config)
end

return M
