let s:suite = themis#suite('test for ripgrep#line')
let s:assert = themis#helper('assert')

function! s:suite.parse_empty()
    let l:from = ''
    let l:want = [g:ripgrep#event#raw, {'raw': ''}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.bared_value()
    let l:from = '0'
    let l:want = [g:ripgrep#event#raw, {'raw': '0'}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.begin_line()
    let l:from = '{"type":"begin","data":{"path":{"text":"test-filename"}}}'
    let l:want = [g:ripgrep#event#file_begin, {'filename': 'test-filename'}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.end_line()
    let l:from = '{"type":"end","data":{"path":{"text":"test-filename"},"stats":"stats-value"}}'
    let l:want = [g:ripgrep#event#file_end, {'filename': 'test-filename', 'stats': 'stats-value'}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.match_line()
    let l:from = '{"type":"match","data":{"path":{"text":"test-filename"},"lines":{"text":"test-lines"},"line_number":2,"submatches":[{"start":3,"end":4}]}}'
    let l:want = [g:ripgrep#event#match, {'filename': 'test-filename', 'text': 'test-lines', 'lnum': 2, 'col': 4, 'end_col': 5}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.match_binary()
    " base64: 'Zml6eg==' => text: 'fizz'
    let l:from = '{"type":"match","data":{"path":{"text":"test-filename"},"lines":{"bytes":"Zml6eg=="},"line_number":2,"submatches":[{"start":3,"end":4}]}}'
    let l:want = [g:ripgrep#event#match, {'filename': 'test-filename', 'text': 'fizz', 'lnum': 2, 'col': 4, 'end_col': 5}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.other_line()
    let l:from = '{"foo":"bar","bar":17}'
    let l:want = [g:ripgrep#event#other, {'foo': 'bar', 'bar': 17}]
    let l:got = ripgrep#line#parse(l:from)
    call s:assert.equals(l:want, l:got)
endfunction

function! s:suite.decode_base64_foo()
    let l:from = 'Zm9v'
    let l:want = 'foo'
    let l:got = ripgrep#line#decode_base64(l:from)
    call s:assert.equals(l:got, l:want)
endfunction

function! s:suite.decode_base64_fizz()
    let l:from = 'Zml6eg=='
    let l:want = 'fizz'
    let l:got = ripgrep#line#decode_base64(l:from)
    call s:assert.equals(l:got, l:want)
endfunction
