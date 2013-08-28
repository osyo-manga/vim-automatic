scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#matchers#localtime#is_match(config, context)
	if !has_key(a:config, "localtime_expr")
		return 1
	endif
	if empty(a:config.localtime_expr)
		return 1
	endif
	let year   = str2nr(strftime("%Y", a:context.localtime))
	let month  = str2nr(strftime("%d", a:context.localtime))
	let day    = str2nr(strftime("%d", a:context.localtime))
	let hour   = str2nr(strftime("%H", a:context.localtime))
	let minute = str2nr(strftime("%M", a:context.localtime))
	let second = str2nr(strftime("%S", a:context.localtime))
	return eval(a:config.localtime_expr)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
