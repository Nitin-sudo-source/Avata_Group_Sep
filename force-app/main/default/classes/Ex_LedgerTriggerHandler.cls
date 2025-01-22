public class Ex_LedgerTriggerHandler {
     public static void beforeDelete(Map<Id, Ledger__c> oldMap, Map<Id, Ledger__c> newMap) {
        Set<Id> lIdSet = new Set<Id>();

        for(Ledger__c oldLedger: oldMap.values()) {
            if(oldLedger.Type__c.equalsIgnoreCase('Credit') && !oldLedger.Cancelled__c)
                lIdSet.add(oldLedger.Id);
        }
        if(!lIdSet.isEmpty() && lIdSet != null)
            Ex_LedgerHandlerServices.reverseCalculationOnDemandAndReceipt(lIdSet);
    }
}