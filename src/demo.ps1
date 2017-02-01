# DEMO 1: Create a service instance.
# Prereqs: Register the JobUnitsDemo application type and create an application instance (or simply Publish through Visual Studio).

Connect-ServiceFabricCluster

# Create job processing service
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/FromPowerShell" `
    -InstanceCount 1

# Create web UI
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "WebServiceType" `
    -ServiceName "fabric:/JobDemo/Web" `
    -InstanceCount 1

######	
# DEMO 2: Upgrades and A/B testing
# Prereqs: Change version numbers to 2.0.0 for StatelessJobService code package, service manifest, and JobUnitsDemo application manifest. Rebuild and create package. Remove WebServicePkg directory from output.

$buildConfig = "Debug"
$imageStore = "file:C:\SfDevCluster\Data\ImageStoreShare"
$SolutionDir =  ## Path to repo src dir; e.g., C:\git\repos\job-units-demo\src ##


######
# 2.a: Register new version

Copy-ServiceFabricApplicationPackage `
    -ApplicationPackagePath "$SolutionDir\JobUnitsDemo\pkg\$buildConfig" `
    -ImageStoreConnectionString $imageStore `
    -ApplicationPackagePathInImageStore "JobDemo"

Register-ServiceFabricApplicationType `
    -ApplicationPathInImageStore "JobDemo"


######
# 2.b: Create instance of new version side-by-side with current version

New-ServiceFabricApplication `
    -ApplicationTypeName "JobUnitsDemoType" `
    -ApplicationTypeVersion "2.0.0" `
    -ApplicationName "fabric:/JobDemo2-Beta"

# Create job processing service
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo2-Beta" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo2-Beta/jobs/FromPowerShell" `
    -InstanceCount 1

# Create web UI
New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo2-Beta" `
    -ServiceTypeName "WebServiceType" `
    -ServiceName "fabric:/JobDemo2-Beta/Web" `
    -InstanceCount 1

# View both applications' web services side-by-side
http://localhost/JobDemo
http://localhost/JobDemo2-Beta


######
# 2.c: Upgrade current application to new version

Remove-ServiceFabricApplication `
    -ApplicationName "fabric:/JobDemo2-Beta"

Start-ServiceFabricApplicationUpgrade `
    -ApplicationName "fabric:/JobDemo" `
    -ApplicationTypeVersion 2.0.0 `
    -Monitored `
    -FailureAction Rollback


######
# DEMO 3: Resource balancing
# Prereqs: Register the JobUnitsDemo application type. Set up cluster with node capacity: JobUnits, 100.
# 3.a: Create instance with JobUnits metrics

Remove-ServiceFabricService `
    -ServiceName "fabric:/JobDemo/jobs/FromPowerShell"

New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/MediumJob1" `
    -InstanceCount 1 `
    -Metric @("WorkUnits,High,50")


######
# 3.b: Create multiple instances with different metrics.

$jobs = @{
    "SmallJob1" = 25
    "SmallJob2" = 25
    "SmallJob3" = 25
    "MediumJob2" = 50
    "MediumJob3" = 50
    "LargeJob1" = 75
}    

foreach ($item in $jobs.GetEnumerator())
{
    New-ServiceFabricService `
        -Stateless `
        -PartitionSchemeSingleton `
        -ApplicationName "fabric:/JobDemo" `
        -ServiceTypeName "StatelessJobServiceType" `
        -ServiceName "fabric:/JobDemo/jobs/$($item.Name)" `
        -InstanceCount 1 `
        -Metric @("WorkUnits,High,$($item.Value)")

}

######
# 3.c: Create service with dedicated node.

New-ServiceFabricService `
    -Stateless `
    -PartitionSchemeSingleton `
    -ApplicationName "fabric:/JobDemo" `
    -ServiceTypeName "StatelessJobServiceType" `
    -ServiceName "fabric:/JobDemo/jobs/BIGJOB" `
    -InstanceCount 1 `
    -Metric @("WorkUnits,High,100")


######
# 3.d: Update big job instance count

Update-ServiceFabricService `
    -Stateless `
    -ServiceName "fabric:/JobDemo/jobs/BIGJOB" `
    -InstanceCount 3

