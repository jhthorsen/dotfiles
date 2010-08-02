#!/bin/sh

for pod_file in $(find lib/ -type f); do
    out_file=html/$(perl -e'$ARGV[0]=~s/.pm/.html/; print $ARGV[0]' $pod_file);
    out_dir=html/$(dirname $out_file);

    if [ ! -e $out_file ]; then
        mkdir -p $out_dir
        pod2html --norecurse --htmlroot=$PWD/lib $pod_file > $out_file;
        echo "Wrote $out_file";
    fi

done

for pod_file in $(find html/ -type f); do
    linkchecker \
        --ignore-url=^mailto: \
        --ignore-url=^http: \
        --ignore-url=Moose \
        --no-warnings \
        --recursion-level=0 \
        --timeout=1 \
        $@ $pod_file || exit;
done
