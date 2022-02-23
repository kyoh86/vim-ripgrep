let s:suite = themis#suite('E2E test for ripgrep')
let s:assert = themis#helper('assert')

function s:suite.test_not_found()
    call setqflist([], 'r')
    call ripgrep#search("foo\rbar\rbaz")
    call ripgrep#wait()
    echo s:assert.length_of(getqflist(), 0)
endfunction

function s:suite.test_found()
    call setqflist([], 'r')
    call ripgrep#search('foobarbafoobarbazzfoobarbaz') " TARGET LINE
    " TARGET COLUMN -----^
    "                      TARGET END COLUMN-------^
    call ripgrep#wait()
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1)
    call s:assert.equals(l:result[0]['lnum'], 13, "TARGET LINE")
    call s:assert.equals(l:result[0]['col'], 25, "TARGET COLUMN")
    call s:assert.equals(l:result[0]['end_col'], 52, "TARGET END COLUMN")
endfunction
