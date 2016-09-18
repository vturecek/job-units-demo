// ------------------------------------------------------------
//  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
// ------------------------------------------------------------

namespace WebService.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using System;
    using System.Collections.Generic;
    using System.Fabric;
    using System.Fabric.Description;
    using System.Fabric.Query;
    using System.Linq;
    using System.Threading.Tasks;

    [Route("api/jobservice")]
    public class JobController : Controller
    {
        private readonly FabricClient fabricClient;
        private readonly StatelessServiceContext context;

        public JobController(FabricClient fabricClient, StatelessServiceContext context)
        {
            this.fabricClient = fabricClient;
            this.context = context;
        }

        [HttpGet]
        public async Task<IEnumerable<Service>> Get()
        {
            string applicationName = this.context.CodePackageActivationContext.ApplicationName;

            return (await fabricClient.QueryManager.GetServiceListAsync(new Uri(applicationName)))
                .Where(x => x.ServiceName.AbsoluteUri.StartsWith($"{applicationName}/jobs"));
                
        }
        
        [HttpPost]
        [Route("{jobName}/{workload?}")]
        public Task PostStateless(string jobName, int? workload = null)
        {
            string applicationName = this.context.CodePackageActivationContext.ApplicationName;

            StatelessServiceDescription serviceDescription = new StatelessServiceDescription()
            {
                ApplicationName = new Uri(applicationName),
                InstanceCount = 1,
                PartitionSchemeDescription = new SingletonPartitionSchemeDescription(),
                ServiceTypeName = "StatelessJobServiceType",
                ServiceName = new Uri($"{applicationName}/jobs/{jobName}")
            };

            if (workload.HasValue)
            {
                serviceDescription.Metrics.Add(new StatelessServiceLoadMetricDescription()
                {
                    Name = "JobUnits",
                    DefaultLoad = workload.Value
                });
            }
            return fabricClient.ServiceManager.CreateServiceAsync(serviceDescription);
        }
    }
}
