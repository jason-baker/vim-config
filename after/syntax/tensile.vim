" Vim syntax file
" Language:	Tensile Literate Source
" Maintainer:	Taylor Venable <taylor@metasyntax.net>
" Last Change:	$Date: 2010/04/10 11:06:57 $
" Version:	$Revision: 1.14 $
" URL:		http://metasyntax.net/cgi-bin/cvsweb/Config/vim/syntax/tensile.vim

" Based on 'noweb.vim' by Xun GONG <minus273@BonBon.net>
" and Dirk Baechle <dl9obn@darc.de>.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax include @tensileIncC		syntax/c.vim		| unlet b:current_syntax
syntax include @tensileIncHaskell	syntax/haskell.vim	| unlet b:current_syntax
syntax include @tensileIncLisp		syntax/lisp.vim		| unlet b:current_syntax
syntax include @tensileIncJava		syntax/java.vim		| unlet b:current_syntax
syntax include @tensileIncJavaScript	syntax/javascript.vim	| unlet b:current_syntax
syntax include @tensileIncLua		syntax/lua.vim		| unlet b:current_syntax
syntax include @tensileIncMake		syntax/make.vim		| unlet b:current_syntax
syntax include @tensileIncOcaml		syntax/ocaml.vim	| unlet b:current_syntax
syntax include @tensileIncPerl		syntax/perl.vim		| unlet b:current_syntax
syntax include @tensileIncScheme	syntax/scheme.vim	| unlet b:current_syntax
syntax include @tensileIncShell		syntax/sh.vim		| unlet b:current_syntax
syntax include @tensileIncTcl		syntax/tcl.vim		| unlet b:current_syntax
syntax include @tensileIncTex		syntax/tex.vim		| unlet b:current_syntax

" The reference to a chunk of code in another code chunk.
"syntax match tensileCodeRef contained /<<.>>\|<<[^ ].*[^ ]>>/

" The code text within a code chunk.
"syntax region tensileCodeBody contained start=/>>=.\|>>=$/lc=3 end=/^@ \|^@$/me=e-3 contains=tensileCodeRef

"syn region  tensileTT     start="\[\["hs=s+2 end="\]\]"he=e-2 
"syn region  tensileXX     start="|"hs=s+1 end="|"he=e-1 
"syn region  tensileName   start="<<" end=">>" oneline contains=tensileTT

" Highlight various kinds of code depending on file name.  These actually
" contain text chunks so that the same highlighting will be applied to later
" code chunks that don't include file names.
syntax region tensileCode start=/^<<\w\+\.\(c\|h\)>>=$\|^%% BEGIN ZONE: C$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncC

syntax region tensileCode start=/^<<\w\+\.java>>=$\|^%% BEGIN ZONE: JAVA$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncJava

syntax region tensileCode start=/^<<\w\+\.ml>>=$\|^%% BEGIN ZONE: ML$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncOcaml

syntax region tensileCode start=/^<<\w\+\.hs>>=$\|^%% BEGIN ZONE: HASKELL$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncHaskell

syntax region tensileCode start=/^<<\w\+\.js>>=$\|^%% BEGIN ZONE: JAVASCRIPT$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncJavaScript

syntax region tensileCode start=/^<<\w\+\.pl>>=$\|^%% BEGIN ZONE: PERL$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncPerl

syntax region tensileCode start=/^<<\w\+\.tcl>>=$\|^%% BEGIN ZONE: TCL$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncTcl

syntax region tensileCode start=/^<<\w\+\.\(cl\|lisp\)>>=$\|^%% BEGIN ZONE: LISP$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncLisp

syntax region tensileCode start=/^<<\w\+\.lua>>=$\|^%% BEGIN ZONE: LUA$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncLua

syntax region tensileCode start=/^<<\w\+\.\(ss\|scm\)>>=$\|^%% BEGIN ZONE: SCHEME$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncScheme

syntax region tensileCode start=/^<<\w\+\.sh>>=$\|^%% BEGIN ZONE: SHELL$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncShell

syntax region tensileCode start=/^<<\w\+\.tex>>=$\|^%% BEGIN ZONE: TEX$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncTex

syntax region tensileCode start=/^<<Makefile>>=$\|%% BEGIN ZONE: MAKE$/ms=e
    \ end=/^<<\w\+\..\+>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeDef,tensileCodeRef,tensileText,@tensileIncMake

" Highlight references to contained code, or definitions of new code.
syntax match tensileCodeRef contained /^<<.*>>$/
if exists('tensile_indented_refs')
    syntax match tensileCodeRef contained /<<.*>>/
endif

syntax match tensileCodeDef contained /^<<.*>>=$/
syntax match tensileTextStart contained /^@\(|.*|\)\?$/

" The text chunk, within which we highlight TeX.
" Option 'keepend' is required because TeX can start \section{...} regions.
syntax region tensileText start=/^@\(|.*|\)\?$/
    \ end=/^<<.*>>=$\|^%% BEGIN ZONE: /me=s-1
    \ keepend contains=tensileCodeRef,tensileTextStart,@tensileIncTex

syn sync minlines=20 maxlines=200

if !exists("did_tensile_syntax_inits")
  let did_tensile_syntax_inits = 1
  " The default methods for highlighting. Can be overridden later.
  hi link tensileCodeRef	Type
  hi link tensileCodeDef	Preproc
  hi link tensileTextStart	Constant
endif

let b:current_syntax = "tensile"
