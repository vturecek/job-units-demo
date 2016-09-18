$buildConfig = "Debug"
$imageStore = "file:C:\SfDevCluster\Data\ImageStoreShare"
$LocalFolder = (Split-Path $MyInvocation.MyCommand.Path)


Connect-ServiceFabricCluster


Copy-ServiceFabricApplicationPackage `
    -ApplicationPackagePath "$LocalFolder\JobUnitsDemo\pkg\$buildConfig" `
    -ImageStoreConnectionString $imageStore `
    -ApplicationPackagePathInImageStore "JobUnitsDemo"


Register-ServiceFabricApplicationType `
    -ApplicationPathInImageStore "JobUnitsDemo"


New-ServiceFabricApplication `
    -ApplicationTypeName "JobUnitsDemoType" `
    -ApplicationTypeVersion "1.0.0" `
    -ApplicationName "fabric:/JobUnitsDemo"


New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobUnitsDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobUnitsDemo/jobs/HelloFromPowerShell" `
    -InstanceCount 1 `
    -Metric @("JobUnits,High,10")

Update-ServiceFabricService `
    -Stateless `
    -ServiceName "fabric:/JobUnitsDemo/jobs/HelloFromPowerShell" `
    -InstanceCount 1