function! s:get_executable() abort
    " Get rip-grep executable from global variable 
    if exists('g:ripgrep#executable')
        return g:ripgrep#executable
    endif
    if has('win32')
        return 'rg.exe'
    else
        return 'rg'
    endif
endfunction

function! s:get_root_marks() abort
    " Get rip-grep root directory marks from global variable.
    " Default: [".git"]
    if exists('g:ripgrep#root_marks')
        return g:ripgrep#root_marks
    endif
    return ['.git']
endfunction

function! s:get_base_options() abort
    " Get common command-line options for ripgrep.
    " It uses 'ignorecase' and 'smartcase' vim option.
    let l:opts = ['--json', '--no-line-buffered', '--no-block-buffered']
    if &ignorecase == 1
        call add(l:opts, '--ignore-case')
    endif
    if &smartcase == 1
        call add(l:opts, '--smart-case')
    endif
    call add(l:opts, '--')
    return l:opts
endfunction

let s:found = v:false
let s:jobid = 0

function! s:reset() abort
    " Reset (initialize) job status and quickfix-list
    let s:found = v:false
    call ripgrep#stop()
    call setqflist([], 'r')
    call ripgrep#observe#add_observer(g:ripgrep#event#match, 'ripgrep#__register_match')
endfunction

function! ripgrep#__register_match(item) abort
    if !s:found
        copen
    endif
    let s:found = v:true
    call setqflist([a:item], 'a')
endfunction

function! s:finish(status) abort
    " Finish quickfix-list
    if s:found
        call setqflist([], 'a', {'title': 'Ripgrep'})
        let s:jobid = 0
    end
    call ripgrep#observe#notify(g:ripgrep#event#finish, {'status': a:status})
endfunction

function! s:stdout_handler_core(rel, job_id, data, event_type) abort
    " Receive lines from rg --json
    for l:line in a:data
        let l:handler = ripgrep#line#parse(l:line)
        let l:event = l:handler[0]
        let l:body = l:handler[1]
        if has_key(l:body, 'filename')
            let l:body['filename'] = ripgrep#path#rel(a:rel . l:body['filename'])
        endif
        call ripgrep#observe#notify(l:event, l:body)
    endfor
endfunction

function! s:get_stdout_handler(rel) abort
    return {job_id, data, event_type -> s:stdout_handler_core(a:rel, job_id, data, event_type)}
endfunction

function! s:stderr_handler(job_id, data, event_type) abort
    " Receive standard-error lines from rg --json
    for l:line in a:data
        call ripgrep#observe#notify(g:ripgrep#event#error, {'raw': l:line})
    endfor
endfunction

function! s:exit_handler(job_id, data, event_type) abort
    let l:status = a:data
    call s:finish(l:status)
    if l:status != 0
        echomsg 'failed to find'
    endif
endfunction

function! ripgrep#search(arg) abort
    let l:exe = s:get_executable()
    if !executable(l:exe)
        echoerr "There's no executable: " . l:exe
    endif
    let l:cmds = [l:exe]
    call extend(l:cmds, s:get_base_options())
    call add(l:cmds, a:arg)
    " get cwd (tuple of [path, rel])
    let l:cwd = ripgrep#path#traverse_root(getcwd(), s:get_root_marks())

    let l:cmd = join(l:cmds, ' ')
    call ripgrep#call(l:cmd, l:cwd[0], l:cwd[1])
endfunction

function! ripgrep#call(cmd, cwd, rel) abort
    call s:reset()

    let s:jobid = ripgrep#job#start(a:cmd, {
        \ 'on_stdout': s:get_stdout_handler(a:rel),
        \ 'on_stderr': function('s:stderr_handler'),
        \ 'on_exit': function('s:exit_handler'),
        \ 'normalize': 'array',
        \ 'overlapped': v:true,
        \ 'cwd': a:cwd,
    \ })
    if s:jobid <= 0
        echoerr 'failed to be call ripgrep'
    endif
endfunction

function! ripgrep#stop() abort
    if s:jobid <= 0
        return
    endif
    silent call ripgrep#job#stop(s:jobid)
    let s:jobid = 0
endfunction

function! ripgrep#wait(...) abort
    " ripgrep#wait([{timeout}]) wait current process
    if s:jobid <= 0
        return
    endif
    try
        let l:timeout = get(a:000, 0, -1)
        call ripgrep#job#wait([s:jobid], l:timeout)
    catch
    endtry
endfunction
