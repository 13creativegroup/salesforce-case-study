/**
 * @description Invocable apex called from Flow for queueable pricing calculation + queueable callout
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class OrderProcessingAction {
    @InvocableMethod(label='Process Orders' description='Trigger async processing for given Orders.')
    public static void run(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }
        System.enqueueJob(new OrderProcessing_Queueable(orderIds));
    }
}