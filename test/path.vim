let s:suite = themis#suite('test for ripgrep#path')
let s:assert = themis#helper('assert')

let s:tempname = tempname()

function s:suite.before()
    call mkdir(s:tempname, 'p')
    call mkdir(s:tempname . '/current/mark', 'p')
    call mkdir(s:tempname . '/parent/child', 'p')
    call mkdir(s:tempname . '/parent/mark', 'p')
    call mkdir(s:tempname . '/ancestor/parent/child', 'p')
    call mkdir(s:tempname . '/ancestor/mark', 'p')
endfunction

function s:suite.after()
    call delete(s:tempname, 'rf')
endfunction

function s:suite.test_traverse_current()
    let l:from = s:tempname . '/current'
    let l:want = [l:from, '']
    let l:got = ripgrep#path#traverse_root(l:from, ['mark'])
    call s:assert.equals(l:got, l:want)
endfunction

function s:suite.test_traverse_parent()
    let l:from = s:tempname . '/parent/child'
    let l:want = [s:tempname . '/parent', '../']
    let l:got = ripgrep#path#traverse_root(l:from, ['mark'])
    call s:assert.equals(l:got, l:want)
endfunction

function s:suite.test_traverse_second_mark()
    let l:from = s:tempname . '/ancestor/parent/child'
    let l:want = [s:tempname . '/ancestor', '../../']
    let l:got = ripgrep#path#traverse_root(l:from, ['pseudo-mark', 'mark'])
    call s:assert.equals(l:got, l:want)
endfunction

function s:suite.test_traverse_not_found()
    let l:from = s:tempname . '/ancestor/parent/child'
    let l:want = [l:from, '']
    let l:got = ripgrep#path#traverse_root(l:from, ['pseudo-mark'])
    call s:assert.equals(l:got, l:want)
endfunction
