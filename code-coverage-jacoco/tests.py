import os

os.system("git status --porcelain > git-status-bare")

tests = set()

gitStatus = open('git-status-bare')
for statusLine in iter(gitStatus):
    if statusLine.startswith(" M code-coverage-jacoco/src/main/java/"):
        sourcefile=statusLine[statusLine.index("/java/") + 6 : statusLine.index(".java")].replace("/", ".");
        testmap = open('src/integration-test/impact-map.txt')
        for mapentry in iter(testmap):
            if mapentry.startswith(sourcefile + " "):
                tests.add(mapentry[mapentry.index(" ")+1 : len(mapentry)-1])
        testmap.close()
gitStatus.close()

if len(tests) > 0:
    commandSeparatedTests = ",".join(tests)
    print "Tests to be run: " + commandSeparatedTests
    os.system("mvn -Dit.test=" + commandSeparatedTests + " clean verify -P integration-test")
else:
    print "No tests impacted by changes"