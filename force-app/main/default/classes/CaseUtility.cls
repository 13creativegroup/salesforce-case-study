/**
 * @description Utility class to fetch custom metadata records and values
 * @author      Eric Bentley
 * @created     2025-01-08
 */
 public with sharing class CaseUtility {

    public class PricingConfig {
        public Map<String, Customer_Tier__mdt> tierRulesByName;
        public Bulk_Discount__mdt bulkRule;
        public Rush_Surcharge__mdt rushRule;
    }

    public static PricingConfig getPricingConfig() {
        PricingConfig cfg = new PricingConfig();

        // Build tier rules keyed by TierName__c
        cfg.tierRulesByName = new Map<String, Customer_Tier__mdt>();
        for (Customer_Tier__mdt rec : [
            SELECT TierName__c, DiscountPct__c, AutoApprovalLimit__c
            FROM Customer_Tier__mdt
        ]) {
            cfg.tierRulesByName.put(rec.TierName__c, rec);
        }

        cfg.bulkRule = [
            SELECT MinQuantity__c, DiscountPct__c
            FROM Bulk_Discount__mdt
            LIMIT 1
        ];

        cfg.rushRule = [
            SELECT SurchargePct__c
            FROM Rush_Surcharge__mdt
            LIMIT 1
        ];

        return cfg;
    }
}