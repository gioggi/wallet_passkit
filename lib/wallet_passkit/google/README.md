# WalletPasskit – Google Wallet Extension

Supporto completo alla generazione e gestione di carte fedeltà digitali per Google Wallet, scritto in Ruby.

## ✅ Funzionalità

- Generazione link "Salva in Google Wallet"
- Supporto a:
    - logo e colore aziendale
    - posizione GPS
    - punti dinamici
- Aggiornamento dei punti via API PATCH REST
- Compatibile con multi-azienda e clienti univoci

---

## 🧩 Struttura

```
lib/wallet_passkit/google/
├── pass.rb # genera JWT e link
├── pass_updater.rb # aggiorna punti
```

---

## 🚀 Setup Google Wallet API

### 1. Crea progetto Google Cloud
- [console.cloud.google.com](https://console.cloud.google.com)
- Abilita `Google Wallet API`

### 2. Crea account di servizio
- Vai su "API & Services" → Credentials → Service Account
- Scarica file `.json`
- Salvalo in `config/google_wallet/service_account.json`

### 3. Verifica dominio su:
- [pay.google.com/business/console](https://pay.google.com/business/console)

### 4. Crea una `LoyaltyClass`
- Nome es: `keristo_loyalty`
- `Issuer ID` ti verrà assegnato da Google

---

## 🔐 Configurazione ENV

```bash
GOOGLE_WALLET_ISSUER_ID=3388000000000000000
GOOGLE_WALLET_SERVICE_ACCOUNT_JSON_PATH=config/google_wallet/service_account.json
```

---

## 🔧 Esempio utilizzo
Generazione link

```ruby
WalletPasskit::Google::Pass.new(
  customer_id: customer.id,
  class_id: "keristo_loyalty",
  issuer_id: ENV["GOOGLE_WALLET_ISSUER_ID"],
  points: customer.loyalty_points,
  name: customer.full_name,
  qr_value: customer.uuid,
  company: {
    id: company.id,
    name: company.name,
    latitude: company.latitude,
    longitude: company.longitude,
    logo_url: company.logo_url,
    hero_image_url: company.hero_image_url,
    background_color: company.color_hex
  }
).save_url
```

---

## Aggiornamento punti

```ruby
object_id = "#{ENV['GOOGLE_WALLET_ISSUER_ID']}.company#{company.id}_customer#{customer.id}"

WalletPasskit::Google::PassUpdater.new(object_id: object_id)
  .update_points(new_point_value: 480)
```

---

## 🧪 Test

```bash
bundle exec rspec
```

Per testare localmente senza invio reale, puoi usare un Net::HTTP stub.

---

## 📫 Info

Maintainer: @gioggi

Google Wallet API Docs: developers.google.com/wallet

