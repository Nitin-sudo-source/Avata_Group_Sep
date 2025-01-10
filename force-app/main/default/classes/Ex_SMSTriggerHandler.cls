public class Ex_SMSTriggerHandler {
    public static void afterInsert(List<SMS__c> smsList) {
         Set<Id> smsIdSet = new Set<Id>();
        
        for(SMS__c s: smsList) {
            if(s.Id != null && s.Mobile__c != null) {
                smsIdSet.add(s.Id);
            }
        }   
        if(!smsIdSet.isEmpty() && smsIdSet != null)
            Ex_SMSTriggerHandlerServices.outboundSMS(smsIdSet);
    }

}