using Microsoft.EntityFrameworkCore;

namespace SAI.Models.DominioModel
{
    [Keyless]
    public class Usuario
    {
        public int UsuarioId { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Rol { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}
