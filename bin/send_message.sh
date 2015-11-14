#!/usr/bin/env bash

source $1

$INSTALLDIR/bin/sendEmail.pl \
-f "+$2/TYPE=PLMN@mms.mnc006.mcc260.gprs" \
-t "+$3/TYPE=PLMN@$4" \
-s 10.200.132.108 \
-o message-file=$5 \
-o message-format=raw
