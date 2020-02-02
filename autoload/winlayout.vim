let s:winlayout_max = get(g:, "winlayout_max", 20)
let s:winlayout_index = -1
let s:layouts=[]
let s:resize_cmds=[]
let s:cursors=[]

"" shouldn't save layout if it is being restored
let s:is_restoring_layout = v:false

func! winlayout#inspect_layout() abort
	let @* = json_encode(s:layouts)
	echom @*
endfunc
func! winlayout#inspect_restcmd() abort
	let @* = json_encode(s:resize_cmds)
	echom @*
endfunc

func! winlayout#save() abort
	if s:is_restoring_layout
		return
	endif

	let l:restcmd = winrestcmd()
	let l:layout = winlayout()
	let l:cursor = getcurpos()
	call s:add_buf_to_layout(l:layout)
	" Do nothing if layout and sizes are the same as previous
	if !empty(s:layouts) && l:layout == s:layouts[-1] && l:restcmd == s:resize_cmds[-1]
		return
	endif

	call add(s:layouts, l:layout)
	call add(s:resize_cmds, l:restcmd)
	call add(s:cursors, [winnr(), l:cursor])

	" Keep only g:winlayout_max layouts
	if len(s:layouts) > s:winlayout_max
		call remove(s:layouts, 0)
		call remove(s:resize_cmds, 0)
		call remove(s:cursors, 0)
	endif

	let s:winlayout_index = len(s:layouts) - 1
endfunc


" add bufnr to leaf
func! s:add_buf_to_layout(layout) abort
	if a:layout[0] ==# 'leaf'
		" replace win_id with buffer number
		let a:layout[1] = winbufnr(a:layout[1])
	else
		for child_layout in a:layout[1]
			call s:add_buf_to_layout(child_layout)
		endfor
	endif
endfunc

func! winlayout#restore(direction) abort
	let s:is_restoring_layout = v:true
	try
		if empty(s:layouts)
			return
		endif

		let s:winlayout_index += a:direction
		if s:winlayout_index < 0 
			let s:winlayout_index = 0
			return
		endif
		if s:winlayout_index >= len(s:layouts)
			let s:winlayout_index = len(s:layouts) - 1
			return
		endif

		
		" Close other windows
		silent wincmd o

		" recursively restore buffers
		call s:apply_layout(s:layouts[s:winlayout_index])

		" resize
		exe s:resize_cmds[s:winlayout_index]

		" goto saved window
		exe printf("%dwincmd w", s:cursors[s:winlayout_index][0])
		
		" set cursor
		call setpos('.', s:cursors[s:winlayout_index][1])

	finally
		let s:is_restoring_layout = v:false
	endtry

endfunc

func! s:apply_layout(layout) abort

	if a:layout[0] ==# 'leaf'

		" load buffer for leaf
		if bufexists(a:layout[1])
			exe printf('b %d', a:layout[1])
		endif
	else

		" split cols or rows, split n-1 times
		let split_method = a:layout[0] ==# 'col' ? 'rightbelow split' : 'rightbelow vsplit'
		let wins = [win_getid()]
		for child_layout in a:layout[1][1:]
			exe split_method
			let wins += [win_getid()]
		endfor

		" recursive into child windows
		for index in range(len(wins) )
			call win_gotoid(wins[index])
			call s:apply_layout(a:layout[1][index])
		endfor

	endif
endfunc


