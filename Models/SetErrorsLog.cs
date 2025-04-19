using System.ComponentModel.DataAnnotations;

namespace SAI.Models
{
    public class SetErrorsLog
    {
        [Key]
        public int Id { get; set; }
        public string? ExceptionMessage { get; set; }
    }
}
