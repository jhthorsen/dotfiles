#!/bin/sh

svn status \
    | grep "^M" \
    | cut -d" " -f7 \
    | while read file; do
    svn diff $file | less;
done

exit 0;
