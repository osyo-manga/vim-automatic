scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! automatic#matchers#unite_sources#is_match(config, ...)
	try
		let sources = copy(get(unite#get_current_unite(), "source_names", []))
	catch
		return 1
	endtry
	if has_key(a:config, "any_unite_sources")
		return !empty(filter(sources, "index(a:config.any_unite_sources, v:val) != -1"))
	endif
	if has_key(a:config, "unite_sources")
		return len(filter(sources, "index(a:config.unite_sources, v:val) != -1")) == len(a:config.unite_sources)
	endif
	return 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
