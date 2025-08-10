/**
 * @description Queueable Class called from invocable method calculating final pricing of order
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class OrderProcessing_Queueable implements Queueable {

    private final Set<Id> orderIds;

    public OrderProcessing_Queueable(List<Id> orderIds) {
        this.orderIds = orderIds;
    }

    public void execute(QueueableContext qc) {
        if (orderIds.isEmpty()) return;

        try {
            // Would normally delegate this logic to a service, but to save time
            List<Order> orders = OrderSelector.selectById(orderIds);
            Map<Id, List<OrderItem>> itemsByOrder = OrderItemSelector.byOrderIds(orderIds);

            // Pricing calculation
            PricingService.Result res = PricingService.priceAndStage(orders, itemsByOrder);

            if (!res.ordersToUpdate.isEmpty()) {
                update res.ordersToUpdate;
            }

            // Only perform callout for orders ready to go immediately
            Set<Id> eligibleForInventory = new Set<Id>();
            for (Order o : res.ordersToUpdate) {
                if (o.ApprovalStatus__c == 'Auto-Approved') {
                    eligibleForInventory.add(o.Id);
                }
            }
            if(!eligibleForInventory.isEmpty()) {
                System.enqueueJob(new InventoryCallout_Queueable(eligibleForInventory));
            }
        } catch (Exception e) {
            //AppLogger for callout here 
        }
    }
}
