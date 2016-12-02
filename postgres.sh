#! /bin/sh
# prefix
prefix=/usr/local/pgsql

# Data directory
PGDATA="/usr/local/pgsql/data"

# PGUSER
PGUSER="postgres"

# log file
PGLOG="/usr/local/pgsql/data/log"

# Nao meche apartir daqui deu trabalho isso

if echo 'c' | grep -s c >/dev/null 2>&1 ; then
ECHO_N="echo -n"
ECHO_C=""
else
ECHO_N="echo"
ECHO_C='c'
fi

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

DAEMON="$prefix/bin/pg_ctl"

set -e

test -f $DAEMON || exit 0

case $1 in
start)
$ECHO_N "Iniciando PostgreSQL: "$ECHO_C
su -l $PGUSER -s /bin/sh -c "$DAEMON -D '$PGDATA' -o -"i" -l $PGLOG start"
echo "ok"
;;
stop)
echo -n "Parando PostgreSQL: "
su - $PGUSER -c "$DAEMON stop -D '$PGDATA' -s -m fast"
echo "ok"
;;
restart)
echo -n "Reiniciando PostgreSQL: "
su - $PGUSER -c "$DAEMON restart -D '$PGDATA' -s -m fast"
echo "ok"
;;
status)
su - $PGUSER -c "$DAEMON status -D '$PGDATA'"
;;
*)
# Help
echo "Modos de uso: postgresql {start|stop|restart|status}" 1>&2
echo "Por Jorginho"
exit 1
;;
esac

exit 0 
