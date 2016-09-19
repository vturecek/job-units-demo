// ------------------------------------------------------------
//  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
// ------------------------------------------------------------

namespace WebService.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using System.Fabric;

    public class HomeController : Controller
    {
        private readonly StatelessServiceContext context;

        public HomeController(StatelessServiceContext context)
        {
            this.context = context;
        }

        public IActionResult Index()
        {
            ViewData["ApplicationName"] = this.context.CodePackageActivationContext.ApplicationName;
            return View();
        }
        
        public IActionResult Error()
        {
            return View();
        }
    }
}
