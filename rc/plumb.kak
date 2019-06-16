# Plumb
# ‾‾‾‾‾

define-command \
    -docstring %{plumb-selection: send selected text to the plumber} \
    plumb-selection %{
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
            evaluate-commands %sh{
                err="$(9 plumb -s kak "$kak_selection" 2>&1)"
                if [ -n "$err" ]; then
                    printf 'fail "%s"\n' "$err"
                fi
            }
        }
    }
}

map global user o ': plumb-selection<ret>'
