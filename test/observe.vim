let s:suite = themis#suite('test for ripgrep#line')
let s:assert = themis#helper('assert')

function! s:suite.add_one_observer()
  let l:got = 0
  function Increment(local)
    let a:local.got += 1
    return a:local.got
  endfunction
  call ripgrep#observe#add_observer("match", function("Increment", [l:]))
  call ripgrep#observe#notify("match")
  call s:assert.equal(1, l:got)
  call ripgrep#observe#notify("match")
  call s:assert.equal(2, l:got)
  delfunction Increment
endfunction

function! s:suite.add_two_observer()
  let l:got1 = 0
  function Increment1(local)
    let a:local.got1 += 1
    return a:local.got1
  endfunction
  let l:got2 = 0
  function Increment2(local)
    let a:local.got2 += 1
    return a:local.got2
  endfunction
  call ripgrep#observe#add_observer("match", function("Increment1", [l:]))
  call ripgrep#observe#add_observer("match", function("Increment2", [l:]))
  call ripgrep#observe#notify("match")
  call s:assert.equal(1, l:got1)
  call s:assert.equal(1, l:got2)
  call ripgrep#observe#notify("match")
  call s:assert.equal(2, l:got1)
  call s:assert.equal(2, l:got2)
  delfunction Increment1
  delfunction Increment2
endfunction
