" Vim config file.

" Install plug {{{
call plug#begin('~/.vim/plugged')
" Unused - old plugin
"Plug 'taglist.vim'
"Plug 'mru.vim'
"Plug 'bufexplorer.zip'

" Used
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'vim-scripts/a.vim' " swtich between source files and header files quickly
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-scripts/Mark' " highlight some key variables
Plug 'vim-scripts/snipMate'
Plug 'vim-scripts/genutils' " Vim-script library
Plug 'vim-scripts/L9' " Vim-script library
Plug 'vim-scripts/desertEx'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/Align'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'bitc/vim-bad-whitespace'
Plug 'andymass/vim-matchup'
Plug 'luochen1990/rainbow'

" display vertical lines
Plug 'Yggdroot/indentLine'
" Fuzzy finder buffer, mru, files, tags, strings
Plug 'Yggdroot/LeaderF', {'do':'./install.sh'}
" Async run shell/vim commands and get the result in quick fix window
Plug 'skywind3000/asyncrun.vim'
" Static tags/Definition/Reference
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'
" LSP - Dynamic tags/Completion/Definition/Reference backend server
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
"Plug 'prabirshrestha/vim-lsp'
"Plug 'mattn/vim-lsp-settings'

" Completion
Plug 'roxma/nvim-yarp'  " Framework to support deoplete
Plug 'roxma/vim-hug-neovim-rpc'  " Framework to support deoplete
Plug 'Shougo/deoplete.nvim'
" cpp syntax highlight
Plug 'octol/vim-cpp-enhanced-highlight'
" surround 插件可以快速编辑围绕在内容两端的字符（pairs of things surrounding
" things），比如成对出现的括号、引号，甚至HTML/XML标签等。
Plug 'tpope/vim-surround'
"  filetype icons
Plug 'ryanoasis/vim-devicons'
" Git staff
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
"dashboard
Plug 'KyleJKC/Vim-dashboard'

" Haven tested, not good for me
call plug#end()
" vim-plug setting end }}}

" Basic Settings {{{
syntax on                           " highlight syntax

set nocompatible                    " out of Vi compatible mode
set number                          " show line number
set relativenumber                  " show relative line number
set numberwidth=3                   " minimal culumns for line numbers
set textwidth=0                     " do not wrap words (insert)
set nowrap                          " do not wrap words (view)
set showcmd                         " show (partial) command in status line
set ruler                           " line and column number of the cursor position
set wildmenu                        " enhanced command completion
set wildmode=list:longest,full      " command completion mode
set laststatus=2                    " always show the status line
set mouse=                          " use mouse in all mode
set foldenable                      " fold lines
set foldmethod=marker               " fold as marker
set noerrorbells                    " do not use error bell
set novisualbell                    " do not use visual bell
set t_vb=                           " do not use terminal bell

set wildignore=.svn,.git,*.swp,*.bak,*~,*.o,*.a
set autowrite                       " auto save before commands like :next and :make
set hidden                          " enable multiple modified buffers
set history=100                     " record recent used command history
set autoread                        " auto read file that has been changed on disk
set backspace=indent,eol,start      " backspace can delete everything
set completeopt=menuone,longest     " complete options (insert)
set pumheight=10                    " complete popup height
set scrolloff=5                     " minimal number of screen lines to keep beyond the cursor
set autoindent                      " automatically indent new line
set cinoptions=:0,l1,g0,t0,(0,(s    " C kind language indent options

set tabstop=4                       " number of spaces in a tab
set softtabstop=4                   " insert and delete space of <tab>
set shiftwidth=4                   " number of spaces for indent
set expandtab                       " expand tabs into spaces
set incsearch                       " incremental search
set hlsearch                        " highlight search match
set ignorecase                      " do case insensitive matching
set smartcase                       " do not ignore if search pattern has CAPS
set nobackup                        " do not create backup file
set noswapfile                      " do not create swap file
set backupcopy=yes                  " overwrite the original file
set formatoptions-=o                " Newline by 'o' is not inherit the last comment
"set formatoptions-=O
set timeoutlen=700                  " timeout length for key sequences

set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=gb2312,utf-8,gbk
set fileformat=unix
"set nolist!                         " toggle highlight trailing whitespace

set background=dark
set t_Co=256
"colorscheme vividchalk
"let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
"colorscheme desert2
colorscheme desertmss
"colorscheme grayvim

" gui settings
if has("gui_running")
    set guioptions-=T " no toolbar
    set guioptions-=r " no right-hand scrollbar
    set guioptions-=R " no right-hand vertically scrollbar
    set guioptions-=l " no left-hand scrollbar
    set guioptions-=L " no left-hand vertically scrollbar
    autocmd GUIEnter * simalt ~x " window width and height
    source $VIMRUNTIME/delmenu.vim " the original menubar has an error on win32, so
    source $VIMRUNTIME/menu.vim    " use this menubar
    language messages zh_CN.utf-8 " use chinese messages if has
endif

" Restore the last quit position when open file.
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \     exe "normal g'\"" |
    \ endif
" Auto update vimrc file
"autocmd BufWritePost $MYVIMRC source $MYVIMRC

" Prevent vim from trying to connect to the X server when connecting from home,
" which causes a startup delay of about 14 seconds.
set clipboard=autoselect,exclude:.*

" remove the old Plugin
" set runtimepath-=/usr/share/vim/vim74
"}}}

" Plugin Settings {{{
if has("win32") " win32 system
    let $HOME  = $VIM
    let $VIMFILES = $HOME . "/vimfiles"
else " unix
    let $HOME  = $HOME
    let $VIMFILES = $HOME . "/.vim"
endif

"tagbar
let g:tagbar_left = 1
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 2
let g:tagbar_foldlevel = 1

" nerdtree
let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize = 50
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeShowBookmarks=1
let g:NERDTreeQuitOnOpen=1

" snipMate
let g:snip_author   = "Lemon Mao"
let g:snip_mail     = "lemon_mao@dell.com"
let g:snip_company  = "Dell Inc."
" show the short key mappings
ino <silent> <tab> <c-r>=TriggerSnippet()<cr>
snor <silent> <tab> <esc>i<right><c-r>=TriggerSnippet()<cr>
"ino <silent> <m-y> <c-r>=TriggerSnippet()<cr>
"snor <silent> <m-y> <esc>i<right><c-r>=TriggerSnippet()<cr>
"ino <silent> <s-tab> <c-r>=BackwardsSnippet()<cr>
"snor <silent> <s-tab> <esc>i<right><c-r>=BackwardsSnippet()<cr>
"ino <silent> <c-r><tab> <c-r>=ShowAvailableSnips()<cr>

" man.vim - view man page in VIM
source $VIMRUNTIME/ftplugin/man.vim

" airline
let g:airline_theme='dark'
" 使用powerline打过补丁的字体
let g:airline_powerline_fonts=1
if !exists('g:airline_symbols')
    let g:airline_symbols={}
endif
" 关闭空白符检测
let g:airline#extensions#whitespace#enabled=0
" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
"let g:airline_inactive_collapse=1
" Tabline
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#branch#displayed_head_limit = 8
let g:airline#extensions#wordcount#enabled = 0

" LeaderF
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_MruMaxFiles = 250
let g:Lf_ShowRelativePath = 1
let g:Lf_WindowPosition = 'popup'
let g:Lf_PopupPreviewPosition = 'bootom'
let g:Lf_PopupPosition = [28, 0]
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewHorizontalPosition = 'right'
let g:Lf_PreviewResult = {'File': 0, 'Tag': 0, 'Function': 0, 'Jumps': 0, 'Mru': 0, 'Line': 0, 'Colorscheme': 0, 'BufTag': 0, 'Buffer': 0}
let g:Lf_CursorBlink = 1
let g:Lf_EmptyQuery = 0
let g:Lf_DiscardEmptyBuffer = 1
let g:airline#extensions#gutentags#enabled = 0
let g:airline#extensions#tagbar#enabled = 0
au User AirlineAfterInit  :let g:airline_section_z = airline#section#create(['windowswap', 'obsession', '%3p%%', 'maxlinenr', ' :%3v'])
"let g:Lf_ExternalCommand = 'find %s -path /vobs/nosx/nos/platform/asic/sdk -a -prune -o -type f -name *.[ch]'
let g:Lf_WildIgnore = {
    \ 'dir': ['.svn','.git','.hg', 'lost+found', 'nos/platform/asic', 'project_vim'],
    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
    \}
let g:Lf_CtagsFuncOpts = {
    \ 'c': '--c-kinds=f',
    \ }

" EasyAlign
xmap ga <Plug>(EasyAlign)
vmap <Enter> <Plug>(EasyAlign)
let g:easy_align_delimiters = {
\ '>': { 'pattern': '>>\|=>\|>' },
\ '/': {
\     'pattern':         '//\+\|/\*\|\*/',
\     'delimiter_align': 'l',
\     'ignore_groups':   ['!Comment'] },
\ ']': {
\     'pattern':       '[[\]]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ ')': {
\     'pattern':       '[()]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ 'd': {
\     'pattern':      ' \(\S\+\s*[;=]\)\@=',
\     'left_margin':  0,
\     'right_margin': 0
\   }
\ }

" asyncrun
let g:asyncrun_open = 30 "Automatically open window
let g:asyncrun_bell = 1 " After finished, make a bell to notify

"DoxygenToolkit
let g:DoxygenToolkit_briefTag_pre="@Brife  "
let g:DoxygenToolkit_paramTag_pre="@Param "
let g:DoxygenToolkit_returnTag="@Returns   "
let g:DoxygenToolkit_blockHeader=""
let g:DoxygenToolkit_blockFooter=""


" Deoplete : Dark powered asynchronous completion framework for neovim/Vim8
let g:deoplete#enable_at_startup = 1
highlight PMenu ctermfg=0 ctermbg=242 guifg=black guibg=darkgrey
highlight PMenuSel ctermfg=242 ctermbg=8 guifg=darkgrey guibg=black

" settings of gtags.
" " I use GNU global instead cscope because global is faster.
" 第一个 GTAGSLABEL 告诉 gtags 默认 C/C++/Java 等六种原生支持的代码直接使用
" gtags 本地分析器，而其他语言使用 pygments 模块。
let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/home/lemon/.globalrc'

" gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_project_root = ['.root', '.project', 'GTAGS']
"let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'
" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
endif
" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" 如果使用 universal ctags 需要增加下面一行
"let g:gutentags_ctags_extra_args += ['--output-format=e-ctags', '--extras=+q']
" gtags extra parameters, manually modify gutentags/gtags_cscope.vim:91
"let l:cmd += ['--incremental --skip-unreadable', '"'.l:db_path.'"']
" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 1
" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif
let g:gutentags_define_advanced_commands = 1
let g:gutentags_plus_nomap = 1

set csto=1 "1 find ctags first, 0 find cscope db first
set cst  " cst jump to definition derectly, nocst show info
set cscopetag
set cscopeprg=gtags-cscope
"set cscopequickfix=c+,d+,e+,f+,i+,s+,t+


" LSP
set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
"let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_serverCommands = {}
let g:LanguageClient_rootMarkers = ['.root', '.project', 'GTAGS']
"let g:LanguageClient_serverCommands.c = ['clangd']
"let g:LanguageClient_serverCommands.cpp = ['clangd']
let g:LanguageClient_serverCommands = {
    \ 'c': {
    \   'name' : 'clangd',
    \   'command' : ['clangd'],
    \   'initializationOptions': {
    \     'cacheDirectory': "/home/lemon/.cache/LanguageClient"
    \   },
    \ },
    \ 'cpp': {
    \   'name' : 'clangd',
    \   'command' : ['clangd'],
    \   'initializationOptions': {
    \     'cacheDirectory': "/home/lemon/.cache/LanguageClient"
    \   },
    \ },
\ }


" Or, you could use vim's popup window feature.
"let g:echodoc#enable_at_startup = 1
"let g:echodoc#type = 'popup'
" To use a custom highlight for the popup window,
" change Pmenu to your highlight group
"highlight link EchoDocPopup Pmenu

" vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 0
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
"let g:cpp_no_function_highlight = 0

" surround
" 不定义任何快捷键
let g:surround_no_mappings = 1

" rainbow
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\	'operators': '_,_',
\	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\	'separately': {
\		'*': {},
\		'tex': {
\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\		},
\		'lisp': {
\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\		},
\		'vim': {
\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\		},
\		'html': {
\			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\		},
\		'css': 0,
\		'nerdtree': 0,
\	}
\}

" vim-matchup
let g:loaded_matchit = 1

" fugitive
let g:github_enterprise_urls = ['https://eos2git.cec.lab.emc.com']

" autopair surround
let g:AutoPairsShortcutBackInsert = '<M-6>'
" dashboard
let g:dashboard_default_executive ='leaderf'
let g:indentLine_fileTypeExclude = ['dashboard']
let g:dashboard_custom_section={
  \ 'MRU': [' Most Recently Used'],
  \ }
function! MRU()
LeaderfMru
endfunction
let g:dashboard_enable_session=0
let g:indentLine_fileTypeExclude = ['dashboard']
let g:dashboard_custom_header = [
    \ '                                                        ',
    \ '                                                        ',
    \ '██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗    ██╗   ██╗██╗███╗   ███╗',
    \ '██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║    ██║   ██║██║████╗ ████║',
    \ '██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║    ██║   ██║██║██╔████╔██║',
    \ '██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║    ╚██╗ ██╔╝██║██║╚██╔╝██║',
    \ '███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║     ╚████╔╝ ██║██║ ╚═╝ ██║',
    \ '╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚═╝     ╚═╝',
    \ '                                                        ',
    \ '                            [ Happy Coding ! ]               ',
    \ '                                                        ',
    \ ]
let g:dashboard_custom_footer = [
    \ '',
    \ '   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠞⠉⢉⣭⣿⣿⠿⣳⣤⠴⠖⠛⣛⣿⣿⡷⠖⣶⣤⡀⠀⠀⠀   ',
    \ '    ⠀⠀⠀⠀⠀⠀⠀⣼⠁⢀⣶⢻⡟⠿⠋⣴⠿⢻⣧⡴⠟⠋⠿⠛⠠⠾⢛⣵⣿⠀⠀⠀⠀  ',
    \ '    ⣼⣿⡿⢶⣄⠀⢀⡇⢀⡿⠁⠈⠀⠀⣀⣉⣀⠘⣿⠀⠀⣀⣀⠀⠀⠀⠛⡹⠋⠀⠀⠀⠀  ',
    \ '    ⣭⣤⡈⢑⣼⣻⣿⣧⡌⠁⠀⢀⣴⠟⠋⠉⠉⠛⣿⣴⠟⠋⠙⠻⣦⡰⣞⠁⢀⣤⣦⣤⠀  ',
    \ '    ⠀⠀⣰⢫⣾⠋⣽⠟⠑⠛⢠⡟⠁⠀⠀⠀⠀⠀⠈⢻⡄⠀⠀⠀⠘⣷⡈⠻⣍⠤⢤⣌⣀  ',
    \ '    ⢀⡞⣡⡌⠁⠀⠀⠀⠀⢀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⢿⡀⠀⠀⠀⠸⣇⠀⢾⣷⢤⣬⣉  ',
    \ '    ⡞⣼⣿⣤⣄⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠸⣿⣇⠈⠻  ',
    \ '    ⢰⣿⡿⢹⠃⠀⣠⠤⠶⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠀⣿⠛⡄⠀  ',
    \ '    ⠈⠉⠁⠀⠀⠀⡟⡀⠀⠈⡗⠲⠶⠦⢤⣤⣤⣄⣀⣀⣸⣧⣤⣤⠤⠤⣿⣀⡀⠉⣼⡇⠀  ',
    \ '    ⣿⣴⣴⡆⠀⠀⠻⣄⠀⠀⠡⠀⠀⠀⠈⠛⠋⠀⠀⠀⡈⠀⠻⠟⠀⢀⠋⠉⠙⢷⡿⡇⠀  ',
    \ '    ⣻⡿⠏⠁⠀⠀⢠⡟⠀⠀⠀⠣⡀⠀⠀⠀⠀⠀⢀⣄⠀⠀⠀⠀⢀⠈⠀⢀⣀⡾⣴⠃⠀  ',
    \ '    ⢿⠛⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠈⠢⠄⣀⠠⠼⣁⠀⡱⠤⠤⠐⠁⠀⠀⣸⠋⢻⡟⠀⠀  ',
    \ '    ⠈⢧⣀⣤⣶⡄⠘⣆⠀⠀⠀⠀⠀⠀⠀⢀⣤⠖⠛⠻⣄⠀⠀⠀⢀⣠⡾⠋⢀⡞⠀⠀⠀  ',
    \ '    ⠀⠀⠻⣿⣿⡇⠀⠈⠓⢦⣤⣤⣤⡤⠞⠉⠀⠀⠀⠀⠈⠛⠒⠚⢩⡅⣠⡴⠋⠀⠀⠀⠀  ',
    \ '    ⠀⠀⠀⠈⠻⢧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣻⠿⠋⠀⠀⠀⠀⠀⠀  ',
    \ '    ⠀⠀⠀⠀⠀⠀⠉⠓⠶⣤⣄⣀⡀⠀⠀⠀⠀⠀⢀⣀⣠⡴⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀  ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '                                       ',
    \ '',
    \ ]
"}}}

" Utility Functions {{{
"
"
" run shell with current cursor
function! RunShell(Msg, Shell)
  echo a:Msg
  let s:curWord =  expand("<cword>")
  let s:cmd = a:Shell . s:curWord
  call system(s:cmd)
  echo s:cmd "done"
endfunction

let s:numberf = 1
function! ToggleMouse()
    if  s:numberf == 1
        let s:numberf = 0
        exec "IndentLinesDisable"
        set norelativenumber
        set nonumber
        set paste
    else
        let s:numberf = 1
        exec "IndentLinesEnable"
        set number
        set nopaste
        set relativenumber
    endif
    echo "Done!"
endfunction

":vertical resize+40<CR>
" move between windows
function! ChangeCurWind(flag)
    let objFind = -1
    let winName = bufname(winbufnr(0))
    let objFind = match(winName, "NERD_tree_")
    "let objFind = objFind >= 0 ? objFind : match(winName, "Tag_List")
    echo "old:" objFind winName
    if objFind != -1
        exe "normal 5\<C-W>|0"
    endif

    exec "wincmd" a:flag

    let objFind = -1
    let winName = bufname(winbufnr(0))
    let objFind = match(winName, "NERD_tree_")
    "let objFind = objFind >= 0 ? objFind : match(winName, "Tag_List")
    echo "new:" objFind winName
    if objFind != -1
        exe "normal 60\<C-W>|0"
    endif
endfunction

function! Terminal_MetaMode(mode)
    set ttimeout
    if $TMUX != ''
        set ttimeoutlen=30
    elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
        set ttimeoutlen=80
    endif
    if has('nvim') || has('gui_running')
        return
    endif
    function! s:metacode(mode, key)
        if a:mode == 0
            exec "set <M-".a:key.">=\e".a:key
        else
            exec "set <M-".a:key.">=\e]{0}".a:key."~"
        endif
    endfunc
    for i in range(10)
        call s:metacode(a:mode, nr2char(char2nr('0') + i))
    endfor
    for i in range(26)
        call s:metacode(a:mode, nr2char(char2nr('a') + i))
        call s:metacode(a:mode, nr2char(char2nr('A') + i))
    endfor
    if a:mode != 0
        for c in [',', '.', '/', ';', '[', ']', '{', '}']
            call s:metacode(a:mode, c)
        endfor
        for c in ['?', ':', '-', '_']
            call s:metacode(a:mode, c)
        endfor
    else
        for c in [',', '.', '/', ';', '{', '}']
            call s:metacode(a:mode, c)
        endfor
        for c in ['?', ':', '-', '_']
            call s:metacode(a:mode, c)
        endfor
    endif
endfunc

call Terminal_MetaMode(0)

"}}}

" Key Bindings {{{
"}}}
let mapleader = ","
let maplocalleader = "\\"

" ## -------------------------------------- ##
" ## Global Hotkeys
" ## -------------------------------------- ##
" map : -> <space>
map <Space> :
map <leader><Space> :AsyncRun
" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>
" Ctrl-N to disable search match highlight
nmap <silent> <C-N> :silent noh<CR>
nmap <leader>d :Dashboard<CR>

" ## -------------------------------------- ##
" ## F1 ~~ F12 Hotkeys
" ## -------------------------------------- ##
nmap <F1>  :Dashboard<cr>
nmap <F2>  :scriptnames<cr>
nmap <F3>  :1,$s/\<<C-R><C-W>\>//g
nmap <F4>  :AsyncRun lt grep <C-R><C-W>
nmap <F5>  <leader>#
nmap <F6>  <leader>*
"nmap <F7>  :AsyncRun cd ;make
nmap <F8>  :AsyncRun docker exec onefs_build /bin/sh -c "cd /home/cross-compiler/output.cross && make -j24"
nmap <F9>  :GscopeFind g
nmap <F10> :EraseBadWhitespace<CR>
"nmap <F11> :<CR>
nmap <F12> :call ToggleMouse()<CR>

" ## -------------------------------------- ##
" ## Windows Hotkeys
" ## Moving/Switch/Paging/Zooming
" ## -------------------------------------- ##
" ---move from the multiple screen
nmap <C-h> :call ChangeCurWind("h")<ESC><cr>
nmap <C-l> :call ChangeCurWind("l")<ESC><cr>
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <leader>1 :vertical resize-20<CR> <ESC>
nmap <leader>2 :vertical resize+20<CR> <ESC>
nmap <leader>3 :abo resize-20<CR> <ESC>
nmap <leader>4 :abo resize+20<CR> <ESC>
"nmap <C-H> <C-w>W
"nmap <C-L> <C-w>w
"Ctrol-E to switch between 2 last buffers
nmap <C-E> :b#<CR>
" vim-preview
noremap <m-u> :PreviewScroll -1<cr>
noremap <m-d> :PreviewScroll +1<cr>
inoremap <m-u> <c-\><c-o>:PreviewScroll -1<cr>
inoremap <m-d> <c-\><c-o>:PreviewScroll +1<cr>
autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
nmap <m-t> :PreviewTag <cr>
nmap <m-s> :PreviewSignature <cr>
nmap <m-c> :PreviewClose <cr>
" close quickfix window
nmap <m-q> :cclose<cr>
nmap <leader>q :q<cr>

" ## -------------------------------------- ##
" ## Find Hotkeys
" ## tags/files/MRU/direcotry
" ## -------------------------------------- ##
" -- LSP def/ref/hover
" You can apply these mappings only for buffers with supported filetypes
function LC_maps()
    if has_key(g:LanguageClient_serverCommands, &filetype)
        nmap <buffer> <leader>sr :call LanguageClient#textDocument_references()<cr>
        nmap <buffer> <leader>sd :call LanguageClient#textDocument_definition()<cr>
        nmap <buffer> <leader>sh :call LanguageClient#textDocument_hover()<cr>
    endif
endfunction
autocmd FileType * call LC_maps()
" -- -- cscope hotkey mapping
noremap <silent> <leader>ss :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>sg :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>sc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>st :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>se :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>sf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>si :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>sb :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>sa :GscopeFind a <C-R><C-W><cr>
" -- -- LeaderF find files/MRU/buffers
nnoremap <silent> sb     :LeaderfBuffer<CR>
nnoremap <silent> sm     :LeaderfMru<CR>
nnoremap <silent> sfi    :LeaderfFile<CR>
nnoremap <silent> st     :LeaderfBufTag<CR>
nnoremap <silent> sta    :LeaderfBufTagAll<CR>
nnoremap <silent> ss     :LeaderfLine<CR>
nnoremap <silent> ssa    :LeaderfLineAll<CR>
nnoremap <silent> sfu    :LeaderfFunction<CR>
nnoremap <silent> sfua   :LeaderfFunctionAll<CR>
" -- open directory
nmap <Leader>f :NERDTreeToggle<CR>
nmap <Leader>F :NERDTreeFind<CR>

" ## -------------------------------------- ##
" ## Coding Hotkeys
" ## -------------------------------------- ##
nnoremap Y y$
"insert 模式下，跳到行首行尾
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>
inoremap <C-h> <BS>
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <m-f> <S-Right>
inoremap <m-b> <S-Left>
" cppman; apt install cppman
noremap <m-k> :!cppman <C-R>=expand("<cword>")<cr><cr>
" run #git mergetool
map <silent> <leader>g1 :diffget 1<CR> :diffupdate<CR>
map <silent> <leader>g2 :diffget 2<CR> :diffupdate<CR>
map <silent> <leader>g3 :diffget 3<CR> :diffupdate<CR>
map <silent> <leader>g4 :diffget 4<CR> :diffupdate<CR>
" Align, av:aliagn variables, am: align micros, ac:align comments, af:align functions
vmap av ,adec
vmap am ,adef
vmap ac ,acom
vmap af ,afnc
" surround maps come from surround.vim
nmap ys <Plug>Ysurround
nmap ds <Plug>Dsurround
nmap cs <Plug>Csurround
" tagbar
nnoremap <silent> <leader>t :TagbarToggle<CR>
nnoremap <silent> <leader>tp :TagbarTogglePause<CR>
" git fugitive, blame / diff
nmap <leader>gb :G blame<CR>
vmap <leader>gb :G blame<CR>
nmap <leader>gd :Gvdiffsplit<CR>
nmap <leader>gs :G<cr>
" highlight

