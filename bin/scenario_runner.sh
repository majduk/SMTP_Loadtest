#!/usr/bin/env bash

GLOBAL_CONFIG="$1"

source "$GLOBAL_CONFIG"
source "$SCENARIOMANAGERCONFIG"
scenario="$2"

#set -x

if [ "$SCENARIO_LOGFILE" != "" ]; then
  exec 2>&1 >> $SCENARIO_LOGFILE
fi

function run_scenario_thread ()
{
  local thread_id=$1;
  local speed=$2;
  local count=$3
  local accel=$4;
  
  counter=0;
  sleep=$speed;
  
  echo `date`" "`hostname`" Starting thread $thread_id"

  #random sleep
  rand=$RANDOM
  let "rand %= $RANDOM_SLEEP"
  echo `date`" "`hostname`" Going into initial sleep for $rand seconds";
  sleep $rand;           
      
  #-----------------------------
    for profile in $MESSAGES; do
      for param in $MESSAGE_PARAMS; do
        eval param_"$profile"_"$param"=\$"$profile""_""$param";
        eval val=\$param_"$profile"_"$param";
        if [ "$val" = "" ]; then
          eval param_"$profile"_"$param"=\$"DEFAULT_$param";
        fi
        eval $param=\$param_"$profile"_"$param";
        eval dbg=\$"$param";
        echo `date`" "`hostname`" Setting $profile $param=$dbg";              
      done

      thread_name=`hostname`.$thread_id.$profile
      lockname=$THREAD_SYNC_LOCK.$thread_name
      if [ -f $lockname ]; then
         echo `date`" "`hostname`" PANIC! Thread $thread_name already exists!"
         exit $EXECUTION_ERROR;
      fi
      
      tmp="$TEMP_MESSAGE".$thread_name
      $INSTALLDIR/bin/make_message.sh $SOURCE $TARGET $TARGET_DOMAIN $MMS_BODY > $tmp
      if [ "$SEND" = "1" ]; then
          #$INSTALLDIR/bin/send_message.sh $GLOBAL_CONFIG $SOURCE $TARGET $TARGET_DOMAIN $tmp
          #rm -r $tmp
          echo `date`" "`hostname`" Launching $thread_name"
          $INSTALLDIR/bin/sendEmailMulti.pl \
           -f "+$SOURCE/TYPE=PLMN@mms.mnc006.mcc260.gprs" \
           -t "+$TARGET/TYPE=PLMN@$TARGET_DOMAIN" \
           -o message-file=$tmp \
           -s $MAIL_SERVER \
           -c $count \
           -sf $THREAD_STAT.$thread_name \
           -rl $SCENARIO_LOCK_FILE \
           -tl $lockname           \
           -tn  $thread_name      \
           -v                     \
           -sleep $sleep &         
      fi
      
      
    done
    #------------------------------
}

echo `date`" "`hostname`" Starting scenario ( $scenario)" 

    profile=$scenario
    for param in $SCENARIO_PARAMS; do
      eval param_"$profile"_"$param"=\$"$profile""_""$param";
      eval val=\$param_"$profile"_"$param";
      if [ "$val" = "" ]; then
        eval param_"$profile"_"$param"=\$"DEFAULT_$param";
      fi
      eval $param=\$param_"$profile"_"$param";
      eval dbg=\$"$param";
      echo `date`" "`hostname`" Setting $profile $param=$dbg";  
    done

for ((i=0; i<$THREADS; i++ )); do
  run_scenario_thread $i $SPEED $COUNT $ACCEL &
done        


echo `date`" "`hostname`" Starting scenario - done"

