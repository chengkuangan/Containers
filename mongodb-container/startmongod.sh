#!/bin/bash

TMPDIR="/tmp"
pidfile="$TMPDIR/container-temp-mongod.pid"
rm -f "$pidfile"
INITIATE_FILE=$MONGODATA_PATH/initiated.status

echo "Discovering hostname dynamically."

OPTS=`getopt -o h: --long hostname: -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"

while true; do
    case "$1" in
    -h | --hostname )     HOSTNAME=$2;        shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
    esac
done

if [ ! -z "$HEADLESS_SERVICE" ]; then
    echo "Appending headless service name: $HEADLESS_SERVICE"
    HOSTNAME="$HOSTNAME.$HEADLESS_SERVICE"
fi

echo "Using hostname: $HOSTNAME" 

mongod=(mongod --dbpath $MONGODATA_PATH --logpath $MONGODATA_PATH/mongod.log)
mongo=(mongosh --host localhost --port 27017 --quiet)

if [ ! -f "$INITIATE_FILE" ]; then
    
    echo "Starting MongoDB with pidfile: $pidfile" 
    "${mongod[@]}" --pidfilepath $pidfile --fork --replSet rs0

    echo "Initializing MongoDB replicaset" 

mongosh localhost:27017/$MONGODB_DATABASE <<-EOF
    rs.initiate({
        _id: "rs0",
        members: [ { _id: 0, host: "${HOSTNAME}:27017" } ]
    });
EOF

    echo "Initiated replica set"
    
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

mongosh localhost:27017/admin <<-EOF
    db.createUser({ user: "${MONGODB_ADMIN_USER}", pwd: "${MONGODB_ADMIN_PASSWORD}", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] })
EOF

        echo "Creating users now ..."
        
        "${mongo[@]}" -u $MONGODB_ADMIN_USER -p $MONGODB_ADMIN_PASSWORD admin <<-EOJS
        db = db.getSiblingDB('admin')

            db.runCommand({
                createRole: "listDatabases",
                privileges: [
                    { resource: { cluster : true }, actions: ["listDatabases"]}
                ],
                roles: []
            })

            db.runCommand({
                createRole: "readChangeStream",
                privileges: [
                    { resource: { db: "", collection: ""}, actions: [ "find", "changeStream" ] }
                ],
                roles: []
            })

            db.createUser({
                user: "$MONGODB_USER",
                pwd: "$MONGODB_PASSWORD",
                roles: [
                    { role: "readWrite", db: "$MONGODB_DATABASE"},
                    { role: "read", db: "local" },
                    { role: "listDatabases", db: "admin" },
                    { role: "readChangeStream", db: "admin" },
                    { role: "read", db: "config" },
                    { role: "read", db: "admin" }
                ]
            })
EOJS
    
    "${mongod[@]}" --shutdown
    rm -f "$pidfile"
    touch $INITIATE_FILE
fi

exec "${mongod[@]}" --bind_ip_all --replSet rs0
