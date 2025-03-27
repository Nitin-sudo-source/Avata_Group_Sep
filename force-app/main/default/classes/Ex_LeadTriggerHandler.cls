public class Ex_LeadTriggerHandler {
    public static void beforeInsert(List<Lead__c> leadList) {
        List<Lead__c> lList = new List<Lead__c>();
        List<Lead__c> lListforDirect = new List<Lead__c>();
        
        for(Lead__c l: leadList) {
            if(l.Direct_Lead__c != true)
                lList.add(l);
            else
                lListforDirect.add(l);                
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('Yes', lList);
        if(!lListforDirect.isEmpty() && lListforDirect != null)
            Ex_LeadHandlerServices.duplicationCheck('No', lListforDirect);
    }
    
    
    public static void beforeUpdate(Map<Id, Lead__c> oldMap, Map<Id, Lead__c> newMap) {
        List<Lead__c> lList = new List<Lead__c>();
        List<Lead__c> LeadList = new List<Lead__c>();
        
        for(Lead__c oldLead: oldMap.values()) {
            Lead__c newLead = newMap.get(oldLead.Id);
            
            if(oldLead.Mobile__c != newLead.Mobile__c || oldLead.Phone__c != newLead.Phone__c || oldLead.Project__c != newLead.Project__c || 
               oldLead.Email__c != newLead.Email__c || oldLead.Alternate_Email__c != newLead.Alternate_Email__c)
            {
                lList.add(newLead);
            }
            
            if(oldLead.Presales_Call_Count__c != newLead.Presales_Call_Count__c && newLead.Presales_Call_Count__c == 1){
                LeadList.add(newLead);
            }
        }
        if(!lList.isEmpty() && lList != null)
            Ex_LeadHandlerServices.duplicationCheck('No', lList);
        if(!LeadList.isEmpty() && LeadList != null){
            Ex_LeadHandlerServices.updateFirstCallDate(LeadList);
        }
    }
}