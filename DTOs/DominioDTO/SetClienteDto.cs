using System.ComponentModel.DataAnnotations;

namespace SAI.DTOs.DominioDTO
{
    public class SetClienteDto
    {
        [Key]
        public int? Id { get; set; }
        public string? Nombre { get; set; }
        public string? Email { get; set; }
        public string? Telefono { get; set; }
        public string? Direccion { get; set; }
        public string? Estado { get; set; } // CHAR(2)
        public bool? Activo { get; set; }
        public int IdUsuarioCrea { get; set; } // requerido
    }
}
