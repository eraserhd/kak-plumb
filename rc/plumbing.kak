
hook global BufCreate (.*/)?plumbing %{
    set-option buffer filetype plumbing
}

hook global WinSetOption filetype=plumbing %{
    require-module plumbing

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window plumbing-.+ }
}

hook -group plumbing-highlight global WinSetOption filetype=plumbing %{
    add-highlighter window/plumbing ref plumbing
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/plumbing }
}

provide-module plumbing %{

# Highlighters
# ------------

add-highlighter shared/plumbing regions
add-highlighter shared/plumbing/code default-region group
add-highlighter shared/plumbing/comment region '#' '$' fill comment
add-highlighter shared/plumbing/string region "'" "'" fill string
add-highlighter shared/plumbing/code/variable regex "^(\w+)\h*=" 1:variable
add-highlighter shared/plumbing/code/expansion regex '\$(\w+)' 0:value
add-highlighter shared/plumbing/code/keywords regex '\b(add|delete|is|isdir|isfile|matches|plumb|set|start|to)\b' 0:keyword

}
