-- author: askfiy

local config = require("lsp-helper.config")

-- TODO: debug mode
-- require("lsp-helper.debug")

local M = {
    lsp = require("lsp-helper.core.lsp"),
    float = require("lsp-helper.core.float"),
    diagnostic = require("lsp-helper.core.diagnostic"),
}

---@param user_config vim.lsp.Config
local function handle_events(user_config)
    local events = { "on_init", "on_attach", "on_error", "on_exit" }
    for _, event in ipairs(events) do
        local private_event = user_config[event]

        user_config[event] = function(client, args)
            if config.lspconfig[event] then
                config.lspconfig[event](client, args)
            end

            if type(private_event) == "function" then
                private_event(client, args)
            end
        end
    end
end

---@param server_conf vim.lsp.Config
---@return table<string,function>
local function get_handlers(server_conf)
    local handlers = server_conf.handlers or vim.lsp.handlers
    return handlers
end

---@param server_conf vim.lsp.Config
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

local function on_mount()
    local lsp_config = getmetatable(vim.lsp.config)
    local mount = vim.tbl_deep_extend("keep", lsp_config, {})

    mount.__newindex = function(self, name, cfg)
        cfg.handlers = get_handlers(cfg)
        cfg.capabilities = get_capabilities(cfg)
        handle_events(cfg)

        if lsp_config.__newindex then
            lsp_config.__newindex(self, name, cfg)
        end
    end

    setmetatable(vim.lsp.config, mount)
end

---@param opts table<string, any>
function M.setup(opts)
    config.update(opts)

    on_mount()
    vim.diagnostic.config(config.diagnostic.config)

    for icon_type, icon_font in pairs(config.diagnostic.icons) do
        local hl = ("DiagnosticSign%s"):format(icon_type)
        vim.fn.sign_define(hl, { text = icon_font, texthl = hl, numhl = hl })
    end
end

return M
