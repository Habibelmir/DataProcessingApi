#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 7074
EXPOSE 443


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["ProcessServices.csproj", "./"]
RUN dotnet restore "ProcessServices.csproj"

COPY . .
RUN dotnet build "ProcessServices.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProcessServices.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

RUN mkdir -p /app/certificates
RUN mkdir -p /app/Uploads

COPY certificates/aspnetapp.pfx /app/certificates/
ENTRYPOINT ["dotnet", "ProcessServices.dll"]
