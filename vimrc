" Vim config file.

" Vim-plug setting {{{
call plug#begin('~/.vim/plugged')
" Unused - old plugin
"Plug 'lookupfile'
"Plug 'taglist.vim'
"Plug 'mru.vim'
"Plug 'bufexplorer.zip'
"Plug 'vim-scripts/AutoComplPop'
"Plug 'vim-scripts/OmniCppComplete'
"Plug 'kien/ctrlp.vim'
"Plug 'FuzzyFinder'

" Used
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'vim-scripts/a.vim' " swtich between source files and header files quickly 
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
"Plug 'scrooloose/syntastic'
Plug 'vim-scripts/Mark' " highlight some key variables 
Plug 'vim-scripts/snipMate'
Plug 'vim-scripts/genutils' " Vim-script library
Plug 'vim-scripts/L9' " Vim-script library 
Plug 'vim-scripts/desertEx'
"Plug 'https://github.com/Lokaltog/vim-powerline.git'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/Align'
Plug 'junegunn/vim-easy-align'
"Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'w0rp/ale' " syntax checker
Plug 'Yggdroot/LeaderF', {'do':'./install.sh'} " Fuzzy finder buffer, mru, files, tags, strings
Plug 'Yggdroot/indentLine' " display vertical lines
"Plug 'CoatiSoftware/vim-sourcetrail'
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/gutentags_plus'
Plug 'skywind3000/vim-preview'
Plug 'Valloric/YouCompleteMe'
Plug 'Shougo/echodoc.vim'

" Good plugin, but not need now
"Plug 'tpope/vim-fugitive' " Git wrapper 
"Plug 'Pydiction'
"Plug 'http://github.com/kevinw/pyflakes-vim'
" Haven tested, not good for me
call plug#end()
" vim-plug setting end }}}

" Global Settings: {{{
syntax on                           " highlight syntax

set nocompatible                    " out of Vi compatible mode
set number                          " show line number
set numberwidth=3                   " minimal culumns for line numbers
set textwidth=0                     " do not wrap words (insert)
set nowrap                          " do not wrap words (view)
set showcmd                         " show (partial) command in status line
set ruler                           " line and column number of the cursor position
set wildmenu                        " enhanced command completion
set wildmode=list:longest,full      " command completion mode
set laststatus=2                    " always show the status line
set mouse=                         " use mouse in all mode
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
set shiftwidth=4                    " number of spaces for indent
set expandtab                       " expand tabs into spaces
set incsearch                       " incremental search
set hlsearch                        " highlight search match
set ignorecase                      " do case insensitive matching
set smartcase                       " do not ignore if search pattern has CAPS
set nobackup                        " do not create backup file
set noswapfile                      " do not create swap file
set backupcopy=yes                  " overwrite the original file

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
"colorscheme desertEx
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

" Plugin Settings: {{{
if has("win32") " win32 system
    let $HOME  = $VIM
    let $VIMFILES = $HOME . "/vimfiles"
else " unix
    let $HOME  = $HOME
    let $VIMFILES = $HOME . "/.vim"
endif

" mru
"let MRU_Window_Height = 10

"Tagbar
let g:tagbar_left = 1

" taglist
"let g:Tlist_WinWidth = 25
"let g:Tlist_Use_Right_Window = 0
"let g:Tlist_Auto_Update = 1
"let g:Tlist_Process_File_Always = 1
"let g:Tlist_Exit_OnlyWindow = 1
"let g:Tlist_Show_One_File = 1
"let g:Tlist_Enable_Fold_Column = 0
"let g:Tlist_Auto_Highlight_Tag = 1
"let g:Tlist_GainFocus_On_ToggleOpen = 1

" nerdtree
let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize = 30
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeShowBookmarks=1
let g:NERDTreeQuitOnOpen=1

" snipMate
let g:snip_author   = "Lemon Mao"
let g:snip_mail     = "maoss1@lenovo.com"
let g:snip_company  = "Lenovo Corporation."

" man.vim - view man page in VIM
source $VIMRUNTIME/ftplugin/man.vim

"ctags
set nocp
let s:tagsFile = system("find $(pwd)/project_vim -type f -name \"cscope_sp_*.tags\" ")
let s:tagsList = split(s:tagsFile, '\n')
for ctagsObj in s:tagsList
    if filereadable(ctagsObj)
        exec "set tags+=".ctagsObj
    endif
endfor

" vim-Powerline
"set guifont=PowerlineSymbols\ for\ Powerline
let g:Powerline_symbols = 'fancy'

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
" Tabline
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#buffer_nr_show = 1



" FuzzyFinder
"let g:fuf_modesDisable = []
"let g:fuf_mrufile_maxItem = 100
"let g:fuf_mrucmd_maxItem = 100
"let g:fuf_mrufile_exclude = ''

" LeaderF
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_MruMaxFiles = 250
"let g:Lf_ExternalCommand = 'find %s -path /vobs/nosx/nos/platform/asic/sdk -a -prune -o -type f -name *.[ch]'
let g:Lf_WildIgnore = {
    \ 'dir': ['.svn','.git','.hg', 'lost+found', 'nos/platform/asic', 'project_vim'],
    \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
    \}
let g:Lf_CtagsFuncOpts = {
    \ 'c': '--c-kinds=fp',
    \ }



" cscope
function! CloseManualCsc()
    echo s:csCnt
    exec "cs del" s:csCnt
endfunction

function! AddProjectCscope()
    let s:csCnt = 0
    let s:csDir = system("find $(pwd)/project_vim -type f -name \"*cscope_sp_*.out\" ")
    let s:csList = split(s:csDir, '\n')
    for csObjFile in s:csList
        if filereadable(csObjFile)
            exec "cs add" csObjFile
            let s:csCnt+=1
        endif
    endfor
endfunction

if has("cscope")
    set csto=0
    set nocst
    set nocsverb  " show the excute info

    call AddProjectCscope()
    "if isdirectory("project_vim")
        "cd project_vim
        "if filereadable("cscope.out")
            "cs add cscope.out
        "endif
        "if filereadable("cscopedriv.out")
            "cs add cscopedriv.out
        "endif
        "cd ..
        "echo "hello ..."
    "endif
    "if filereadable("cscope.out")
        "cs add cscope.out
    "endif
endif


" LookupFile setting
"let g:LookupFile_TagExpr='"./project_vim/tags.filename"'
"let g:LookupFile_MinPatLength=2
"let g:LookupFile_PreserveLastPattern=0
"let g:LookupFile_PreservePatternHistory=1
"let g:LookupFile_AlwaysAcceptFirst=1
"let g:LookupFile_AllowNewFiles=0

" EasyAlign
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
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

" vimgdb.vim
"if has("gdb")
	"set asm=0
	"let g:vimgdb_debug_file=""
	"run macros/gdb_mappings.vim
"endif

" Async
let g:asyncrun_open = 8 "Automatically open window 
let g:asyncrun_bell = 1 " After finished, make a bell to notify 

"CtrlP
"let g:ctrlp_map      = '<c-p>'
"let g:ctrlp_cmd      = 'CtrlP'
"let g:ctrlp_mruf_max = 300
"let g:ctrlp_by_filename = 1 " default search by full path, set to 1 by filename only, change with <c-d>
"let g:ctrlp_custom_ignore = {
    "\ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    "\ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc)$',
    "\ }
"let g:ctrlp_custom_ignore = {
    "\ 'dir':  'lost+found/',
    "\ }
"let g:ctrlp_regexp = 0 "默认不使用正则表达式，置1改为默认使用正则表达式，可以用<C-r>进行切换
"let g:ctrlp_clear_cache_on_exit = 0
"let g:ctrlp_user_command = 'find %s -path /vobs/nosx/nos/platform/asic/sdk -a -prune -o -type f -name *.[ch]'
"let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'
"let g:ctrlp_working_path_mode = ''


"DoxygenToolkit
let g:DoxygenToolkit_briefTag_pre="@Brife  "
let g:DoxygenToolkit_paramTag_pre="@Param "
let g:DoxygenToolkit_returnTag="@Returns   "
let g:DoxygenToolkit_blockHeader="--------------------------------------------------------------------------"
let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------"
let g:DoxygenToolkit_authorName="Mathias Lorente"


" syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_always_populate_loc_list=1
"let g:syntastic_auto_loc_list=1
"let g:syntastic_enable_signs=1
"let g:syntastic_check_on_wq=0
"let g:syntastic_aggregate_errors=1
"let g:syntastic_loc_list_height=5
"let g:syntastic_error_symbol='X'
"let g:syntastic_style_error_symbol='X'
"let g:syntastic_warning_symbol='>'
"let g:syntastic_style_warning_symbol='>'
"let g:syntastic_python_checkers=['flake8', 'pydocstyle', 'python']
"let g:syntastic_quiet_messages = {"regex": 'No such file or directory'}
"let g:syntastic_mode_map = {"mode": "passive", "active_filetypes": ["python"], "passive_filetypes": [""] } 

"python-mode
" syntax highlight
"let g:pymode_python = 'python2'
let g:pymode=0
let g:pymode_options_max_line_length = 120
let g:pymode_options_colorcolumn = 0
let g:pymode_syntax=1
let g:pymode_syntax_slow_sync=1
let g:pymode_syntax_all=1
let g:pymode_syntax_print_as_function=g:pymode_syntax_all
let g:pymode_syntax_highlight_async_await=g:pymode_syntax_all
let g:pymode_syntax_highlight_equal_operator=g:pymode_syntax_all
let g:pymode_syntax_highlight_stars_operator=g:pymode_syntax_all
let g:pymode_syntax_highlight_self=g:pymode_syntax_all
let g:pymode_syntax_indent_errors=g:pymode_syntax_all
let g:pymode_syntax_string_formatting=g:pymode_syntax_all
"let g:pymode_syntax_space_errors=g:pymode_syntax_all
let g:pymode_syntax_string_format=g:pymode_syntax_all
let g:pymode_syntax_string_templates=g:pymode_syntax_all
let g:pymode_syntax_doctests=g:pymode_syntax_all
let g:pymode_syntax_builtin_objs=g:pymode_syntax_all
let g:pymode_syntax_builtin_types=g:pymode_syntax_all
let g:pymode_syntax_highlight_exceptions=g:pymode_syntax_all
let g:pymode_syntax_docstrings=g:pymode_syntax_all
""开启警告
let g:pymode_warnings = 0
let g:pymode_quickfix_minheight = 3
let g:pymode_quickfix_maxheight = 10
let g:pymode_python = 'python3'
"使用PEP8风格的缩进
let g:pymode_indent = 1
""取消代码折叠
let g:pymode_folding = 0
"开启python-mode定义的移动方式
let g:pymode_motion = 0
""启用python-mode内置的python文档，使用K进行查找
let g:pymode_doc = 1
let g:pymode_doc_bind = 'K'
"自动检测并启用virtualenv
let g:pymode_virtualenv = 1
"不使用python-mode运行python代码
let g:pymode_run = 0
let g:pymode_run_bind = '<Leader>r'
"不使用python-mode设置断点
let g:pymode_breakpoint = 0
"let g:pymode_breakpoint_bind = '<leader>b'
"启用python语法检查
let g:pymode_lint = 1
"修改后保存时进行检查
let g:pymode_lint_on_write = 0
"编辑时进行检查
let g:pymode_lint_on_fly = 0
let g:pymode_lint_checkers = ['pyflakes', 'pep8']
"发现错误时不自动打开QuickFix窗口
let g:pymode_lint_cwindow = 0
"侧边栏不显示python-mode相关的标志
let g:pymode_lint_signs = 1
let g:pymode_lint_todo_symbol = 'WW'
let g:pymode_lint_comment_symbol = 'CC'
let g:pymode_lint_visual_symbol = 'RR'
let g:pymode_lint_error_symbol = 'EE'
let g:pymode_lint_info_symbol = 'II'
let g:pymode_lint_pyflakes_symbol = 'FF'
"启用重构
let g:pymode_rope = 0
""不在父目录下查找.ropeproject，能提升响应速度
"let g:pymode_rope_lookup_project = 0
""光标下单词查阅文档
"let g:pymode_rope_show_doc_bind = '<C-c>d'
"""项目修改后重新生成缓存
"let g:pymode_rope_regenerate_on_write = 1
""开启补全，并设置<C-Tab>为默认快捷键
"let g:pymode_rope_completion = 1
"let g:pymode_rope_complete_on_dot = 1
"let g:pymode_rope_completion_bind = '<C-Tab>'
"""<C-c>g跳转到定义处，同时新建竖直窗口打开
"let g:pymode_rope_goto_definition_bind = '<C-c>g'
"let g:pymode_rope_goto_definition_cmd = 'vnew'
""重命名光标下的函数，方法，变量及类名
"let g:pymode_rope_rename_bind = '<C-c>rr'
"""重命名光标下的模块或包
"let g:pymode_rope_rename_module_bind = '<C-c>r1r'

" ale
"ale
""始终开启标志列
let g:ale_enabled = 0
let g:ale_sign_column_always = 1
let g:ale_set_highlights = 0
"自定义error和warning图标
let g:ale_sign_error = 'X'
let g:ale_sign_warning = 'W'
"在vim自带的状态栏中整合ale
let g:ale_statusline_format = ['✗ %d', '⚡ %d', '✔ OK']
"显示Linter名称,出错或警告等相关信息
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
""普通模式下，sp前往上一个错误或警告，sn前往下一个错误或警告
nmap cp <Plug>(ale_previous_wrap)
nmap cn <Plug>(ale_next_wrap)
"<Leader>s触发/关闭语法检查
"nmap <Leader>c :ALEToggle<CR>
""<Leader>d查看错误或警告的详细信息
"nmap <Leader>cl :ALEDetail<CR>
"文件内容发生变化时不进行检查
"let g:ale_lint_on_text_changed = 'never'
""打开文件时不进行检查
"let g:ale_lint_on_enter = 0
"使用clang对c和c++进行语法检查，对python使用pylint进行语法检查
let g:ale_linters = {
\   'python': ['pylint'],
\}

let s:numberf = 1

" YCM
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<m-y>'
set completeopt=menu,menuone

"noremap <c-z> <NOP>

let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{3}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ }

let g:ycm_filetype_whitelist = { 
            \ "c":1,
            \ "cpp":1, 
            \ "objc":1,
            \ "sh":1,
            \ "zsh":1,
            \ "zimbu":1,
            \ }
highlight PMenu ctermfg=0 ctermbg=242 guifg=black guibg=darkgrey
highlight PMenuSel ctermfg=242 ctermbg=8 guifg=darkgrey guibg=black

"let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'  "设置全局配置文件的路径
"let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
let g:ycm_confirm_extra_conf=0  " 打开vim时不再询问是否加载ycm_extra_conf.py配置
"let g:ycm_key_invoke_completion = '<C-a>' " ctrl + a 触发补全，防止与其他插件冲突
"set completeopt=longest,menu    "让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
"nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR> "定义跳转快捷键



" Echodoc
let g:echodoc#type = "echo" " Default value
set noshowmode
"set cmdheight=2
let g:echodoc_enable_at_startup = 1
"}}}

" Lemon Mao - configure: {{{
"
"
" Utility Funtions
function! RunShell(Msg, Shell)
    "let s:curFile = getcwd() . '/' . bufname("%")
    let s:curFile =  expand("%:p")
	echo a:Msg . s:curFile
    if filereadable(s:curFile)
        let s:cmd = a:Shell . s:curFile
        "echo s:cmd
        call system(s:cmd)
        exec "edit" 
    endif
    if match(a:Shell, "lg update ") > 0
        call AddProjectCscope()
        exec "cs reset"
    endif
	echo s:cmd "done"
endfunction

function! ToggleMouse()                                                          
    if  s:numberf == 1
        let s:numberf = 0
        exec "IndentLinesToggle" 
        set nonumber
    else 
        let s:numberf = 1
        exec "IndentLinesToggle" 
        set number
    endif
    "<cr>
    "exec "<cr>"
    echo "Done!"                                                      
    "if &mouse == 'a'                                                                 
        "set mouse=                                                                                                                                    
        "set nonumber                                                                     
        "IndentLinesToggle
        "echo "Mouse usage disabled"                                                      
    "else                                                                             
        "set mouse=a                                                                      
        "set number                                                                       
        "IndentLinesToggle
        "echo "Mouse usage enabled"                                                       
    "endif                                                                            
endfunction
"map gd gD
"
":vertical resize+40<CR>
" move between windows
function! ChangeCurWind(flag)
    let objFind = -1
    let winName = bufname(winbufnr(0))
    let objFind = match(winName, "NERD_tree_")
    let objFind = objFind >= 0 ? objFind : match(winName, "Tag_List")
    echo "old:" objFind winName
    if objFind != -1
        exe "normal 5\<C-W>|"
    endif

    exec "wincmd" a:flag

    let objFind = -1
    let winName = bufname(winbufnr(0))
    let objFind = match(winName, "NERD_tree_")
    let objFind = objFind >= 0 ? objFind : match(winName, "Tag_List")
    echo "new:" objFind winName
    if objFind != -1
        exe "normal 60\<C-W>|"
    endif
endfunction


" settings of cscope.
" " I use GNU global instead cscope because global is faster.
" 第一个 GTAGSLABEL 告诉 gtags 默认 C/C++/Java 等六种原生支持的代码直接使用
" gtags 本地分析器，而其他语言使用 pygments 模块。
"let $GTAGSLABEL = 'native-pygments'
"let $GTAGSCONF = '/path/to/share/gtags/gtags.conf'

" gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'
" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
else
    let g:gutentags_modules += ['ctags']
endif
" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" 如果使用 universal ctags 需要增加下面一行
"let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0
" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif
let g:gutentags_define_advanced_commands = 1
" change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1
let g:gutentags_plus_nomap = 1

set cscopetag
set cscopeprg=gtags-cscope
"set cscopequickfix=c+,d+,e+,f+,i+,s+,t+
"nmap <silent> <leader>j <ESC>:cstag <c-r><c-w><CR>
"nmap <silent> <leader>g <ESC>:lcs f c <c-r><c-w><cr>:lw<cr>
"nmap <silent> <leader>s <ESC>:lcs f s <c-r><c-w><cr>:lw<cr>
"command! -nargs=+ -complete=dir FindFiles :call FindFiles(<f-args>)
"au VimEnter * call VimEnterCallback()
"au BufAdd *.[ch] call FindGtags(expand('<afile>'))
"au BufWritePost *.[ch] call UpdateGtags(expand('<afile>'))

"function! FindFiles(pat, ...)
    "let path = ''
    "for str in a:000
        "let path .= str . ','
    "endfor

    "if path == ''
        "let path = &path
    "endif

    "echo 'finding...'
    "redraw
    "call append(line('$'), split(globpath(path, a:pat), '\n'))
    "echo 'finding...done!'
    "redraw
"endfunc

function! VimEnterCallback()
    if filereadable("GTAGS")
        cs add GTAGS
    endif

    "for f in argv()
        "if fnamemodify(f, ':e') != 'c' && fnamemodify(f, ':e') != 'h'
            "continue
        "endif

        "call FindGtags(f)
    "endfor
endfunc

"function! FindGtags(f)
    "let dir = fnamemodify(a:f, ':p:h')
    "while 1
        "let tmp = dir . '/GTAGS'
        "if filereadable(tmp)
            "exe 'cs add ' . tmp . ' ' . dir
            "break
        "elseif dir == '/'
            "break
        "endif

        "let dir = fnamemodify(dir, ":h")
    "endwhile
"endfunc

function! UpdateGtags(f)
    let s:filename = fnamemodify(a:f, ':p')
    echo s:filename "lemon !!"
    "exe '!echo' filename '| gtags -i -f -'
    "' | global -u &> /dev/null &'
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

" Key Bindings: {{{
let mapleader = ","
let maplocalleader = "\\"

" map : -> <space>
map <Space> :

"nmap <Leader>r :MRU<cr>
"nmap <Leader>R :MRU 
"nmap <Leader>t :TlistToggle<cr>
nmap <Leader>t :TagbarToggle<cr>
nmap <Leader>f :NERDTreeToggle<CR>
nmap <Leader>F :NERDTreeFind<CR>

" F1 ~~ F12 hotkey mapping
"nmap <F2>  :AsyncRun lt find zebos/
nmap <F3>  :diffput<cr>
nmap <F4>  :AsyncRun lt find zebos/
"nmap <F4>  :vimgrep //g zebos/**/*.[ch]
"nmap <F5> <Plug>LookupFile " This has been mapped in lookupfile plugin 
nmap <F5>  <leader>#
nmap <F6>  <leader>*
nmap <F7>  :AsyncRun cd /vobs/nosx/nos/build/mars; make 
nmap <F9>  :call RunShell("Check out file : ", "/usr/atria/bin/cleartool co ")<cr>
nmap <F10> :call RunShell("Uncheck out file : ", "/usr/atria/bin/cleartool unco -rm ")<cr>
nmap <F11> :call RunShell("Update current project_vim info! ", "cd /vobs/nosx;lg update ")<cr>
nmap <F12> :call ToggleMouse() <CR> 
"nmap <silent> <C-1> *<CR>

" useful mappings for managing tabs
map <leader>tn :tabnew 
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" ##### Moving Hotkeys #####
" ---move from the multiple screen
nmap <C-h> :call ChangeCurWind("h")<ESC><cr>
nmap <C-l> :call ChangeCurWind("l")<ESC><cr>
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <leader>1 :vertical resize-10<CR> <ESC>
nmap <leader>2 :vertical resize+10<CR> <ESC>
"nmap <C-h> <C-w>h
"nmap <C-l> <C-w>l
" ---Ctrol-E to switch between 2 last buffers
nmap <C-E> :b#<CR>
" ########################

" Don't use Ex mode, use Q for formatting
" map Q gq

"make Y consistent with C and D
nnoremap Y y$

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" ,n to get the next location (compilation errors, grep etc)
"nmap <leader>n :cn<CR>
"nmap <leader>p :cp<CR>

" Ctrl-N to disable search match highlight
nmap <silent> <C-N> :silent noh<CR>

"cscope hotkey mapping
"nmap <leader>sh :cs show<cr>
"nmap <leader>ll :cs find f 
"nmap <leader>ss :cs find s <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>ss :cs find s <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>sg :cs find g <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>sc :cs find c <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>st :cs find t <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>se :cs find e <C-R>=expand("<cword>")<cr><cr>
"nmap <leader>sf :cs find f <C-R>=expand("<cfile>")<cr><cr>
"nmap <leader>si :cs find i <C-R>=expand("<cfile>")<cr><cr>
"nmap <leader>sd :cs find d <C-R>=expand("<cword>")<cr><cr>
noremap <silent> <leader>ss :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>sg :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>sc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>st :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>se :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>sf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>si :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>sd :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>sa :GscopeFind a <C-R><C-W><cr>

" FuzzyFinder
"nnoremap <silent> sb     :FufBuffer<CR>
"nnoremap <silent> sm     :FufMruFile<CR>
"nnoremap <silent> smc    :FufMruCmd<CR>
"nnoremap <silent> su     :FufBookmarkFile<CR>
"nnoremap <silent> s<C-u> :FufBookmarkFileAdd<CR>
"vnoremap <silent> s<C-u> :FufBookmarkFileAddAsSelectedText<CR>
"nnoremap <silent> sf     :FufFile<CR>
"nnoremap <silent> st     :FufTaggedFile<CR>

" CtrlP
"nnoremap <silent> sb     :CtrlPBuffer<CR>
"nnoremap <silent> sm     :CtrlPMRUFiles<CR>

" LeaderF
nnoremap <silent> sb     :LeaderfBuffer<CR>
nnoremap <silent> sm     :LeaderfMru<CR>
nnoremap <silent> sf     :LeaderfFile<CR>
nnoremap <silent> st     :LeaderfBufTag<CR>
nnoremap <silent> sta    :LeaderfBufTagAll<CR>
nnoremap <silent> ss     :LeaderfLine<CR>
nnoremap <silent> ssa    :LeaderfLineAll<CR>
nnoremap <silent> sfu    :LeaderfFunction<CR>
nnoremap <silent> sfua   :LeaderfFunctionAll<CR>


" Align
",ascom

" Pydiction
"let g:pydiction_location = '~/.vim/bundle/Pydiction/complete-dict'

"LookupFile hotkey mapping
"nmap <silent> <leader>l :LUTags<cr>
"nmap <silent> <leader>lb :LUBufs<cr>
"nmap <silent> <leader>lw :LUWalk<cr>

" center display after searching
nnoremap n   nzz
nnoremap N   Nzz
nnoremap *   *zz
nnoremap #   #zz
nnoremap g*  g*zz
nnoremap g#  g#z

" vim-preview
noremap <m-u> :PreviewScroll -1<cr>
noremap <m-d> :PreviewScroll +1<cr>
inoremap <m-u> <c-\><c-o>:PreviewScroll -1<cr>
inoremap <m-d> <c-\><c-o>:PreviewScroll +1<cr>
autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
noremap <m-t> :PreviewTag <cr>
noremap <m-s> :PreviewSignature <cr>
noremap <m-c> :PreviewClose <cr>

"Airline 设置切换Buffer快捷键"
"nnoremap <C-N> :bn<CR>
nnoremap <C-P> :bp<CR>

" close 
nnoremap <m-q> <ESC> :q<cr> <ESC>
"}}}
