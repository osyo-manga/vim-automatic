scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:is_percent(str)
	return a:str =~# '^\zs\d\+\.\?\d*\ze%$'
endfunction


function! s:percent_to_float(value)
	return str2float(matchstr(a:value, '^\zs\d\+\.\?\d*\ze%$')) / 100.0
endfunction



function! s:lines(value)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:lines(float2nr(s:percent_to_float(a:value) * &lines))
	endif
	let &lines = a:value
endfunction


function! s:columns(value)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:columns(float2nr(s:percent_to_float(a:value) * &columns))
	endif
	let &columns = a:value
endfunction


function! automatic#setters#gui_window#apply(config, ...)
	if has_key(a:config, "lines")
		call s:lines(a:config.lines)
	endif

	if has_key(a:config, "columns")
		call s:columns(a:config.columns)
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
