using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.EntityFrameworkCore;
using MimeKit;
using SAI.Context;
using SAI.DTOs.DominioDTO;
using SAI.Interfaces.AuditoriaInterfaces;
using SAI.Models;
using SAI.Models.AuditoriaModel;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace SAI.Services.AuditoriaServices
{
    public class NotificationService : INotification
    {
       // private readonly IEmailSender _emailSender;
        private readonly IConfiguration _config;
        private readonly IWebHostEnvironment _env;

        public NotificationService(
          //  IEmailSender emailSender,
            IConfiguration config,
            IWebHostEnvironment env)
        {
           // _emailSender = emailSender;
            _config = config;
            _env = env;
        }
        public async Task NotifyAdminInvoiceCreatedAsync(InvoiceNotificationData data)
        {
            var templatePath = Path.Combine(_env.ContentRootPath, "HTML", "FacturaCreadaAdmin.html");
            var template = await File.ReadAllTextAsync(templatePath);

            var body = template
                .Replace("{FacturaId}", data.FacturaId.ToString())
                .Replace("{ClienteNombre}", data.ClienteNombre)
                .Replace("{UsuarioNombre}", data.UsuarioNombre)
                .Replace("{Fecha}", data.Fecha.ToString("dd/MM/yyyy"))
                .Replace("{Total}", data.Total.ToString("C"));

            var adminEmail = _config["Notifications:AdminEmail"]!;
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(_config["Smtp:From"]));
            message.To.Add(MailboxAddress.Parse(adminEmail));
            message.Subject = $"[Admin] Factura {data.FacturaId} Creada";
            message.Body = new BodyBuilder { HtmlBody = body }.ToMessageBody();

            await SendAsync(message);
        }

        public async Task NotifyAdminInvoiceUpdatedAsync(InvoiceNotificationData data, string diffJson)
        {
            var templatePath = Path.Combine(_env.ContentRootPath, "HTML", "FacturaModificadaAdmin.html");
            var template = await File.ReadAllTextAsync(templatePath);

            var body = template
                .Replace("{FacturaId}", data.FacturaId.ToString())
                .Replace("{UsuarioNombre}", data.UsuarioNombre)
                .Replace("{DiffJson}", diffJson);

            var adminEmail = _config["Notifications:AdminEmail"]!;
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(_config["Smtp:From"]));
            message.To.Add(MailboxAddress.Parse(adminEmail));
            message.Subject = $"[Admin] Factura {data.FacturaId} Modificada";
            message.Body = new BodyBuilder { HtmlBody = body }.ToMessageBody();

            await SendAsync(message);
        }

        public async Task NotifyAdminInvoiceDeletedAsync(InvoiceNotificationData data)
        {
            var templatePath = Path.Combine(_env.ContentRootPath, "HTML", "FacturaEliminadaAdmin.html");
            var template = await File.ReadAllTextAsync(templatePath);

            var body = template
                .Replace("{FacturaId}", data.FacturaId.ToString())
                .Replace("{UsuarioNombre}", data.UsuarioNombre);

            var adminEmail = _config["Notifications:AdminEmail"]!;
            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(_config["Smtp:From"]));
            message.To.Add(MailboxAddress.Parse(adminEmail));
            message.Subject = $"[Admin] Factura {data.FacturaId} Eliminada";
            message.Body = new BodyBuilder { HtmlBody = body }.ToMessageBody();

            await SendAsync(message);
        }

        public async Task NotifyClientInvoiceCreatedAsync(InvoiceNotificationData data)
        {
            var templatePath = Path.Combine(_env.ContentRootPath, "HTML", "FacturaCreadaCliente.html");
            var template = await File.ReadAllTextAsync(templatePath);

            var body = template
                .Replace("{FacturaId}", data.FacturaId.ToString())
                .Replace("{NombreCliente}", data.ClienteNombre)
                .Replace("{Fecha}", data.Fecha.ToString("dd/MM/yyyy"))
                .Replace("{Total}", data.Total.ToString("C"));

            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(_config["Smtp:From"]));
            message.To.Add(MailboxAddress.Parse(data.ClientEmail));
            message.Subject = "Tu factura ha sido generada";
            message.Body = new BodyBuilder { HtmlBody = body }.ToMessageBody();

            await SendAsync(message);
        }

        // Método helper para enviar cualquier MimeMessage
        private async Task SendAsync(MimeMessage message)
        {
            using var client = new SmtpClient();
            await client.ConnectAsync(_config["Smtp:Host"]!, int.Parse(_config["Smtp:Port"]!), SecureSocketOptions.SslOnConnect);
            await client.AuthenticateAsync(_config["Smtp:User"]!, _config["Smtp:Pass"]!);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}
