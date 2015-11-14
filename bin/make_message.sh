#!/usr/bin/env bash

#PARAMS#
source=$1
target=$2
source_domain="mms.mnc006.mcc260.gprs"
target_domain=$3
subject=`date`
mms_delivery_report="No"
mms_read_reply="No"
mms_expiry_sec="600";
#mms_body=mms65k.txt 
#mms_body=mms1k.txt
#mms_body=mms10k.txt
#mms_body=mms40k.txt
mms_body=$4

#HEADERS#
message_id=`printf "1%07d.1%07d%05d" ${RANDOM} ${RANDOM} ${RANDOM}`;
mms_transaction_id=`printf "48%05d%05d%05d%05d" ${RANDOM} ${RANDOM} ${RANDOM} ${RANDOM}`                
mms_message_id=`printf "g2q%05d%04x151" ${RANDOM} ${RANDOM}`                
sdate=`date "+%a, %e %b %Y %T +0100"` 

cat << EOF
Message-ID: <$message_id.JavaMail.mms@mms2.mms.playmobile.pl>
Date: $sdate
From: +$source/TYPE=PLMN
To: +$target/TYPE=PLMN
Subject:  $subject
Mime-Version: 1.0
Content-Type: multipart/related;Type="application/smil";Start="<AAAA>"; 
	boundary="----=_Part_210936_2101044.1259765620911"
Sender: +$source/TYPE=PLMN@$source_domain
X-Mms-Message-Type: MM4_forward.REQ
X-Mms-3GPP-MMS-Version: 5.5.0
X-Mms-Transaction-ID: "$mms_transaction_id@mms.playmobile.pl"
X-Mms-Message-ID: "$mms_message_id@w.mms.playmobile.pl"
X-Mms-Expiry: $mms_expiry_sec 
X-Mms-Message-Class: Personal
X-Mms-Delivery-Report: $mms_delivery_report
X-Mms-Priority: Normal
X-Mms-Sender-Visibility: Show
X-Mms-Read-Reply: $mms_read_reply
X-Mms-Ack-Request: Yes
X-Mms-Originator-System: PostMaster@mms.mnc006.mcc260.gprs
X-Mms-Originator-R/S-Delivery-Report: No

EOF
cat $mms_body
cat << EOF
.
EOF