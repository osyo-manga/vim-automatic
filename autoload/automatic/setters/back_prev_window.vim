scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let g:automatic_prev_uniq_winnr = 0


function! automatic#setters#back_prev_window#apply(config, context)
	if get(a:config, "back_prev_window", 0)
		call automatic#gift().set_current_window(g:automatic_prev_uniq_winnr)
	endif
endfunction


augroup automatic-bacK_prev_window
	autocmd!
	autocmd WinLeave * let g:automatic_prev_uniq_winnr = automatic#gift().uniq_winnr()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
