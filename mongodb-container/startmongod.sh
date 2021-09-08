#!/bin/bash

TMPDIR="/tmp"
pidfile="$TMPDIR/container-temp-mongod.pid"
rm -f "$pidfile"
INITIATE_FILE=$MONGODATA_PATH/initiated.status

mongod=(mongod --dbpath $MONGODATA_PATH --logpath $MONGODATA_PATH/mongod.log)
mongo=( mongo --host 127.0.0.1 --port 27017 --quiet)

if [ ! -f "$INITIATE_FILE" ]; then

    "${mongod[@]}"  --pidfilepath $pidfile --fork

    tries=30
    while true; do
        if ! { [ -s "$pidfile" ] && ps "$(< "$pidfile")" &> /dev/null; }; then
            # bail ASAP if "mongod" isn't even running
            echo >&2
            echo >&2 "error: mongod does not appear to have stayed running -- perhaps it had an error?"
            echo >&2
            exit 1
        fi
        if "${mongo[@]}" 'admin' --eval 'quit(0)' &> /dev/null; then
            # success!
            break
        fi
        (( tries-- ))
        if [ "$tries" -le 0 ]; then
            echo >&2
            echo >&2 "error: mongod does not appear to have accepted connections quickly enough -- perhaps it had an error?"
            echo >&2
            exit 1
        fi
        sleep 1
    done

    if ! "${mongo[@]}" admin -u $MONGODB_ADMIN_USER -p $MONGODB_ADMIN_PASSWORD --eval 'quit(0)' &> /dev/null; then
        echo "User $MONGODB_ADMIN_USER not created. Creating now ... "
        
        "${mongo[@]}" admin <<-EOJS
        db = db.getSiblingDB('admin')
            db.createUser(
                {
                    user: "$MONGODB_ADMIN_USER",
                    pwd: "$MONGODB_ADMIN_PASSWORD",
                    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
                }
            )
            db = db.getSiblingDB('$MONGODB_DATABASE')
            db.createUser({
                "user" : "$MONGODB_USER",
                "pwd" : "$MONGODB_PASSWORD",
                    "roles" : [
                        {
                            "role" : "readWrite",
                            "db" : "$MONGODB_DATABASE"
                        },
                        {
                            "role" : "read",
                            "db" : "local"
                        }
                    ]
                })
EOJS
    fi

    "${mongod[@]}" --shutdown

    rm -f "$pidfile"

    "${mongod[@]}" --fork --replSet rs0
    
    "${mongo[@]}" admin -u $MONGODB_ADMIN_USER -p $MONGODB_ADMIN_PASSWORD --eval 'rs.initiate()'
    
    "${mongod[@]}" --shutdown

    touch $INITIATE_FILE
fi

exec "${mongod[@]}" --bind_ip_all --replSet rs0
