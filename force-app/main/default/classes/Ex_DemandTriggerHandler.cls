//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_DemandTriggerHandler {
    public static void afterInsert(List<Demand__c> dList) {
        Set<Id> demandIdSet = new Set<Id>();
        
        for(Demand__c d: dList) {
            demandIdSet.add(d.Id);
        }
        if(!demandIdSet.isEmpty() && demandIdSet != null)
            Ex_DemandHandlerServices.createDebitLedgerAndUpdateLastDemandNo(demandIdSet);
    }
    
    public static void afterUpdate(Map<Id, Demand__c> oldMap, Map<Id, Demand__c> newMap) {
        Set<Id> reverseDemandIdSet = new Set<Id>();
        
        for(Demand__c oldDemand: oldMap.values()) {
            Demand__c newDemand = newMap.get(oldDemand.Id);
            
            if(oldDemand.Demand_Status__c != newDemand.Demand_Status__c && newDemand.Demand_Status__c.equalsIgnoreCase('Reverse'))
                reverseDemandIdSet.add(newDemand.Id);
        }
        if(!reverseDemandIdSet.isEmpty() && reverseDemandIdSet != null && Ex_CheckRecursive.runOnce())
            Ex_DemandHandlerServices.reverseDemandCalculation(reverseDemandIdSet);
    }
    
    public static void beforeDelete(Map<Id, Demand__c> oldMap, Map<Id, Demand__c> newMap) {
        Set<Id> deletedDemandIdSet = new Set<Id>();
        
        for(Demand__c oldDemand: oldMap.values()) {
            deletedDemandIdSet.add(oldDemand.Id);
        }
        if(!deletedDemandIdSet.isEmpty() && deletedDemandIdSet != null)
            Ex_DemandHandlerServices.deletedDemandCalculation(deletedDemandIdSet);
    }
    
    
}