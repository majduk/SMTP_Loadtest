##RELAY##

#Instalacja
1) Utworzyæ katalogi w katalogu wspólnym (zapis i odczyt katalogów dla wszystkich userów)
COMMONDIR=/usr/mms/share/p4apps/loadtest/work
$COMMONDIR/locks
$COMMONDIR/stats

1a) Prawa - 777: 
COMMONDIR=~p4apps/loadtest/work
$COMMONDIR/locks
$COMMONDIR/stats

1b) Prawa - 666: 
SCENARIO_LOGFILE=$COMMONDIR/scenario.log

2) Ustawic w konfiguracji
INSTALLDIR=~p4apps/loadtest

2a) Ustawiæ prawa:
chmod 755 $INSTALLDIR/bin/*

3) Wpisac w cronie 
-na wszystkich maszynach
* * * * * ~p4apps/loadtest/bin/cron_main.sh ~p4apps/loadtest/etc/manager.cfg
* * * * * ~p4apps/loadtest/bin/cron_main.sh ~p4apps/loadtest/etc/system_statistics.cfg

-na jednej maszynie
* * * * * ~p4apps/loadtest/bin/cron_main.sh ~p4apps/loadtest/etc/scenario_statistics.cfg

4) Uruchamianie/zatrzymywanie wykonywania
root@mms1[/home/ajdukm/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg start first
root@mms1[~/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg stop first
root@mms1[~/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg pause first
root@mms1[~/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg resume first

-przed tym nale¿y zastartowac statystyki
mms1:~p4apps/loadtest/bin ROOT > ./manager_interface.sh ../etc/manager.cfg stat start

#Troubleshooting:
root@mms1[~/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg status 
[2009/12/01_11:48:04] Monitor scenario
[2009/12/01_11:48:04] Monitor scenario (      30 threads) - done
root@mms1[~/apps/LoadTester/bin]>

root@mms1[~/apps/LoadTester/bin]>./manager_interface.sh ../etc/manager.cfg status verbose
[2009/12/01_14:18:57] Monitor scenario
[2009/12/01_14:18:57] Monitor scenario (      30 threads) - done
[2009/12/01_14:18:57] Scenario statistics (verbose to print)
2009/12/01_14:18:57 mms1.thread.0 71 10
[2009/12/01_14:18:58] Scenario statistics - done

Logi managera komend (wymagaja wlaczenia w pliku):
LOGDIR=$INSTALLDIR/log

Log watków wykonuj±cych  (wymagaja wlaczenia w pliku):
SCENARIO_LOGFILE=$COMMONDIR/scenario.log   (~p4apps/loadtest/log/scenario.log)


Statystyki:
~p4apps/loadtest/stats/stats.csv
~p4apps/loadtest/stats/mms1.sys_stats.csv

##MTA##
1) Ustawic w konfiguracji
INSTALLDIR=~/apps/LoadTester
WORKDIR=$INSTALLDIR/work


2a) Ustawiæ prawa:
chmod 755 $INSTALLDIR/bin/*

3) Wpisac w cronie
-na obu maszynach
* * * * * ~/apps/LoadTester/bin/cron_main.sh ~/apps/LoadTester/etc/mta_system_statistics.cfg

-na jednej maszynie
* * * * * ~/apps/LoadTester/bin/cron_main.sh ~/apps/LoadTester/etc/mta_mailq_statistics.cfg


4) Uruchomiæ generacjê statystyk na obu maszynach
./manager_interface.sh ../etc/mta_mailq_statistics.cfg stat start

Statystyki:
/apps/LoadTester/work/mm4-node1.mailq_stats.csv
/apps/LoadTester/work/mm4-node1.sys_stats.csv

Troubleshooting:
./system_stat_linux.sh ../etc/manager.cfg print
./mailq_stat_linux.sh ../etc/manager.cfg print