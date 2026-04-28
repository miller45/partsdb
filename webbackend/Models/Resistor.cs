using System.Text.Json.Serialization;

namespace PartsDb.Api.Models;

public class Resistor
{
    [JsonPropertyName("f_value")]
    public string F_Value { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string Tolerance { get; set; } = string.Empty;
    public string Comment { get; set; } = string.Empty;
}

