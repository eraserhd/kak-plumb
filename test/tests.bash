#!/usr/bin/env bash
source test/functions.bash

h2 'selection length >1'
t 'plumbs selected text' -in 'h%(ello) world' -keys ,o -plumbs ello

h2 'selection length =1'
t 'plumbs click on WORD' -in 'h%(e)llo world' -keys ,o -plumbs hello -attr click=1
t 'plumbs click on whitespace before WORD' -in '%( )   hello world' -keys ,o -plumbs hello -attr click=0

summarize
