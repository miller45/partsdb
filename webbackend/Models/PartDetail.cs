using System.Text.Json.Serialization;
using PartsDb.Api.Converters;

namespace PartsDb.Api.Models;

public class PartDetail
{
    public string Artnr { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    [JsonConverter(typeof(FlexibleIntConverter))]
    public int? Stock { get; set; }

    public string? Class { get; set; }
}

public class PartDetailsResponse
{
    public List<PartDetail> Partsdetails { get; set; } = [];
}

