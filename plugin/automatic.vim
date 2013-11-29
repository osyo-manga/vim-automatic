scriptencoding utf-8
if exists('g:loaded_automatic')
  finish
endif
let g:loaded_automatic = 1

let s:save_cpo = &cpo
set cpo&vim


let g:automatic_config               = get(g:, "automatic_config", [])
let g:automatic_default_match_config = get(g:, "automatic_default_match_config", {})
let g:automatic_default_set_config   = get(g:, "automatic_default_set_config", {})
let g:autocmd_history_size           = get(g:, "autocmd_history_size", 20)
let g:automatic_match_presets        = get(g:, "automatic_match_presets ", {})

let s:autocmds = [
\	"BufWinEnter",
\	"BufWinLeave",
\	"WinEnter",
\	"WinLeave",
\	"FileType",
\	"CmdwinEnter",
\	"CmdwinLeave",
\	"VimEnter",
\	"GUIEnter",
\	"CursorMoved",
\	"CursorMovedI",
\	"QuitPre",
\]

augroup automatic
	autocmd!
	for s:autocmd in s:autocmds
		if exists("##" . s:autocmd)
		execute "autocmd" s:autocmd '* call automatic#run({"autocmd" : ' . string(s:autocmd) . '})'
	endif
	endfor
	autocmd User BufWinEnterFuture call automatic#run({"autocmd" : "BufWinEnterFuture"})
augroup END




let g:automatic_enable_autocmd_Futures = get(g:, "automatic_enable_autocmd_Futures", {})


let s:check_future = {}
function! s:future(cmd)
	if get(s:check_future, a:cmd, 0)
		return
	endif

	let s:check_future[a:cmd] = 1
" 	echom "future"
" 	echom "s:check :" . s:check
" 	echom "updatetime :" . &updatetime

	let task = {
\		"updatetime" : &updatetime,
\		"doautocmd" : a:cmd
\	}

	function! task.apply(...)
" 		echom "apply"
		execute "doautocmd <nomodeline> User " . self.doautocmd
	endfunction

	function! task.kill()
" 		echom "kill"
" 		echom "updatetime :" . &updatetime
" 		echom "self.updatetime :" . self.updatetime
		if self.updatetime != 1
			let &updatetime = self.updatetime
		endif
		let s:check_future[self.doautocmd] = 0
	endfunction

	let id = reunions#task_once(task)
	set updatetime=1
endfunction


augroup automatic-future
	autocmd!
	autocmd User BufWinEnterCursorHold execute ""
	autocmd BufWinEnter *
\		if get(g:automatic_enable_autocmd_Futures, "BufWinEnterFuture", 0)
\|			call s:future("BufWinEnterFuture")
\|		endif

augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
