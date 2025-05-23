local mod = "lsp-helper"

vim.opt.cmdheight = 2

local function reload()
    for k, _ in pairs(package.loaded) do
        if k:match(mod:gsub("-", "%%-")) then
            package.loaded[k] = nil
        end
    end
    require(mod).setup()
    vim.notify("reload completed")
    vim.cmd([[messages clear]])
end

vim.keymap.set(
    { "n" },
    "<leader>pr",
    reload,
    { silent = true, desc = "Reload plugin in debug mode" }
)
