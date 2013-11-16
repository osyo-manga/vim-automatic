scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:hook = {
\	"name" : "automatic_save_filetype",
\}


function! s:hook.init(...)
	let g:automatic_quickrun_latest_filetype = &filetype
endfunction


function! quickrun#hook#automatic_save_filetype#new()
	return s:hook
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
