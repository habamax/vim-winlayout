if exists("g:loaded_winlayout") || v:version < 800
	finish
endif
let g:loaded_winlayout = 1

"XXX: How can I detect if size of a split window has been changed?
augroup winlayout | au!
	au BufEnter * :call winlayout#save("BufEnter")
	au WinNew * :call winlayout#save("WinNew")
	au QuitPre * :call winlayout#save("QuitPre")
augroup end

command WinlayoutInspectLayout call winlayout#inspect_layout()
command WinlayoutInspectRestcmd call winlayout#inspect_restcmd()

nnoremap <silent> <Plug>(WinlayoutBackward) :silent call winlayout#restore(-1)<CR>
nnoremap <silent> <Plug>(WinlayoutForward) :silent call winlayout#restore(1)<CR>
