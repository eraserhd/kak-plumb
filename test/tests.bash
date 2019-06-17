#!/usr/bin/env bash
source test/functions.bash

h2 'plumbing selected text'
t 'plumbs selected text' -in 'h%(ello) world' -keys ,o -plumbs ello

summarize
