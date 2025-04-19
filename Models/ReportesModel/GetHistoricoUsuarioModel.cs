using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace SAI.Models.ReportesModel
{
    [Keyless]
    public class GetHistoricoUsuarioModel
    {
        public int? UsuarioId { get; set; }
        public string? UsuarioNombre { get; set; }
        public DateTime? Periodo { get; set; }
        public int? CantidadFacturas { get; set; }
    }
}
