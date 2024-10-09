public class SMSTriggerHandler {
    public static void afterInsert(List<SMS__c> smsList) {
        Set<Id> smsIdSet = new Set<Id>();
        
        for(SMS__c s: smsList) {
            if(s.Id != null && s.Sender_Mobile_No__c != null) {
                smsIdSet.add(s.Id);
            }
        }   
        if(!smsIdSet.isEmpty() && smsIdSet != null)
            SMSHandlerServices.outboundSMS(smsIdSet);
    }
}