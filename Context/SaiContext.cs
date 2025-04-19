using Microsoft.EntityFrameworkCore;
using SAI.Models;
using SAI.Models.DominioModel;
using SAI.Models.ReportesModel;

namespace SAI.Context
{
    public class SaiContext : DbContext
    {
        public SaiContext(DbContextOptions<SaiContext> options) : base(options) { }

        // Domain entities
        public DbSet<Factura> Facturas { get; set; }
        public DbSet<Cliente> Clientes { get; set; }
        public DbSet<Usuario> Usuarios { get; set; }

        // Stored-proc results & logs
        public DbSet<GenericResult> ContextForEverSet { get; set; }
        public DbSet<SetErrorsLog> SetErrorsLog { get; set; }

        // Audit/reporting models (keyless)
        public DbSet<GetFacturaAuditoriaModel> FacturaAuditoria { get; set; }
        public DbSet<GetHistoricoClienteModel> HistoricoCliente { get; set; }
        public DbSet<GetHistoricoUsuarioModel> HistoricoUsuario { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Keyless DTOs — no mapean a tablas reales
            modelBuilder.Entity<GetFacturaAuditoriaModel>()
                        .HasNoKey()
                        .ToView(null);

            modelBuilder.Entity<GetHistoricoClienteModel>()
                        .HasNoKey()
                        .ToView(null);

            modelBuilder.Entity<GetHistoricoUsuarioModel>()
                        .HasNoKey()
                        .ToView(null);

            modelBuilder.Entity<GenericResult>()
                        .HasNoKey()
                        .ToView(null);

            modelBuilder.Entity<SetErrorsLog>()
                        .HasNoKey()
                        .ToView(null);

            base.OnModelCreating(modelBuilder);
        }

    }
}
