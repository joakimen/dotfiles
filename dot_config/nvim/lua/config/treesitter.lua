require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = { enable = true, },
  indent = { enable = true },
  query_linter = { enable = true },
}
