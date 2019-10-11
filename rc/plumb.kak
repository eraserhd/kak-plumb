# Plumb
# ‾‾‾‾‾

declare-option -docstring 'a directory to send instead of $(pwd) for wdir' str plumb_wdir

define-command \
    -params 1.. \
    -docstring %{plumb [<switches>] <text>: send text to the plumber
Switches:
    -attr <name>=<value>   Add an attribute to the message (accumulative)} \
    plumb %{
    evaluate-commands %sh{
        attrs="session=${kak_session}"
        while [ $# -ne 1 ]; do
            case "$1" in
                -attr)
                    attrs="${attrs} $2"
                    shift
                    ;;
                *)
                    printf 'fail "unknown switch %s"\n' "$1"
                    exit 0
            esac
            shift
        done
        wdir="$kak_opt_plumb_wdir"
        if [ -z "$wdir" ]; then
            wdir="$(pwd)"
        fi
        err="$(9 plumb -s kakoune -w "${wdir}" -a "${attrs}" "$@" 2>&1)"
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
            plumb -attr %sh{
                eval set -- "$kak_reg_l"
                printf click=%d $((${#1} - 1))
            } %val{selection}
        } catch %{
            plumb %val{selection}
        }
    }
}

define-command \
    -params 1 \
    -docstring %{plumb-select <address>: select by Plan 9 address

Address can be:
    ''                 does nothing
    <number>           a line number
    <number>:<number>  a line and column
    <number>.<number>  a line and column
    /<regex>           first occurrence of <regex> in file} \
    plumb-select %{
    evaluate-commands %sh{
        address="${1%:}"
        case "$address" in
            '')
                ;;
            /*)
                regex="$(printf %s "${address#/}" |sed '
                    s/</\a/g
                    s/>/<gt>/g
                    s/\a/<lt>/g
                ')"
                printf %s\\n "execute-keys gg/${regex}<ret>"
                ;;
            *:*)
                line="${address%:*}"
                column="${address#*:}"
                printf %s\\n "select ${line}.${column},${line}.${column}"
                ;;
            *.*)
                line="${addreses%.*}"
                column="${address#*.}"
                printf %s\\n "select ${line}.${column},${line}.${column}"
                ;;
            *)
                printf %s\\n "select ${address}.1,${address}.1"
                ;;
        esac
    }
}

map global normal <ret> ': plumb-click<ret>'
