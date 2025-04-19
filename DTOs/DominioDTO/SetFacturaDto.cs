using SAI.Models.ReportesModel;
using System.ComponentModel.DataAnnotations;

namespace SAI.DTOs.DominioDTO
{
    public class SetFacturaDto
    {
        [Key]
        public int? Id { get; set; }
        public int? ClienteId { get; set; }
        public decimal? Total { get; set; }
        public string? Estado { get; set; } // CHAR(2)
        public bool? Activo { get; set; }
        public int IdUsuarioCrea { get; set; } // requerido

        public GetHistoricoClienteModel? Cliente { get; set; }
    }
}
