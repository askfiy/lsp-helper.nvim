local config = require("lsp-helper.config")

local M = {}

local methods = vim.lsp.protocol.Methods
local flag = "handled"

-- Number of scrolling rows
local cache_scrolloff = vim.opt.scrolloff:get()

---@class FloatType
---@field signatureHelp? boolean
---@field hover? boolean

---@param types? FloatType
function M.get_lsp_float(types)
    local filter_types = {}

    if types then
        if types.hover then
            table.insert(filter_types, methods.textDocument_hover)
        end

        if types.signatureHelp then
            table.insert(filter_types, methods.textDocument_signatureHelp)
        end
    end

    for _, winner in ipairs(vim.api.nvim_list_wins()) do
        for _, filter_type in ipairs(filter_types) do
            if vim.w[winner][filter_type] then
                local bufnr = vim.api.nvim_win_get_buf(winner)
                return winner, bufnr
            end
        end
    end
end

---@param winner window
---@param bufnr buffer
local function footer_handler(winner, bufnr)
    if config.float.border == "none" then
        return
    end

    local cursor_line = vim.fn.line(".", winner)
    local buffer_total_line = vim.api.nvim_buf_line_count(bufnr)
    local window_height = vim.api.nvim_win_get_height(winner)
    local window_last_line = vim.fn.line("w$", winner)

    local progress = math.floor(window_last_line / buffer_total_line * 100)

    if buffer_total_line <= window_height + 5 then
        return
    end

    if cursor_line == 1 then
        progress = 0
    end

    vim.api.nvim_win_set_config(winner, {
        footer = config.float.progress_format(progress),
        footer_pos = "right",
    })
end

vim.api.nvim_create_autocmd({ "LspRequest" }, {
    pattern = { "*" },
    callback = function(args)
        -- Use defer_fn to wait for the window rendering to complete and add a progress bar prompt
        if
            args.data.request.type == "complete"
            and vim.tbl_contains({
                methods.textDocument_hover,
                methods.textDocument_signatureHelp,
            }, args.data.request.method)
        then
            vim.defer_fn(function()
                local winner, bufnr = M.get_lsp_float({
                    signatureHelp = true,
                    hover = true,
                })

                if not bufnr or not winner then
                    return
                end

                --
                if not pcall(vim.api.nvim_buf_get_var, bufnr, flag) then
                    footer_handler(winner, bufnr)
                    vim.api.nvim_buf_set_var(bufnr, flag, true)
                end
            end, 0)
        end
    end,
    desc = "Add footer by signatureHelp and hover",
})

---@param scroll_lines integer
function M.scroll_hover_to_up(scroll_lines)
    scroll_lines = scroll_lines or 5

    local winner, bufnr = M.get_lsp_float({
        hover = true,
        signatureHelp = true,
    })

    if not bufnr or not winner then
        local key = vim.api.nvim_replace_termcodes("<c-b>", true, false, true)
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_feedkeys(key, "n", true)
        return
    end

    local cursor_line = vim.fn.line(".", winner)
    local buffer_total_line = vim.api.nvim_buf_line_count(bufnr)
    local window_height = vim.api.nvim_win_get_height(winner)
    local win_first_line = vim.fn.line("w0", winner)

    if buffer_total_line + 1 <= window_height or cursor_line == 1 then
        return
    end

    vim.opt.scrolloff = 0

    if cursor_line > win_first_line then
        if win_first_line - scroll_lines > 1 then
            vim.api.nvim_win_set_cursor(
                winner,
                { win_first_line - scroll_lines, 0 }
            )
        else
            vim.api.nvim_win_set_cursor(winner, { 1, 0 })
        end
    elseif cursor_line - scroll_lines < 1 then
        vim.api.nvim_win_set_cursor(winner, { 1, 0 })
    else
        vim.api.nvim_win_set_cursor(winner, { cursor_line - scroll_lines, 0 })
    end

    vim.opt.scrolloff = cache_scrolloff

    -- Updat Tempourogress bar
    return footer_handler(winner, bufnr)
end

---@param scroll_lines integer
function M.scroll_hover_to_down(scroll_lines)
    scroll_lines = scroll_lines or 5

    local winner, bufnr = M.get_lsp_float({
        hover = true,
        signatureHelp = true,
    })

    if not bufnr or not winner then
        local key = vim.api.nvim_replace_termcodes("<c-f>", true, false, true)
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.api.nvim_feedkeys(key, "n", true)
        return
    end

    local cursor_line = vim.fn.line(".", winner)
    local buffer_total_line = vim.api.nvim_buf_line_count(bufnr)
    local window_height = vim.api.nvim_win_get_height(winner)
    local window_last_line = vim.fn.line("w$", winner)

    if
        buffer_total_line + 1 <= window_height
        or cursor_line == buffer_total_line
    then
        return
    end

    vim.opt.scrolloff = 0

    if cursor_line < window_last_line then
        if window_last_line + scroll_lines < buffer_total_line then
            vim.api.nvim_win_set_cursor(
                winner,
                { window_last_line + scroll_lines, 0 }
            )
        else
            vim.api.nvim_win_set_cursor(winner, { buffer_total_line, 0 })
        end
    elseif cursor_line + scroll_lines >= buffer_total_line then
        vim.api.nvim_win_set_cursor(winner, { buffer_total_line, 0 })
    else
        vim.api.nvim_win_set_cursor(winner, { cursor_line + scroll_lines, 0 })
    end

    vim.opt.scrolloff = cache_scrolloff

    -- Updat Tempourogress bar
    return footer_handler(winner, bufnr)
end

return M
