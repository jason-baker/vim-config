" Vim support file to detect file types
" Listen very carefully, I will say this only once
if exists("did_load_filetypes_user_after")
  finish
endif
let did_load_filetypes_user_after = 1

augroup filetypedetect

" Handle the changes file
au BufNewFile,BufRead CHANGES       setf changelog

" Tensile
au BufNewFile,BufRead *.tnsl set filetype=tensile

" Tcl (JACL too)
au BufNewFile,BufRead *.tcl,*.tk,*.itcl,*.itk,*.jacl	setf tcl

augroup END
