#!/bin/sh

if [ -n "$1" ]; then
  MODULE=$1;
  echo "\$ cpanm $MODULE";
  cpanm $MODULE && exit 0;

  echo "# cpanm $MODULE FAILED $?";
  WORK_ID=$(ls -r $HOME/.cpanm/work | head -n1);
  MODULE_DIR=$(echo $MODULE | perl -pe's!::!-!g');
  cd $HOME/.cpanm/work/$WORK_ID/$MODULE_DIR-* || exit 1;
  $0;
  exit $?;
fi

TARGET=$(basename $PWD);

if echo $TARGET | grep -q "Crypt-OpenSSL-Bignum"; then
  OPENSSL_INCLUDE="-I$HOMEBREW_PREFIX/opt/openssl/include" \
    OPENSSL_LIB="-L$HOMEBREW_PREFIX/opt/openssl/lib" \
    perl Makefile.PL || exit $?
  make && make install;

elif echo $TARGET | grep -q "DBD-MariaDB"; then
  perl Makefile.PL \
    --libs="-L$HOMEBREW_PREFIX/opt/openssl/lib -L$HOMEBREW_PREFIX/opt/mysql-client/lib -lmysqlclient" \
    --testuser=root || exit $?;
  make && make install

elif echo $TARGET | grep -q "DBD-mysql"; then
  perl Makefile.PL \
    --libs="-L$HOMEBREW_PREFIX/opt/openssl/lib -L$HOMEBREW_PREFIX/opt/mysql-client/lib -lmysqlclient" \
    --testuser=root || exit $?;
  make && make install

else
  echo "Usage";
  echo "$0 Crypt::OpenSSL::Bignum";
  echo "$0 DBD::mysql";
fi

