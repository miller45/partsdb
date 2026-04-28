using Microsoft.AspNetCore.Mvc;
using PartsDb.Api.Models;
using PartsDb.Api.Services;

namespace PartsDb.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PartsController(PartsDataService dataService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<Part>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var parts = await dataService.GetPartsAsync();
        return Ok(parts);
    }

    [HttpGet("find")]
    [ProducesResponseType<Part>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByArtnr([FromQuery] string artnr)
    {
        var part = await dataService.GetPartByArtnrAsync(artnr);
        return part is null ? NotFound() : Ok(part);
    }
}

