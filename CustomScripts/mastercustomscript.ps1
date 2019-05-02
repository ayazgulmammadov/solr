$xmlfiles = Get-ChildItem -Path "F:\Solr\" -Recurse | Where-Object name -eq 'solrconfig.xml'
foreach($xmlfile in $xmlfiles){
[xml]$xml = Get-Content $xmlfile.PSPath
$directory = $xmlfile.DirectoryName

$newElement = $xml.CreateElement("requestHandler")
$newElement.SetAttribute('name','/replication')
$newElement.SetAttribute('class','solr.ReplicationHandler')

$lst = $xml.CreateElement('lst')
$lst.SetAttribute('name','master')

$str = $xml.CreateElement('str')
$str.SetAttribute('name','replicateAfter')
$strtext = $xml.CreateTextNode("commit")
$str.AppendChild($strtext)

$str1 = $xml.CreateElement('str')
$str1.SetAttribute('name','replicateAfter')
$str1text = $xml.CreateTextNode('startup')
$str1.AppendChild($str1text)

$str2 = $xml.CreateElement('str')
$str2.SetAttribute('name','confFiles')
$str2text = $xml.CreateTextNode('schema.xml,stopwords.txt')
$str2.AppendChild($str2text)

$lst.AppendChild($str)
$lst.AppendChild($str1)
$lst.AppendChild($str2)

$newElement.AppendChild($lst)
$xml.config.AppendChild($newElement)

$xml.Save("$directory\solrconfig.xml")} #end of editing solrconfig.xml file

$corePropFiles = Get-ChildItem -Path "F:\Solr\" -Recurse | Where-Object name -eq core.properties
foreach($corePropFile in $corePropFiles){
Add-Content -Path $corePropFile.PSPath -Value "`r`nenable.master=true `r`nenable.slave=false"} #end of editing core.properties file

$action = New-ScheduledTaskAction -Execute "F:\Solr\solr-6.6.5\bin\solr.cmd" -Argument "start"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'Solr' -User "nt authority\localservice" -Description 'Start Solr at startup' #add solr to startup

Start-Process 'F:\Solr\solr-6.6.5\bin\solr.cmd' -ArgumentList 'start'
