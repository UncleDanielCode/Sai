using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace SAI.Models.ReportesModel
{
    [Keyless]
    public class GetFacturaAuditoriaModel
    {
        public int? AuditoriaId { get; set; }
        public DateTime? FechaHora { get; set; }
        public string? Accion { get; set; }
        public int? FacturaId { get; set; }
        public DateTime? FechaFactura { get; set; }
        public decimal? Total { get; set; }
        public string? Estado { get; set; }
        public int? ClienteId { get; set; }
        public string? ClienteNombre { get; set; }
        public int? UsuarioId { get; set; }
        public string? UsuarioNombre { get; set; }
        public string? ValorAnterior { get; set; }
        public string? ValorNuevo { get; set; }
        public string? Contexto { get; set; }
    }
}
