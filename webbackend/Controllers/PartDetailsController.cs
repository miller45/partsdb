using Microsoft.AspNetCore.Mvc;
using PartsDb.Api.Models;
using PartsDb.Api.Services;

namespace PartsDb.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PartDetailsController(PartsDataService dataService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<PartDetail>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var details = await dataService.GetPartDetailsAsync();
        return Ok(details);
    }

    [HttpGet("find")]
    [ProducesResponseType<PartDetail>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> FindByArtnr([FromQuery] string artnr)
    {
        var detail = await dataService.GetPartDetailByArtnrAsync(artnr);
        return detail is null ? NotFound() : Ok(detail);
    }
}

