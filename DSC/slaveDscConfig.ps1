Configuration Main
{

    Param ( 
        [string] $nodeName,
        [string] $SolrConfFileUri )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName StorageDsc

    Node $nodeName 
    {
        xFirewall firewallRule {
            Name        = "Allow Solr 8983 Port"
            DisplayName = "Allow Solr 8983 Port"
            Description = "Allow Solr 8983 Port"
            Ensure      = "Present"
            Enabled     = $true
            Profile     = ("Public", "Private")
            Direction   = "Inbound"
            LocalPort   = 8983
            Protocol    = "TCP"
        }
        WaitForDisk dataDisk {
            DiskId           = 2
            DiskIdType       = "Number"
            RetryIntervalSec = 60
            RetryCount       = 60
        }
        Disk diskVolume {
            DiskId      = 2
            DiskIdType  = "Number"
            DriveLetter = "F"
            FSLabel     = "Data"
            FSFormat    = "NTFS"
            ClearDisk   = $true
            DependsOn   = "[WaitForDisk]dataDisk"
        }
        WaitForVolume volumeF {
            DriveLetter      = "F"
            RetryIntervalSec = 5
            RetryCount       = 10
        }
        File SolrFolder {
            Ensure          = "Present"
            DestinationPath = "F:\Solr"
            Type            = "Directory"
            DependsOn       = "[Disk]diskVolume"
        }
        File DownloadsFolder {
            Ensure          = "Present"
            DestinationPath = "C:\Downloads"
            Type            = "Directory"
        }
        xRemoteFile downloadJRE {
            Uri             = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=236888_42970487e3af4f5aa5bca3f542482c60"
            DestinationPath = "C:\Downloads\jre.exe"
            DependsOn       = "[File]DownloadsFolder"
        }
        Package installJRE {
            Ensure    = "Present"
            Name      = "Java Platform SE 8 U201"
            Path      = "C:\Downloads\jre.exe"
            Arguments = "/s"
            ProductId = "26A24AE4-039D-4CA4-87B4-2F64180201F0"
            DependsOn = "[xRemoteFile]downloadJRE"
        }
        xRemoteFile downloadSolr {
            Uri             = "http://archive.apache.org/dist/lucene/solr/6.6.5/solr-6.6.5.zip"
            DestinationPath = "C:\Downloads\solr-6.6.5.zip"
            DependsOn       = "[File]DownloadsFolder"
        }
        Archive unzipSolr {
            Path        = "C:\Downloads\solr-6.6.5.zip"
            Destination = "F:\Solr"
            Ensure      = "Present"
            DependsOn   = @("[xRemoteFile]downloadSolr", "[File]SolrFolder")
        }
        xRemoteFile copyCoresConf {
            Uri             = $SolrConfFileUri
            DestinationPath = "C:\Downloads\cores_conf.zip"
            DependsOn       = "[File]DownloadsFolder"
        }
        Archive unzipCoresConf {
            Path        = "C:\Downloads\cores_conf.zip"
            Destination = "F:\Solr\solr-6.6.5\server\solr\configsets"
            Ensure      = "Present"
            DependsOn   = @("[Archive]unzipSolr", "[xRemoteFile]copyCoresConf")
        }
    }
}