local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.jinja2 = {
  install_info = {
    url = "https://github.com/theHamsta/tree-sitter-jinja2.git",
    files = {"src/parser.c"},
    -- optional entries:
    -- branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "html", -- if filetype does not match the parser name
}

require('nvim-treesitter.configs').setup({
  ensure_installed = {'bash', 'html', 'htmldjango', 'javascript', 'json', 'lua', 'rust', 'scss', 'svelte', 'typescript', 'vue', 'yaml'},
  auto_install = true,
  sync_install = false,
  highlight = {
    disable = {'perl'},
    enable = true,
  },
  indent = {
    enable = false,
  },
})
