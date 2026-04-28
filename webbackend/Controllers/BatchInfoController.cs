using Microsoft.AspNetCore.Mvc;
using PartsDb.Api.Models;
using PartsDb.Api.Services;

namespace PartsDb.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BatchInfoController(PartsDataService dataService) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<BatchInfo>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var batches = await dataService.GetBatchInfoAsync();
        return Ok(batches);
    }

    [HttpGet("{batchnr:int}")]
    [ProducesResponseType<BatchInfo>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByNr(int batchnr)
    {
        var batch = await dataService.GetBatchByNrAsync(batchnr);
        return batch is null ? NotFound() : Ok(batch);
    }
}

