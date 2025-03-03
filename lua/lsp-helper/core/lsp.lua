local config = require("lsp-helper.config")
local float = require("lsp-helper.core.float")

local M = {}

-- Number of scrolling rows
local cache_scrolloff = vim.opt.scrolloff:get()

function M.signature_help()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if pcall(vim.api.nvim_buf_get_var, bufnr, config.float.flag) then
            vim.api.nvim_win_close(vim.fn.bufwinid(bufnr), false)
            return
        end
    end

    vim.lsp.buf.signature_help()
end

---@param scroll_lines integer
function M.scroll_hover_to_up(scroll_lines)
    scroll_lines = scroll_lines or 5

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if pcall(vim.api.nvim_buf_get_var, bufnr, config.float.flag) then
            local winner = vim.fn.bufwinid(bufnr)
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
                vim.api.nvim_win_set_cursor(
                    winner,
                    { cursor_line - scroll_lines, 0 }
                )
            end

            vim.opt.scrolloff = cache_scrolloff

            -- Updat Tempourogress bar
            return float.flooter_handler(winner, bufnr)
        end
    end

    local key = vim.api.nvim_replace_termcodes("<c-b>", true, false, true)
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_feedkeys(key, "n", true)
end

---@param scroll_lines integer
function M.scroll_hover_to_down(scroll_lines)
    scroll_lines = scroll_lines or 5

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if pcall(vim.api.nvim_buf_get_var, bufnr, config.float.flag) then
            local winner = vim.fn.bufwinid(bufnr)
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
                    vim.api.nvim_win_set_cursor(
                        winner,
                        { buffer_total_line, 0 }
                    )
                end
            elseif cursor_line + scroll_lines >= buffer_total_line then
                vim.api.nvim_win_set_cursor(winner, { buffer_total_line, 0 })
            else
                vim.api.nvim_win_set_cursor(
                    winner,
                    { cursor_line + scroll_lines, 0 }
                )
            end

            vim.opt.scrolloff = cache_scrolloff

            -- Updat Tempourogress bar
            return float.flooter_handler(winner, bufnr)
        end
    end

    local key = vim.api.nvim_replace_termcodes("<c-f>", true, false, true)
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_feedkeys(key, "n", true)
end

return M
