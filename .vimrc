colorscheme koehler
set number
set encoding=utf-8

filetype indent on
filetype plugin on
filetype on

set autoindent
syntax enable

set tabstop=4
set shiftwidth=4
set textwidth=79

set wildmenu
set wildmode=longest:full
set wildignore=*.class,*.swp,*.out

" Highlight extra whitespace at the end of lines
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Highlight the 80th column
highlight ColorColumn ctermbg=red guibg=red
call matchadd('ColorColumn', '\%81v', 100)

autocmd BufRead,BufNewFile *.sv setfiletype verilog
