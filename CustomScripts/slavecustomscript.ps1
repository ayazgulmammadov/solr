$xmlfiles = Get-ChildItem -Path "F:\Solr\" -Recurse | Where-Object name -eq 'solrconfig.xml'
foreach($xmlfile in $xmlfiles){
[xml]$xml = Get-Content $xmlfile.PSPath
$directory = $xmlfile.DirectoryName

$newElement = $xml.CreateElement("requestHandler")
$newElement.SetAttribute('name','/replication')
$newElement.SetAttribute('class','solr.ReplicationHandler')

$lst = $xml.CreateElement('lst')
$lst.SetAttribute('name','slave')

$str = $xml.CreateElement('str')
$str.SetAttribute('name','masterUrl')
$strtext = $xml.CreateTextNode("http://10.0.0.4:8983/solr")
$str.AppendChild($strtext)

$str1 = $xml.CreateElement('str')
$str1.SetAttribute('name','pollInterval')
$str1text = $xml.CreateTextNode('00:00:60')
$str1.AppendChild($str1text)

$lst.AppendChild($str)
$lst.AppendChild($str1)

$newElement.AppendChild($lst)
$xml.config.AppendChild($newElement)

$xml.Save("$directory\solrconfig.xml")} #end of editing solrconfig.xml file

$corePropFiles = Get-ChildItem -Path "F:\Solr\" -Recurse | Where-Object name -eq core.properties
foreach($corePropFile in $corePropFiles){
Add-Content -Path $corePropFile.PSPath -Value "`r`nenable.master=false `r`nenable.slave=true"} #end of editing core.properties file

$action = New-ScheduledTaskAction -Execute "F:\Solr\solr-6.6.5\bin\solr.cmd" -Argument "start"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'Solr' -User "nt authority\localservice" -Description 'Start Solr at startup' #add solr to startup

Start-Process 'F:\Solr\solr-6.6.5\bin\solr.cmd' -ArgumentList 'start'