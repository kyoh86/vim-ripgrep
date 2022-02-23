let s:observers = {}

function! ripgrep#observe#add_observer(name, observer) abort
    if !has_key(s:observers, a:name)
        let s:observers[a:name] = []
    endif
    let l:o = a:observer
    if len(filter(copy(s:observers[a:name]), {o -> o ==# l:o})) == 0
        call add(s:observers[a:name], l:o)
    endif
endfunction

function! ripgrep#observe#notify(name, ...) abort
    if !has_key(s:observers, a:name)
        return
    endif
    for l:O in s:observers[a:name]
        try
            call call(l:O, a:000)
        catch
            echo v:exception
        endtry
    endfor
endfunction
