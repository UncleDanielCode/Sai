using SAI.Interfaces.DominioInterfaces;
using SAI.Services.DominioServices;
using SAI.Context;
using SAI.Interfaces.AuditoriaInterfaces;
using SAI.Services.AuditoriaServices;
using Microsoft.AspNetCore.Builder.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(
        policy =>
        {
            policy.WithOrigins("*");
        });
});

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSqlServer<SaiContext>(builder.Configuration.GetConnectionString("AppConnection"));
builder.Services.AddScoped<IDominio, DominioService>();
builder.Services.AddScoped<INotification, NotificationService>();
//builder.Services.AddScoped<IAuth, AuthServices>();
builder.Services.AddScoped<NotificationService>();
var app = builder.Build();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(option => option.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
