" SETTINGS

" Misc settings.
filetype plugin on
set nocp  
set timeoutlen=200  " Time in ms to wait for next keycode in a remapping. 
set backspace=2  " Fix backspace sometimes not working in insert mode.
set showcmd
set exrc  " Use .vimrc in directory vim is opened from (project level settings).
set secure
set mouse=a

" Search settings.
set hlsearch
set incsearch  
set noic

" Tab settings.
let TABSZ = 8
let &tabstop = TABSZ
let &softtabstop = TABSZ
let &shiftwidth = TABSZ
set noexpandtab

" Statusline and visual settings.
set statusline=%{winnr()}:\ %m\ %f\ %y\%h%r\ %l/%L,%c
set laststatus=2  " Always show status line, even when there's only one file.
set noruler  " Disable ruler as redundant with status line.
set number " Use line numbers.

" Colour settings.
" See https://jonasjacek.github.io/colors/ for colours codes.
set t_Co=256  " Use 256 colours.
set cursorline  " Background highlight the current line grey.
hi CursorLine cterm=none ctermbg=255
hi CursorLineNr cterm=none ctermbg=255 ctermfg=174
hi Visual ctermbg=252
hi LineNr ctermfg=174
hi Search ctermbg=210
hi Pmenu ctermbg=217 ctermfg=16
hi PmenuSel ctermbg=204 ctermfg=16
hi WildMenu ctermbg=174
hi StatusLine cterm=bold ctermbg=250 ctermfg=233
hi StatusLineNC cterm=none ctermbg=253 ctermfg=233
hi VertSplit cterm=none
hi SignColumn ctermbg=255
hi TODO ctermbg=214 ctermfg=16

" OmniCppComplete plugin settings.
" Have selecting an option in a popup window show more info in another popup
" instead of the preview window.
set completeopt=menu,preview,popup

" Vim-gitgutter plugin settings.
let g:gitgutter_enabled = 0
set updatetime=100  " Update signs every 100 ms.

" Vim-gutentags plugin settings.
let g:gutentags_ctags_extra_args = ['--options=' . $HOME . '/.ctags']
let g:gutentags_modules = ['ctags', 'cscope']
" Files to generate tags for by default. This can be overridden per-project
" by setting this again in the project root .vimrc file.
let g:gutentags_file_list_command = 'find . -name "*.[ch]"'
let g:gutentags_cscope_build_inverted_index = 1

" Ale plugin settings.
let g:ale_enabled = 0  " Disable ale by default.
let g:ale_c_cc_options = "-std=c11 -Wall"

" Cscope settings.
" Dump results in quickfix window.
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
" Consult ctags tags database before cscope database on :tag command.
set csto=1


" FUNCTIONS

" Whether the cwindow is currently open (opens with commands :cwindow and :copen).
" Used to toggle it being open.
let cwinopen = 0  " This name can represent the reverse if cwin is opened manually.

" Open the cwindow if it's closed, and close it if it's open.
func! ToggleCwindow()
	if g:cwinopen
		exec ':cclose'
		let g:cwinopen = 0
	else
		exec ':botright copen'
		let g:cwinopen = 1
	endif
endfunc

" Open the cwindow. Use this instead of :copen directly to not break
" ToggleCWindow.
func! OpenCwindow()
	if !g:cwinopen 
		exec ':copen'
		let g:cwinopen = 1
	endif
endfunc

func! EditAltFileErr(fname, fext)
	echo "file '" . a:fname . "' no alt " . a:fext . 'file'
endfunc

" Swap to (edit) an alternate file to the input file. E.g. the alternate 
" file for a .c file is a .h file, and vice versa. 
func! EditAltFile(fname)
	" Mapping between a file extension and its alternative file extensions to swap to.
	let alt_maps = [
		\['c',   ['h']],
		\['cpp', ['hpp', 'h']],
		\['h',   ['cpp', 'c']],
		\['hpp', ['cpp']]
	\]
	let fname_parts = split(a:fname, '\.')

	if len(fname_parts) != 2
		echo "error: " . a:fname
		return
	else
		let fname_prefix = fname_parts[0]
		let fname_extension = fname_parts[1]
	endif

	for alt_map in alt_maps
		if alt_map[0] == fname_extension
			for alt_extension in alt_map[1]
				let alt_fname = fname_prefix . '.' . alt_extension
				if filereadable(alt_fname)
					" Use :buffer to open instead of :edit so that editing continues
					" from where the cursor previously was in the file, and not from
					" the top of the file.
					if bufexists(alt_fname)
						exec ':b ' . alt_fname
					else
						exec ':e ' . alt_fname
					endif
					return
				endif
			endfor
		endif
	endfor
	echo "no alternate file for " . a:fname
endfunc

" Jump back or forth a file. 
"
" @s: normal command to execute. This command will jump the cursor
" to either an older or newer position.
func! JmpFile(s)
	" Previous line, column, bufnr.
	let pl = -1
	let pc = -1
	let pn = bufnr('%')

	while 1
		exec a:s

		let l = line('.')
		let c = col('.')
		let n = bufnr('%')

		" Stop at a different buffer or if didn't move at all.
		if pn != n || (pl == l && pc == c && pn == n)
			break
		endif
		let pl = l
		let pc = c
		let pn = n
	endwhile
endfunc

func! JmpBackFile()
	call JmpFile("normal! \<c-o>")
endfunc

func! JmpFwdFile()
	call JmpFile("normal! 1\<c-i>")
endfunc

" Find all occurrences of a string in the current file.
func! VimgrepCurFile(s)
	exec 'vimgrep /' . a:s . '/j %'
endfunc

" Find all occurrences a string in all C and header
" files rooted at the directory Vim was started from.
func! VimgrepAllFiles(s)
	exec 'vimgrep /' . a:s . '/j **/*.[ch]'
endfunc

func! VimgrepYankedCurFile()
	exec 'norm! yiw'
	call VimgrepCurFile(getreg('"'))
endfunc

func! VimgrepYankedAllFiles()
	exec 'norm! yiw'
	call VimgrepAllFiles(getreg('"'))
endfunc

" Wrapper for fzf.vim Tags command to open a searched for tag
" in the ptag preview window.
func! Ptags()
	pclose
	pedit
	wincmd P
	Tags
	" Commented out because can't currently auto jump back 
	" because of error.
	"wincmd p
endfunc

" Cscope find where a symbol is used.
" @s: symbol name
func! CscopeSymbol(s)
	exec 'cs find s ' . a:s
endfunc

" Cscope find functions calling a function.
" @s: function being called
func! CscopeFuncCalled(s)
	exec 'cs find c ' . a:s
endfunc

" Cscope find places a symbol is assigned to.
" @s: symbol 
func! CscopeSymAssign(s)
	exec 'cs find a ' . a:s
endfunc

" Get the name of the C function the cursor is currently in.
" The function body open brace { needs to be on a line by itself
" for this to work as intended.
func! CurCFuncName()
	exec 'norm! mz[['
	" Function name is on the first line above that has at its start at least two words but 
	" the second word can be an asterisk *, and then following it is an open parenthesis. 
	" These two words make up the function's type and name. There could however be more words 
	" involved in its type, such as static or unsigned, which have yet to be accounted for.  
	" This could potentitally break if there's a function pointer parameter or the function returns
	" a function pointer.
	" TODO this regex can be improved, but it works well enough currently
	?^\s*\w\+\s\+\(\w\|\*\)\+.*(
	exec 'norm! f(bye`z:delmark z\<cr>'
	return getreg('"')
endfunc

" Run a normal mode command that might move the cursor without
" moving the cursor.
" @mid_ncmd: string normal mode command to run that might move cursor
" @after_ncmd: string normal mode command to run after having returned to the
"	cursor position the cursor was at when this function was called
func! RunNCmdCursorStay(mid_ncmd, after_ncmd)
	delmark z
	exec "norm! mz" . a:mid_ncmd . "\<esc>`z"
	delmark z
	if a:after_ncmd != ""
		exec 'norm! ' . a:after_ncmd
	endif
endfunc


" NORMAL MODE REMAPS

" Function keys.
nnoremap <F1> :cp<cr>
nnoremap <F2> :cn<cr>
nnoremap <F5> :ALEToggle<cr>
nnoremap <silent><F6> :call ToggleCwindow()<cr>
nnoremap <silent><F7> :TagbarToggle<cr>

" Clear the current line in both directions, except for leading whitespace.
nnoremap DD $d^xA
" Swap current line with below line.
nnoremap <c-j> ddp
" Swap current line with above line.
nnoremap <c-k> dd<up><up>p
" Use tjump instead of tag.
nnoremap <c-]> g<c-]>

" Jump to 25%, 50%, and 75% of the way through the current line.
nnoremap <silent>g1 :call cursor(0, virtcol('$')/4)<cr>
nnoremap <silent>g2 :call cursor(0, virtcol('$')/2)<cr>
nnoremap <silent>g3 :call cursor(0, virtcol('$')/4*3)<cr>


" NORMAL MODE LEADER KEY REMAPS

" Function keys.
nnoremap <leader><F1> :cold<cr>
nnoremap <leader><F2> :cnew<cr>

" Delete bracket under cursor and its match.
nnoremap <silent><leader>% :call RunNCmdCursorStay('%x', 'x')<cr>
" Using 6 since shortcut <c-^> (caret is shift 6) is used for swapping to most
" recent file.
nnoremap <leader>6 :call EditAltFile(expand('%'))<cr>

nnoremap <leader>sc :call VimgrepYankedCurFile()<cr>
nnoremap <leader>sa :call VimgrepYankedAllFiles()<cr>
nnoremap <leader>b :call JmpBackFile()<cr>
nnoremap <leader>f :call JmpFwdFile()<cr>

nnoremap <leader>gq :GitGutterQuickFix<cr>:call OpenCwindow()<cr>
" Insert C-style multiline comment above current line.
nnoremap <leader>h O/*<cr><cr>/<esc>kA 

nnoremap <leader>p <c-w>g}
nnoremap <leader>m :make!<cr><cr>
nnoremap <leader>n :make clean<cr><cr> 
nnoremap <leader>o :call RunNCmdCursorStay('o', "")<cr>
nnoremap <leader>O :call RunNCmdCursorStay('O', "")<cr>
" Append ; to end of current line.
nnoremap <silent><leader>; :call RunNCmdCursorStay('A;', "")<cr>

" Open the header of the current C-style function the cursor is inside in the 
" preview window. Assumes the function has its opening { on a line by itself.
nnoremap <leader>H :pclose<cr>:pedit<cr><c-w><up>[[<c-w><down>
nnoremap <silent><leader>F :Files<cr>
nnoremap <silent><leader>T :Tags<cr>
nnoremap <silent><leader>B :Buffers<cr>
nnoremap <silent><leader>P :call Ptags()<cr>
nnoremap <silent><leader>C yiw:call CscopeFuncCalled(getreg('"'))<cr>
nnoremap <silent><leader>D    :call CscopeFuncCalled(CurCFuncName())<cr>
nnoremap <silent><leader>S yiw:call CscopeSymbol(getreg('"'))<cr>
nnoremap <silent><leader>U    :call CscopeSymbol(CurCFuncName())<cr>
nnoremap <silent><leader>A yiw:call CscopeSymAssign(getreg('"'))<cr>


" Jump to an older/newer position in the preview window without leaving
" the current window. Can't use <leader><c-o> for going to an older position
" because can't use ctrl with leader.
nnoremap <leader>I <c-w>P<c-o><c-w>p
nnoremap <leader>i <c-w>P<c-i><c-w>p

nnoremap <leader>M :e Makefile<cr>


" INSERT MODE REMAPS

" Characters with matching open and close characters. 
let mchars = {
	    \ '"': '""',
	    \ '''': '''''',
	    \ '(': '()',
	    \ '[': '[]',
	    \ '{': '{}'
	    \ }

" Auto-close matching open-close chars on one press. Double press for no auto-close.
for [openchar, closechar] in items(mchars)
	exec 'inoremap ' . openchar . ' ' . closechar . '<left>'
	exec 'inoremap ' . openchar . openchar . ' ' . openchar
endfor

" Auto-close python multiline comment.
inoremap """ """   """<s-left><left><left>
" Spread array block [] across multiple lines.
inoremap [<cr> [<cr><tab><cr>]<up><right> 
" Code block open { not on its own line. Appends
" { to end of current line.
inoremap {<cr> <end><space>{<cr><tab><cr>}<up><end><bs>

" Vim movement keys hjkl in insert mode.
inoremap <c-l> <right>
inoremap <c-k> <up>
inoremap <c-j> <down>
inoremap <c-h> <left>

inoremap <leader>x <del>


" INSERT MODE LEADER KEY REMAPS

" Code block open { on its own line.
inoremap <leader>{ <end><cr>{<cr><tab><cr>}<up><end><bs>


" VISUAL MODE REMAPS

" Indent back and forth with shift and shift+tab. Keeps the
" selection afterwards.
vnoremap <tab> >gv
vnoremap <s-tab> <gv



" Vimplug plugin manager.
"
" Install vimplug with 
"
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Then run ':PlugInstall' from Vim to install plugins
" listed below. 
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdcommenter'
Plug 'preservim/tagbar'
Plug 'vim-scripts/OmniCppComplete'
Plug 'airblade/vim-gitgutter'
Plug 'ludovicchabant/vim-gutentags'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'dense-analysis/ale'

call plug#end()
