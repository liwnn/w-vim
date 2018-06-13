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
if !isdirectory($HOME.'/.cache') | call mkdir($HOME.'/.cache') | endif
if !isdirectory($VIMTEMP) | call mkdir($VIMTEMP) | endif

"General
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk
set autochdir
set splitright
set lazyredraw
set noerrorbells
set shortmess=filnxtToOc
set belloff=all
filetype plugin indent on
syntax on

"View
set wildmenu
set guioptions-=T
set guitablabel=%{fnamemodify(bufname(tabpagebuflist(v:lnum)[tabpagewinnr(v:lnum)-1]),':t')}
set display=lastline
set cursorline
set listchars=tab:»\ ,trail:·
set list
autocmd FileType go setlocal listchars=tab:\¦\ ,trail:·
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
        elseif color_name == 'solarized'
            exe 'set background=' . ((randnum % 3 == 0) ? 'dark' : 'light')
        end
        exe 'colorscheme ' . color_name
    end
elseif color_name != 'default'
    exe 'colorscheme ' . color_name
end
if has("gui_running")
    set balloondelay=300
endif

"Edit
set number
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
autocmd FileType proto setlocal tabstop=2 | setlocal autoindent
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
autocmd BufEnter *
            \ if &buftype == 'quickfix' |
            \     exe 'unmap <2-LeftMouse>' |
            \ elseif &buftype == '' |
            \     exe 'noremap <2-LeftMouse> ms:%s/\<<C-R>=expand("<cword>")<CR>\>//gen<cr>`sviw' |
            \ endif

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

"snipMate
let g:snippets_dir = $VIMFILES . "/snippets"

" ale
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

"Tagbar
let g:tagbar_width = 32
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
let g:tagbar_compact = 1
nnoremap <silent> <F9> :TagbarToggle<CR>

"Minibufexpl
let g:miniBufExplMaxSize = 3
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplCycleArround = 1
noremap <C-TAB> :MBEbn<CR>
noremap <C-S-TAB> :MBEbp<CR>

"MUcomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#can_complete = {}
let g:mucomplete#can_complete.go = { 'omni': { t -> t =~# '\m\k\%(\k\|\.\)$' } }

" netrw
let g:netrw_home=$VIMTEMP
let g:netrw_sort_sequence = '[\/]$,*'
let g:netrw_liststyle= 3

"Nerd_commenter
let NERDCommentEmptyLines = 1
let NERDDefaultAlign = 'both' " left start both none

"vbookmark
let g:vbookmark_bookmarkSaveFile = $VIMTEMP . '/.vimbookmark'
nnoremap <silent> <C-F2> :VbookmarkToggle<CR>
nnoremap <silent> <F2> :VbookmarkNext<CR>
nnoremap <silent> <S-F2> :VbookmarkPrevious<CR>

"Ctrlp
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_by_filename = 1
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\.git$\|\.hg$\|\.svn$',
            \ 'file': '\.class$\|\.o$\|\~$\|\.DS_Store'
            \ }

"mru
let MRU_File = $VIMTEMP . '/.vim_mru_files'

"indentline
let g:indentLine_char = '¦'
let g:indentLine_first_char = g:indentLine_char
let g:indentLine_showFirstIndentLevel = 1
au BufReadPost * exec "call SetIndent()"
func! SetIndent()
    if expand('%:e') == 'log' || getfsize(expand(@%)) > 4 * 1024 * 1024
        setlocal nowrap
        set guioptions+=b
        let g:indentLine_enabled = 0
    else
        set guioptions-=b
        let g:indentLine_enabled = 1
    endif
endfunc

"vim-go
let g:go_def_mode = 'godef'
let g:go_list_type = 'quickfix'
let g:go_list_height = 10
let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment', 'comment']

"Tools
func! CompileRun()
    exec ":w"
    let g:asyncrun_open = 10
    if &filetype == "lua"
        exec "AsyncRun lua %"
    elseif &filetype == "python"
        exec "AsyncRun -raw python %"
    elseif &filetype == "go"
        exec "AsyncRun! -raw go run %"
    elseif &filetype == "objc" || &filetype == "cpp" || &filetype == "c" || &filetype == "cs" || &filetype == "java"
        if &filetype == "objc"
            exec "AsyncRun g++ -framework Foundation % -o %<"
        elseif &filetype == "cpp" || &filetype == "c"
            if &filetype == "c"
                let l:cmd = "AsyncRun gcc % -g -Wall -o %< -std=c11"
            else
                let l:cmd = 'AsyncRun g++ -o %< % -g -Wall -std=c++11 -lpthread'
            endif
            if g:os == 'win'
                let l:cmd = l:cmd . ' -lwsock32'
            endif
            exec l:cmd
        elseif &filetype == "cs"
            exec "AsyncRun csc % /nologo /utf8output"
        elseif &filetype == "java"
            exec "AsyncRun javac %"
        endif
        let g:asyncrun_exit = 'call Run()'
    endif
    unlet g:asyncrun_open
endfunc "CompileRun
func! Run()
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
        let g:asyncrun_exit = ''
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

noremap <silent> <F5> :call CompileRun() <CR>
noremap <Leader>o :call OpenContainerFolder() <CR><CR>
