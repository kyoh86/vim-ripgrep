function! ripgrep#parse#jsonl_suspected(line, stderr) abort
    " Parse json-line from ripgrep (with --json option) to qf-list item.
    try
        let l:line_object = json_decode(a:line)
    catch
    endtry

    if type(l:line_object) != v:t_dict
        if a:stderr
            call ripgrep#observe#notify('errline', a:line)
        else
            call ripgrep#observe#notify('rawline', a:line)
        endif
        return v:null
    endif

    let l:type = get(l:line_object, 'type', '')
    if a:stderr
        return s:process_error(l:line_object)
    elseif l:type ==# 'begin'
        return s:process_begin(l:line_object)
    elseif l:type ==# 'match'
        return s:process_match(l:line_object)
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

function! s:process_begin(line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:begin = a:line_object['data']
    let l:filename = l:begin['path']['text']
    call ripgrep#observe#notify('file', l:filename)
    return v:null
endfunction

function! s:process_match(line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:match =  a:line_object['data']
    let l:filename = l:match['path']['text']
    let l:linetext = l:match['lines']['text']
    let l:lnum = l:match['line_number']
    let l:submatches = l:match['submatches']
    let l:start = l:submatches[0]['start']
    let l:end = l:submatches[0]['end']
    call ripgrep#observe#notify('match', {
        \ 'filename': l:filename,
        \ 'lnum': l:lnum,
        \ 'col': l:start,
        \ 'end_col': l:end,
        \ 'text': l:linetext,
    \ })
    return v:null
endfunction
