scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#matchers#unite_bufname#is_match(config, ...)
	let bufname = get(a:config, "unite_bufname", "")
	if !empty(bufname)
		let bufname = '[\[\*]unite[\]\*] - ' . bufname
	endif
	return bufname("%") =~# bufname
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
