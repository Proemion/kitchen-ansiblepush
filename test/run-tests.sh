#!/bin/sh
set -e
echo "Run rspec"
cd ..
bundle exec rspec --require spec_helper --format d

echo "Run Rubocop"
bundle exec rubocop lib

bundle exec kitchen test simple
bundle exec kitchen test notidempotent | tee /tmp/notidempotent

number_of_servers_in_idempotent="$(bundle exec kitchen list notidempotent | grep Ssh | wc -l |  tr -d '[[:space:]]')"
#number_of_servers_in_idempotent="1"

failed_nonotidempotent=$(cat /tmp/notidempotent | grep "Warning idempotency test \[failed\]" | wc -l |  tr -d '[[:space:]]')
if [ ! "${failed_nonotidempotent}" = "${number_of_servers_in_idempotent}" ] ; then
    echo "Non idempotent tasks '$failed_nonotidempotent' should match '${number_of_servers_in_idempotent}'. :( failed"
    exit 1
fi


printf "\n\n\nTest Pass :)"

