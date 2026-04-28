namespace PartsDb.Api.Models;

public class Module
{
    public string Artnr { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Stock { get; set; }
}

public class ModulesResponse
{
    public List<Module> Modules { get; set; } = [];
}

