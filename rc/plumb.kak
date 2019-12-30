# Plumb
# ‾‾‾‾‾

declare-option -docstring 'a directory to send instead of $(pwd) for wdir' str plumb_wdir
declare-option -docstring 'data sent during the last plumb' str plumb_data

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

declare-option -hidden str-list plumb_saved_d

define-command \
    -params 0 \
    -docstring %{plumb-showdata: display contents of plumb_data option} \
    plumb-showdata %{
    set-option global plumb_saved_d %reg{d}
    set-register d %opt{plumb_data}
    edit -scratch *showdata*
    execute-keys '%"dRgg'
    set-register d %opt{plumb_saved_d}
}

define-command -hidden plumb-click-WORD %{
    execute-keys 'Z[<a-w>"lyz<a-i><a-w>'
    plumb -attr %sh{
        eval set -- "$kak_reg_l"
        printf click=%d $((${#1} - 1))
    } %val{selection}
}

declare-option -hidden str plumb_diff_filename
declare-option -hidden int plumb_diff_chunk_start
declare-option -hidden str-list plumb_diff_preceding_adds

define-command -hidden plumb-click-diff %{
    try %{
        evaluate-commands -draft %{
            execute-keys <a-/>^diff<space>[^\n]+<space>b/([^\n]+)$<ret>
            set-option global plumb_diff_filename %reg{1}
        }
        evaluate-commands -draft %{
            execute-keys '<a-/>^@@ -\d+,\d+ \+(\d+),\d+ @@<ret>'
            set-option global plumb_diff_chunk_start %reg{1}
        }
        evaluate-commands -draft %{
            execute-keys '<a-?>^@@ <ret>J<a-s>gh<a-K>-<ret>"ay'
            set-option global plumb_diff_preceding_adds %reg{a}
        }
        evaluate-commands %sh{
            eval set -- "$kak_quoted_opt_plumb_diff_preceding_adds"
            line=$(( $kak_opt_plumb_diff_chunk_start + $# - 1 ))
            column=$(( $kak_cursor_column - 1 ))
            text="${kak_opt_plumb_diff_filename}:${line}:${column}"
            printf 'plumb "%s"\n' "$text"
        }
    } catch %{
        # Fallback case, which means we are likely in a commit header and
        # can't find a diff and chunk begin line above us, so do the usual
        # thing.
        plumb-click-WORD
    }
}

define-command \
    -docstring %{plumb-click: send selection or WORD to plumber

If the selection length is 1, send the current WORD to the plumber along with
click coordinates.  Otherwise, send the selection to the plumber.

There is special handling for filetype=diff.} \
    plumb-click %{
    evaluate-commands -itersel -draft %{
        # Move forward if on a single whitespace
        try %{ execute-keys '<a-k>\A\s\z<ret>/[^\s]<ret>' }
        try %{
            # If we have more than a single character, send it as an
            # intentional selection
            execute-keys '<a-K>\A[^\s]\z<ret>'
            plumb %val{selection}
        } catch %{
            evaluate-commands -draft %sh{
                case "$kak_opt_filetype" in
                    diff) printf plumb-click-diff\\n ;;
                    *)    printf plumb-click-WORD\\n ;;
                esac
            }
        }
    }
}

map global normal <ret> ': plumb-click<ret>'
