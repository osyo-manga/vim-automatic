scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:is_percent(str)
	return a:str =~# '^\zs\d\+\.\?\d*\ze%$'
endfunction


function! s:percent_to_float(value)
	return str2float(matchstr(a:value, '^\zs\d\+\.\?\d*\ze%$')) / 100.0
endfunction



function! s:height(value)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:height(float2nr(s:percent_to_float(a:value) * &lines))
	endif
	execute "resize" a:value
endfunction


function! s:width(value)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:width(float2nr(s:percent_to_float(a:value) * &columns))
	endif
	execute "vertical resize" a:value
endfunction


function! automatic#setter#resize#apply(config, ...)
	if has_key(a:config, "height")
		call s:height(a:config.height)
	endif

	if has_key(a:config, "width")
		call s:width(a:config.width)
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
