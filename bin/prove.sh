PROVE_RECORD_FILE="local/.prove-last-run";

prove-all() {
  prove --color $* | tee $PROVE_RECORD_FILE;
}

prove-fail() {
  if [ "x$1" = "x" ]; then
    cat $PROVE_RECORD_FILE | grep 'Wstat:' | grep -o "t/[^ ]*";
  else
    prove --color $* $(cat $PROVE_RECORD_FILE | grep 'Wstat:' | grep -o "t/[^ ]*");
  fi
}
