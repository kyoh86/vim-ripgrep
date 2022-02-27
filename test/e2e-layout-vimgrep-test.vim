" for comparison

let s:suite = themis#suite('vimgrep layout test for comparison')
let s:assert = themis#helper('assert')

let s:tempname = tempname()

function s:suite.before_each()
    call mkdir(s:tempname, 'p')

    execute 'cd ' . s:tempname

    " prepare files
    edit found.txt
    let s:found_bufnr = bufnr()
    call setline(1, 'match: foo')
    write!

    edit opening-1.txt
    let s:opening1_bufnr = bufnr()
    call setline(1, 'never match line')
    write!

    " NOTE: RIGHTBELOW
    rightbelow vnew opening-2.txt
    let s:opening2_bufnr = bufnr()
    call setline(1, 'never match line')
    write!

    " check layout (['row', [['leaf', win_getid()], ['leaf', xxxx]]])
    " +-------+-------+
    " |       | focus |
    " | open1 | open2 |
    " +-------+-------+
    let l:layout = winlayout()
    call s:assert.equals(l:layout[0], 'row', "horizontal layout")
    call s:assert.length_of(l:layout[1], 2, "there are two columns")
    call s:assert.equals(l:layout[1][0], ['leaf', bufwinid(s:opening1_bufnr)], "opening-1.txt is opened on left window")
    call s:assert.equals(l:layout[1][1], ['leaf', bufwinid(s:opening2_bufnr)], "opening-2.txt is opened on right window")
    call s:assert.equals(l:layout[1][1], ['leaf', win_getid()], "focused on right window")
endfunction

function s:suite.after_each()
    execute "cd -"
    cclose
    call setqflist([], ' ')
    bufdo bwipeout!
    call delete(s:tempname, 'rf')
endfunction

function s:suite.test_layout_by_vimgrep_with_copen()
    " action (vimgrep for comparison)
    vimgrep /foo/j ./found.txt
    copen

    " +-------+-------+
    " |       | open2 |
    " |       |       |
    " + open1 +-------+
    " |       | qfix  |
    " |       | focus |
    " +-------+-------+

    " save window-id
    let l:w_left = bufwinid(s:opening1_bufnr)
    let l:w_right_above = bufwinid(s:opening2_bufnr)
    let l:w_right_below = win_getid()

    " move to left
    wincmd h

    " re-action
    vimgrep /foo/j ./found.txt
    copen " <================================ diff

    " open first result
    .cc

    " check
    call s:assert.equals(bufwinid(s:found_bufnr), l:w_left, "found result may be shown on left window")
    call s:assert.equals(win_getid(), l:w_left, "focus on left window")
endfunction


function s:suite.test_layout_by_vimgrep_without_copen()
    " action (vimgrep for comparison)
    vimgrep /foo/j ./found.txt
    copen

    " save window-id
    let l:w_left = bufwinid(s:opening1_bufnr)
    let l:w_right_above = bufwinid(s:opening2_bufnr)
    let l:w_right_below = win_getid()

    " move to left
    wincmd h

    " re-action
    vimgrep /foo/j ./found.txt

    " open first result
    .cc

    " check
    call s:assert.equals(bufwinid(s:found_bufnr), l:w_left, "found result may be shown on left window")
    call s:assert.equals(win_getid(), l:w_left, "focus on left window")
endfunction
