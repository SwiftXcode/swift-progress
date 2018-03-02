#!/bin/bash

echo "Fetching git@github.com:helje5/ApacheExpressAdmin2.git"
echo "Updating git@github.com:helje5/ZeeQLExpress3.git"
echo "Updating https://github.com/AlwaysRightInstitute/WebPackMiniS.git"
sleep 3

echo >&2 "error: failed to clone; Cloning into bare repository '/Users/helge/dev/Swift/Apex3/ApacheExpress/.build/repositories/ApacheExpressAdmin2.git-9159445275726089249'..."
echo >&2 "ERROR: Repository not found."
echo >&2 "fatal: Could not read from remote repository."
echo >&2
echo >&2 "Please make sure you have the correct access rights"
echo >&2 "and the repository exists."

exit 13
