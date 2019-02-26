call ale#Set('elm_analyse_executable', 'elm-analyse')
call ale#Set('elm_analyse_use_global', get(g:, 'ale_use_global_executables', 0))

" Return the command to execute the linter in the projects directory.
" If it doesn't, then this will fail when imports are needed.
function! elm_analyse#GetCommand(buffer) abort
    let l:executable = elm_analyse#GetExecutable(a:buffer)
    let l:root_dir = ale_linters#elm#make#GetRootDir(a:buffer)

    if empty(l:root_dir)
        let l:dir_set_cmd = ''
    else
        let l:dir_set_cmd = 'cd ' . ale#Escape(l:root_dir) . ' && '
    endif

    return l:dir_set_cmd . '%e --lsp --stdio'
endfunction

function! elm_analyse#GetPackageFile(buffer) abort
    let l:elm_json = ale#path#FindNearestFile(a:buffer, 'elm.json')

    if empty(l:elm_json)
        " Fallback to Elm 0.18
        let l:elm_json = ale#path#FindNearestFile(a:buffer, 'elm-package.json')
    endif

    return l:elm_json
endfunction

function! elm_analyse#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'elm_analyse', ['node_modules/.bin/elm-analyse'])
endfunction

call ale#linter#Define('elm', {
\   'name': 'elm_analyse',
\   'lsp': 'stdio',
\   'executable_callback': function('elm_analyse#GetExecutable'),
\   'command': function('ale_linters#elm#make#GetCommand'),
\   'project_root_callback': 'elm_analyse#GetPackageFile',
\})
