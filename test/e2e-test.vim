let s:suite = themis#suite('E2E test for ripgrep')
let s:assert = themis#helper('assert')

function s:suite.after_each()
    cclose
    call setqflist([], ' ')
    bufdo bwipeout!
endfunction

function s:suite.test_not_found()
    call ripgrep#search("foo" . "bar" . "baz" . "pseudo" . "never" . "found")
    call ripgrep#wait(1000)
    echo s:assert.length_of(getqflist(), 0, 'quickfix list is empty')
endfunction

function s:suite.test_found()
    call ripgrep#search('foobarbafoobarbazzfoobarbaz test') " TARGET LINE
    " TARGET COLUMN -----^
    "                      TARGET END COLUMN -------^
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')
    let l:first = l:result[0]
    call s:assert.equals(l:first['lnum'], 17, "TARGET LINE")
    call s:assert.equals(l:first['col'], 26, "TARGET COLUMN")
    if has_key(l:first, 'end_col')
        call s:assert.equals(l:first['end_col'], 53, "TARGET END COLUMN")
    endif
endfunction
