#!/bin/ash

#set -vx

echo "Running tests..."

source /fedora-env.sh
apk -q --no-progress add curl
/init-fedora.sh 2>/tmp/run_tests.err 1>/tmp/run_tests.out &

fedora_up 30

echo "** run_tests.err **"
cat /tmp/run_tests.err
echo "** run_tests.out **"
cat /tmp/run_tests.out

if [ $? -ne 0 ] ;
then
    echo "Tests completed with error."
    echo "Exiting."
    exit 1;
fi

echo "Tests completed successfully."