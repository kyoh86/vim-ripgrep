function! ripgrep#parse#jsonl(line) abort
    " Parse json-line from ripgrep (with --json option) to qf-list item.
    try
        let l:prof = json_decode(a:line)
    catch
        return v:null
    endtry

    let l:type = get(l:prof, 'type', '')
    if l:type ==# 'begin'
        return s:parse_begin(l:prof['data'])
    elseif l:type ==# 'match'
        return s:parse_match(l:prof['data'])
    endif
endfunction

function! s:parse_begin(begin) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:filename = a:begin['path']['text']
    call ripgrep#observe#notify("file", l:filename)
    return v:null
endfunction

function! s:parse_match(match) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:filename = a:match['path']['text']
    let l:linetext = a:match['lines']['text']
    let l:lnum = a:match['line_number']
    let l:submatches = a:match['submatches']
    let l:start = l:submatches[0]['start']
    let l:end = l:submatches[0]['end']
    let l:item = {
        \ 'filename': l:filename,
        \ 'lnum': l:lnum,
        \ 'col': l:start,
        \ 'end_col': l:end,
        \ 'text': l:linetext,
    \ }
    call ripgrep#observe#notify("match", l:item)
    return l:item
endfunction
