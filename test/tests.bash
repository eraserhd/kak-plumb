#!/usr/bin/env bash
source test/functions.bash

h2 'selection length >1'
t 'plumbs selected text' -in 'h%(ello) world' -keys ,o -plumbs ello
#t 'sends session name'
#t 'sends current working directory' (?? or file directory?)

h2 'selection length =1'
t 'plumbs click on WORD' -in 'h%(e)llo world' -keys ,o -plumbs hello -attr click=1
t 'plumbs click on whitespace before WORD' -in '%( )   hello world' -keys ,o -plumbs hello -attr click=0

h2 'in *grep* buffer'
#t 'pressing enter plumbs match'
#t 'sends current working directory'
#t 'grep-next plumbs next match'
#t 'grep-previous plumbs previous match'

h2 'in *make* buffer'
#t 'pressing enter plumbs error'
#t 'sends current working directory'
#t 'make-next plumbs next error'
#t 'make-previous plumbs previous error'

h2 'edit-in-kakoune script'
#t '...'

summarize
