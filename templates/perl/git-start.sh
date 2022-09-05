#!/bin/bash
start_project() {
  MAIN_PM_FILE="$(perl -e'$_=shift;s!-!/!g;print "lib/$_.pm"' "$PROJECT_NAME")";
  MAIN_PM_NAME="$(perl -e'$_=shift;s!-!::!g;print' "$PROJECT_NAME")";

  run sed -i '' -e "s!\${PROJECT_NAME}!$PROJECT_NAME!" ./Changes ./Makefile.PL \
    && run sed -i '' -e "s!\${MAIN_PM_FILE}!$MAIN_PM_FILE!" ./Makefile.PL \
    && run sed -i '' -e "s!\${MAIN_PM_NAME}!$MAIN_PM_NAME!" ./Makefile.PL \
    && run sed -i '' -e "s!\${PROJECT_NAME_LC}!$PROJECT_NAME_LC!" ./Makefile.PL;

  [ -e '.git/hooks/pre-commit' ] || run githook-perltidy install;
  [ -d "$(dirname "$MAIN_PM_FILE")" ] || run mkdir -p "$(dirname "$MAIN_PM_FILE")";
  [ -e "$MAIN_PM_FILE" ] || echo -ne "package $MAIN_PM_NAME;\n\nour \$VERSION = '0.01';\n\n1;\n" > "$MAIN_PM_FILE";
}
