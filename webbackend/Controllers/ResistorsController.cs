using Microsoft.AspNetCore.Mvc;
using PartsDb.Api.Models;
using PartsDb.Api.Services;

namespace PartsDb.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ResistorsController(PartsDataService dataService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<Resistor>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var resistors = await dataService.GetResistorsAsync();
        return Ok(resistors);
    }
}

