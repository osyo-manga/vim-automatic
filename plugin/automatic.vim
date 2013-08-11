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
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
