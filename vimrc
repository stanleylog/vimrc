" File:         .vimrc
" Author:       Stanley Sun <coolingverse AT gmail DOT com>
" Version:      1.5
" For:          Windows and Linux
" Last Change:  2011/5/24 22:44:36
"
" What's New: 
"   1.调整代码以适用于Linux系统
"   2.删除不使用的插件配置信息
"   3.加强代码折叠,代码补全的设置
"   4.更改文件的字符集为UTF-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 自定义函数 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 取得操作系统类型
function! MySys()
  if has("win32")
    return "win32"
  elseif has("unix")
    return "unix"
  else
    return "mac"
  endif
endfunction

" 实现括号的自动配对后防止重复输入），适用python 
function! ClosePair(char) 
  if getline('.')[col('.') - 1] == a:char 
    return "\<Right>" 
  else 
    return a:char 
  endif 
endf 

" Last change用到的函数，返回时间，能够自动调整位置 
function! TimeStamp(...) 
  let sbegin = '' 
  let send = '' 
  if a:0 >= 1 
    let sbegin = a:1.'\s*' 
  endif 
  if a:0 >= 2 
    let send = ' '.a:2 
  endif 
  let pattern =  'Last Change: .\+' 
        \. send 
  let pattern = '^\s*' . sbegin . pattern . '\s*$' 
  let now = strftime('%Y-%m-%d %H:%M:%S', 
        \localtime()) 
  let row = search(pattern, 'n') 
  if row  == 0 
    let now = a:1 .  ' Last Change:  ' 
          \. now . send 
    call append(2, now) 
  else 
    let curstr = getline(row) 
    let col = match( curstr , 'Last') 
    let spacestr = repeat(' ',col - 1) 
    let now = a:1 . spacestr . 'Last Change:  ' 
          \. now . send 
    call setline(row, now) 
  endif 
endfunction

" 获取当前工作目录
function! CurDir()
  let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
  return curdir
endfunction

"标签显示
function ShortTabLabel ()
  let bufnrlist = tabpagebuflist (v:lnum)
  let label = bufname (bufnrlist[tabpagewinnr (v:lnum) -1])
  let filename = fnamemodify (label, ':t')
  return filename
endfunction

" 可视化查询
function! VisualSearch(direction) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if a:direction == 'b'
    execute "normal ?" . l:pattern . "^M"
  else
    execute "normal /" . l:pattern . "^M"
  endif
  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

"
function! <SID>BufcloseCloseIt()
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum)
    buffer #
  else
    bnext
  endif

  if bufnr("%") == l:currentBufNum
    new
  endif

  if buflisted(l:currentBufNum)
    execute("bdelete! ".l:currentBufNum)
  endif
endfunction

"命令行设置
func! Cwd()
  let cwd = getcwd()
  return "e " . cwd 
endfunc

func! DeleteTillSlash()
  let g:cmd = getcmdline()
  if MySys() == "linux" || MySys() == "mac"
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
  else
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
  endif
  if g:cmd == g:cmd_edited
    if MySys() == "linux" || MySys() == "mac"
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
    else
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
    endif
  endif
  return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
  return a:cmd . " " . expand("%:p:h") . "/"
endfunc

fun! DeleteAllBuffersInWindow()
  let s:curBufNr = bufnr("%")
  exe "bn"
  let s:nextBufNr = bufnr("%")
  while s:nextBufNr != s:curBufNr
    exe "bn"
    exe "bdel ".s:nextBufNr
    let s:nextBufNr = bufnr("%")
  endwhile
endfun

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 通用设置 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"设置操作系统脚本
if MySys() == "unix" || MySys() == "mac"
  set shell=bash
elseif MySys() == "win32"
  set shell=c:\WINDOWS\system32\cmd.exe
endif

set history=400                  "设置保存的历史记录个数
set autoread                     "当文件变更自动刷新

if has("gui_running")
  set clipboard+=unnamed         "使用windows剪切板
endif
set so=7                         "设置垂直滚动基点
set wildmenu                     "打开命令行增强模式补全
set ruler                        "显示标尺
set nu                           "显示行号
set numberwidth=4                "设置行号使用的最小列数
set cmdheight=1                  "命令行高度
set wrap                         "自动折行
set lz                           "当运行宏时不重画布局
set hid                          "当改变缓冲区时不提示保存
set backspace=eol,start,indent   "Set backspace
set whichwrap+=<,>,h,l           "Bbackspace and cursor keys wrap to
set magic                        "打开魔术功能
set showmatch                    "在插入括号时跳转到匹配的括号上
set mat=2                        "设置高亮显示模式
set hlsearch                     "高亮查询结果
set makeprg=gcc\ -o\ %<\ %       "设置make命令
set ffs=unix,dos,mac             "设置文件格式
set completeopt=longest,menu     "即时的过滤和匹配的代码补全
syntax enable                    "开启语法高亮


if has("gui_running")
if exists("+mouse")
  set mouse=a                    "开启鼠标支持
endif
endif

"自动切换工作目录
if exists("+autochdir")
  set autochdir
else
  autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent!
  lcd %:p:h:gs/ /\\ /
endif

"查询时忽略大小写
set ignorecase                   "忽略大小写
set incsearch                    "即时搜索

"当出错时关闭提示音
set noerrorbells                 "错误信息响铃
set visualbell                   "使用可视响铃代替鸣叫
set vb t_vb=                     "设置可视铃声

"排版设置
set tabstop=4                    "tab的空格数
set shiftwidth=4                 "缩进使用的空格数
set cindent shiftwidth=4         "C语言缩进的空格数
set autoindent shiftwidth=4      "自动缩进的空格数
set expandtab                    "插入模式中插入<Tab>时使用合适数量的空格
set smarttab                     "行首的 <Tab> 根据 'shiftwidth' 插入空白

set formatoptions+=mM            "自动排版的字母序列
"set lbr                         "在 'breakat' 中显示回绕长行
set tw=500                       "插入文本的最大宽度

"内容缩进
set ai                           "Auto indent
set si                           "Smart indet
set cindent                      "C-style indeting
"set guioptions+=b               "开启底部的滚动条
set guioptions-=l                "隐藏左侧滚动条
set guioptions-=r                "隐藏左侧滚动条

"关闭文件备份
set nobackup                     "关闭文件备份
set nowb                         "关闭覆盖文件前建立备份
set noswapfile                   "关闭缓冲区使用交换文件

"设置mapleader
let mapleader = ","
let g:mapleader = ","

"设置行结束符
"set listchars=eol:<
"set list                       "显示行结束符

"开启 filetype 插件
filetype plugin on               "打开特定文件类型允许插件载入
filetype indent on               "打开特定文件类型允许缩进载入

"中文标点
set ambiwidth=double             "东亚二义性宽度
"set brk=^I!@*-+;:,./?
"map <leader>' :set brk+=，。；：？《》～·！
"

"光标样式
"let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"let &t_SR = "\<Esc>]50;CursorShape=2\x7"
"let &t_EI = "\<Esc>]50;CursorShape=0\x7"

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 颜色与字体 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"设置MAC与LINUX系统的字体为Monaco 10pt
if MySys() == "mac"
  "set gfn=Courier_New:h16
  "set nomacatsui
  "set termencoding=macroman
elseif MySys() == "linux"
  "set gfn=Monospace\ 11
elseif MySys() =="win32"
  "set guifont=Consolas:h10.5:cANSI
  "set guifontwide=Microsoft\ YaHei\ Mono:h10.5
  "set guifontwide=YaHei\ Mono:h10.5
  set guifont=Microsoft_YaHei_Mono:h11:cGB2312
endif

set gfn=Monaco:h13

"设置配色方案
colorscheme default
"colorscheme solarized
set background=dark
hi preproc ctermfg=Cyan
hi LineNr  ctermfg=14   term=NONE   cterm=NONE
hi MatchParen ctermbg=blue ctermfg=white

if has("gui_running")
  colorscheme murphy
  hi Error		    guifg=red		    guibg=Black	gui=undercurl	ctermfg=red
  hi Folded       guifg=LightCyan guibg=Black
  hi FoldColumn   guifg=LightCyan guibg=Black

  "当前行高亮
  set cursorline
  hi cursorline guibg=#333333
  hi CursorColumn guibg=#333333
endif

"设置菜单颜色
hi Pmenu guibg=#333333 ctermfg=0 ctermbg=7
hi PmenuSel guibg=#555555 guifg=#ffffff ctermfg=15 ctermbg=6

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 语言与字符集 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set fileencodings=utf-8,gbk,ucs-bom,gb18030,gb2312,cp936 " 设置文件编码检测类型及支持格式

"设置文件编码
if has("win32")
  set fileencoding=chinese
else
  set fileencoding=utf-8
endif

"字符集方案
if has("gui_running")             "GUI字符集方案
  set encoding=utf-8              "设置编码

  "解决菜单乱码
  source $VIMRUNTIME/delmenu.vim
  source $VIMRUNTIME/menu.vim

  language messages zh_CN.utf-8   "解决consle输出乱码
else                              "DOS字符集方案
  
endif

"中文帮助
if version >= 603
  set helplang=cn
endif

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 图形界面 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if (has("gui_running"))
  winpos 675 295                       "指定启动时窗口的位置与大小
  set lines=35 columns=100             "设置最大行和列
endif

set guioptions-=m                       "隐藏菜单
set guioptions-=T                       "隐藏工具栏

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " 标签页 {{{
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  set tabpagemax=99                     "最大使用标签数
  set guitablabel=%{ShortTabLabel()}    "标签名

  "显示标签页
  try
    set switchbuf=usetab                "缓冲区切换时跳到第一个打开的包含指定缓冲区的窗口
    set stal=1                          "至少有两个标签的时候才显示标签页
  catch
  endtry
  
  "}}}

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " 状态栏 {{{
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  set laststatus=2                      "一直显示状态栏

"  highlight FileStat   guifg=#000000 guibg=#c2bfa5 cterm=NONE ctermfg=Black ctermbg=LightGray
"  highlight BufferNum  guifg=#888888 guibg=#c2bfa5 cterm=NONE ctermfg=DarkGray ctermbg=LightGray
"  highlight CWD        guifg=#0000ff guibg=#c2bfa5 cterm=NONE ctermfg=Blue ctermbg=LightGray
"  highlight Encoding   guifg=#ff0000 guibg=#c2bfa5 cterm=NONE ctermfg=Red ctermbg=LightGray
"  highlight Position   guifg=#ff0000 guibg=#c2bfa5 cterm=NONE ctermfg=Red ctermbg=LightGray
  
  "格式化状态栏内容
  set statusline=%#FileStat#\ %-12(%t%m%r%h\ %w%)
  "set statusline+=%#FileSize#\ %-15(Size:[%{line2byte(line("$")+1)-1}]%)
  "set statusline+=%#BufferNum#\ %-15(BufferNum:[%n]%)
  "set statusline+=%#CWD#\ %-15(CWD:\ %{CurDir()}%)
  set statusline+=%=
  set statusline+=%#Encoding#\ %(%y\ Encoding:\ %{(&fenc==\"\")?toupper(&enc):toupper(&fenc)}%{(&bomb?\",BOM\":\"\")}\ [%{toupper(&fileformat)}]\%)
  set statusline+=\ \|
  set statusline+=%#Position#\ %(\ Line:\ %l/%L:%c%V\ %P\ \ %)


  if has("gui_running")
    if version >= 700 
      "hi statusline guifg=darkblue guibg=white
      hi statusline guifg=#404040 guibg=#DDDDDD
      
      "hi StatusLine guibg=#ffeecc guifg=black gui=bold ctermbg=14 ctermfg=0
      "hi StatusLineNC guibg=#ff4455 guifg=white gui=none ctermbg=4 ctermfg=11
      au InsertEnter * hi StatusLine gui=reverse
      au InsertLeave * hi StatusLine gui=None

      "au InsertEnter * hi FileStat gui=reverse
      "au InsertLeave * hi FileStat gui=None
    else
      set statusline=\ %t%m%r%h\ %w\ \ BufferNum:[%n]\ \ \ CWD:\ %r%{CurDir()}%h\ \ \ %=\ \ \ %y\ Encoding:\ %#test#%{(&fenc==\"\")?toupper(&enc):toupper(&fenc)}%{(&bomb?\",BOM\":\"\")}\ \|\ Line:\ %l/%L:%c%V\ %P\ \ 
    endif
  else
    "set statusline=CWD:\ %r%{CurDir()}%h\ \ \ %=\ \ \ %y\ Encoding:\ %{(&fenc==\"\")?toupper(&enc):toupper(&fenc)}%{(&bomb?\",BOM\":\"\")}\ \|\ Line:\ %l/%L:%c%V\ %P\ \ 
  endif
  "}}}
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 文件类型 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au FileType html,python,vim,javascript setl shiftwidth=2
au FileType html,python,vim,javascript setl tabstop=2
au FileType java setl shiftwidth=4
au FileType java setl tabstop=4

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 自动命令 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"au GUIEnter * simalt ~x                                         "启动时窗口最大化
"au GUIENTER * call libcallnr("vimtweak.dll","SetAlpha",200)     "启动时开启窗口透明功能


au BufWinEnter ?* silent loadview                               "自动加载视图

au! bufwritepost vimrc source $MYVIMRC                          "当.vimrc被更改后进行重载

" 自动补全括号，包括大括号 
:inoremap ( ()<ESC>i
:inoremap ) <c-r>=ClosePair(')')<CR>
:inoremap { {}<ESC>i
:inoremap } <c-r>=ClosePair('}')<CR>
:inoremap [ []<ESC>i
:inoremap ] <c-r>=ClosePair(']')<CR>
:inoremap < <><ESC>i
:inoremap > <c-r>=ClosePair('>')<CR>

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 快捷键 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"快速保存与查询
nmap <leader>w :w!<cr>
nmap <leader>f :find<cr>


map <leader>s v0
map <leader>e v$
map <leader>g vgg0
map <leader>G vG$

"快速更新.vimrc
map <leader>r :source $MYVIMRC<cr>

"快速编辑 .vimrc
map <leader>x :e! $MYVIMRC<cr>

"切换语法
map <leader>1 :set ft=html<cr>
map <leader>2 :set syntax=jsp<cr>
map <leader>3 :set syntax=vim<cr>
map <leader>4 :set ft=javascript<cr>
map <leader>$ :syntax sync fromstart<cr>

"文件格式
nmap <leader>fd :se ff=dos<cr>
nmap <leader>fu :se ff=unix<cr>

"查询选择的区域
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

"用空格进行查询
map <space> /
"map <C-d> :
map <leader>d :
"map <C-Space> ?

"窗口定位
"nmap <C-j> <C-W>j
"nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l

"关闭高亮显示
map <silent> <leader>` :noh<cr>

"Presse c-q insted of space (or other key) to complete the snippet
imap <C-q> <C-]> 

""用方向键切换缓冲区
"map <leader>bd :Bclose<cr>
"map <C-up> :ls<cr>
"map <C-down> :Bclose<cr>
"map <C-right> :bn<cr>
"map <C-left> :bp<cr>
nmap j gj
nmap k gk
"imap <Down> <C-o>gj
"imap <Up> <C-o>gk

" Close the current buffer
map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

imap <C-left> <esc>%i
imap <C-right> <esc>%a

"标签选择
"map <leader>te :tabedit
"map <leader>tm :tabmove
nmap <C-t> : tabnew <cr>
nmap <C-h> : tabp<cr>
nmap <C-l> : tabn<cr>
"
" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove 
map <leader>t<leader> :tabnext 

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()


" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

"Moving fast to front, back and 2 sides ;)
imap <C-$> <esc>$a
imap <C-0> <esc>0i
imap <D-$> <esc>$a
imap <D-0> <esc>0i

"切换当前目录
map <leader>cd :cd %:p:h<cr>

"Remove the Windows ^M
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

"设置半页翻页映像键
map <C-k> 
map <C-j> 

" 文本折行
map <F3> :set wrap<cr>
"文本不折行
map <F4> :set nowrap<cr>
"插入当前日期时间
:inoremap <F5> <c-r>=strftime("%c")<CR>
"窗口高度等分
map <F6> <c-w>=<cr>
"当前窗口高度最小化
map <F7> <c-w>1_<cr>
"当前窗口高度最大化
map <F8> <c-w>_<cr>
"当前窗口宽度最小化
"map <F9> <c-w>1|<cr>
"当前窗口宽度最大化
"map <F10> <c-w>|<cr>
"Buffer - reverse everything ... :)
"map <F9> ggVGg?

"map <F11> :MaximizedWin<cr>
"map <F12> :RestoreWin<cr>
"Paste toggle - when pasting something in, don't indent.
"set pastetoggle=<F11>

map <C-Down> :next<CR>
map <C-Up> :previous<CR>

"Orginal for all
"map <leader>n :cn<cr>
"map <leader>p :cp<cr>
"map <leader>c :botright cw 10<cr>
"map <c-u> <c-l><c-j>:q<cr>:botright cw 10<cr>

"map <unique> <leader>y "*y
"map <unique> <leader>p "*p 

"拼写检查
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=

map <leader>t2 :set shiftwidth=2<cr>
map <leader>t4 :set shiftwidth=4<cr>

"执行程序
nmap <leader>p :! %

"关键字补全
set cpt=.,w,b,t,i

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 命令行设置 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Smart mappings on the command line
cno $h e ~/
cno $d e ~/Desktop/
cno $j e ./

cno $q <C-\>eDeleteTillSlash()<cr>

cno $c e <C-\>eCurrentFileDir("e")<cr>

cno $tc <C-\>eCurrentFileDir("tabnew")<cr>
cno $th tabnew ~/
cno $td tabnew ~/Desktop/

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 缓冲区 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Fast open a buffer by search for a name
"map <c-q> :sb<cr>

"Open a dummy buffer for paste
map <leader>q :e ~/buffer<cr>

"Restore cursor to file position in previous editing session
"set viminfo='10,\"100,:20,%,n~/.viminfo
"au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()

"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 平台依赖 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if (has("win32")) "Win32
    " VimTweak
    if (has("gui_running"))
        "command -nargs=1 SetAlpha call libcallnr("vimtweak.dll", "SetAlpha", <args>)
        "command -nargs=0 TopMost call libcallnr("vimtweak.dll", "EnableTopMost", 1)
        "command -nargs=0 NoTopMost call libcallnr("vimtweak.dll", "EnableTopMost", 0)
        "command -nargs=0 MaximizedWin call libcallnr("vimtweak.dll", "EnableMaximize", 1)
        "command -nargs=0 RestoreWin call libcallnr("vimtweak.dll", "EnableMaximize", 0)
    endif
elseif (has("linux")) "Linux
    set makeprg=build
endif

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle 插件配置 {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " 去除VI一致性,必须要添加
filetype off                  " 必须要添加

" 设置包括vundle和初始化相关的runtime path
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')

" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

"自定义插件
"Plugin 'bling/vim-airline'
"Plugin 'vim-airline/vim-airline'
"Plugin 'vim-airline/vim-airline-themes'

" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
filetype plugin indent on    " 必须 加载vim自带和插件相应的语法和文件类型相关脚本
" 忽视插件改变缩进,可以使用以下替代:
"filetype plugin on
"
" 常用的命令
" :PluginList       - 列出所有已配置的插件
" :PluginInstall  	 - 安装插件,追加 `!` 用以更新或使用 :PluginUpdate
" :PluginSearch foo - 搜索 foo ; 追加 `!` 清除本地缓存
" :PluginClean      - 清除未使用插件,需要确认; 追加 `!` 自动批准移除未使用插件
"
" 查阅 :h vundle 获取更多细节和wiki以及FAQ
" 将你自己对非插件片段放在这行之后
"
"}}}
