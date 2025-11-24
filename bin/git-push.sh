#!/bin/bash
[ "$FORCE_PUSH" = "yes" ] && exec command git push "$@";

[ -z "$__RECURSION" ] && __RECURSION="0";
[ "$__RECURSION" -gt 2 ] && exec echo "__RECURSION=$__RECURSION # git push $*";
__RECURSION=$((__RECURSION+1));
export __RECURSION;

branch="$(git rev-parse --abbrev-ref HEAD)";
echo "$branch" | grep -q "main" || $DRY_RUN exec command git push "$@";

unsigned_commits=();
for commit in $(git rev-list "origin/$branch..$branch" --reverse); do
  git log --format=%G? -n 1 "$commit" | grep -q 'G' \
    || unsigned_commits+=("$commit");
done

if [ ${#unsigned_commits[@]} -gt 0 ]; then
  git rebase -i --exec "git commit --amend --no-edit --gpg-sign" "origin/$branch";
  $DRY_RUN git push "$@";
  exit "$?";
fi

$DRY_RUN exec command git push "$@";
