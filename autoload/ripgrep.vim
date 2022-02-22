function! s:get_executable()
    " Get rip-grep executable from global variable 
    if exists('g:ripgrep#executable')
        return g:ripgrep#executable
    endif
    return 'rg'
endfunction

function! s:get_base_options()
    " Get common command-line options for ripgrep.
    " It uses 'ignorecase' and 'smartcase' vim option.
    let l:opts = ['--json']
    if &ignorecase == 1
        call insert(l:opts, '--ignore-case')
    endif
    if &smartcase == 1
        call insert(l:opts, '--smart-case')
    endif
    return l:opts
endfunction

let s:found = v:false
let s:jobid = 0

function! s:reset()
    " Reset (initialize) job status and quickfix-list
    let s:found = v:false
    if s:jobid > 0
        silent call ripgrep#job#stop(s:jobid)
        let s:jobid = 0
    endif
    call setqflist([], 'r')
endfunction

function! s:finish()
    " Finish quickfix-list
    if s:found
        call setqflist([], 'a', {'title': 'Ripgrep'})
        let s:jobid = 0
    end
endfunction

function! s:stdout_handler(job_id, data, event_type)
    " Receive lines from rg --json
    for l:line in a:data
        let l:item = ripgrep#parse#jsonl(l:line)
        if type(l:item) != v:t_dict
            continue
        endif
        if !s:found
            copen
        endif
        let s:found = v:true
        call setqflist([l:item], 'a')
    endfor
endfunction

function! s:exit_handler(job_id, data, event_type)
    let l:status = a:data
    if l:status == 0
        call s:finish()
    else
        echomsg "failed to find"
    endif
endfunction

function! ripgrep#search(arg) abort
    let l:cmds = [s:get_executable()]
    call extend(l:cmds, s:get_base_options())
    call add(l:cmds, a:arg)
    call s:reset()
    echomsg join(l:cmds, " ")
    let s:jobid = ripgrep#job#start(join(l:cmds, " "), {
        \ 'on_stdout': function('s:stdout_handler'),
        \ 'on_exit': function('s:exit_handler'),
        \ 'normalize': 'array',
        \ 'nvim': {
            \ 'pty': v:true,
            \ 'stdin': 'null',
        \ },
        \ 'vim': {
            \ 'pty': v:true,
            \ 'in_io': 'null',
        \ },
    \ })
    if s:jobid <= 0
        echoerr 'failed to be call ripgrep'
    endif
endfunction
