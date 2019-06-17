TEST_COUNT=0
TESTS_FAILED=0
TEST_OK=true
PLUMB_ATTRS=''
PLUMB_WDIR=''
PLUMB_DATA=''

h2() {
    printf '\n \e[33;1m%s\e[0m\n' "$1"
}

h3() {
    printf '   \e[33m%s\e[0m\n' "$1"
}

fail() {
    if $TEST_OK; then
        printf '\e[31;1mfailed\e[0m\n'
    fi
    TEST_OK=false
    local escaped_out="$TEST_OUT"
    escaped_out="${escaped_out///\\x0E}"
    escaped_out="${escaped_out///\\x0F}"
    printf '      Assertion: \e[31m%s\e[0m\n' "$*"
    printf "       Commands:\n"
    cat test/9commands.txt
    printf "          Debug:\n"
    cat test/debug.txt
    printf '\n'
}

did_command() {
    case "$1" in
        plumb)
            shift
            while (( $# > 0 )); do
                case "$1" in
                    -a)
                        PLUMB_ATTRS="$2"
                        shift 2
                        ;;
                    -w)
                        PLUMB_WDIR="$2"
                        shift 2
                        ;;
                    *)
                        PLUMB_TEXT="$1"
                        shift
                        ;;
                esac
            done
            ;;
    esac
}

t() {
    local description="$1"
    shift

    local in='' keys='' flags=''
    while true; do
        case "$1" in
            -in)
                in="$2"
                shift 2
                ;;
            -keys)
                keys="$2"
                shift 2
                ;;
            -flags)
                flags="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    printf '     %s ... ' "$description"
    printf '' >test/9commands.txt
    printf '%s' "$in" >test/in.txt

    PATH=./test:"$PATH" kak -n $flags -ui json -e '
        source rc/plumb.kak
        try %{
            exec -save-regs / %{%s%\(\K[^)]+\)<ret>a<backspace><esc>i<backspace><backspace><c-u><esc><a-;>}
        } catch %{ exec gg }
        hook global RuntimeError .* %{
            echo -debug -- error: %val{hook_param}
            eval -buffer *debug* write test/debug.txt
            quit!
        }
        execute-keys -with-hooks -with-maps %{'"$keys"'}
        eval -buffer *debug* write test/debug.txt
        quit 0
    ' test/in.txt >/dev/null </dev/null

    PLUMB_ATTRS=''
    PLUMB_WDIR=''
    PLUMB_DATA=''
    source test/9commands.txt

    while (( $# > 0 )); do
        case "$1" in
            -attr)
                case " $PLUMB_ATTRS " in
                    *" $2 "*)
                        ;;
                    *)
                        fail "$@"
                        ;;
                esac
                shift 2
                ;;
            -plumbs)
                if [[ $PLUMB_TEXT != $2 ]]; then
                    fail "$@"
                fi
                shift 2
                ;;
            -wdir)
                if [[ $PLUMB_WDIR != $2 ]]; then
                    fail "$@"
                fi
                shift 2
                ;;
            *)
                fail "$1"
                break
                ;;
        esac
    done

    TEST_COUNT=$(( TEST_COUNT + 1 ))
    if $TEST_OK; then
        printf 'ok\n'
    else
        TESTS_FAILED=$(( TESTS_FAILED + 1 ))
    fi
}

summarize() {
    local color=''
    if (( TESTS_FAILED > 0 )); then
        color="$(printf '\e[31;1m')"
    fi
    printf '\n%s%d tests, %d failed.\e[0m\n' "$color" $TEST_COUNT $TESTS_FAILED
}
