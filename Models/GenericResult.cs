using System.ComponentModel.DataAnnotations;

namespace SAI.Models
{
    public class GenericResult
    {
        [Key]
        public int Id { get; set; }
        public string? Result { get; set; }
    }
}
