" line.vim
"
" Functions to process output lines from rg --json

function! ripgrep#line#parse(rel, line, stderr) abort
    " Parse json-line from ripgrep (with --json option) to qf-list item.
    let l:line_object = v:null
    try
        let l:line_object = json_decode(a:line)
    catch
    endtry

    if type(l:line_object) != v:t_dict
        if a:stderr
            call ripgrep#observe#notify('rawerror', {'line': a:line})
        else
            call ripgrep#observe#notify('raw', {'line': a:line})
        endif
        return v:null
    endif

    let l:type = get(l:line_object, 'type', '')
    if a:stderr
        return s:process_error(l:line_object)
    elseif l:type ==# 'begin'
        return s:process_begin(a:rel, l:line_object)
    elseif l:type ==# 'match'
        return s:process_match(a:rel, l:line_object)
    else
        return s:process_other(l:line_object)
    endif
endfunction

function! s:process_error(line_object) abort
    call ripgrep#observe#notify('error', a:line_object)
    return v:null
endfunction

function! s:process_other(line_object) abort
    call ripgrep#observe#notify('other', a:line_object)
    return v:null
endfunction

function! s:process_begin(rel, line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:begin = a:line_object['data']
    let l:filename = l:begin['path']['text']
    call ripgrep#observe#notify('file', {'filename': ripgrep#path#rel(a:rel . l:filename)})
    return v:null
endfunction

function! s:process_match(rel, line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:match =  a:line_object['data']
    let l:filename = l:match['path']['text']
    let l:linetext = l:match['lines']['text']
    let l:lnum = l:match['line_number']
    let l:submatches = l:match['submatches']
    " The start is based 0.
    let l:start = l:submatches[0]['start'] + 1
    let l:end = l:submatches[0]['end'] + 1
    call ripgrep#observe#notify('match', {
        \ 'filename': ripgrep#path#rel(a:rel . l:filename),
        \ 'lnum': l:lnum,
        \ 'col': l:start,
        \ 'end_col': l:end,
        \ 'text': l:linetext,
    \ })
    return v:null
endfunction
