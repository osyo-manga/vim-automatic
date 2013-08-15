scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! automatic#setters#tags#apply(config, ...)
	let w:automatic_setter_tags = get(a:config, "tags", [])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
