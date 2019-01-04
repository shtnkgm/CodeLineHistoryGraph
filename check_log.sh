#!/bin/bash

readonly PROJECT_DIR=$1
readonly EXCLUDE_DIR="Carthage,Pods"
readonly SWIFT="Swift"
readonly OBJC="Objective C"

function write_to_file() {
  return 0
}

function exec_cloc() {
  if which cloc >/dev/null; then
    echo "cloc command found"
  else
    echo "cloc command not found"
    echo "> brew install cloc"
    exit 1
  fi

  cloc_result=`cloc $PROJECT_DIR --exclude-dir="$EXCLUDE_DIR" --include-lang="$SWIFT,$OBJC"`
  swift_files=`echo "$cloc_result" | grep $SWIFT | awk -F' +' '{print $2}'`
  swift_lines=`echo "$cloc_result" | grep $SWIFT | awk -F' +' '{print $5}'`
  objc_files=`echo "$cloc_result" | grep $OBJC | awk -F' +' '{print $3}'`
  objc_lines=`echo "$cloc_result" | grep $OBJC | awk -F' +' '{print $6}'`
  objc_per_cloc_result=`echo "scale=5; $objc_files/$swift_files*100" | bc`
  objc_per_swift_lines=`echo "scale=5; $objc_lines/$swift_lines*100" | bc`
  echo "exclude directory: $EXCLUDE_DIR"
  echo "$SWIFT: $swift_files files"
  echo "$OBJC: $objc_files files"
  echo "$OBJC / $SWIFT: $objc_per_swift_files % (file)"
  echo "$SWIFT: $swift_lines lines"
  echo "$OBJC: $objc_lines lines"
  echo "$OBJC / $SWIFT: $objc_per_swift_lines % (line)"
  return 0
}

cd $PROJECT_DIR

LATEST_COMMIT=`git log |grep '^commit' |head -1|awk '{print $2}'`
last_write_date = ""

while :
do
  git reset --hard HEAD^
  if [ $? -ne 0 ]; then
    exit 1
  fi
  date=`git log -1 --date=iso-strict --format='%cd' | cut -c 1-10`

  if [ "$date" = "$last_write_date" ]; then
    echo "$date skipped"
    continue
  fi

  echo "$date write to file"
  exec_cloc
  last_write_date=$date
done

git reset --hard LATEST_COMMIT
