using Microsoft.Identity.Web;
using PartsDb.Api.Services;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// ── Authentication – Microsoft Entra ID (OIDC / JWT Bearer) ───────────────────────────
// Reads AzureAd:Instance / TenantId / ClientId / Audience from configuration.
// In Azure App Service these come from env vars (AzureAd__TenantId, etc.).
builder.Services.AddMicrosoftIdentityWebApiAuthentication(builder.Configuration);

// Require authentication on every endpoint by default.
// Individual endpoints can opt out with .AllowAnonymous().
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = options.DefaultPolicy;
});

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Keep property names as camelCase (matches Angular models)
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    });

builder.Services.AddOpenApi();

// Register the data service as a singleton (JSON files don't change at runtime)
builder.Services.AddSingleton<PartsDataService>();

// CORS – allow Angular dev server and allow the frontend origin to be
// configured via environment variable (used in Azure App Service config)
var allowedOrigins = builder.Configuration
    .GetSection("AllowedOrigins")
    .Get<string[]>() ?? ["http://localhost:4200"];

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendPolicy", policy =>
        policy.WithOrigins(allowedOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod());
});

// ── App pipeline ──────────────────────────────────────────────────────────────
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    // Scalar API UI at /scalar/v1  (replaces Swagger UI, compatible with .NET 9 OpenAPI)
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();
app.UseCors("FrontendPolicy");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Health check endpoint – required for Azure App Service health probes
// AllowAnonymous so load-balancer probes don’t need a bearer token.
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }))
   .WithTags("Health")
   .AllowAnonymous();

app.Run();

