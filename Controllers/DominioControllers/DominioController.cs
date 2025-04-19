using Microsoft.AspNetCore.Mvc;
using SAI.DTOs.DominioDTO;
using SAI.Interfaces.DominioInterfaces;

namespace SAI.Controllers.DominioControllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DominioController : ControllerBase
    {
        private readonly IDominio _service;
        public DominioController(IDominio service)
        {
            this._service = service;
        }
        [HttpPost("SetUsuario")]
        public async Task<IActionResult> SetUsuario(SetUsuarioDto param)
        {
            return Ok(await _service.SetUsuario(param));
        }
        [HttpPost("SetCliente")]
        public async Task<IActionResult> SetCliente(SetClienteDto param)
        {
            return Ok(await _service.SetCliente(param));
        }
        [HttpPost("SetFactura")]
        public async Task<IActionResult> SetFactura(SetFacturaDto param)
        {
            return Ok(await _service.SetFactura(param));
        }
    }
}
