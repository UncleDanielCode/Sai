using SAI.DTOs;
using SAI.DTOs.DominioDTO;
using SAI.Models;

namespace SAI.Interfaces.DominioInterfaces
{
    public interface IDominio
    {
        Task<Response<GenericResult>> SetUsuario(SetUsuarioDto param);
        Task<Response<GenericResult>> SetCliente(SetClienteDto param);
        Task<Response<GenericResult>> SetFactura(SetFacturaDto param);
    }
}
