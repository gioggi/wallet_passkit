# Google Wallet - Practical Examples

This document contains practical examples of how to use methods for creating and managing Google Wallet objects using the `wallet_passkit` gem.

## 📋 Prerequisites

- Google Cloud service account configured
- LoyaltyClass created in Google Wallet
- `wallet_passkit` gem installed

## 🔧 Configuration

```ruby
require 'wallet_passkit'

# Global configuration (RECOMMENDED)
WalletPasskit.configure do |c|
  c.google_service_account_credentials = "my-service-account-123456.json"
  c.google_issuer_id = "1234567890123456789"
  c.google_class_prefix = "com.example"
end

# After this configuration, you DON'T need to specify the service account anymore!
```

## 🔄 **Two Configuration Approaches**

### ✅ **Approach 1: Global Configuration (RECOMMENDED)**
```ruby
# Configuration ONCE at app startup
WalletPasskit.configure do |c|
  c.google_service_account_credentials = "my-service-account-123456.json"
  c.google_issuer_id = "1234567890123456789"
end

# Then you use SIMPLY:
pass = WalletPasskit::Google::Pass.new(
  company: company_data,
  customer: customer_data
  # service_account_path NOT needed anymore!
)
```

### ⚠️ **Approach 2: Local Parameters (FOR SPECIFIC CASES)**
```ruby
# Only if you need to use different service accounts for different operations
pass = WalletPasskit::Google::Pass.new(
  company: company_data,
  customer: customer_data,
  service_account_path: "other-service-account.json"  # Local override
)
```

## 🎫 Creating Google Wallet Objects

### Example 1: Complete Object Creation

```ruby
# Company data
company_data = {
  issuer_id: "1234567890123456789",
  class_id: "1",
  background_color: "#1976d2",      # Google Blue
  font_color: "#FFFFFF",            # White
  logo_uri: "https://example.com/logo.png",
  hero_image_uri: "https://example.com/hero.png",
  # Note: locations/merchantLocations requires special Google authorization
# For now, we'll skip locations to avoid API errors
# locations: [
#   { latitude: 45.4642, longitude: 9.1900 },  # Milan
#   { latitude: 41.9028, longitude: 12.4964 }  # Rome
# ]
}

# Customer data
customer_data = {
  id: "customer_#{Time.now.to_i}",
  first_name: "John",
  last_name: "Doe",
  points: 750,
  qr_value: "LOYALTY_#{Time.now.to_i}",
  barcode_value: "123456789#{Time.now.to_i}",
  barcode_type: "CODE_128"
}

# Creating the pass (AFTER global configuration)
pass = WalletPasskit::Google::Pass.new(
  company: company_data,
  customer: customer_data
  # service_account_path NOT needed anymore!
)

# Option 1: Generate Save URL only (for existing objects)
save_url = pass.save_url
puts "🔗 Save URL: #{save_url}"

# Option 2: Create object in Google Wallet AND generate Save URL
created_object = pass.create_loyalty_object
puts "🎫 Object created with ID: #{created_object['id']}"

# Option 3: Create object and get Save URL in one call
save_url = pass.create_and_save_url
puts "🔗 Save URL for new object: #{save_url}"

### Example 2: Simple Object Creation (Without Images)

```ruby
# Minimal data to avoid image loading errors
company_data = {
  issuer_id: "1234567890123456789",
  class_id: "1",
  background_color: "#1976d2",
  font_color: "#FFFFFF"
}

customer_data = {
  id: "customer_#{Time.now.to_i}",
  first_name: "Test",
  last_name: "Customer",
  points: 150,
  qr_value: "TEST_#{Time.now.to_i}"
}

pass = WalletPasskit::Google::Pass.new(
  company: company_data,
  customer: customer_data
  # service_account_path NOT needed anymore!
)

save_url = pass.save_url
```

## 🆕 **New Methods for Creating Loyalty Objects**

### **Method 1: `create_loyalty_object`**
Creates a loyalty object in Google Wallet using the API and returns the created object data.

```ruby
# Create the object in Google Wallet
created_object = pass.create_loyalty_object

if created_object && created_object['id']
  puts "✅ Object created successfully!"
  puts "   ID: #{created_object['id']}"
  puts "   State: #{created_object['state']}"
  puts "   Created at: #{created_object['createTime']}"
else
  puts "❌ Failed to create object"
end
```

### **Method 2: `create_and_save_url`**
Creates the loyalty object AND generates the save URL in one call.

```ruby
# Create object and get save URL in one operation
save_url = pass.create_and_save_url
puts "🔗 Save URL for new object: #{save_url}"
```

### **Method 3: `save_url` (existing)**
Generates save URL for existing objects (doesn't create new objects).

```ruby
# Generate save URL for existing object
save_url = pass.save_url
puts "🔗 Save URL: #{save_url}"
```

### **When to Use Each Method:**

- **`create_loyalty_object`**: When you want to create a new object and get the object data
- **`create_and_save_url`**: When you want to create a new object and immediately get the save URL
- **`save_url`**: When you already have an existing object and just need the save URL

## 🔍 Retrieving Google Wallet Objects

### Example 1: Complete Object Retrieval

```ruby
# Static class method (without creating instance)
object_data = WalletPasskit::Google::PassUpdater.retrieve_object(
  object_id: "1234567890123456789.test_customer_1234567890"
  # service_account_path NOT needed anymore!
)

puts "ID: #{object_data['id']}"
puts "State: #{object_data['state']}"
puts "Account: #{object_data['accountName']}"
puts "Points: #{object_data.dig('loyaltyPoints', 'balance', 'int')}"
puts "Created at: #{object_data['createTime']}"
```

### Example 2: Retrieval with Instance and Specific Methods

```ruby
# Creating instance for multiple operations
updater = WalletPasskit::Google::PassUpdater.new(
  object_id: "1234567890123456789.test_customer_1234567890"
  # service_account_path NOT needed anymore!
)

# Methods for specific information
puts "Current points: #{updater.get_points}"
puts "State: #{updater.get_state}"
puts "Account name: #{updater.get_account_name}"
puts "Account ID: #{updater.get_account_id}"
puts "Creation time: #{updater.get_creation_time}"
puts "Update time: #{updater.get_update_time}"

# Complete object
full_object = updater.get_object
puts "Available keys: #{full_object.keys.join(', ')}"
```

### Example 3: Existence Verification and Details

```ruby
begin
  object_data = WalletPasskit::Google::PassUpdater.retrieve_object(
    object_id: "1234567890123456789.test_customer_1234567890"
    # service_account_path NOT needed anymore!
  )
  
  puts "✅ Object found!"
  puts "   State: #{object_data['state']}"
  puts "   Points: #{object_data.dig('loyaltyPoints', 'balance', 'int')}"
  
  # Additional information
  if object_data['locations']
    puts "   Locations: #{object_data['locations'].length} configured"
  end
  
  if object_data['barcode']
    puts "   Barcode: #{object_data['barcode']['type']} - #{object_data['barcode']['value']}"
  end
  
rescue WalletPasskit::Error => e
  puts "❌ Object not found or error: #{e.message}"
end
```

## 🔄 Updating Objects

### Example: Updating Points

```ruby
updater = WalletPasskit::Google::PassUpdater.new(
  object_id: "1234567890123456789.test_customer_1234567890"
  # service_account_path NOT needed anymore!
)

# Update points
begin
  result = updater.update_points(new_point_value: 200)
  puts "✅ Points updated successfully!"
  puts "   New points: #{updater.get_points}"
rescue WalletPasskit::Error => e
  puts "❌ Error updating: #{e.message}"
end
```

## 🚀 Complete Workflow

### Example: Complete Creation and Management

```ruby
class LoyaltyCardManager
  def initialize(issuer_id, class_id)
    @issuer_id = issuer_id
    @class_id = class_id
  end
  
  def create_card(customer_data)
    company_data = {
      issuer_id: @issuer_id,
      class_id: @class_id,
      background_color: "#1976d2",
      font_color: "#FFFFFF"
    }
    
    pass = WalletPasskit::Google::Pass.new(
      company: company_data,
      customer: customer_data
      # service_account_path NOT needed after global configuration
    )
    
    save_url = pass.save_url
    puts "🎫 Card created: #{save_url}"
    
    # Returns the object ID for future operations
    "#{@issuer_id}.#{customer_data[:id]}"
  end
  
  def get_card_info(object_id)
    WalletPasskit::Google::PassUpdater.retrieve_object(
      object_id: object_id
      # service_account_path NOT needed after global configuration
    )
  end
  
  def update_points(object_id, new_points)
    updater = WalletPasskit::Google::PassUpdater.new(
      object_id: object_id
      # service_account_path NOT needed after global configuration
    )
    
    updater.update_points(new_point_value: new_points)
  end
end

# Usage (AFTER global configuration)
manager = LoyaltyCardManager.new(
  nil,  # service_account_path not needed anymore
  "1234567890123456789",
  "1"
)

# Create a new card
customer = {
  id: "customer_#{Time.now.to_i}",
  first_name: "John",
  last_name: "Smith",
  points: 100,
  qr_value: "LOYALTY_#{Time.now.to_i}"
}

object_id = manager.create_card(customer)

# Retrieve information
card_info = manager.get_card_info(object_id)
puts "Card created for: #{card_info['accountName']}"

# Update points
manager.update_points(object_id, 250)
puts "Points updated: #{manager.get_card_info(object_id).dig('loyaltyPoints', 'balance', 'int')}"
```

## ⚠️ Important Notes

### Security
- Generated links are **public** and accessible to anyone
- Implement authentication before generating links
- Consider using temporary links for greater security

### Error Handling
- Always handle `WalletPasskit::Error` exceptions
- Verify object existence before operations
- Check API response codes

### Performance
- Reuse `PassUpdater` instances for multiple operations
- Use static class method for single operations
- Cache access tokens when possible

### Known Issues and Limitations

#### **Deprecated Fields**
- **`locations` field is deprecated** according to [Google Wallet API documentation](https://developers.google.com/wallet/reference/rest/v1/loyaltyobject)
- **`merchantLocations` is the replacement** but requires special Google authorization
- **Your Issuer ID is not allowlisted** for merchant locations functionality

#### **Solutions for Locations**
1. **Contact Google Support** to request merchant locations authorization
2. **Remove locations** from your objects (current workaround)
3. **Use alternative methods** like custom text fields to display location info

#### **JWT Structure Issues**
- **Save URL JWT** now uses simplified object structure
- **API calls** use full object structure with all fields
- **Both structures** are validated and tested

## 🔗 Useful Links

- [Google Wallet API Documentation](https://developers.google.com/wallet)
- [Loyalty API Reference](https://developers.google.com/wallet/loyalty/rest)
- [Service Account Setup](https://cloud.google.com/iam/docs/service-accounts)
