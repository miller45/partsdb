using Microsoft.AspNetCore.Mvc;
using PartsDb.Api.Models;
using PartsDb.Api.Services;

namespace PartsDb.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ModulesController(PartsDataService dataService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<Module>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var modules = await dataService.GetModulesAsync();
        return Ok(modules);
    }
}

