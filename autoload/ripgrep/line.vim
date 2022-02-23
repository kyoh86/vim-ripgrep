" line.vim
"
" Functions to process output lines from rg --json

function! ripgrep#line#parse(line) abort
    " Parse json-line from ripgrep (with --json option) to qf-list item.
    let l:line_object = v:null
    try
        let l:line_object = json_decode(a:line)
    catch
    endtry

    if type(l:line_object) != v:t_dict
        return [g:ripgrep#event#raw, {'raw': a:line}]
    endif

    let l:type = get(l:line_object, 'type', '')
    if l:type ==# 'begin'
        return s:process_begin(l:line_object)
    elseif l:type ==# 'match'
        return s:process_match(l:line_object)
    elseif l:type ==# 'end'
        return s:process_end(l:line_object)
    else
        return [g:ripgrep#event#other, l:line_object]
    endif
endfunction

function! s:process_begin(line_object) abort
    " Parse beginning of file from ripgrep.
    let l:begin = a:line_object['data']
    let l:filename = l:begin['path']['text']
    return [g:ripgrep#event#file_begin, {'filename': l:filename}]
endfunction

function! s:process_end(line_object) abort
    " Parse ending of file from ripgrep.
    let l:end = a:line_object['data']
    let l:filename = l:end['path']['text']
    return [g:ripgrep#event#file_end, {'filename': l:filename, 'stats': l:end['stats']}]
endfunction

function! s:process_match(line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:match =  a:line_object['data']
    let l:filename = l:match['path']['text']
    let l:linetext = l:match['lines']['text']
    let l:lnum = l:match['line_number']
    let l:submatches = l:match['submatches']
    " The start is based 0.
    let l:start = l:submatches[0]['start'] + 1
    let l:end = l:submatches[0]['end'] + 1
    return [
        \ g:ripgrep#event#match, {
            \ 'filename': l:filename,
            \ 'lnum': l:lnum,
            \ 'col': l:start,
            \ 'end_col': l:end,
            \ 'text': l:linetext,
        \ }
    \ ]
endfunction
