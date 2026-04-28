using System.Text.Json;
using PartsDb.Api.Models;

namespace PartsDb.Api.Services;

public class PartsDataService
{
    private readonly string _dataPath;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public PartsDataService(IWebHostEnvironment env)
    {
        _dataPath = Path.Combine(env.ContentRootPath, "Data");
    }

    public async Task<List<Part>> GetPartsAsync()
    {
        var filePath = Path.Combine(_dataPath, "parts.json");
        await using var stream = File.OpenRead(filePath);
        var response = await JsonSerializer.DeserializeAsync<PartsResponse>(stream, JsonOptions);
        return response?.Parts ?? [];
    }

    public async Task<Part?> GetPartByArtnrAsync(string artnr)
    {
        var parts = await GetPartsAsync();
        return parts.FirstOrDefault(p =>
            string.Equals(p.Artnr, artnr, StringComparison.OrdinalIgnoreCase));
    }

    public async Task<List<Module>> GetModulesAsync()
    {
        var filePath = Path.Combine(_dataPath, "modules.json");
        await using var stream = File.OpenRead(filePath);
        var response = await JsonSerializer.DeserializeAsync<ModulesResponse>(stream, JsonOptions);
        return response?.Modules ?? [];
    }

    public async Task<List<Resistor>> GetResistorsAsync()
    {
        var filePath = Path.Combine(_dataPath, "myresistors.json");
        await using var stream = File.OpenRead(filePath);
        var resistors = await JsonSerializer.DeserializeAsync<List<Resistor>>(stream, JsonOptions);
        return resistors ?? [];
    }

    public async Task<List<BatchInfo>> GetBatchInfoAsync()
    {
        var filePath = Path.Combine(_dataPath, "batchinfo.json");
        await using var stream = File.OpenRead(filePath);
        var response = await JsonSerializer.DeserializeAsync<BatchInfoResponse>(stream, JsonOptions);
        return response?.Batchinfo ?? [];
    }

    public async Task<BatchInfo?> GetBatchByNrAsync(int batchnr)
    {
        var batches = await GetBatchInfoAsync();
        return batches.FirstOrDefault(b => b.Batchnr == batchnr);
    }

    public async Task<List<PartDetail>> GetPartDetailsAsync()
    {
        var filePath = Path.Combine(_dataPath, "partsdetails.json");
        await using var stream = File.OpenRead(filePath);
        var response = await JsonSerializer.DeserializeAsync<PartDetailsResponse>(stream, JsonOptions);
        return response?.Partsdetails ?? [];
    }

    public async Task<PartDetail?> GetPartDetailByArtnrAsync(string artnr)
    {
        var details = await GetPartDetailsAsync();
        return details.FirstOrDefault(p =>
            string.Equals(p.Artnr, artnr, StringComparison.OrdinalIgnoreCase));
    }
}

