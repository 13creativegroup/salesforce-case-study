# Order Management System

A Salesforce order processing solution with automated pricing, inventory management, and approval workflows.

## Features

- **Automated Pricing**: Customer tier discounts, bulk pricing, and rush surcharges
- **Approval Workflow**: Auto-approval based on customer limits and order totals  
- **Inventory Management**: Asynchronous inventory checks and updates
- **Order Processing**: Complete order lifecycle management

## Components

- `PricingService` - Core pricing calculations and approval logic
- `CaseUtility` - Configuration management via custom metadata
- `InventoryCallout_Queueable` - External inventory system integration
- `OrderProcessing_Queueable` - Internal inventory processing
- `OrderSelector/OrderItemSelector` - Data access layer

## Structure

```
force-app/main/default/
├── classes/           # Apex classes
```

## Author

Eric Bentley 
