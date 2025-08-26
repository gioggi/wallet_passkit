# WalletPasskit – Google Wallet Guide

Helpers to create Save to Google Wallet links and update Loyalty cards using Ruby.

### What you can do
- Generate a "Save to Google Wallet" link (JWT)
- Customize brand colors, logo, hero image, and store locations
- Assign a QR/barcode and dynamic loyalty points
- Update points later via REST (PATCH)

---

## Prerequisites
- A Google Wallet Issuer account for your business
- A Google Cloud project with the Google Wallet API enabled
- A Service Account with a JSON key file

---

## Step-by-step setup

### 1) Request/Configure your Issuer
- Open the Google Pay & Wallet Console: `https://pay.google.com/business/console`
- Request an Issuer account if you do not have one yet and complete verification (business info, branding, domain if applicable)
- Note your Issuer ID (a long numeric id, e.g. `3388000000000000000`)

### 2) Enable the API in Google Cloud
- Go to `https://console.cloud.google.com` and select or create a project
- Enable "Google Wallet API" from the API Library

### 3) Create a Service Account + key
- In Google Cloud Console: IAM & Admin → Service Accounts → Create
- Grant a role that can access Wallet Objects (Editor is sufficient for development)
- Create a JSON key and download it
- Store it in your app, e.g. `config/google/service_account.json`

### 4) Grant the Service Account access to the Issuer
- In the Google Pay & Wallet Console, add the service account email as a member/collaborator for your Issuer so it can create/update objects

### 5) Create a LoyaltyClass
Your passes (objects) must reference an existing LoyaltyClass.

You can create it via the Console (if available) or via REST API. The class id format is:

- `loyaltyClass.id = "<ISSUER_ID>.<CLASS_ID>"` (e.g., `3388000000000000000.keristo_loyalty`)

Minimal LoyaltyClass via REST:

```bash
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "3388000000000000000.keristo_loyalty",
    "issuerName": "My Brand",
    "programName": "Keristo Loyalty",
    "reviewStatus": "underReview"
  }' \
  https://walletobjects.googleapis.com/walletobjects/v1/loyaltyClass
```

You can add branding fields later (logo, colors, etc.) directly on the class or customize per-object.

---

## Configuration in your app
Add the service account path to your configuration. For Rails:

```ruby
Rails.application.config.wallet_passkit.google_service_account_credentials = \
  Rails.root.join("config", "google", "service_account.json").to_s
```

---

## Generate a Save to Google Wallet link
Build your company and customer hashes, then create the URL.

```ruby
company = {
  issuer_id: ENV["GOOGLE_ISSUER_ID"],      # e.g. "3388000000000000000"
  class_id:  "keristo_loyalty",           # your LoyaltyClass suffix
  background_color: "#112233",            # optional
  font_color: "#FFFFFF",                  # optional
  logo_uri: "https://example.com/logo.png",        # optional
  hero_image_uri: "https://example.com/hero.png",  # optional
  locations: [ { latitude: 45.4642, longitude: 9.1900 } ] # optional
}

customer = {
  id: "customer-123",
  first_name: "Mario",
  last_name: "Rossi",
  points: 120,
  qr_value: "UUID-1234" # or use :barcode_value and optional :barcode_type
}

url = WalletPasskit::Google::Pass.new(
  company: company,
  customer: customer,
  service_account_path: Rails.application.config.wallet_passkit.google_service_account_credentials
).save_url
# Redirect the user to `url`, or render it as a link/button
```

What the gem generates
- A JWT with `payload.loyaltyObjects[0]` that includes your colors, images, locations, and the customer’s points/barcode
- The Save URL: `https://pay.google.com/gp/v/save/<JWT>`

---

## Update points later (PATCH)
Use the object id format: `<ISSUER_ID>.<CUSTOMER_ID>`.

```ruby
object_id = "#{company[:issuer_id]}.#{customer[:id]}"

WalletPasskit::Google::PassUpdater.new(
  object_id: object_id,
  service_account_path: Rails.application.config.wallet_passkit.google_service_account_credentials
).update_points(new_point_value: 480)
```

---

## Troubleshooting
- 401/403 errors: ensure the Service Account is added to your Issuer in the Wallet Console and the API is enabled
- Not found: verify the LoyaltyClass exists and your object references `classId = "<ISSUER_ID>.<CLASS_ID>"`
- Branding not visible: check whether you set colors/images on the class vs object; some UI elements derive from the class

---

## Useful links
- Developer site: `https://developers.google.com/wallet`
- Loyalty cards API reference: `https://developers.google.com/wallet/retail/loyalty-cards`

