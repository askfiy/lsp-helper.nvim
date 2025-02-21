local config = require("lsp-helper.config")

local ok, telescope = pcall(require, "telescope.builtin")

local M = {}

---@param ignore_lsp_sources table<string>
---@return integer[] namespaces
local function exclude_diagnostic_namespace_by_name(ignore_lsp_sources)
    local namespaces = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if not vim.tbl_contains(ignore_lsp_sources, diagnostic.source) then
            table.insert(namespaces, diagnostic.namespace)
        end
    end
    return namespaces
end

---@param ignore_lsp_sources table<string>
---@return integer[] namespaces
local function include_diagnostic_namespace_by_name(ignore_lsp_sources)
    local namespaces = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if vim.tbl_contains(ignore_lsp_sources, diagnostic.source) then
            table.insert(namespaces, diagnostic.namespace)
        end
    end
    return namespaces
end

---@param opts? vim.diagnostic.GotoOpts
function M.goto_prev(opts)
    opts = vim.tbl_deep_extend("force", {
        float = { border = config.get_float_border("rounded") },
        namespace = exclude_diagnostic_namespace_by_name(
            config.diagnostic.jump_ignore_lsp_sources
        ),
    }, opts or {})

    vim.diagnostic.goto_prev(opts)
end

---@param opts? vim.diagnostic.GotoOpts
function M.goto_next(opts)
    opts = vim.tbl_deep_extend("force", {
        float = { border = config.get_float_border("rounded") },
        namespace = exclude_diagnostic_namespace_by_name(
            config.diagnostic.jump_ignore_lsp_sources
        ),
    }, opts or {})

    vim.diagnostic.goto_next(opts)
end

---@param opts? vim.diagnostic.GotoOpts
---@return integer? float_bufnr
---@return integer? win_id
function M.open(opts)
    opts = vim.tbl_deep_extend("force", {
        border = config.get_float_border("rounded"),
    }, opts or {})

    if not ok then
        return vim.diagnostic.open_float(opts)
    end

    if
        not vim.tbl_isempty(
            vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
        )
    then
        return vim.diagnostic.open_float({
            border = config.get_float_border("rounded"),
        })
    end

    telescope.diagnostics({ bufnr = 0 })
end

return M
