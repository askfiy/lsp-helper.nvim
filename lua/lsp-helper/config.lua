---@class Config
---@field float ConfigFloat
---@field diagnostic ConfigDiagnostic
---@field lspconfig ConfigLspconfig
local M = {}

local config = {
    float = {
        border = "none", -- The style of the floating window
        progress_format = function(progress)
            return ("%s%%"):format(tostring(progress))
        end,
    },
    diagnostic = {
        config = {
            --[[
            signs = true,
            underline = true,
            severity_sort = true,
            update_in_insert = false,
            float = { source = "always" },
            virtual_text = { prefix = "●", source = "always" },
            ]]
        },
        icons = {
            --[[
            Error = "E",
            Warn = "W",
            Info = "I",
            Hint = "N",
            ]]
        },
        jump_ignore_lsp_sources = {}, -- Lepsus ignored when jumping
    },
    lspconfig = {
        --[[
         Some general Lsp-Client hook functions
         See: https://neovim.io/doc/user/lsp.html#LspAttach

         They are used for the public settings of every lsp-client
         so you don't have to worry about overwriting your private settings
         as they will always run before the private settings

         on_init:
            - close the formatter provided by Lsp-Server
            - close semanticTokens by Lsp-Server
        ]]
        on_init = function(client, initialize_result)
            -- client.server_capabilities.documentFormattingProvider = false
            -- client.server_capabilities.semanticTokensProvider = nil
        end,
        on_attach = function(client, bufnr)
            -- vim.lsp.inlay_hint.enable(false)
        end,

        on_error = function(code, err) end,
        on_exit = function(code, signal, client_id) end,
    },
}

setmetatable(M, {
    -- getter
    __index = function(_, key)
        return config[key]
    end,

    -- setter
    __newindex = function(_, key, value)
        config[key] = value
    end,
})

---@param opts table<string, any>
function M.update(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.get_float_border(style)
    return config.float.border ~= "none" and style or "none"
end

return M
