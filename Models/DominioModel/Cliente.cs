using Microsoft.EntityFrameworkCore;

namespace SAI.Models.DominioModel
{
    [Keyless]
    public class Cliente
    {
        public int ClienteId { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}
