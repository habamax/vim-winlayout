if exists("g:loaded_winlayout") || v:version < 800
	finish
endif
let g:loaded_winlayout = 1

"XXX: How can I detect if size of a split window has been changed?
augroup winlayout | au!
	au BufEnter * :call winlayout#save()
	au WinNew,QuitPre * :call winlayout#save()
augroup end

command WinlayoutInspectLayout call winlayout#inspect_layout()
command WinlayoutInspectRestcmd call winlayout#inspect_restcmd()

nnoremap <Plug>(WinlayoutBackward) :call winlayout#restore(-1)<CR>
nnoremap <Plug>(WinlayoutForward) :call winlayout#restore(1)<CR>
