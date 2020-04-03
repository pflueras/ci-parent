#!/bin/sh

# Params:
#   - downstream module name
#   - Release version
#   - Next development version
release_dependency()
{
    echo "Releasing dependency version $2 of $1. Next development version $3"

    cd $TRAVIS_BUILD_DIR/..
    git clone --depth=50 --branch=master https://${GITHUB_TOKEN}@github.com/pflueras/$1.git
    cd $1

    # Update project version and all org.examples dependencies
    mvn versions:set -DnewVersion=$VERSION
    mvn versions:use-dep-version -Dincludes=org.examples -DdepVersion=$VERSION -DforceVersion=true

    git add pom.xml
    git commit -m "Release of version $2"
    git tag "$2" -m "Release version $2"

    # Prepare for next development version
    mvn versions:set -DnewVersion=$3
    mvn versions:use-dep-version -Dincludes=org.examples -DdepVersion=$3 -DforceVersion=true
    git add pom.xml
    git commit -m "Next development version $3"

    git push --follow-tags
}

VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
echo "Releasing verion: $VERSION"

git config --global user.email "petru.flueras@gmail.com"
git config --global user.name "Petru Flueras"

# New version
MAJOR=$(echo $VERSION | cut -f 1 -d '.')
MINOR=$(echo $VERSION | cut -f 2 -d '.')
PATCH=$(echo $VERSION | cut -f 3 -d '.')
NEW_VERSION=$MAJOR.$MINOR.$(($PATCH + 1))-SNAPSHOT

for dependency in 'ci-module1';
do
    release_dependency $dependency $VERSION $NEW_VERSION
done
