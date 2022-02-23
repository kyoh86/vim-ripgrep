let s:suite = themis#suite('E2E test for ripgrep')
let s:assert = themis#helper('assert')

function s:suite.test_not_found()
    call setqflist([], 'r')
    call ripgrep#search("foo" . "bar" . "baz" . "pseudo" . "never" . "found")
    call ripgrep#wait(1000)
    echo s:assert.length_of(getqflist(), 0, 'quickfix list is empty')
endfunction

function s:suite.test_found()
    call setqflist([], 'r')
    call ripgrep#search('foofoofoofoofoofoofoofoofoo test') " TARGET LINE
    " TARGET COLUMN -----^
    "                      TARGET END COLUMN -------^
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')
    let l:first = l:result[0]
    call s:assert.equals(l:first['lnum'], 13, "TARGET LINE")
    call s:assert.equals(l:first['col'], 26, "TARGET COLUMN")
    if has_key(l:first, 'end_col')
        call s:assert.equals(l:first['end_col'], 53, "TARGET END COLUMN")
    endif
endfunction

let s:tempname = tempname()

function s:suite.before()
    call mkdir(s:tempname, 'p')
    call system('echo ' . "'" . '{"type":"match","data":{"path":{"text":"test/e2e-test.vim"},"lines":{"text":"pseudo"},"line_number":11,"submatches":[{"start":13,"end":17}]}}' . "' > " . s:tempname . '/cat1.txt')
    call system('echo ' . "'" . '{"type":"match","data":{"path":{"text":"test/e2e-test.vim"},"lines":{"text":"pseudo"},"line_number":19,"submatches":[{"start":23,"end":29}]}}' . "' > " . s:tempname . '/cat2.txt')
endfunction

function s:suite.after()
    call delete(s:tempname, 'rf')
endfunction

function s:suite.parallelly()
    let g:ripgrep#executable =
                \ 'unbuffer bash -c "sleep 1 && cat ' . s:tempname . '/cat1.txt && sleep 1 && cat ' . s:tempname . '/cat2.txt'
    call setqflist([], 'r')
    call ripgrep#search('pseudo')
    call ripgrep#wait(1500)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')
    let l:first = l:result[0]
    call s:assert.equals(l:first['lnum'], 11)
    call s:assert.equals(l:first['col'], 14)
    if has_key(l:first, 'end_col')
        call s:assert.equals(l:first['end_col'], 18, "TARGET END COLUMN")
    endif
endfunction
