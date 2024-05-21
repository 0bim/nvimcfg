return {
    "sekke276/dark_flat.nvim",
    opts = {
        colors = {
            pink = "#ff5c8d",
            light_pink = "#ff8ab3",

            fuchsia = "#ff00ff",
            bright_red = "#ff0000",

            lime = "#00ff00",

            bright_grey = "#808080",

            -- visual studio blue
            blue = "#007acc",
        },
        themes = function(colors)
            return {
                LineNr = { fg = colors.light_pink },
                CursorLineNr = { fg = colors.pink },

                Boolean = { fg = colors.fuchsia },
                Keyword = { fg = colors.red },
                StorageClass = { fg = colors.purple },
                Structure = { fg = colors.bright_red },
                Identifer = { fg = colors.bright_red },
                Function = { fg = colors.yellow },
                Type = { fg = colors.blue },
                Typedef = { fg = colors.yellow },

                String = { fg = colors.orange },
                Number = { fg = colors.green },
                Float = { fg = colors.green },
                constant = { fg = colors.green },

                -- treesitter
                ["@parameter"] = { fg = colors.fuchsia },
            }
        end,
        italics = false,
        bold = true,
    }
}
