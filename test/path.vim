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
    let l:want_0 = s:tempname . '/parent'
    let l:want_1_pattern = '\.\.[/\\]'
    let l:got = ripgrep#path#traverse_root(l:from, ['mark'])
    call s:assert.is_list(l:got)
    call s:assert.length_of(l:got, 2)
    call s:assert.equals(l:want_0, l:got[0])
    call s:assert.match(l:got[1], l:want_1_pattern)
endfunction

function s:suite.test_traverse_second_mark()
    let l:from = s:tempname . '/ancestor/parent/child'
    let l:want_0 = s:tempname . '/ancestor'
    let l:want_1_pattern = '\.\.[/\\]\.\.[/\\]'
    let l:got = ripgrep#path#traverse_root(l:from, ['pseudo-mark', 'mark'])
    call s:assert.is_list(l:got)
    call s:assert.length_of(l:got, 2)
    call s:assert.equals(l:want_0, l:got[0])
    call s:assert.match(l:got[1], l:want_1_pattern)
endfunction

function s:suite.test_traverse_not_found()
    let l:from = s:tempname . '/ancestor/parent/child'
    let l:want = [l:from, '']
    let l:got = ripgrep#path#traverse_root(l:from, ['pseudo-mark'])
    call s:assert.equals(l:got, l:want)
endfunction
