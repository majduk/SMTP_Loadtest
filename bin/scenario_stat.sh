#!/usr/bin/env bash

GLOBAL_CONFIG="$1"

source "$GLOBAL_CONFIG"

stat_type="summary"
stat_print="file"

if [ "$2" != "" ]; then
  stat_type=$2;
fi

if [ "$3" != "" ]; then
  stat_print=$3;
fi

function write_stat()
{
  str="$1";
  if [ "$stat_print" = "file" ]; then 
    echo "$str" >> $SCENARIO_STATS;
    echo "$str" > $SCENARIO_STATS_CURR;
  else
    echo "$str";
  fi 
}

#set -x

echo `date $LOGDATEFORMAT`" Scenario statistics ($stat_type to $stat_print)"

if [ -f "$STAT_LOCK_FILE" ]; then
  is_running=1;
else
  is_running=0;
  #is_running=1;
fi

if [[ $is_running = "1" || "$stat_print" != "file" ]]; then 
    stat_time=`date +%Y/%m/%d_%H:%M:%S`;
    stat_timestamp=`$INSTALLDIR/bin/perl_timestamp.pl`;
    total_sum=0;
    total_speed=0;
    total_errors=0;
    
    if [[ "$stat_print" != "file" && "$stat_stat_type" = "verbose" ]]; then
      write_stat "TIME THREAD COUNTER ERRORS SPEED*100"
    fi
    
    for file in $( ls -1 $THREAD_STAT* 2>/dev/null ); do
        threadname=`basename $file`;
        read start_time now_time counter errors tspeed < "$file";
        
        for param in start_time now_time counter errors tspeed; do
           eval tmp=\$"$param";
           if [ "$tmp" = "" ]; then
              echo `date $LOGDATEFORMAT`" Scenario statistic $param for $threadname read failed. Retrying"
              read start_time now_time counter errors tspeed < "$file";
           fi 
        done
        
        total_errors=`expr "$total_errors" + "$errors"` ;
        total_sum=`expr "$total_sum" + "$counter"` ;
        
        difftime=`expr "$now_time" - "$start_time"`;
        if [ "$difftime" -gt "0" ]; then
          let nc="$counter"*100
          let speed="$nc"/"$difftime"                   
        else
          speed=0;          
        fi
        total_speed=`expr "$total_speed" + "$speed"` ;
        if [ "$stat_type" = "verbose" ]; then
          write_stat "$stat_time $threadname $counter $errors $speed $tspeed"
        fi
        
    done
    
      if [ "$stat_type" != "verbose" ]; then
        if [ -f "$SCENARIO_STATS_CURR" ]; then
          read last_stat_time last_stat_timestamp last_total_sum last_total_errors last_total_speed last_curr_speed < "$SCENARIO_STATS_CURR"
        fi
        difftime=`expr "$stat_timestamp" - "$last_stat_timestamp"`;
        if [ "$difftime" -lt "1" ]; then
          difftime=1;
        fi
        
        if [ "$total_sum" -ge "$last_total_sum" ]; then
          diffcount=`expr "$total_sum" - "$last_total_sum"`;
        else
          diffcount=$total_sum;
        fi
        
        let nc="$diffcount"*100
        let curr_speed="$nc"/"$difftime"        
       
        write_stat  "$stat_time $stat_timestamp $total_sum $total_errors $total_speed $curr_speed";
      fi
fi
echo `date $LOGDATEFORMAT`" Scenario statistics - done"

