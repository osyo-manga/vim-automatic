scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:multidict()
	let self = {
\		"list" : []
\	}
	
	function! self.find_first(key)
		let i = 0
		for [key, value] in self.list
			if key >= a:key
				return i
			endif
			let i = i + 1
		endfor
		return i
	endfunction


	function! self.find_values(key)
		return map(filter(deepcopy(self.list), "v:val[0] == a:key"), "v:val[1]")
	endfunction


	function! self.insert(key, value)
		let index = self.find_first(a:key)
		call insert(self.list, [a:key, a:value], index)
	endfunction


	function! self.values()
		return map(deepcopy(self.list), "v:val[1]")
	endfunction

	function! self.clear()
		let self.list = []
	endfunction

	return self
endfunction


function! automatic#make_current_context(...)
	let base = get(a:, 1, {})
	let bufname = bufname("%")
	return extend({
\		"filetype" : &filetype,
\		"bufname"  : bufname,
\		"buftype"  : &buftype,
\		"filename" : substitute(fnamemodify(bufname, ":p"), '\\', '/', "g")
\	}, base)
endfunction



let s:matcher = {}
function! automatic#regist_matcher(name, func)
	let s:matcher[a:name] = a:func
endfunction



function! s:matcher_autocmd(config, context)
	if !has_key(a:context, "autocmd")
		return 1
	endif
	let autocmd = get(a:config, "autocmds", ["BufWinEnter"])
	return index(autocmd, a:context.autocmd) != -1
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
	for name in map(split(globpath(&rtp, "autoload/automatic/setter/*.vim"), "\n"), "fnamemodify(v:val, ':t:r')")
		call automatic#regist_setter(name, function("automatic#setter#" . name . "#apply"))
	endfor
endfunction
call automatic#load_setter()


function! s:setter_resize(config)
	if has_key(a:config, "height")
		execute "resize" a:config.height
	endif

	if has_key(a:config, "width")
		execute "vertical resize" a:config.width
	endif
endfunction
call automatic#regist_setter("resize", function("s:setter_resize"))


function! s:setter_move(config)
	if !has_key(a:config, "move")
		return
	endif
	let move_keys = {
\		"top"    : "\<C-w>K",
\		"bottom" : "\<C-w>J",
\		"left"   : "\<C-w>H",
\		"right"  : "\<C-w>L",
\	}
	
	let move_key = get(move_keys, a:config.move, "")
	if !empty(move_key)
		execute "normal!" move_key
	endif
endfunction
call automatic#regist_setter("move", function("s:setter_move"))


function! s:setter_apply(config)
	if has_key(a:config, "apply")
		return a:config.apply(a:config)
	endif
	return 1
endfunction
call automatic#regist_setter("apply", function("s:setter_apply"))


function! s:setter_command(config)
	let commands = get(a:config, "commands", [])
	for command in commands
		execute command
	endfor
endfunction
call automatic#regist_setter("command", function("s:setter_command"))





function! automatic#set_current(config)
	let setlist = get(a:config, "setlist", keys(s:setter))
	for name in setlist
		call s:setter[name](a:config)
	endfor
endfunction




function! automatic#run(...)
	let context = automatic#make_current_context(get(a:, 1, {}))
	let setlist = filter(deepcopy(g:automatic_config), "automatic#is_match(v:val.match, context)")
	for config in setlist
		if get(config.set, "unsetting", 0)
			return -1
		endif
	endfor
	call map(setlist, "automatic#set_current(v:val.set)")
" 	call map(filter(deepcopy(g:automatic_config), "automatic#is_match(v:val.match, context)"), "automatic#set_current(v:val.set)")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
