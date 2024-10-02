using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;

namespace FunctionApp
{
    public class Function1
    {
        private readonly ILogger<Function1> _logger;
        private readonly IConfiguration _config;

        public Function1(ILogger<Function1> logger, IConfiguration config)
        {
            _logger = logger;
            _config = config;
        }

        [Function("GetSecret")]
        public IActionResult GetSecret([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req, 
            [FromQuery] string name,
            [FromQuery] string credentialType)
        {
            var kvName = _config["KV_NAME"];
            _logger.LogInformation($"C# HTTP trigger function processed a request. {name} {credentialType} {kvName}");

            var tokenCredential = GetTokenCredential(credentialType);
            var client = new SecretClient(new Uri($"https://{kvName}.vault.azure.net/"), tokenCredential);

            return new OkObjectResult(client.GetSecret(name));
        }

        private TokenCredential GetTokenCredential(string credentialType)
        {
            switch (credentialType) {
                case "DefaultAzureCredential":
                    return new DefaultAzureCredential();
                case "ChainedTokenCredential":
                    return new ChainedTokenCredential();
                case "ManagedIdentityCredential":
                    return new ManagedIdentityCredential();
            }

            throw new Exception($"The credential type {credentialType} is not valid");
        }
    }
}
