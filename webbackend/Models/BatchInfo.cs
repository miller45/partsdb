using System.Text.Json.Serialization;
using PartsDb.Api.Converters;

namespace PartsDb.Api.Models;

public class BatchInfo
{
    public int Batchnr { get; set; }
    public string Orderdate { get; set; } = string.Empty;
}

public class BatchInfoResponse
{
    public List<BatchInfo> Batchinfo { get; set; } = [];
}

