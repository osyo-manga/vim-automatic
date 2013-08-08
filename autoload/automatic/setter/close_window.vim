scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#setter#close_window#apply(config, ...)
	if get(a:config, "is_close_focus_out", 0)
		let w:automatic_setter_close_window = 1
	endif
endfunction

function! s:close_window()
	if get(w:, "automatic_setter_close_window", 0)
		close
	endif
endfunction

augroup automatic-close_window
	autocmd!
	autocmd WinLeave * call s:close_window()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
