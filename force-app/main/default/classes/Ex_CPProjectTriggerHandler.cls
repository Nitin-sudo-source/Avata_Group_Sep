public class Ex_CPProjectTriggerHandler {
     public static void beforeInsert(List<CP_Project__c> cpProjectList) {
        List<CP_Project__c> lList = new List<CP_Project__c>();
        
        for(CP_Project__c l: cpProjectList) {
            lList.add(l);
        }
        if(!lList.isEmpty() && lList != null)
            Ex_CPProjectTriggerHandlerServices.assignCPAccountId(false, lList);
    }
    
    public static void beforeUpdate(Map<Id, CP_Project__c> oldMap, Map<Id, CP_Project__c> newMap) {
        List<CP_Project__c> lList = new List<CP_Project__c>();
        
        for(CP_Project__c oldCPProject: oldMap.values()) {
            CP_Project__c newCPProject = newMap.get(oldCPProject.Id);
            
            if(oldCPProject.Channel_Partner__c != newCPProject.Channel_Partner__c && newCPProject.Channel_Partner__c != null)
            {
                lList.add(newCPProject);   
            }
                
        }
        if(!lList.isEmpty() && lList != null)
            Ex_CPProjectTriggerHandlerServices.assignCPAccountId(true, lList);
    }

}