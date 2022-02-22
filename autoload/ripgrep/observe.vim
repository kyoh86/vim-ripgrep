let s:observers = {}

function! ripgrep#observe#add_observer(name, func)
    if !has_key(s:observers, a:name)
        let s:observers[a:name] = []
    endif
    let func = type(a:func) == 2 ? string(a:func) : a:func
    if len(filter(copy(s:observers[a:name]), 'v:val==func')) == 0
        call add(s:observers[a:name], a:func)
    endif
endfunction

function! ripgrep#observe#notify(name, ...)
    if has_key(s:observers, a:name)
        for l:F in s:observers[a:name]
            try
                call call(l:F, a:000)
            catch
            endtry
        endfor
    endif
endfunction
