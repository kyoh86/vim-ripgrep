let s:suite = themis#suite('E2E test for ripgrep')
let s:assert = themis#helper('assert')

function s:suite.test_not_found()
    call setqflist([], 'r')
    call ripgrep#search("foo\rbar\rbaz test")
    call ripgrep#wait()
    echo s:assert.length_of(getqflist(), 0)
endfunction

function s:suite.test_found()
    call setqflist([], 'r')
    call ripgrep#search('foobarbafoobarbazzfoobarbaz test') " TARGET LINE
    " TARGET COLUMN -----^
    "                      TARGET END COLUMN-------^
    call ripgrep#wait()
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1)
    let l:first = l:result[0]
    call s:assert.equals(l:first['lnum'], 13, "TARGET LINE")
    call s:assert.equals(l:first['col'], 25, "TARGET COLUMN")
    if has_key(l:first, 'end_col')
        call s:assert.equals(l:first['end_col'], 52, "TARGET END COLUMN")
    endif
endfunction
