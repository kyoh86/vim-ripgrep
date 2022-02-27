let s:suite = themis#suite('E2E layout test for ripgrep')
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

function s:suite.test_layout_0()
    " action
    call ripgrep#search('foo')
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')

    " check layout (['row', [['leaf', xxxx], ['col', [['leaf', xxxx], ['leaf', win_getid()]]]]])
    " +-------+-------+
    " |       | open2 |
    " + open1 +-------+
    " |       | focus |
    " +-------+-------+
    let l:layout = winlayout()
    call s:assert.equals(l:layout[0], 'row', "horizontal layout")
    call s:assert.length_of(l:layout[1], 2, "there are two columns")

    call s:assert.equals(l:layout[1][0], ['leaf', bufwinid(s:opening1_bufnr)], "opening-1.txt is opened on left window")

    call s:assert.equals(l:layout[1][1][0], 'col', "right window is layouted vertical")
    call s:assert.length_of(l:layout[1][1][1], 2, "there are two rows")

    call s:assert.equals(l:layout[1][1][1][0], ['leaf', bufwinid(s:opening2_bufnr)], "opening-2.txt is opened on right above window")
    call s:assert.equals(l:layout[1][1][1][1], ['leaf', win_getid()], "focused on right below window")
endfunction

function s:suite.test_layout_1()
    " action
    call ripgrep#search('foo')
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')

    " save window-id
    let l:w_left = bufwinid(s:opening1_bufnr)
    let l:w_right_above = bufwinid(s:opening2_bufnr)
    let l:w_right_below = win_getid()

    " open first result
    .cc

    " check
    call s:assert.equals(bufwinid(s:found_bufnr), l:w_right_above, "found result may be shown on right above window")
    call s:assert.equals(win_getid(), l:w_right_above, "focus on right above window")

    " return to 'open-2.txt'
    execute s:opening2_bufnr . 'buffer'
    " move to left
    wincmd h
    " re-open first result
    .cc

    " check
    call s:assert.equals(bufwinid(s:found_bufnr), l:w_left, "found result may be shown on left window")
    call s:assert.equals(win_getid(), l:w_left, "focus on left window")
endfunction

function s:suite.test_layout_2()
    " action
    call ripgrep#search('foo')
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')

    " save window-id
    let l:w_left = bufwinid(s:opening1_bufnr)
    let l:w_right_above = bufwinid(s:opening2_bufnr)
    let l:w_right_below = win_getid()

    " move to left
    wincmd h

    " re-action
    call ripgrep#search('foo')
    call ripgrep#wait(1000)
    let l:result = getqflist()
    call s:assert.length_of(l:result, 1, 'has 1 item in quickfix list')

    " open first result
    .cc

    " check
    call s:assert.equals(bufwinid(s:found_bufnr), l:w_left, "found result may be shown on left window")
    call s:assert.equals(win_getid(), l:w_left, "focus on left window")
endfunction
