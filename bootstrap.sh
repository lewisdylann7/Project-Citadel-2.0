az group create --name rg-citadel-mgmt-can --location canadaeast

# 2. Hardened State Storage (The 'Brain' of Terraform)
az storage account create \
  --name stcitadelstateprod01 \
  --resource-group rg-citadel-mgmt-can \
  --sku Standard_ZRS \
  --min-tls-version TLS1_2

# 3. THE FIX: Enable Recovery (Soft Delete) and Versioning
# This allows us to 'Undo' any accidental deletions of our infrastructure memory.
az storage account blob-service-properties update \
  --account-name stcitadelstateprod01 \
  --resource-group rg-citadel-mgmt-can \
  --enable-delete-retention true \
  --delete-retention-days 7 --enable-versioning true

# 4. Apply Immutability Policy (WORM)
# This prevents even an Admin from deleting the state for 7 days.
az storage container create --name tfstate --account-name stcitadelstateprod01
az storage container immutability-policy create \
  --account-name stcitadelstateprod01 --container-name tfstate \
  --period 7 --allow-protected-append-writes true