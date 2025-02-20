local config = require("lsp-helper.config")

local M = {}

---@param winner window
---@param bufnr buffer
function M.flooter_handler(winner, bufnr)
    if config.float.border == "none" then
        return
    end

    local cursor_line = vim.fn.line(".", winner)
    local buffer_total_line = vim.api.nvim_buf_line_count(bufnr)
    local window_height = vim.api.nvim_win_get_height(winner)
    local window_last_line = vim.fn.line("w$", winner)

    local progress = math.floor(window_last_line / buffer_total_line * 100)

    if buffer_total_line <= window_height + 1 then
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

---@param handler lsp.Handler
---@return lsp.Handler
function M.lsp_float_handler(handler)
    ---@param err? lsp.ResponseError
    ---@param result any
    ---@param context lsp.HandlerContext
    ---@param conf? table
    return function(err, result, context, conf)
        local bufnr, winner = handler(err, result, context, conf)

        if not bufnr or not winner then
            return
        end

        -- set flag
        vim.api.nvim_buf_set_var(bufnr, config.float.flag, true)

        M.flooter_handler(winner, bufnr)

        -- Adjust the orientation to fit the display, in general, I prefer the floating window to appear above the cursor rather than below
        local window_height = vim.api.nvim_win_get_height(winner)
        local current_cursor_line = vim.fn.line(".")
        if current_cursor_line > window_height + 2 then
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.api.nvim_win_set_config(winner, {
                anchor = "SW",
                relative = "cursor",
                row = 0,
                col = -1,
            })
        end

        return bufnr, winner
    end
end

return M
