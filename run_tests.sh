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

test_and_exit $? "Jetty failed to start (see above log output)"

ls -l /data/README.md

test_and_exit $? "Missing expected file /data/README.md from assets image."

echo "Tests completed successfully."