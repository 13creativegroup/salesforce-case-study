/**
 * @description Selector Layer for OrderItem Object
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class OrderItemSelector {
    public static Map<Id, List<OrderItem>> byOrderIds(Set<Id> orderIds) {
        Map<Id, List<OrderItem>> mapOrderIdToOrderLines = new Map<Id, List<OrderItem>>();
        if (orderIds == null || orderIds.isEmpty()) return mapOrderIdToOrderLines;

        for (OrderItem oi : [
            SELECT Id, OrderId, Quantity, UnitPrice
            FROM OrderItem
            WHERE OrderId IN :orderIds
        ]) {
            List<OrderItem> orderItems = mapOrderIdToOrderLines.get(oi.OrderId);
            if (orderItems == null) {
                orderItems = new List<OrderItem>();
                mapOrderIdToOrderLines.put(oi.OrderId, orderItems);
            }
            orderItems.add(oi);
        }
        return mapOrderIdToOrderLines;
    }
}
