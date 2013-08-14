scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! automatic#matchers#set_once_in_window#is_match(config, ...)
	if get(a:config, "set_once_in_window", 0)
		return get(w:, "automatic_matchers_set_once_in_window", 1)
	else
		return 1
	endif
endfunction

function! automatic#matchers#set_once_in_window#apply(config, context)
	let w:automatic_matchers_set_once_in_window = 0
endfunction
call automatic#regist_setter("set_once_in_window", function("automatic#matchers#set_once_in_window#apply"))


let &cpo = s:save_cpo
unlet s:save_cpo
