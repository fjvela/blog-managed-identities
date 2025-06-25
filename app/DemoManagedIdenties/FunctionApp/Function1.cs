using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using System.Web;
using System.Net.Security;

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

        [Function("GetSecretHardWay")]
        public async Task<IActionResult> GetSecretHardWay([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req,
            [FromQuery] string name = "secret-sauce")
        {
            var accessToken = await GetToken();
            if (accessToken != null)
            {
                var kvName = _config["KV_NAME"];
                _logger.LogInformation($"C# HTTP trigger function processed a request. {kvName} {name}");

                using var httpClient = new HttpClient();
                httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);

                var secretUri = $"https://{kvName}.vault.azure.net/secrets/{name}?api-version=7.3";
                var secretResponse = await httpClient.GetAsync(secretUri);

                if (secretResponse.IsSuccessStatusCode)
                {
                    var secretContent = await secretResponse.Content.ReadAsStringAsync();
                    return new OkObjectResult(secretContent);
                }
                else
                {
                    var errorContent = await secretResponse.Content.ReadAsStringAsync();
                    _logger.LogError($"Failed to get secret: {errorContent}");
                    return new ObjectResult("Failed to get secret from Key Vault.") { StatusCode = 500 };
                }
            }
            return new OkObjectResult("An error occurred while processing the request.");
        }

        private async Task<string?> GetToken()
        {
            var managedIdentityEndpoint = Environment.GetEnvironmentVariable("IDENTITY_ENDPOINT");
            var managedIdentityAuthenticationCode = Environment.GetEnvironmentVariable("IDENTITY_HEADER");
            var managedIdentityApiVersion = "2019-08-01";
            var kvName = _config["KV_NAME"];
            var resource = $"https://{kvName}.vault.azure.net/";

            _logger.LogInformation($"IDENTITY_ENDPOINT: {managedIdentityEndpoint}");

            var requestUri = $"{managedIdentityEndpoint}?api-version={managedIdentityApiVersion}&resource={resource}";
            _logger.LogInformation($"Request URI: {requestUri}");

            var requestMessage = new HttpRequestMessage(HttpMethod.Get, requestUri);
            requestMessage.Headers.Add("X-IDENTITY-HEADER", managedIdentityAuthenticationCode);
            requestMessage.Headers.Add("Metadata", "true");

            try
            {
                using var httpClient = new HttpClient();
                var response = await httpClient.SendAsync(requestMessage)
                    .ConfigureAwait(false);

                response.EnsureSuccessStatusCode();

                var tokenResponseString = await response.Content.ReadAsStringAsync()
                    .ConfigureAwait(false);

                using var doc = System.Text.Json.JsonDocument.Parse(tokenResponseString);
                var accessToken = doc.RootElement.GetProperty("access_token").GetString();

                return accessToken;
            }
            catch (Exception ex)
            {
                string errorText = String.Format("{0} \n\n{1}", ex.Message, ex.InnerException != null ? ex.InnerException.Message : "Acquire token failed");

                _logger.LogError(errorText);
            }

            return null;
        }

        [Function("GetSecret")]
        public async Task<IActionResult> GetSecret([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req,
            [FromQuery] string name = "secret-sauce",
            [FromQuery] string credentialType = "DefaultAzureCredential")
        {
            var kvName = _config["KV_NAME"];
            _logger.LogInformation($"C# HTTP trigger function processed a request. {name} {credentialType} {kvName}");

            try
            {
                var tokenCredential = GetTokenCredential(credentialType);
                var client = new SecretClient(new Uri($"https://{kvName}.vault.azure.net/"), tokenCredential);
                var secret = await client.GetSecretAsync(name);
                return new OkObjectResult(secret.Value);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get secret from Key Vault.");
                return new ObjectResult("Failed to get secret from Key Vault.") { StatusCode = 500 };
            }
        }

        private TokenCredential GetTokenCredential(string credentialType)
        {
            switch (credentialType)
            {
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
