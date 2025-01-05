local builtin = _G.builtin -- prevent lsp errors

return {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {
        frktest = {
            git = { "https://github.com/itsfrank/frktest" },
            _luaurc = { append_alias = "src" },
        },
    },
}
