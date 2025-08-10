/**
 * @description Selector Layer for Order Object
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class OrderSelector {
    public static List<Order> selectById(Set<Id> orderIds){
        if (orderIds == null || orderIds.isEmpty()) return new List<Order>();
        return [
            SELECT Id,
                   AccountId,
                   Account.Tier__c,
                   Account.AutoApprovalLimit__c,
                   RushRequested__c,
                   GrandTotal__c,
                   ApprovalStatus__c,
                   FulfillmentStatus__c,
                   Status
            FROM Order
            WHERE Id IN :orderIds
        ];
    }
}
