using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace SAI.Models.ReportesModel
{
    [Keyless]
    public class GetHistoricoClienteModel
    {
        public int? ClienteId { get; set; }
        public string? ClienteNombre { get; set; }
        public DateTime? Periodo { get; set; }
        public decimal? TotalFacturado { get; set; }
        public int? CantidadFacturas { get; set; }
    }
}
