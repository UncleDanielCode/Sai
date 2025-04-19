using System.ComponentModel.DataAnnotations;

namespace SAI.DTOs.DominioDTO
{
    public class SetUsuarioDto
    {
        [Key]
        public int? Id { get; set; }
        public string? Nombre { get; set; }
        public string? Rol { get; set; }
        public string? Email { get; set; }
        public string? Estado { get; set; } // CHAR(2)
        public bool? Activo { get; set; }
        public int IdUsuarioCrea { get; set; }
    }
}
