// ------------------------------------------------------------
//  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
// ------------------------------------------------------------

namespace WebService
{
    using Common;
    using Microsoft.AspNetCore.Hosting;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.ServiceFabric.Services.Communication.Runtime;
    using Microsoft.ServiceFabric.Services.Runtime;
    using System;
    using System.Collections.Generic;
    using System.Fabric;
    using System.IO;

    internal sealed class WebService : StatelessService
    {
        public WebService(StatelessServiceContext serviceContext)
            : base(serviceContext)
        {
        }

        protected override IEnumerable<ServiceInstanceListener> CreateServiceInstanceListeners()
        {
            return new[]
            {
                new ServiceInstanceListener(context =>
                {
                    Uri applicationName = new Uri(context.CodePackageActivationContext.ApplicationName);

                    string appPath = applicationName.AbsolutePath;
                    
                    return new WebHostCommunicationListener(context, appPath, "ServiceEndpoint", uri =>
                        new WebHostBuilder().UseWebListener()
                                           .UseContentRoot(Directory.GetCurrentDirectory())
                                           .ConfigureServices(services => services
                                                .AddSingleton<FabricClient>(new FabricClient())
                                                .AddSingleton<StatelessServiceContext>(context))
                                           .UseStartup<Startup>()
                                           .UseUrls(uri)
                                           .Build());
                })                         
            };
        }
    }
}
