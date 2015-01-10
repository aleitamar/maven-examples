#!/bin/sh

mkdir target
mkdir src/integration-test/meta

ack -l "@Test" src/integration-test > target/integration_test_list.txt

for fn in `cat target/integration_test_list.txt`; do
	testname=$(echo "$fn" | sed 's#src/integration-test/java/##')
	testname=$(echo "$testname" | sed 's#/#.#g')
    mvn -Dit.test=$testname clean verify -P integration-test
	metapath="${fn/java/meta}"
	mkdir -p ${metapath%/*}
	python testimpact_subset_csv.py > $metapath 
done

ack --noheading "." src/integration-test/meta/ | sed 's#src/integration-test/meta/##g' | sed 's/\.java/ /' | sed 's#/#.#g' | sed 's/:[[:digit:]]://' | awk ' { t = $1; $1 = $2; $2 = t; print; } ' | sort > src/integration-test/impact-map.txt