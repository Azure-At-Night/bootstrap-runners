Date=$(date +'%Y-%m-%dT%H-%M-%S')
TemplateFilePath='./bootstrap.bicep'
 
az deployment sub create \
  --name "terraformlearn-$Date" \
  --location "eastus" \
  --template-file $TemplateFilePath \
  --what-if
