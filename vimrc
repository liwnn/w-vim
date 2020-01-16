"OS
if has('win32')
    let $VIMFILES=$VIM.'/vimfiles'
    set guifont=consolas:h10
    let g:os = 'win'
elseif has('mac')
    let $VIMFILES=$HOME.'/.vim'
    let g:os = 'mac'
else
    let $VIMFILES=$HOME.'/.vim'
    let g:os = 'linux'
endif
let $VIMTEMP=$HOME.'/.cache/vimtemp'
if !isdirectory($VIMTEMP) | call mkdir($VIMTEMP, "p") | endif

"General
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk
set autochdir
set splitright
set lazyredraw
set noerrorbells
set belloff=all
set shortmess=filnxtToOc
filetype plugin indent on
syntax on

"View
set number
set cursorline
set wildmenu
set balloondelay=300
set guioptions-=T
set guitablabel=%{fnamemodify(bufname(tabpagebuflist(v:lnum)[tabpagewinnr(v:lnum)-1]),':t')}
set display=lastline
set listchars=tab:»\ ,trail:·
autocmd FileType go setlocal listchars=tab:\¦\ ,trail:·
set list
set laststatus=2
set statusline=%F%m%r%0*%=%0*%k%1*\ %{&filetype}\ %2*\ Ln\ %l\ \ Col\ %c\ \ %L\ %3*\ %{&ff}\ %4*%(\ %{&fenc.(&bomb?\"\(BOM\)\":\"\")}\ %)%*
set t_Co=256
autocmd ColorScheme * hi User1 guifg=#ffffff  guibg=#666666 gui=bold ctermfg=255 ctermbg=243 cterm=bold |
            \ hi User2 guifg=#292b00  guibg=#a4a597 ctermfg=black ctermbg=lightgrey |
            \ hi User3 guifg=#ffffff  guibg=#6b7977 ctermfg=255 ctermbg=245 |
            \ hi def link User4 StatusLine |
            \ hi SpecialKey gui=none
let color_name = ''
if color_name == ''
    let arr = []
    for colorsheme_dir in [$VIMFILES.'/colors']
        let arr += split(glob(colorsheme_dir.'/*.vim'), '\n')
    endfor
    if len(arr) > 0
        let slash = (g:os == 'win') ? '\' : '/'
        let randnum = str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
        let color_name = split(arr[randnum % len(arr)], slash)[-1][:-5]
        if color_name == 'molokai'
            let g:rehash256 = 1
            let g:molokai_original = randnum % 2
        end
        exe 'colorscheme ' . color_name
    end
elseif color_name != 'default'
    exe 'colorscheme ' . color_name
end

"Edit
set expandtab
set shiftwidth=4
set linebreak
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set completeopt=menuone,longest,noinsert
set cino=:0g0t0(sus
set mouse=a
set clipboard=unnamed,unnamedplus
autocmd FileType make,go setlocal noexpandtab
autocmd FileType xml setlocal nowrap
set tabstop=4
autocmd FileType python setlocal tabstop=4
autocmd FileType proto setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal autoindent
set foldlevelstart=8
autocmd BufNewFile,BufRead *.[ch],*.cpp,*.cs,*.java,*.go set foldmethod=syntax
autocmd BufNewFile,BufRead *.py,*.sh,*.php,*.lua,*.xml set foldmethod=indent
noremap <C-a> ggVG
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a
vnoremap <C-c> y
vnoremap <Leader>p "0p
noremap <Leader>d :g/<C-R><C-W>/d<CR>gg
if g:os == 'mac'
    nmap ∆ mz:m+<cr>`z
    nmap ˚ mz:m-2<cr>`z
else
    nmap <M-j> mz:m+<cr>`z
    nmap <M-k> mz:m-2<cr>`z
endif

"Search
set hlsearch
set incsearch
set ignorecase
set smartcase
nnoremap <Leader>f :vim /<C-R><C-W>/j %<CR>:copen<CR>:wincmd p<CR>:wincmd p<CR>:wincmd p<CR>
nnoremap <F3> ms:%s/\<<C-R>=expand("<cword>")<CR>\>//gen<cr>`sviw
nnoremap <Esc><Esc> :<C-u>nohlsearch<CR>

"Session
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
set noswapfile
set undofile
set undodir=$VIMTEMP
set undolevels=200
let &viminfo="'100,f0,<0,@0,s10,:5,/5,h,n" . expand("$VIMTEMP") . "/.viminfo"
set sessionoptions=blank,buffers
if has("gui_running")
    if g:os != 'mac'
        if filereadable($VIMTEMP . '/vimsize')
            let sizepos = split(readfile($VIMTEMP . '/vimsize')[0])
        else
            let sizepos = ['85','31','500','150']
        endif
        silent! exe "set columns=".sizepos[0]
        silent! exe "set lines=".sizepos[1]
        silent! exe "winpos ".sizepos[2]." ".sizepos[3]
    endif

    if argc() == 0
        autocmd VimEnter * nested : call LoadSession($VIMTEMP . '/session.vim')
    endif
    autocmd VimLeavePre * : call MakeSession()
endif

function! LoadSession(session_file)
    if filereadable(a:session_file) && !&diff
        exe 'silent! source ' . a:session_file
    endif
endfunc
function! MakeSession()
    exe 'cclose'
    let bufcount = 0
    for i in range(1, bufnr('$'))
        if bufname(i) == '-MiniBufExplorer-'
            if bufwinnr(i) != -1
                exe 'bdelete ' . i
            endif
        elseif bufname(i) == '__MRU_Files__'
            exe 'bdelete ' . i
        elseif bufname(i) != '' && buflisted(i) == 1
            let bufcount = bufcount + 1
        endif
    endfor
    if bufcount > 1
        if argc() > 0
            silent! argdel *
        endif
        mksession! $VIMTEMP/session.vim
    endif
    if has("gui_running") && (getwinposx() > 70 || getwinposy() > 30)
        let data = &columns . ' '. &lines . ' ' . getwinposx() . ' ' . getwinposy()
        call writefile([data], $VIMTEMP . '/vimsize')
    endif
endfunc

"Tagbar
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
nmap <silent> <F8> :TagbarToggle<CR>

"Minibufexpl
let g:miniBufExplMaxSize = 3
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplCycleArround = 1
noremap <C-TAB> :MBEbn<CR>
noremap <C-S-TAB> :MBEbp<CR>

"MUcomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#completion_delay = 100
let g:mucomplete#can_complete = {}
let g:mucomplete#can_complete.go = { 'omni': { t -> t =~# '\m\k\%(\k\|\.\)$' } }
let g:mucomplete#chains = {
            \ 'sql' : ['path', 'keyn']
            \}
if !(has('python') || has('python3'))
  let g:mucomplete#chains.python = ['path', 'keyn']
endif

"netrw
let g:netrw_home=$VIMTEMP
let g:netrw_sort_sequence = '[\/]$,*'
let g:netrw_liststyle= 3

"NERD Commenter
let NERDCommentEmptyLines = 1
let NERDDefaultAlign = 'both' " left start both none

"vim-bookmark
let g:vbookmark_bookmarkSaveFile = $VIMTEMP . '/.vimbookmark'
nnoremap <silent> <F2> :VbookmarkNext<CR>
nnoremap <silent> <S-F2> :VbookmarkPrevious<CR>

"Ctrlp
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_by_filename = 1
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$',
            \ 'file': '\v\.(class|o|DS_Store|so|dll|exe)$',
            \ }

"mru
let MRU_File = $VIMTEMP . '/.vim_mru_files'

"indentLine
let g:indentLine_char = '¦'
let g:indentLine_first_char = g:indentLine_char
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_fileTypeExclude = ['', 'json']

"vim-go
let g:go_fmt_command = "goimports"
let g:go_gocode_unimported_packages = 1
let g:go_list_type = 'quickfix'
let g:go_list_height = 10
let g:go_rename_command = 'gopls'
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1

"Tools
noremap <silent> <F5> :call CompileRun() <CR>
noremap <Leader>o :call OpenContainerFolder() <CR><CR>
func! CompileRun()
    if &filetype == "lua"
        let cmd = "AsyncRun lua %"
    elseif &filetype == "python"
        let cmd = "AsyncRun -raw python %"
    elseif &filetype == "go"
        let cmd = "AsyncRun! -raw go run %"
    elseif &filetype == "php"
        let cmd = "AsyncRun! -raw php %"
    else
        if &filetype == "objc"
            let cmd = "AsyncRun g++ -framework Foundation % -o %<"
        elseif &filetype == "cpp" || &filetype == "c"
            if &filetype == "c"
                let cmd = "AsyncRun gcc % -g -Wall -o %< -std=c11"
            else
                let cmd = 'AsyncRun g++ -o %< % -g -Wall -std=c++11 -lpthread'
            endif
            if g:os == 'win'
                let cmd = cmd . ' -lwsock32'
            endif
        elseif &filetype == "cs"
            let cmd = "AsyncRun csc % /nologo /utf8output"
        elseif &filetype == "java"
            let cmd = "AsyncRun javac %"
        else
            return
        endif
        let g:asyncrun_exit = 'call Run()'
    endif
    noautocmd silent! exec 'w | botright copen | wincmd k'
    exec cmd
endfunc "CompileRun
func! Run()
    let g:asyncrun_exit = ''
    if g:asyncrun_status == "success"
        if &filetype == "java"
            exec "AsyncRun java %:r"
        else
            if g:os == 'win'
                exec "AsyncRun -mode=4 %<"
            else
                exec "AsyncRun ./%<"
            endif
        endif
    endif
endfunc
function! OpenContainerFolder()
    if expand('%') != ""
        if g:os == 'win'
            exe "!start explorer /select, %"
        elseif g:os == 'mac'
            exe "!open $PWD"
        else
            exe "!nautilus $PWD"
        endif
    endif
endfunc "OpenContainerFolder

call plug#begin("vim/pack/plugins/start")
Plug 'fatih/vim-go'
Plug 'dense-analysis/ale'
Plug 'lifepillar/vim-mucomplete'
Plug 'https://github.com/ctrlpvim/ctrlp.vim.git'
Plug 'terryma/vim-multiple-cursors'
Plug 'majutsushi/tagbar'
Plug 'wining/snipmate.vim'
Plug 'preservim/nerdcommenter'
Plug 'yegappan/mru'
Plug 'Yggdroot/indentLine'
call plug#end()
