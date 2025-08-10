/**
 * @description Callout queueable to retrieve information from warehouse api
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class InventoryCallout_Queueable implements Queueable, Database.AllowsCallouts {

    private final Set<Id> orderIds;

    public InventoryCallout_Queueable(Set<Id> orderIds) {
        this.orderIds = (orderIds == null) ? new Set<Id>() : orderIds;
    }

    public void execute(QueueableContext qc) {
        if (orderIds.isEmpty()) return;

        try {
            List<Order> orders = [
                SELECT Id,
                    Status,
                    FulfillmentStatus__c,
                    (SELECT Id, Product2Id, Quantity FROM OrderItems)
                FROM Order
                WHERE Id IN :orderIds
            ];

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:InventoryAPI/check'); 
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(orders));

            Http http = new Http();
            HttpResponse res = http.send(req);

            // TODO: Parse API response and update FulfillmentStatus__c 
            for (Order o : orders) {
                if(parsedInvQuantity > orderQuantity) {
                    o.FulfillmentStatus__c = 'Inventory OK';
                } else {
                    o.FulfillmentStatus__c = 'On Hold';
                }
            }
            update orders;
        } catch (Exception e) {
            //AppLogger for this class
        }
    }
}
