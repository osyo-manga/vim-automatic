scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:move_keys = {
\	"top"    : "\<C-w>K",
\	"bottom" : "\<C-w>J",
\	"left"   : "\<C-w>H",
\	"right"  : "\<C-w>L",
\}

function! s:setter_move(config, ...)
	if !has_key(a:config, "move")
		return
	endif
	let move_key = get(s:move_keys, a:config.move, "")
	if !empty(move_key)
		execute "normal!" move_key
	endif
endfunction


function! automatic#setter#move#apply(config, ...)
	return s:setter_move(a:config)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
