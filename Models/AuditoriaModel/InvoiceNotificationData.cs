using Microsoft.EntityFrameworkCore;

namespace SAI.Models.AuditoriaModel
{
    [Keyless]
    public class InvoiceNotificationData
    {
        public int FacturaId { get; set; }
        public int ClienteId { get; set; }
        public string ClienteNombre { get; set; } = string.Empty;
        public string ClientEmail { get; set; } = string.Empty;
        public int UsuarioId { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public DateTime Fecha { get; set; }
        public string? DiffJson { get; set; }
    }
}
