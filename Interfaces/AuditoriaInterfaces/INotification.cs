using SAI.DTOs.DominioDTO;
using SAI.Models.AuditoriaModel;

namespace SAI.Interfaces.AuditoriaInterfaces
{
    public interface INotification
    {
        Task NotifyClientInvoiceCreatedAsync(InvoiceNotificationData data);
        Task NotifyAdminInvoiceCreatedAsync(InvoiceNotificationData data);

        Task NotifyAdminInvoiceUpdatedAsync(InvoiceNotificationData data, string diffJson);

        Task NotifyAdminInvoiceDeletedAsync(InvoiceNotificationData data);

    }
}
