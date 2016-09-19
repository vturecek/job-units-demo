$buildConfig = "Debug"
$imageStore = "file:C:\SfDevCluster\Data\ImageStoreShare"
$LocalFolder = "C:\Users\vturecek\Documents\visual studio 2015\Projects\JobDemo" #(Split-Path $MyInvocation.MyCommand.Path)

Connect-ServiceFabricCluster

Copy-ServiceFabricApplicationPackage `
    -ApplicationPackagePath "$LocalFolder\JobDemo\pkg\$buildConfig" `
    -ImageStoreConnectionString $imageStore `
    -ApplicationPackagePathInImageStore "JobDemo"

Register-ServiceFabricApplicationType `
    -ApplicationPathInImageStore "JobDemo"


New-ServiceFabricApplication `
    -ApplicationTypeName "JobDemoType" `
    -ApplicationTypeVersion "1.0.0" `
    -ApplicationName "fabric:/JobDemo"


New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/HelloFromPowerShell" `
    -InstanceCount 1

Start-ServiceFabricApplicationUpgrade `
    -ApplicationName "fabric:/JobDemo" `
    -ApplicationTypeVersion 2.0.0 `
    -Monitored `
    -FailureAction Rollback
    

Update-ServiceFabricService `
    -Stateless `
    -ServiceName "fabric:/JobDemo/jobs/BIGJOB" `
    -InstanceCount 3

    
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobUnitsDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobUnitsDemo/jobs/HelloFromPowerShell" `
    -InstanceCount 1 `
    -Metric @("JobUnits,High,10")

