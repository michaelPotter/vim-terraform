" terraform.vim - basic vim/terraform integration
" Maintainer: HashiVim <https://github.com/hashivim>

if exists('b:did_ftplugin') || v:version < 700 || &compatible
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

" j is a relatively recent addition; silence warnings when setting it.
setlocal formatoptions-=t formatoptions+=croql
silent! setlocal formatoptions+=j
let b:undo_ftplugin = 'setlocal formatoptions<'

if !has('patch-7.4.1142')
    " Include hyphens as keyword characters so that a keyword appearing as
    " part of a longer name doesn't get partially highlighted.
    setlocal iskeyword+=-
    let b:undo_ftplugin .= ' iskeyword<'
endif

if get(g:, 'terraform_fold_sections', 0)
  setlocal foldmethod=expr
  setlocal foldexpr=terraform#folds()
  setlocal foldlevel=1
  setlocal foldtext=terraform#foldText()
  let b:undo_ftplugin .= ' foldmethod< foldexpr< foldlevel< foldtext<'
endif

" Set the commentstring
setlocal commentstring=#%s
let b:undo_ftplugin .= ' commentstring<'

" Re-map the space bar to fold and unfold
if get(g:, 'terraform_remap_spacebar', 0)
  nnoremap <buffer> <space> za
  onoremap <buffer> <space> <C-C>za
  vnoremap <buffer> <space> zf
  let b:undo_ftplugin .= '|unmap <buffer> <space>'
endif

if get(g:, 'terraform_align', 0) && exists(':Tabularize')
  inoremap <buffer> <silent> = =<Esc>:call terraform#align()<CR>a
  let b:undo_ftplugin .= '|iunmap <buffer> ='
endif

let &cpoptions = s:cpo_save
unlet s:cpo_save

if !executable('terraform')
  finish
endif

let s:cpo_save = &cpoptions
set cpoptions&vim

command! -nargs=+ -complete=customlist,terraform#commands -buffer Terraform execute '!terraform '.<q-args>. ' -no-color'
command! -nargs=0 -buffer TerraformFmt call terraform#fmt()
let b:undo_ftplugin .= '|delcommand Terraform|delcommand TerraformFmt'

if get(g:, 'terraform_fmt_on_save', 0)
  augroup vim.terraform.fmt
    autocmd!
    autocmd BufWritePre *.tf call terraform#fmt()
    autocmd BufWritePre *.tfvars call terraform#fmt()
  augroup END
endif

let &cpoptions = s:cpo_save
unlet s:cpo_save
