public class Ex_CPLeadTriggerHandler {
    public static void beforeInsert(List<CP_Lead__c> leadList) {
        List<CP_Lead__c> lList = new List<CP_Lead__c>();
        
        for(CP_Lead__c l: leadList) {
            lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_CPLeadHandlerServices.duplicationCheck('Yes', lList);
    }
    
    public static void beforeUpdate(Map<Id, CP_Lead__c> oldMap, Map<Id, CP_Lead__c> newMap) {
        List<CP_Lead__c> lList = new List<CP_Lead__c>();
        
        for(CP_Lead__c oldLead: oldMap.values()) {
            CP_Lead__c newLead = newMap.get(oldLead.Id);
            
            if(oldLead.Mobile__c != newLead.Mobile__c || oldLead.Phone__c != newLead.Phone__c || oldLead.Email__c != newLead.Email__c || oldLead.Alternate_Email__c != newLead.Alternate_Email__c)
            {
                lList.add(newLead);   
            }
                
        }
        if(!lList.isEmpty() && lList != null)
            Ex_CPLeadHandlerServices.duplicationCheck('No', lList);
    }
}