# Plumb
# ‾‾‾‾‾

define-command \
    -params 1.. \
    -docstring %{plumb <text>: send text to the plumber} \
    plumb %{
    evaluate-commands %sh{
        err="$(9 plumb -s kakoune "$@" 2>&1)"
        if [ -n "$err" ]; then
            printf 'fail "%s"\n' "$err"
        fi
    }
}

define-command \
    -docstring %{plumb-click: send selection or WORD to plumber

If the selection length is 1, send the current WORD to the plumber along with
click coordinates.  Otherwise, send the selection to the plumber.} \
    plumb-click %{
    evaluate-commands -itersel -draft %{
        # Move forward if on a single whitespace
        try %{ execute-keys '<a-k>\A\s\z<ret>/[^\s]<ret>' }
        try %{
            # If we have a single-character selection, simulate clicking
            execute-keys '<a-k>\A[^\s]\z<ret>'
            execute-keys 'Z[<a-w>"lyz<a-i><a-w>'
            evaluate-commands %sh{
                eval set -- "$kak_reg_l"
                err="$(9 plumb -s kak -a click=$((${#1} - 1)) "$kak_selection" 2>&1)"
                if [ -n "$err" ]; then
                    printf 'fail "%s"\n' "$err"
                fi
            }
        } catch %{
            plumb %val{selection}
        }
    }
}

map global user o ': plumb-click<ret>' # Mnemonic: (O)pen
