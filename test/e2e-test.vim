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
    call system('echo ' . "'" . '{"type":"match","data":{"path":{"text":"test/e2e-test.vim"},"lines":{"text":"pseudo"},"line_number":11,"submatches":[{"start":13,"end":17}]}}' . "' > " . s:tempname . '/cat.txt')
endfunction

function s:suite.after()
    call delete(s:tempname, 'rf')
endfunction

function s:suite.parallelly()
    let l:exec = []
    let l:count = 1
    while l:count < 100
        call add(l:exec, 'cat ' . s:tempname . '/cat.txt')
        let l:count = l:count + 1
    endwhile
    let g:ripgrep#executable =
                \ 'bash -c "sleep 1 && ' . join(l:exec, " && ") . ' && sleep 1 && cat ' . s:tempname . '/cat.txt"'
    call setqflist([], 'r')
    call ripgrep#search('pseudo')
    call ripgrep#wait(1500)
    call s:assert.not_equals(0, len(getqflist()), 'has any items in quickfix list')
endfunction
