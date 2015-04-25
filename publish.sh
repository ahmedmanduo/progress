#!/usr/bin/env bash
set -e

PROJECT_ROOT=`pwd`

DOCS_SOURCE="$PROJECT_ROOT/docs"

BUILD_ROOT="$PROJECT_ROOT/build/gh-pages"
REPOSITORY_ROOT="$BUILD_ROOT/repository"
GENERATE_ROOT="$BUILD_ROOT/generate"

echo "Clearing build directory $BUILD_ROOT"
rm -rf $BUILD_ROOT

mkdir $BUILD_ROOT

echo cloning git into build directory
git clone https://github.com/mplatvoet/progress-site.git $REPOSITORY_ROOT
cd $REPOSITORY_ROOT
git checkout gh-pages


cd $DOCS_SOURCE
mkdocs build
mv $DOCS_SOURCE/site $GENERATE_ROOT

diff -qr $REPOSITORY_ROOT $GENERATE_ROOT --exclude .git --exclude .DS_Store| awk -v base="$REPOSITORY_ROOT" '$1=="Only"&&$3==base":" {print base"/"$4}' | sort -r | awk '{cmd="git rm " $1; system(cmd)}'


cp -rf $GENERATE_ROOT/* $REPOSITORY_ROOT

cd $REPOSITORY_ROOT
if [ -z "GIT_API" ]; then
    echo "local publish"
else
{
    git config user.name "$GIT_NAME"
    git config user.email "$GIT_EMAIL"
    git config push.default simple
    git remote set-url origin https://${GIT_API}@github.com/mplatvoet/progress-site.git
} &> /dev/null
fi
git add .
git status
git commit -m "auto publish" || true

if [ -z "GIT_API" ]; then
    git push || true
else
{
    git push || true
    git remote set-url origin https://github.com/mplatvoet/progress-site.git
} &> /dev/null
fi
cd $REPOSITORY_ROOT