#!/opt/homebrew/bin/bash

rm -f response
mkfifo response
chmod 777 response

function handle_sys_stats() {
    # echo out a page of system statistics
    RESPONSE=$(echo -e "HTTP/1.1 200\r\n\r\n\r\n<h1>System Stats</h1>
<pre>
Uptime:  $(uptime)
Free Memory: $(top -l 1 -s 0 | grep PhysMem)
Disk Usage: $(df -h)
</pre>")
}


function handle_GET_login() {
    RESPONSE=$(cat login.html)
}

function handle_home() {
    if [[ ! -z ${_COOKIES['name']} ]]; then
        RESPONSE=$(cat logged-in-home.html | sed "s/{{name}}/${_COOKIES['name']}/")
    else
        RESPONSE=$(cat home.html)
    fi
}

function handele_404() {
 RESPONSE=$(cat 404.html)
}

function handle_POST_login() {
    # echo out a page of system statistics
    echo "${!_DATA[@]}"
    echo "${_DATA[@]}"
    echo "${_DATA['name']}"
    RESPONSE=$(cat post-login.http | sed "s/{{name}}/${_DATA['name']}/")
}

function handle_POST_logout() {
    # echo out a page of system statistics
    echo "LOGOUT"
    echo "${_COOKIES['name']}"
    if [[ ! -z ${_COOKIES['name']} ]]; then
        RESPONSE=$(cat post-logout.http | sed "s/{{name}}/${_COOKIES['name']}/")
    else
        RESPONSE=$(cat post-logout.http | sed "s/{{name}}/anonymous/")
    fi
}

function handle_request() {
    # 1 process request
    declare -A _HEADERS
    declare -A _COOKIES
    declare -A _DATA
    _BODY=""
    while read line; do
      echo $line
      trline=$(echo $line | tr -d '\r\n')


      if [ -z "$trline" ]; then
        break
      else
        if [[ $trline == GET* ]] || [[ $trline == POST* ]] ; then
          _VERB=$(echo $trline | cut -d' ' -f1)
          _PATH=$(echo $trline | cut -d' ' -f2 | cut -d'?' -f1)
          _QUERY=$(echo $trline | cut -d' ' -f2 | cut -d'?' -f2)
          _PROTOCOL=$(echo $trline | cut -d' ' -f3)


        else
          KEY=$(echo $trline | cut -d':' -f1)
          VALUE=$(echo $trline | cut -d':' -f2)
          if [[ $KEY == 'Cookie' ]]; then
            IFS=';' read -ra COOKIES <<< "$VALUE"
            for COOKIE in "${COOKIES[@]}"; do
              COOKIE=$(echo $COOKIE | tr -d ' ')
              COOKIE_KEY=$(echo $COOKIE | cut -d'=' -f1)
              COOKIE_VALUE=$(echo $COOKIE | cut -d'=' -f2)
              _COOKIES[$COOKIE_KEY]=$COOKIE_VALUE
            done
          fi
          _HEADERS[$KEY]=$VALUE
        fi
      fi
    done

    echo "VERB: $_VERB"
    echo "PATH: $_PATH"
    echo "QUERY: $_QUERY"
    echo "PROTOCOL: $_PROTOCOL"
    echo

    if [ ! -z $HEADERS['Content-Length'] ] && [ ! ${_HEADERS['Content-Length']} == "0" ]; then
      echo "GOT HEADERS"
      CONTENT_LENGTH=${_HEADERS['Content-Length']}
      echo "CONTENT_LENGTH: $CONTENT_LENGTH"
      while read -n "$CONTENT_LENGTH" -t1 datum; do
        if [[ $datum == *'='* ]]; then
          echo "GETTING DATA"
          KEY=$(echo $datum | cut -d'=' -f1)
          VALUE=$(echo $datum | cut -d'=' -f2)
          _DATA[$KEY]=$VALUE
          echo "X"
        else
          echo "GETTING BODY"
          _BODY="$_BODY\n$datum"
          echo "X"
#          break
        fi
      done
      echo "_DATA"
      echo "${_DATA[@]}"
      echo
      echo "BODY"
      echo $_BODY
    fi
    echo "still going..."

    # 2 route request to correct handler
    case $_VERB in
      GET)
        case $_PATH in
              /sys*) handle_sys_stats ;;
              /login) handle_GET_login ;;
              /logout) handle_POST_logout ;;
              /) handle_home ;;
              *) handele_404 ;;
        esac
        ;;
      POST)
        case $_PATH in
            /login) handle_POST_login ;;
            /logout)
              echo "LOGOUT??="
              handle_POST_logout ;;
            *) handele_404 ;;
        esac
        ;;
      *)
        echo 'UNKNOWN VERB'
        ;;
    esac

    # 3 build response based on the request
    # 4 send the response to the named pipe
#    echo $RESPONSE
    echo -e "$RESPONSE" > response
#    echo "$(cat response)"
}

echo 'Listening on 3000...'
#cat response | nc -l 3000 |
while true; do
    cat response | nc -l 3000 | handle_request
done