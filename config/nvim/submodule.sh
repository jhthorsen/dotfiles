#!/bin/sh

start="$(pwd)/share/nvim/site/pack/batpack/start";
mkdir -p "$start";

while read -r url; do
  echo "# $url";
	cd "$start" || exit 1;
	name="$(basename "$url")";
	if [ -d "$name" ]; then cd "$name" && git pull; else git clone "$url" "$name"; fi
done <<HERE
https://github.com/folke/tokyonight.nvim
https://github.com/folke/which-key.nvim
https://github.com/ggandor/leap.nvim
https://github.com/hrsh7th/cmp-buffer
https://github.com/hrsh7th/cmp-nvim-lsp
https://github.com/hrsh7th/cmp-path
https://github.com/hrsh7th/nvim-cmp
https://github.com/jbyuki/venn.nvim
https://github.com/jiaoshijie/undotree.git
https://github.com/jose-elias-alvarez/null-ls.nvim
https://github.com/kyazdani42/nvim-web-devicons
https://github.com/l3mon4d3/luasnip.git
https://github.com/lucas1/vim-perl
https://github.com/mg979/vim-visual-multi
https://github.com/mrjones2014/legendary.nvim
https://github.com/neovim/nvim-lspconfig
https://github.com/nfnty/vim-nftables.git
https://github.com/norcalli/nvim-colorizer.lua
https://github.com/ntbbloodbath/color-converter.nvim
https://github.com/numtostr/comment.nvim
https://github.com/nvim-lua/plenary.nvim
https://github.com/nvim-lualine/lualine.nvim
https://github.com/nvim-telescope/telescope.nvim
https://github.com/nvim-tree/nvim-tree.lua
https://github.com/nvim-treesitter/nvim-treesitter
https://github.com/osamuaoki/vim-spell-under
https://github.com/ray-x/lsp_signature.nvim
https://github.com/rebelot/kanagawa.nvim
https://github.com/theprimeagen/harpoon
https://github.com/yko/mojo.vim
HERE
