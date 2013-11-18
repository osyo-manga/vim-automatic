scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:autocmd_histories = []
function! automatic#clear_autocmd_history()
	let s:autocmd_histories = []
endfunction


function! automatic#make_current_context(...)
	let base = get(a:, 1, {})
	if has_key(base, "autocmd")
		call add(s:autocmd_histories, base.autocmd)
		if len(s:autocmd_histories) > g:autocmd_history_size
			unlet s:autocmd_histories[0]
		endif
	endif
	let bufname = bufname("%")
	return extend({
\		"filetype"  : &filetype,
\		"bufname"   : bufname,
\		"buftype"   : &buftype,
\		"filename"  : substitute(fnamemodify(bufname, ":p"), '\\', '/', "g"),
\		"autocmd"   : "",
\		"autocmd_history"   : s:autocmd_histories,
\		"localtime" : localtime(),
\	}, base)
endfunction



let s:matcher = {}
function! automatic#regist_matcher(name, func)
	let s:matcher[a:name] = a:func
endfunction


function! automatic#load_matcher()
	for name in map(split(globpath(&rtp, "autoload/automatic/matchers/*.vim"), "\n"), "fnamemodify(v:val, ':t:r')")
		call automatic#regist_matcher(name, function("automatic#matchers#" . name . "#is_match"))
	endfor
endfunction
call automatic#load_matcher()



function! s:matcher_autocmd(config, context)
	if empty(get(a:context, "autocmd", ""))
\	&& empty(get(a:context, "autocmd_history", []))
		return 1
	endif
	let autocmds = get(a:config, "autocmds", ["BufWinEnter"])
	let pattern  = get(a:config, "autocmd_history_pattern", "NotFound")
	return index(autocmds, get(a:context, "autocmd", "")) != -1
\		|| join(get(a:context, "autocmd_history", []), "") =~ pattern
endfunction
call automatic#regist_matcher("autocmd", function("s:matcher_autocmd"))


function! s:matcher_filetype(config, context)
	return get(a:context, "filetype", "") =~# get(a:config, "filetype", "")
endfunction
call automatic#regist_matcher("filetype", function("s:matcher_filetype"))


function! s:matcher_bufname(config, context)
	return get(a:context, "bufname", "") =~# get(a:config, "bufname", "")
endfunction
call automatic#regist_matcher("bufname", function("s:matcher_bufname"))


function! s:matcher_filename(config, context)
	let filename = get(a:context, "filename", "")
	if !filereadable(filename)
		return 1
	endif
	return filename =~# get(a:config, "filename", "")
endfunction
call automatic#regist_matcher("filename", function("s:matcher_filename"))


function! s:matcher_buftype(config, context)
	return get(a:context, "buftype", "") =~# get(a:config, "buftype", "")
endfunction
call automatic#regist_matcher("buftype", function("s:matcher_buftype"))


function! s:matcher_apply(config, context)
	if has_key(a:config, "apply")
		return a:config.apply(a:config, a:context)
	endif
	return 1
endfunction
call automatic#regist_matcher("apply", function("s:matcher_apply"))


function! s:matcher_is_open_other_window(config, context)
	if get(a:config, "is_open_other_window", 1) == 1
		return winnr("$") > 1
	elseif get(a:config, "is_open_other_window", 1) == 0
		return winnr("$") == 1
	endif
	return 1
endfunction
call automatic#regist_matcher("is_open_other_window", function("s:matcher_is_open_other_window"))


function! s:is_match_all(config, context)
	let matchlist = get(a:config, "matchlist", keys(s:matcher))
	for name in matchlist
		if !s:matcher[name](a:config, a:context)
			return 0
		endif
	endfor
	return 1
endfunction


function! automatic#is_match(match_config, context)
	return s:is_match_all(a:match_config, a:context)
endfunction




let s:setter = {}
function! automatic#regist_setter(name, func)
	let s:setter[a:name] = a:func
endfunction


function! automatic#load_setter()
	for name in map(split(globpath(&rtp, "autoload/automatic/setters/*.vim"), "\n"), "fnamemodify(v:val, ':t:r')")
		call automatic#regist_setter(name, function("automatic#setters#" . name . "#apply"))
	endfor
endfunction
call automatic#load_setter()



function! s:setter_apply(config, context)
	if has_key(a:config, "apply")
		return a:config.apply(a:config, a:context)
	endif
	return 1
endfunction
call automatic#regist_setter("apply", function("s:setter_apply"))


function! s:setter_command(config, context)
	let commands = get(a:config, "commands", [])
	for command in commands
		execute command
	endfor
endfunction
call automatic#regist_setter("command", function("s:setter_command"))





function! automatic#set_current(config, context, unsettings)
	let setlist = get(a:config, "setlist", keys(s:setter))
	for name in setlist
		if index(a:unsettings, name) == -1
			call s:setter[name](a:config, a:context)
		endif
	endfor
endfunction


let s:default_match_presets = {
\	"unite_opened" : {
\		"autocmd_history_pattern" : 'BufWinEnterFileType\(CursorMoved\|CursorMovedI\)$',
\		"filetype" : "unite",
\		"is_open_other_window" : -1,
\	},
\	"helped" : {
\		"filetype" : "help",
\		"buftype"  : "help",
\	},
\	"gui_enter" : {
\			"autocmds" : ["GUIEnter"],
\			"is_open_other_window" : 0
\	},
\}

function! automatic#get_match_preset(name)
	return get(extend(deepcopy(s:default_match_presets), g:automatic_match_presets), a:name, {})
endfunction


function! s:as_match_config(config)
	return type(a:config) == type({}) ? a:config
\		 : type(a:config) == type("") ? automatic#get_match_preset(a:config)
\		 : {}
endfunction


function! s:is_match(config, def_match, context)
	let def_match = deepcopy(a:def_match)
	let match     = s:as_match_config(get(a:config, 'match', {}))
	let preset    = deepcopy(s:as_match_config(get(match, 'preset', {})))
	return automatic#is_match(extend(def_match, extend(preset, match)), a:context)
endfunction


function! automatic#run(...)
	let context = automatic#make_current_context(get(a:, 1, {}))

	let def_conf = g:automatic_default_match_config

	let setlist = filter(deepcopy(g:automatic_config), "s:is_match(v:val, def_conf, context)")
" 	let setlist = filter(deepcopy(g:automatic_config), "automatic#is_match(extend(deepcopy(def_conf), s:as_match_config(get(v:val, 'match', {}))), context)")

	let unsettings = []
	for config in setlist
		if get(get(config, "set", {}), "unsetting", 0)
			return -1
		endif
		let unsettings = get(get(config, "set", {}), "unsettings", [])
	endfor

	let def_set = g:automatic_default_set_config
	call map(setlist, "automatic#set_current(extend(deepcopy(def_set), get(v:val, 'set', {})), context, unsettings)")
endfunction



function! automatic#close_window_for_tag(tag)
	return gift#close_window_by("index(gettabwinvar(tabnr, winnr, 'automatic_setter_tags', []), ".string(a:tag).") != -1", "execute get(w:, 'automatic_setter_close_window_cmd', 'close')")
endfunction


function! automatic#close_window_for_tag_from_current_tabpage(tag)
	return gift#close_window_by("tabpagenr() == tabnr && index(getwinvar(winnr, 'automatic_setter_tags', []), ".string(a:tag).") != -1", "execute get(w:, 'automatic_setter_close_window_cmd', 'close')")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
