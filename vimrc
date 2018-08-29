" Vim config file.

" Vundel setting {{{
set nocompatible " be iMproved
filetype off " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
" let Vundle manage Vundle  
" " required!   
Bundle 'gmarik/vundle'


" original repos on github 
" Bundle 'tpope/vim-fugitive'
" vim-scripts repos
Bundle 'DoxygenToolkit.vim'
Bundle 'a.vim'
Bundle 'taglist.vim'
Bundle 'mru.vim'
Bundle 'bufexplorer.zip'
Bundle 'The-NERD-tree'
Bundle 'The-NERD-Commenter'
Bundle 'genutils'
Bundle 'lookupfile'
Bundle 'Mark'
Bundle 'AutoComplPop'
Bundle 'OmniCppComplete'
Bundle 'snipMate'
Bundle 'L9'
Bundle 'desertEx'
Bundle 'https://github.com/skywind3000/asyncrun.vim'
Bundle 'https://github.com/Lokaltog/vim-powerline.git'
Bundle 'Align'
Bundle 'FuzzyFinder'
Bundle 'https://github.com/junegunn/vim-easy-align'
" --- For python
"Bundle 'Pydiction'
"Bundle 'http://github.com/kevinw/pyflakes-vim'
Bundle 'klen/python-mode' 
Bundle 'scrooloose/syntastic'

" --- Unused
"Bundle 'UltiSnips'
" Bundle ''
" non github repos
" Bundle 'git://git.wincent.com/command-t.git'
" Bundle 'file:///Users/gmarik/path/to/plugin'

filetype plugin indent on           " auto detect file type
" Vundel setting end }}}

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
let MRU_Window_Height = 10

" taglist
let g:Tlist_WinWidth = 25
let g:Tlist_Use_Right_Window = 0
let g:Tlist_Auto_Update = 1
let g:Tlist_Process_File_Always = 1
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Show_One_File = 1
let g:Tlist_Enable_Fold_Column = 0
let g:Tlist_Auto_Highlight_Tag = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1

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
for s:tagsObj in s:tagsList
    exec "set tags+=".s:tagsObj
endfor

" vim-Powerline
"set guifont=PowerlineSymbols\ for\ Powerline
let g:Powerline_symbols = 'fancy'

" FuzzyFinder
let g:fuf_modesDisable = []
let g:fuf_mrufile_maxItem = 100
let g:fuf_mrucmd_maxItem = 100
let g:fuf_mrufile_exclude = ''

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
let g:LookupFile_TagExpr='"./project_vim/tags.filename"'
let g:LookupFile_MinPatLength=2
let g:LookupFile_PreserveLastPattern=0
let g:LookupFile_PreservePatternHistory=1
let g:LookupFile_AlwaysAcceptFirst=1
let g:LookupFile_AllowNewFiles=0

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
"}}}

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_enable_signs=1
let g:syntastic_check_on_wq=0
let g:syntastic_aggregate_errors=1
let g:syntastic_loc_list_height=5
let g:syntastic_error_symbol='X'
let g:syntastic_style_error_symbol='X'
let g:syntastic_warning_symbol='>'
let g:syntastic_style_warning_symbol='>'
let g:syntastic_python_checkers=['flake8', 'pydocstyle', 'python']
let g:syntastic_quiet_messages = {"regex": 'No such file or directory'}
let g:syntastic_mode_map = {"mode": "passive", "active_filetypes": ["python"], "passive_filetypes": [""] } 

"python-mode
" syntax highlight
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
    if &mouse == 'a'                                                                 
        set mouse=                                                                                                                                    
        set nonumber                                                                     
        echo "Mouse usage disabled"                                                      
    else                                                                             
        set mouse=a                                                                      
        set number                                                                       
        echo "Mouse usage enabled"                                                       
    endif                                                                            
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
"set cscopetag
"set cscopeprg=gtags-cscope
"set cscopequickfix=c-,d-,e-,f-,g0,i-,s-,t-
"nmap <silent> <leader>j <ESC>:cstag <c-r><c-w><CR>
"nmap <silent> <leader>g <ESC>:lcs f c <c-r><c-w><cr>:lw<cr>
"nmap <silent> <leader>s <ESC>:lcs f s <c-r><c-w><cr>:lw<cr>
"command! -nargs=+ -complete=dir FindFiles :call FindFiles(<f-args>)
"au VimEnter * call VimEnterCallback()
"au BufAdd *.[ch] call FindGtags(expand('<afile>'))
au BufWritePost *.[ch] call UpdateGtags(expand('<afile>'))

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
"}}}

" Key Bindings: {{{
let mapleader = ","
let maplocalleader = "\\"

" map : -> <space>
map <Space> :

nmap <Leader>r :MRU<cr>
nmap <Leader>R :MRU 
nmap <Leader>t :TlistToggle<cr>
nmap <Leader>f :NERDTreeToggle<CR>
nmap <Leader>F :NERDTreeFind<CR>

" F1 ~~ F12 hotkey mapping
"nmap <F2>  $<CR>
nmap <F3>  :diffput<cr>
nmap <F4>  :vimgrep //g zebos/**/*.[ch]
"nmap <F5> <Plug>LookupFile " This has been mapped in lookupfile plugin 
nmap <F6>  <leader>#<cr>
nmap <F7>  <leader>*<cr>
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
map Q gq

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
nmap <leader>sh :cs show<cr>
nmap <leader>ll :cs find f 
nmap <leader>ss :cs find s <C-R>=expand("<cword>")<cr><cr>
nmap <leader>ss :cs find s <C-R>=expand("<cword>")<cr><cr>
nmap <leader>sg :cs find g <C-R>=expand("<cword>")<cr><cr>
nmap <leader>sc :cs find c <C-R>=expand("<cword>")<cr><cr>
nmap <leader>st :cs find t <C-R>=expand("<cword>")<cr><cr>
nmap <leader>se :cs find e <C-R>=expand("<cword>")<cr><cr>
nmap <leader>sf :cs find f <C-R>=expand("<cfile>")<cr><cr>
nmap <leader>si :cs find i <C-R>=expand("<cfile>")<cr><cr>
nmap <leader>sd :cs find d <C-R>=expand("<cword>")<cr><cr>

" FuzzyFinder
nnoremap <silent> sb     :FufBuffer<CR>
nnoremap <silent> sm     :FufMruFile<CR>
nnoremap <silent> smc    :FufMruCmd<CR>
nnoremap <silent> su     :FufBookmarkFile<CR>
nnoremap <silent> s<C-u> :FufBookmarkFileAdd<CR>
vnoremap <silent> s<C-u> :FufBookmarkFileAddAsSelectedText<CR>
nnoremap <silent> sf     :FufFile<CR>
nnoremap <silent> st     :FufTaggedFile<CR>

" Align
",ascom

" Pydiction
"let g:pydiction_location = '~/.vim/bundle/Pydiction/complete-dict'

"LookupFile hotkey mapping
nmap <silent> <leader>l :LUTags<cr>
nmap <silent> <leader>lb :LUBufs<cr>
"nmap <silent> <leader>lw :LUWalk<cr>

" center display after searching
nnoremap n   nzz
nnoremap N   Nzz
nnoremap *   *zz
nnoremap #   #zz
nnoremap g*  g*zz
nnoremap g#  g#z
"}}}
