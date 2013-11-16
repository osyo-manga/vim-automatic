scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#matchers#quickrun_latest_filetype#is_match(config, ...)
	if !exists("g:automatic_quickrun_latest_filetype")
\	|| !has_key(a:config, "quickrun_latest_filetype")
		return 1
	endif
	return g:automatic_quickrun_latest_filetype == a:config.quickrun_latest_filetype
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
