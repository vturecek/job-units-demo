# DEMO 1
Connect-ServiceFabricCluster

New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/FromPowerShell" `
    -InstanceCount 1


# DEMO 2.a
$buildConfig = "Release"
$imageStore = "file:C:\SfDevCluster\Data\ImageStoreShare"
$LocalFolder = "C:\Demo\JobDemo" #(Split-Path $MyInvocation.MyCommand.Path)

Connect-ServiceFabricCluster

Copy-ServiceFabricApplicationPackage `
    -ApplicationPackagePath "$LocalFolder\JobDemo\pkg\$buildConfig" `
    -ImageStoreConnectionString $imageStore `
    -ApplicationPackagePathInImageStore "JobDemo"

Register-ServiceFabricApplicationType `
    -ApplicationPathInImageStore "JobDemo"


# DEMO 2.b

New-ServiceFabricApplication `
    -ApplicationTypeName "JobDemoType" `
    -ApplicationTypeVersion "2.0.0" `
    -ApplicationName "fabric:/JobDemo2-Beta"


# DEMO 2.c

Start-ServiceFabricApplicationUpgrade `
    -ApplicationName "fabric:/JobDemo" `
    -ApplicationTypeVersion 2.0.0 `
    -Monitored `
    -FailureAction Rollback

# DEMO 3

Update-ServiceFabricService `
    -Stateless `
    -ServiceName "fabric:/JobDemo/jobs/BIGJOB" `
    -InstanceCount 3

    
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/HelloFromPowerShell" `
    -InstanceCount 1 `
    -Metric @("WorkUnits,High,10")

