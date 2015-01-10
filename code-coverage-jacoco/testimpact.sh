#!/bin/sh

mkdir target
mkdir src/integration-test/meta

# list of integration tests (unit tests would be in src/tests)

ack -l "@Test" src/integration-test > target/integration_test_list.txt

# Process them one at a time

for fn in `cat target/integration_test_list.txt`; do
	testname=$(echo "$fn" | sed 's#src/integration-test/java/##')
	testname=$(echo "$testname" | sed 's#/#.#g')

	# One maven invocation per test (so we can get focused coverage)

    mvn -Dit.test=$testname clean verify -P integration-test

    # TODO Maven could fail per test, which is half expected

	metapath="${fn/java/meta}"
	mkdir -p ${metapath%/*}
	python testimpact_subset_csv.py > $metapath 
done

# Turn many files into map of the total picture
# that's source vs tests (instead of tests vs sources)

ack --noheading "." src/integration-test/meta/ | sed 's#src/integration-test/meta/##g' | sed 's/\.java/ /' | sed 's#/#.#g' | sed 's/:[[:digit:]]://' | awk ' { t = $1; $1 = $2; $2 = t; print; } ' | sort > src/integration-test/impact-map.txt

# TODO - check in potentially changed cross references files here