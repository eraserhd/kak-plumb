#!/usr/bin/env bash
source test/functions.bash

h2 'selection length >1'
t 'plumbs selected text' -in 'h%(ello) world' -keys '<ret>' -plumbs ello
t 'sends session name' -flags '-s test-plumb' -in 'h%(ello) world' -keys '<ret>' -attr session=test-plumb
t 'sends current working directory when plumb_wdir is blank' -in 'h%(ello) world' -keys '<ret>' -wdir $PWD
t 'sends plumb_wdir directory when not blank' -in 'h%(ello) world' -keys ':set-option buffer plumb_wdir /tmp/foo<ret><ret>' -wdir /tmp/foo

h2 'selection length =1'
h3 'in WORD'
t 'plumbs WORD' -in 'h%(e)llo world' -keys '<ret>' -plumbs hello -attr click=1
t 'sends session name' -flags '-s test-plumb' -in 'h%(e)llo world' -keys '<ret>' -attr session=test-plumb

h3 'on whitespace before WORD'
t 'plumbs following WORD' -in '%( )   hello world' -keys '<ret>' -plumbs hello -attr click=0
t 'sends session name' -flags '-s test-plumb' -in '%( )   hello world' -keys '<ret>' -attr session=test-plumb

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

h2 'plumb-select'
t 'empty string changes nothing' -in '  %(h)ello' -keys ':plumb-select ""<ret>' -selects "'h'"
t '<number> selects a line' -in '%(1)x\n2y\n3z' -keys ':plumb-select 2<ret>' -selects "'2'"
t '<number>:<number> selects line and column' -in '%(1)x\n2y\n3z' -keys ':plumb-select 3:2<ret>' -selects "'z'"
t '<number>.<number> selects line and column' -in '%(1)x\n2y\n3z' -keys ':plumb-select 3.2<ret>' -selects "'z'"
t 'trailing colons are ignored' -in '%(1)x\n2y\n3z' -keys ':plumb-select 3:<ret>' -selects "'3'"
t '/<regex> finds an occurrence' -in '%(1)x\n2y\n3z' -keys ':plumb-select /2<ret>' -selects "'2'"

summarize
