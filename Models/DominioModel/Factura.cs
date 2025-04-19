using Microsoft.EntityFrameworkCore;

namespace SAI.Models.DominioModel
{
    [Keyless]
    public class Factura
    {
        public int FacturaId { get; set; }
        public int ClienteId { get; set; }
        public Cliente Cliente { get; set; } = null!;
        public DateTime Fecha { get; set; }
        public decimal Total { get; set; }
        public bool Activo { get; set; }
        public string Estado { get; set; } = string.Empty;
        public int IdUsuarioCrea { get; set; }
        public DateTime FechaCrea { get; set; }
        public int? IdUsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
