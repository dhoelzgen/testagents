#! /bin/sh

# initialize certain values
date=`date +%Y-%m-%d_%H:%M`
server=../target/agentcontest-2011-1.0.jar
webappPath=/home/massim/www/webapps/massim
webapp=$webappPath/WEB-INF/classes
hostname=`hostname -f`
conf=conf/ruby-batch.xml

cd "/Users/dhoelzgen/Studium/Contest 2011/Massim-2011-1.0/massim/scripts"
java -ea -Dcom.sun.management.jmxremote -Xss10000k -Xmx600M  -DentityExpansionLimit=1000000 -DelementAttributeLimit=1000000 -Djava.rmi.server.hostname=$hostname -jar $server --conf $conf  <<EOF

EOF
