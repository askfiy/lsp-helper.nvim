# README

lsp-helper is a decorative plugin designed to simplify the setup of `vim.lsp.config` and provides some utility functions:

- Provides toggleable signature_help
- Offers scrolling methods for signature_help and hover
- Provides progress notifications for signature_help and hover content
- Offers public function configurations

## Installation

Using lazy:

```lua
{
    "askfiy/lsp-helper.nvim",
    config = function()
        require("lsp-helper").setup()
    end,
}
```

## Usage

Once lsp-helper is configured, it will automatically take effect. Simply execute `vim.lsp.config`, example from pyright:

```lua
vim.lsp.config("pyright", {
  root_markers = { '.git' },
  ...
})
vim.lsp.enable("pyright")
```

## Available Functions

The provided functions are as follows:

```lua
require("lsp-helper").lsp.signature_help -- Provides toggleable signature_help; press once to open, press twice to close
require("lsp-helper").lsp.hover -- Provides toggleable hover; Press toggleable hover once, press to focus twice, and press to close three times
require("lsp-helper").float.scroll_hover_to_up -- Provides scrolling for signature_help and hover
require("lsp-helper").float.scroll_hover_to_down -- Provides scrolling for signature_help and hover
require("lsp-helper").diagnostic.goto_prev  -- Can skip specific lsp sources
require("lsp-helper").diagnostic.goto_next  -- Can skip specific lsp sources
require("lsp-helper").diagnostic.open -- Works with telescope; opens a floating window if there is a diagnostic under the cursor, otherwise opens workspace diagnostics
```

## Default Configs

```lua
{
    float = {
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
        on_init = function(client, bufnr)
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
```

## License

This plugin is licensed under the MIT License. See the [LICENSE](https://github.com/askfiy/lsp-helper.nvim/blob/master/LICENSE) file for details.

## Contributing

Contributions are welcome! If you encounter a bug or want to enhance this plugin, feel free to open an issue or create a pull request.
