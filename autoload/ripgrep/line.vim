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
    let l:filename = s:process_textlike(l:begin['path'])
    if l:filename is v:null
        return [g:ripgrep#event#other, a:line_object]
    endif
    return [g:ripgrep#event#file_begin, {'filename': l:filename}]
endfunction

function! s:process_end(line_object) abort
    " Parse ending of file from ripgrep.
    let l:end = a:line_object['data']
    let l:filename = s:process_textlike(l:end['path'])
    if l:filename is v:null
        return [g:ripgrep#event#other, a:line_object]
    endif
    return [g:ripgrep#event#file_end, {'filename': l:filename, 'stats': l:end['stats']}]
endfunction

function! s:process_match(line_object) abort
    " Parse match-data from ripgrep to qf-list item.
    let l:match =  a:line_object['data']
    let l:filename = s:process_textlike(l:match['path'])
    if l:filename is v:null
        return [g:ripgrep#event#other, a:line_object]
    endif
    let l:lnum = l:match['line_number']
    let l:submatches = l:match['submatches']
    " The start is based 0.
    let l:start = l:submatches[0]['start'] + 1
    let l:end = l:submatches[0]['end'] + 1


    let l:linetext = s:process_textlike(l:match['lines'])
    if l:linetext is v:null
        return [g:ripgrep#event#other, a:line_object]
    end
    let l:linetext = trim(l:linetext, "\n", 2)
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

function! s:process_textlike(textlike) abort
    " Decode an object like a text:
    "   - (text): {'text':'value'}  (raw string)
    "   - (text): {'bytes':"Zml6eg=="}  (base 64 encoded)
    if has_key(a:textlike, 'text')
        return a:textlike['text']
    elseif has_key(a:textlike, 'bytes')
        return ripgrep#line#decode_base64(a:textlike['bytes'])
    else
        return v:null
    end
endfunction

let s:base64_table = [
      \ 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
      \ 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
      \ '0','1','2','3','4','5','6','7','8','9','+','/']
let s:base64_pad = '='

let s:base64_atoi_table = {}
function! s:decode_base64_atoi(a) abort
    if len(s:base64_atoi_table) == 0
        for l:i in range(len(s:base64_table))
            let s:base64_atoi_table[s:base64_table[l:i]] = l:i
        endfor
    endif
    return s:base64_atoi_table[a:a]
endfunction

function! ripgrep#line#decode_base64(seq) abort
    let l:res = ''
    for l:i in range(0, len(a:seq) - 1, 4)
        let l:n = s:decode_base64_atoi(a:seq[l:i]) * 0x40000
            \ + s:decode_base64_atoi(a:seq[l:i + 1]) * 0x1000
            \ + (a:seq[l:i + 2] == s:base64_pad ? 0 : s:decode_base64_atoi(a:seq[l:i + 2])) * 0x40
            \ + (a:seq[l:i + 3] == s:base64_pad ? 0 : s:decode_base64_atoi(a:seq[l:i + 3]))
        let l:res = s:add_str(l:res, l:n / 0x10000)
        let l:res = s:add_str(l:res, l:n / 0x100 % 0x100)
        let l:res = s:add_str(l:res, l:n % 0x100)
    endfor
    return eval('"' . l:res . '"')
endfunction

function! s:add_str(left, right) abort
    if a:right == 0
        return a:left
    endif
    return a:left . printf("\\x%02x", a:right)
endfunction
