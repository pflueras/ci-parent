#!/bin/sh

VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo 'Releasing verion:' $VERSION

git config --global user.email "petru.flueras@gmail.com"
git config --global user.name "Petru Flueras"

cd $TRAVIS_BUILD_DIR/..
git clone --depth=50 --branch=master https://${GITHUB_TOKEN}@github.com/pflueras/ci-module1.git
cd ci-module1

# Update project version and all org.examples dependencies
mvn versions:set -DnewVersion=$VERSION
mvn versions:use-dep-version -Dincludes=org.examples -DdepVersion=$VERSION -DforceVersion=true

git add pom.xml
git commit -m "Release of version $VERSION"
git tag "$VERSION" -m "Release version $VERSION"

# New version
MAJOR=$(echo $1 | cut -f 1 -d '.')
MINOR=$(echo $1 | cut -f 2 -d '.')
PATCH=$(echo $1 | cut -f 3 -d '.')
NEW_VERSION=$MAJOR.$MINOR.$(($PATCH + 1))-SNAPSHOT
echo 'New version:' $NEW_VERSION

# Prepare for next development version
mvn versions:set -DnewVersion=$NEW_VERSION
mvn versions:use-dep-version -Dincludes=org.examples -DdepVersion=$NEW_VERSION -DforceVersion=true
git add pom.xml
git commit -m "Next development version $NEW_VERSION"

git push --follow-tags

# Clean up
cd $TRAVIS_BUILD_DIR
rm -rf ci-module1
