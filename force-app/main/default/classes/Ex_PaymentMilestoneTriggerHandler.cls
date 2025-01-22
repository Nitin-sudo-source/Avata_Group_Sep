public class Ex_PaymentMilestoneTriggerHandler {
    public static void afterUpdate(Map<Id, Payment_Milestone__c> oldMap, Map<Id, Payment_Milestone__c> newMap) {
        Boolean isBatchReq = false;
        
        for(Payment_Milestone__c oldPM: oldMap.values()) {
            Payment_Milestone__c newPM = newMap.get(oldPM.Id);
            
            if(oldPM.Is_Due__c != newPM.Is_Due__c && newPM.Is_Due__c){
                isBatchReq = true;
                system.debug('inside true::::'+isBatchReq);
            }
        } 
        
        if(isBatchReq)
            Database.executeBatch(new Ex_DemandRaiseBatch(),1); // Calling Batch Class
    }
}