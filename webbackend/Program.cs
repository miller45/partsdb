using PartsDb.Api.Services;

var builder = WebApplication.CreateBuilder(args);

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
    // Swagger UI at /swagger
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/openapi/v1.json", "PartsDB API v1"));
}

app.UseHttpsRedirection();
app.UseCors("FrontendPolicy");
app.UseAuthorization();
app.MapControllers();

// Health check endpoint – required for Azure App Service health probes
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }))
   .WithTags("Health");

app.Run();

