scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#matchers#expr#is_match(config, ...)
	return eval(get(a:config, "expr", "1"))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
