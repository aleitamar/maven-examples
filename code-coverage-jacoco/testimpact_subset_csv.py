import csv

reader = csv.DictReader(open("target/site/jacoco-it/jacoco.csv"), dialect="excel")
for row in reader:
    if row["INSTRUCTION_COVERED"] != "0":
        print row["PACKAGE"] + "." + row["CLASS"]