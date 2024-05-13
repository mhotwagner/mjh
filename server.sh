#!/opt/homebrew/bin/bash

rm -f response
mkfifo response

function sys_stats() {
    # echo out a page of system statistics
    echo -e 'HTTP/1.1 200\r\n\r\n\r\n<h1>System Stats</h1>'
    echo '<pre>'
    echo 'Uptime: ' $(uptime)
    echo 'Free Memory: ' $(free -m)
    echo 'Disk Usage: ' $(df -h)
    echo '</pre>'

}

function handle_request() {
    # 1 process request
    declare -A HEADERS
    declare -A DATA
    _BODY=""
    while read line; do
#      echo $line
      trline=$(echo $line | tr -d '\r\n')


      if [ -z "$trline" ]; then
        break
      else
        if [[ $trline == GET* ]]; then
          _VERB=$(echo $trline | cut -d' ' -f1)
          _PATH=$(echo $trline | cut -d' ' -f2 | cut -d'?' -f1)
          _QUERY=$(echo $trline | cut -d' ' -f2 | cut -d'?' -f2)
          _PROTOCOL=$(echo $trline | cut -d' ' -f3)


        else
          KEY=$(echo $trline | cut -d':' -f1)
          VALUE=$(echo $trline | cut -d':' -f2)
          HEADERS[$KEY]=$VALUE
        fi
      fi
    done

    echo $_VERB
    echo $_PATH
    echo $_QUERY
    echo $_PROTOCOL
    echo

    if [ ! -z $HEADERS['Content-Length'] ] && [ ! "${HEADERS['Content-Length']}" == "" ]; then
      while read -n"${HEADERS['Content-Length']}" -t1 datum; do
        if [[ $datum == *'='* ]]; then
          KEY=$(echo $datum | cut -d'=' -f1)
          VALUE=$(echo $datum | cut -d'=' -f2)
          DATA[$KEY]=$VALUE
        else
          _BODY="$_BODY\n$datum"
        fi
      done
      echo "DATA"
      echo "${DATA[@]}"
      ehco
      ehco "BODY"
      echo $_BODY
    fi

    # 2 route request to correct handler
    case $_VERB in
      GET)
        case $_PATH in
              /sys*)
                sys_stats > response
                ;;
              /login)
                cat login.html > response
                ;;
              /)
                echo -e 'HTTP/1.1 200\r\n\r\n\r\n<h1>OK</h1>' > response
                ;;
              *)
                echo -e 'HTTP/1.1 404\r\n\r\n\r\n<h1>Not Found</h1>' > response
                ;;
        esac
        ;;
      POST)
        case $_PATH in
              /login)
                echo -e 'HTTP/1.1 200\r\n\r\n\r\n<h1>Logged In</h1>' > response
                ;;
              *)
                echo -e 'HTTP/1.1 404\r\n\r\n\r\n<h1>Not Found</h1>' > response
                ;;
        esac
        ;;
      *)
        echo 'UNKNOWN'
        ;;
    esac

    # 3 build response based on the request
    # 4 send the response to the named pipe
}

echo 'Listening on 3000...'
#cat response | nc -l 3000 |
while true; do
    cat response | nc -l 3000 | handle_request
done