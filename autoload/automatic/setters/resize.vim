scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:clamp(value, min, max)
	return min([max([a:min, a:value]), a:max])
endfunction


function! s:is_percent(str)
	return a:str =~# '^\zs\d\+\.\?\d*\ze%$'
endfunction


function! s:percent_to_float(value)
	return str2float(matchstr(a:value, '^\zs\d\+\.\?\d*\ze%$')) / 100.0
endfunction



function! s:height(value, min, max)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:height(float2nr(s:percent_to_float(a:value) * &lines), a:min, a:max)
	endif
	execute "resize" s:clamp(a:value, a:min, a:max)
endfunction


function! s:width(value, min, max)
	if type(a:value) == type("") && s:is_percent(a:value)
		return s:width(float2nr(s:percent_to_float(a:value) * &columns), a:min, a:max)
	endif
	execute "vertical resize" s:clamp(a:value, a:min, a:max)
endfunction


function! automatic#setters#resize#apply(config, ...)
	if has_key(a:config, "height")
		call s:height(a:config.height, get(a:config, "min_height", 1), get(a:config, "max_height", &lines))
	endif

	if has_key(a:config, "width")
		call s:width(a:config.width, get(a:config, "min_width", 1), get(a:config, "max_width", &columns))
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
