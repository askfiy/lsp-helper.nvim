---@class ConfigFloat
---@field flag string
---@field border string
---@field progress_format fun(progress: number): string

---@class ConfigDiagnostic
---@field config vim.diagnostic.Opts
---@field icons ConfigIcons
---@field jump_ignore_lsp_sources table

---@class ConfigIcons
---@field Error string
---@field Warn string
---@field Info string
---@field Hint string

---@class ConfigLspconfig
---@field on_init fun(client: table, bufnr: number)
---@field on_attach fun(client: table, bufnr: number)
---@field on_error fun(code: number, err: string)
---@field on_exit fun(code: number, signal: number, client_id: number)
