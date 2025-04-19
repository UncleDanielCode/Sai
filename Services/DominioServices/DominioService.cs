using Microsoft.EntityFrameworkCore;
using SAI.Context;
using SAI.DTOs;
using SAI.DTOs.DominioDTO;
using SAI.Interfaces.DominioInterfaces;
using SAI.Models;
using SAI.Models.AuditoriaModel;
using SAI.Models.ReportesModel;
using SAI.Services.AuditoriaServices;
using System.Reflection;

namespace SAI.Services.DominioServices
{
    public class DominioService : IDominio
    {
        private readonly SaiContext _dbContext;
        private readonly NotificationService _notificationService;

        public DominioService(SaiContext dbContext, NotificationService notificationService)
        {
            _dbContext = dbContext;
            _notificationService = notificationService;
        }

        public async Task<Response<GenericResult>> SetUsuario(SetUsuarioDto param)
        {
            var Result = new Response<GenericResult>();
            try
            {
                var res = await _dbContext.ContextForEverSet.FromSqlRaw(@"dominio.SET_Usuario {0},{1},{2},{3},{4},{5},{6}",
                param.Id,
                param.Nombre,
                param.Rol,
                param.Email,
                param.Estado,
                param.Activo,
                param.IdUsuarioCrea)
                .ToListAsync();

                if (res.Any())
                    Result.SingleData = res.FirstOrDefault();
                else
                {
                    Result.Errors.Add("Error insertando la data.");
                    return Result;
                }
            }
            catch (Exception ex)
            {
                var reflectedType = MethodBase.GetCurrentMethod()?.ReflectedType?.FullName;
                if (reflectedType == null)
                {
                    Result.Errors.Add("Error obteniendo el nombre del tipo reflejado.");
                    return Result;
                }

                var res = _dbContext.SetErrorsLog.FromSqlRaw("Registro.SP_SET_ERRORS_LOG {0},{1},{2},{3},{4},{5}",
                                                            reflectedType,
                                                            ex.Message, ex.StackTrace, ex.InnerException, "Admin",
                                                            ex.GetType().Name).ToList();
                Result.Errors.Add(res.SingleOrDefault()?.ExceptionMessage ?? "Error desconocido.");
            }

            return Result;
        }

        public async Task<Response<GenericResult>> SetCliente(SetClienteDto param)
        {
            var Result = new Response<GenericResult>();
            try
            {
                var res = await _dbContext.ContextForEverSet.FromSqlRaw(@"dominio.SET_Cliente {0},{1},{2},{3},{4},{5},{6},{7}",
                param.Id,
                param.Nombre,
                param.Email,
                param.Telefono,
                param.Direccion,
                param.Estado,
                param.Activo,
                param.IdUsuarioCrea)
                .ToListAsync();

                if (res.Any())
                    Result.SingleData = res.FirstOrDefault();
                else
                {
                    Result.Errors.Add("Error insertando la data.");
                    return Result;
                }
            }
            catch (Exception ex)
            {
                var reflectedType = MethodBase.GetCurrentMethod()?.ReflectedType?.FullName;
                if (reflectedType == null)
                {
                    Result.Errors.Add("Error obteniendo el nombre del tipo reflejado.");
                    return Result;
                }

                var res = _dbContext.SetErrorsLog.FromSqlRaw("Registro.SP_SET_ERRORS_LOG {0},{1},{2},{3},{4},{5}",
                                                            reflectedType,
                                                            ex.Message, ex.StackTrace, ex.InnerException, "Admin",
                                                            ex.GetType().Name).ToList();
                Result.Errors.Add(res.SingleOrDefault()?.ExceptionMessage ?? "Error desconocido.");
            }

            return Result;
        }

        public async Task<Response<GenericResult>> SetFactura(SetFacturaDto param)
        {
            var result = new Response<GenericResult>();
            try
            {
                // 1) Ejecutar SP de inserción/actualización
                var spRes = await _dbContext.ContextForEverSet
                    .FromSqlInterpolated($@"EXEC dominio.SET_Factura {param.Id}, {param.ClienteId}, {param.Total}, {param.Estado}, {param.Activo}, {param.IdUsuarioCrea}")
                    .ToListAsync();

                if (!spRes.Any())
                {
                    result.Errors.Add("No se pudo insertar la factura.");
                    return result;
                }
                result.SingleData = spRes.First();

                // 2) Si fue inserción, notificar al cliente
                if (result.SingleData.Result.Equals("Inserted", StringComparison.OrdinalIgnoreCase))
                {
                    var newId = result.SingleData.Id;

                    // 2.1) Cargar factura y su cliente
                    var factura = await _dbContext.Facturas
                        .Include(f => f.Cliente)
                        .SingleAsync(f => f.FacturaId == newId);

                    // 2.2) Preparar datos de notificación
                    var notificationData = new InvoiceNotificationData
                    {
                        FacturaId = factura.FacturaId,
                        ClienteId = factura.ClienteId,
                        ClienteNombre = factura.Cliente.Nombre,
                        ClientEmail = factura.Cliente.Email,
                        UsuarioId = param.IdUsuarioCrea,
                        UsuarioNombre = (await _dbContext.Usuarios.FindAsync(param.IdUsuarioCrea))?.Nombre ?? string.Empty,
                        Total = factura.Total,
                        Fecha = factura.Fecha
                    };

                    // 2.3) Enviar notificación al cliente
                    await _notificationService.NotifyClientInvoiceCreatedAsync(notificationData);
                }
            }
            catch (Exception ex)
            {
                // Logging de errores vía SP
                var reflectedType = MethodBase.GetCurrentMethod()?.ReflectedType?.FullName ?? "Unknown";
                var log = await _dbContext.SetErrorsLog
                    .FromSqlInterpolated($@"Registro.SP_SET_ERRORS_LOG {reflectedType}, {ex.Message}, {ex.StackTrace}, {ex.InnerException}, 'Admin', {ex.GetType().Name}")
                    .ToListAsync();

                result.Errors.Add(log.SingleOrDefault()?.ExceptionMessage ?? "Error desconocido en SetFactura.");
            }

            return result;
        }
    }
}
