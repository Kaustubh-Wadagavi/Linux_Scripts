#!/bin/bash

initVariables() {
  #Memory information.
  totalMem=$(free -m | awk '{ if (NR > 1) print $2 }' | head -1)
  usedMem=$(free -m | awk '{ if (NR > 1) print $3 }' | head -1)
  freeMem=$(free -m | awk '{ if (NR > 1) print $4+$7 }' | head -1)
  percentMemUsed=$(( (usedMem*100)/totalMem ))

  #CPU information
  percentCpuUsed=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d"." -f1)
  cpuIdeal=$(top -b -n 1| head -3 | grep "Cpu(s)" | awk '{print $8}' | cut -d"." -f1)

  #Disk information
  partition="/dev/vda1"
  totalDisk=$(df -m | grep -w "$partition" | awk '{ print $2}')
  usedDisk=$(df -m | grep -w "$partition" | awk '{ print $3}')
  freeDisk=$(( (totalDisk - usedDisk)/1000 ))

  #Threshold values
  memThreshold=90
  cpuThreshold=90
  diskThreshold=2

  #Mail Properties
  to='admin@gmail.com'
  from='krishna.jenkins@gmail.com'
  contentType='text/html'
  
  #CheckOsHealth variables
  appUrl=$1
  openspecimen_logs="/home/user/app/openspecimen/data/logs"

  if [ -z "$appUrl" ]; then
     echo "Provide the application URL as command line arg to script.";
     echo "Run the script as ./server-monitoring.sh <openspecimen url>";
     exit 0;
  fi

  #Port Monitoring
  serverIp="142.93.114.79"
  usedPorts=$(nmap -sT -p- $serverIp | awk 'NR>=7' | grep -w '80\|22\|443\|8009')
  allPorts=$(nmap -sT -p- $serverIp | awk 'NR>=7')
  diffPorts=$(diff <(echo "$usedPorts") <(echo "$allPorts"))
  openPorts=$(echo "$diffPorts" | sed 's/>//g' | sed 's/<//g' | sed '/\/tcp/!d')
}

setMailProps() {
  template+="To: $to \n"
  template+="From: $from \n"
  template+="Content-Type: $contentType \n"
}

topResourceConsumeProcesses() {
  resource=$1
  template+="<table border=1 style=width:100%>"
  template+="$(ps -eo pid,%mem,%cpu,cmd --sort=-%$resource | head -11 | awk '{ print "<tr>" "<td width=10%>" $1 "</td>" "<td width=10%>" $2 "</td>" "<td width=10%>" $3 "</td>" "<td width=70%>" $4 $5 $6 "</td>" "</tr> \n" }')"
  template+="</table>"
}

topMemConsumeDirs() {
  template+="<table border=1 style=width:100%>"
  template+="<tr> <th> Directory </th> <th> Size </th> </tr>"
  template+=$(find / -not -path "/proc/*" -type f -printf "%s\t%p\n" | sort -nr | head -11 | awk '{print "<tr> <td width=50%>" $2 "</td> <td width=50%>" (($1/1024)/1024) "MB </td> </tr>" }')
  template+="</table>"
  template+="<br>"
}

generateReport() {
  subject="Alert !! $(hostname) server statistics"
  template+="Subject: $subject \n"
  
  template+="<html> \n"
  template+="<body> \n"
  template+="<p> Hi customer, </p>"
  template+="<p> The server is consuming resources at its peak. Please check below detailed information. </p>"

  template+="<h3> Memory report: </h3>"
  template+="<table border=1 style=width:50%>"
  template+="<tr> <td width=25%> Total Memory  </td> <td width=25%> $totalMem MB </td> </tr>"
  template+="<tr> <td width=25%> Used Memory   </td> <td width=25%> $usedMem MB </td> </tr>"
  template+="<tr> <td width=25%> Free Memory   </td> <td width=25%> $freeMem MB </td> </tr>"
  template+="<tr> <td width=25%> Used Memory in (%) </td> <td width=25%>  $percentMemUsed % </td> <tr>"
  template+="</table>"
  template+="<br>"

  template+="<h3> CPU report: </h3>"
  template+="<table border=1 style=width:50%>"
  template+="<tr> <td width=25%> CPU Used  </td> <td width=25%> $percentCpuUsed % </td> </tr>"
  template+="<tr> <td width=25%> CPU Ideal </td> <td width=25%> $cpuIdeal % </td> </tr>"
  template+="</table>"
  template+="<br>"

  template+="<h3> Disk report: </h3>"
  template+="<table border=1 style=width:50%>"
  template+="<tr> <td width=25%> Total Disk  </td> <td width=25%> "$(( $totalDisk/1000 ))" GB </td> </tr>"
  template+="<tr> <td width=25%> Used Disk   </td> <td width=25%> "$(( $usedDisk/1000 ))" GB </td> </tr>"
  template+="<tr> <td width=25%> Free Disk   </td> <td width=25%> $freeDisk  GB </td> </tr>"
  template+="</table>"
  template+="<br>"

  template+="<h4> Top 10 CPU consuming processes  </h4>"
  topResourceConsumeProcesses $1;
  template+="<br>"

  template+="<h4> Top 10 files by size  </h4>"
  topMemConsumeDirs;

  setFooter;
}

sendOsHealthAlert() {
  subject="Alert !! $(hostname) OpenSpecimen is down."
  template+="Subject: $subject \n"

  template+="<html> \n"
  template+="<body> \n"
  template+="<p> Hi customer, </p> \n"
  template+="<p> The OpenSpecimen server is down please check $openspecimen_logs/os.log file to find reason. </p> \n"

  setFooter;
  echo -e $template | /usr/sbin/ssmtp -v $to
}

sendPortAlert() {
  subject="Alert !! $(hostname) ports are open"
  template+="Subject: $subject \n"

  template+="<html> \n"
  template+="<body> \n"
  template+="<p> Hi customer, </p> \n"
  template+="<p> The OpenSpecimen server's below ports are open. Contact system/network administrator to check why these ports are open. </p> \n"

  template+="<table border=1 style=width:100%>"
  template+="<tr> <th width=33% align=left> Port </th> <th width=33% align=left> Status </th> <th width=33% align=left> Service </th> </tr>"
  template+="$(echo "$openPorts" | awk '{ print "<tr> <td width=33%>" $1 "</td> <td width=33%>" $2 "</td> <td width=33%>" $3 "</td> </tr>" }')"
  template+="</table>"

  setFooter;
  echo -e $template | /usr/sbin/ssmtp -v $to
}

setFooter(){
  template+="<h4> OpenSpecimen Administrator </h4>"
  template+="<center> Contact on  <a href='support.krishagni.com'> support@krishagni.com </a> for any OpnSpecimen issues. </center> \n"
  template+="</body> \n"
  template+="</html> \n"
}

monitorResource() {
  if [ $percentMemUsed -gt $memThreshold ];
  then
    generateReport "mem";
    echo -e "$template" | /usr/sbin/ssmtp -v $to
    return;
  fi
  
  if [ $percentCpuUsed -gt $cpuThreshold ];
  then
    generateReport "cpu";
    echo -e "$template" | /usr/sbin/ssmtp -v $to
    return;
  fi
  
  if [ $diskThreshold -gt $freeDisk ];
  then
    generateReport "mem";
    echo -e "$template" | /usr/sbin/ssmtp -v $to
    return;
  fi

}

invoke_server_api() {
  wget --no-check-certificate -o applog  $appUrl/rest/ng/config-settings/app-props
  rc=$?;
  if [ $rc -eq 0 ]
  then
    echo "App is running";
  else
    setMailProps;
    sendOsHealthAlert;
  fi
}

portMonitoring() {
  if [ ! -z "$openPorts" ]
  then
    sendPortAlert;
  fi
}

main() {
  initVariables $1;
  setMailProps;
  monitorResource;
  portMonitoring;
  invoke_server_api $1;
}
main $1;
