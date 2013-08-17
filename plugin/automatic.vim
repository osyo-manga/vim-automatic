scriptencoding utf-8
if exists('g:loaded_automatic')
  finish
endif
let g:loaded_automatic = 1

let s:save_cpo = &cpo
set cpo&vim


let g:automatic_config = get(g:, "automatic_config", [])
let g:automatic_default_match_config = get(g:, "automatic_default_match_config", {})
let g:automatic_default_set_config = get(g:, "automatic_default_set_config", {})

augroup automatic
	autocmd!
	autocmd BufWinEnter * call automatic#run({"autocmd" : "BufWinEnter"})
	autocmd WinEnter    * call automatic#run({"autocmd" : "WinEnter"})
	autocmd WinLeave    * call automatic#run({"autocmd" : "WinLeave"})
	autocmd FileType    * call automatic#run({"autocmd" : "FileType"})
	autocmd CmdwinEnter * call automatic#run({"autocmd" : "CmdwinEnter"})
	autocmd CmdwinLeave * call automatic#run({"autocmd" : "CmdwinLeave"})
	autocmd VimEnter    * call automatic#run({"autocmd" : "VimEnter"})
	autocmd GUIEnter    * call automatic#run({"autocmd" : "GUIEnter"})
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

	function! task.apply(id)
		echom "apply"
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


augroup automatic-bufwinenter-future
	autocmd!
	autocmd User BufWinEnterCursorHold execute ""
	autocmd BufWinEnter *
\		if get(g:automatic_enable_autocmd_Futures, "BufWinEnterFuture", 0)
\|			call s:future("BufWinEnterFuture")
\|		endif

augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
