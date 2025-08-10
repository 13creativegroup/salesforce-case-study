/**
 * @description Service class for handling order pricing calculations and approval workflows
 * @author      Eric Bentley
 * @created     2025-01-08
 */
public with sharing class PricingService {

    public class Result {
        public List<Order> ordersToUpdate = new List<Order>();
    }

    public static Result priceAndStage(
        List<Order> orders,
        Map<Id, List<OrderItem>> itemsByOrder
    ){
        CaseUtility.PricingConfig cfg = CaseUtility.getPricingConfig();
        return priceAndStage(orders, itemsByOrder, cfg);
    }

    public static Result priceAndStage(
        List<Order> orders,
        Map<Id, List<OrderItem>> itemsByOrder,
        CaseUtility.PricingConfig cfg
    ){
        Result res = new Result();
        if (orders == null || orders.isEmpty()) return res;

        for (Order o : orders) {
            List<OrderItem> lines = itemsByOrder.get(o.Id);
            if (lines == null || lines.isEmpty()) continue;

            Customer_Tier__mdt tier = cfg.tierRulesByName.get(o.Account.Tier__c);
            Decimal tierPct  = tier.DiscountPct__c;
            Integer bulkMin  = Integer.valueOf(cfg.bulkRule.MinQuantity__c);
            Decimal bulkPct  = cfg.bulkRule.DiscountPct__c;
            Decimal rushPct  = (o.RushRequested__c) ? cfg.rushRule.SurchargePct__c : 0;

            Decimal undiscounted = 0, discounted = 0;

            for (OrderItem li : lines) {
                Decimal qty  = (li.Quantity == null)  ? 0 : li.Quantity;
                Decimal unit = (li.UnitPrice == null) ? 0 : li.UnitPrice;

                Decimal lineBase      = unit * qty; 
                undiscounted         += lineBase;

                Decimal unitAfterTier = unit * (1 - tierPct);
                Decimal unitNet       = (qty >= bulkMin) ? unitAfterTier * (1 - bulkPct) : unitAfterTier;

                discounted += unitNet * qty;
            }
            Decimal surcharge  = discounted * rushPct;
            Decimal grandTotal = discounted + surcharge;

            o.Subtotal__c       = discounted.setScale(2, RoundingMode.HALF_UP);
            o.DiscountTotal__c  = (undiscounted - discounted).setScale(2, RoundingMode.HALF_UP);
            o.SurchargeTotal__c = surcharge.setScale(2, RoundingMode.HALF_UP);
            o.GrandTotal__c     = grandTotal.setScale(2, RoundingMode.HALF_UP);

            Decimal limit = (o.Account.AutoApprovalLimit__c != null)
                ? o.Account.AutoApprovalLimit__c
                : tier.AutoApprovalLimit__c;

            if (grandTotal > limit) {
                o.ApprovalStatus__c    = 'Needs Manager';
                o.Status               = 'Manager approval';  // per requirements
            } else {
                o.ApprovalStatus__c    = 'Auto-Approved';
                o.Status               = 'Ready for Fulfillment'; // your business choice
            }

            o.FulfillmentStatus__c = 'Pending'; // inventory check will update this later

            res.ordersToUpdate.add(o);
        }
        return res;
    }
}
