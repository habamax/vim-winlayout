if exists("g:loaded_winlayout") || v:version < 800
	finish
endif
let g:loaded_winlayout = 1

augroup winlayout | au!
	au BufEnter * :call winlayout#save()
	au WinNew * :call winlayout#save()
	au QuitPre * :call winlayout#save()
augroup end

command WinlayoutInspectLayout call winlayout#inspect_layout()
command WinlayoutInspectRestcmd call winlayout#inspect_restcmd()

nnoremap <silent> <Plug>(WinlayoutBackward) :silent call winlayout#restore(-1)<CR>
nnoremap <silent> <Plug>(WinlayoutForward) :silent call winlayout#restore(1)<CR>
