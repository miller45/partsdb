using System.Text.Json;
using System.Text.Json.Serialization;

namespace PartsDb.Api.Converters;

/// <summary>
/// Reads a JSON value that may be either a number or a numeric string and returns an int?.
/// Writes as a number.
/// </summary>
public class FlexibleIntConverter : JsonConverter<int?>
{
    public override int? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Number)
            return reader.GetInt32();

        if (reader.TokenType == JsonTokenType.String)
        {
            var s = reader.GetString();
            if (int.TryParse(s, out var v)) return v;
            return null;
        }

        if (reader.TokenType == JsonTokenType.Null)
            return null;

        throw new JsonException($"Unexpected token {reader.TokenType} when parsing int.");
    }

    public override void Write(Utf8JsonWriter writer, int? value, JsonSerializerOptions options)
    {
        if (value.HasValue) writer.WriteNumberValue(value.Value);
        else writer.WriteNullValue();
    }
}

