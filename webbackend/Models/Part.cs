using System.Text.Json.Serialization;
using PartsDb.Api.Converters;

namespace PartsDb.Api.Models;

public class Part
{
    public int Batch { get; set; }
    public string Artnr { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    [JsonConverter(typeof(FlexibleIntConverter))]
    public int? Stock { get; set; }

    public string? Class { get; set; }
    public string? Value1 { get; set; }
    public string? Value2 { get; set; }
    public string? Mark { get; set; }
}

public class PartsResponse
{
    public List<Part> Parts { get; set; } = [];
}
