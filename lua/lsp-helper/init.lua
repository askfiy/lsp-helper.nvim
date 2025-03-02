-- author: askfiy

local config = require("lsp-helper.config")
local float = require("lsp-helper.core.float")

-- TODO: debug mode
-- require("lsp-helper.debug")

local M = {
    lsp = require("lsp-helper.core.lsp"),
    diagnostic = require("lsp-helper.core.diagnostic"),
}

---@param server_conf lspconfig.Config
local function handle_events(server_conf)
    local events = { "on_init", "on_attach", "on_error", "on_exit" }

    for _, event in ipairs(events) do
        local private_event = server_conf[event]

        server_conf[event] = function(client, args)
            if config.lspconfig[event] then
                config.lspconfig[event](client, args)
            end

            if type(private_event) == "function" then
                private_event(client, args)
            end
        end
    end
end

---@param server_conf lspconfig.Config
---@return table<string,function>
local function get_handlers(server_conf)
    local handlers = server_conf.handlers or vim.lsp.handlers
    local methods = vim.lsp.protocol.Methods

    local lsp_float_config = {
        -- :h nvim_open_win() config
        border = config.float.border,
    }

    handlers[methods.textDocument_hover] = vim.lsp.with(
        float.lsp_float_handler(vim.lsp.handlers.hover),
        lsp_float_config
    )

    handlers[methods.textDocument_signatureHelp] = vim.lsp.with(
        float.lsp_float_handler(vim.lsp.handlers.signature_help),
        lsp_float_config
    )

    return handlers
end

---@param server_conf lspconfig.Config
---@return lsp.ClientCapabilities
local function get_capabilities(server_conf)
    local capabilities = server_conf.capabilities
        or vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    capabilities.textDocument.completion.completionItem = {
        snippetSupport = true,
        commitCharactersSupport = true,
        documentationFormat = { "markdown", "plaintext" },
        deprecatedSupport = true,
        preselectSupport = true,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        resolveSupport = {
            properties = {
                "documentation",
                "detail",
                "additionalTextEdits",
            },
        },
    }

    return capabilities
end

---@param opts table<string, any>
function M.setup(opts)
    local ok, lspconfig_util = pcall(require, "lspconfig.util")
    assert(ok, "Not Found lspconfig")

    config.update(opts)
    lspconfig_util.on_setup = function(server_config, _)
        handle_events(server_config)

        server_config.handlers = get_handlers(server_config)
        server_config.capabilities = get_capabilities(server_config)
    end

    vim.diagnostic.config(config.diagnostic.config)

    for icon_type, icon_font in pairs(config.diagnostic.icons) do
        local hl = ("DiagnosticSign%s"):format(icon_type)
        vim.fn.sign_define(hl, { text = icon_font, texthl = hl, numhl = hl })
    end
end

return M
