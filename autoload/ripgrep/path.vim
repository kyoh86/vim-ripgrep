function! ripgrep#path#traverse_root(path, marks) abort
    " Search root directory from cwd with root-dir-names
    let l:path = s:trim_last_separator(a:path)
    if type(a:marks) != v:t_list || len(a:marks) == 0
        return [l:path, '']
    endif
    let l:found = s:traverse(l:path, '', a:marks)
    if l:found is v:null
        return [l:path, '']
    endif
    return l:found
endfunction

function! s:traverse(path, rel, marks) abort
    if a:path ==# ''
        return [a:path, a:rel]
    endif
    for l:m in a:marks
        let l:path = a:path . s:separator() . l:m
        if filereadable(l:path) || isdirectory(l:path)
            return [a:path, a:rel]
        endif
    endfor
    let l:parent = fnamemodify(a:path, ':h')
    if l:parent ==# a:path
        return v:null
    endif
    return s:traverse(l:parent, a:rel . '..' . s:separator(), a:marks)
endfunction

" Get the directory separator.
let s:sep = v:null
function! s:separator() abort
    if s:sep is v:null
        let s:sep = fnamemodify('.', ':p')[-1 :]
    endif
    return s:sep
endfunction

" Trim end the separator of a:path.
function! s:trim_last_separator(path) abort
    let l:sep = s:separator()
    let l:pat = escape(l:sep, '\') . '\+$'
    return substitute(a:path, l:pat, '', '')
endfunction

function! ripgrep#path#rel(path) abort
    return fnamemodify(a:path, ':.')
endfunction
