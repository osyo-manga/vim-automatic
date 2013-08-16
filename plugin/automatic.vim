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



let g:automatic_enable_BufWinEnterFuture = get(g:, "automatic_enable_BufWinEnterFuture", 0)

let s:check = 0
function! s:future(cmd)
	if s:check
		return
	endif
	let s:check = 1

	let task = {
\		"updatetime" : &updatetime,
\		"doautocmd" : a:cmd
\	}
	function! task.apply(id)
		call reunions#taskkill(a:id)
		if self.updatetime != 1
			let &updatetime = self.updatetime
		endif
		execute "doautocmd <nomodeline> User " . self.doautocmd
		let s:check = 0
	endfunction
	call reunions#task(task)
	set updatetime=1
endfunction

augroup automatic-bufwinenter-future
	autocmd!
	autocmd User BufWinEnterCursorHold execute ""
	autocmd BufWinEnter * 
\		if g:automatic_enable_BufWinEnterFuture
\|			call s:future("BufWinEnterFuture")
\|		endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
