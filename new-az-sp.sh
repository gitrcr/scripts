#!/bin/bash
# 0. Ejecuta en  Cloud Shell el contenido del comentario DIRECT.

<<DIRECT
bash <(wget -qO - https://raw.githubusercontent.com/gitrcr/azure/refs/heads/main/bin/new-az-sp.sh)
DIRECT

# 1. Inicio de sesión en Azure (opcional si ya estás logueado)
# az login

# 2. Establecer la suscripción activa (opcional si ya está seleccionada)
# az account set --subscription "your-subscription-id"

# 3. Obtener el ID de la suscripción y asignarlo a una variable
subscriptionId=$(az account show --query id --output tsv)

# 4. Crear un Service Principal y extraer sus credenciales
read -p "Enter the name of the Principal Service (example terra3-sp): " service_principal_name
echo "Creating Service Principal..."
sp_output=$(az ad sp create-for-rbac --name "$service_principal_name" --role="Contributor" --scopes="/subscriptions/$subscriptionId" --output json)

# 5. Extraer valores del JSON
client_id=$(echo $sp_output | jq -r '.appId')
client_secret=$(echo $sp_output | jq -r '.password')
tenant_id=$(echo $sp_output | jq -r '.tenant')

# 6. Resultado y bloque para copiar en terraform.tf
echo "Service Principal created: $service_principal_name"
echo "### Insert the rows betwen ---- in the file terraform.tf ###"

echo "----"
echo "lab_subscription_id = \"$subscriptionId\""
echo "lab_tenant_id       = \"$tenant_id\""
echo "lab_client_id       = \"$client_id\""
echo "lab_client_secret   = \"$client_secret\""
echo "----"  
echo ""

# 7. Addons info
echo "##Management App accounts: Entra ID/App registrations (All applications)"
echo "az ad app list --query "[].{displayName: displayName, appId: appId}" --output table"
echo ""
az ad app list --query "[].{displayName: displayName, appId: appId}" --output table
echo ""
echo "#Secret change, add DisplayName to the end of the command" 
echo "az ad sp credential reset --name "
echo ""
echo "#Delete SP account, add AppId to the end of the command"
echo  "az ad sp delete --id "
echo ""
echo "Fin del script"
