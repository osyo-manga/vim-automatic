scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! automatic#matchers#unite_bufname#is_match(config, ...)
	let bufname = get(a:config, "unite_bufname", "")
	try
		return get(unite#get_current_unite(), "buffer_name", "") =~# bufname
	catch
		return 1
	endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
