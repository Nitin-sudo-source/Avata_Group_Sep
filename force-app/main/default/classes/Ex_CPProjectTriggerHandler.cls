public class Ex_CPProjectTriggerHandler {
    Public static void beforeInsert(List<CP_Project__c> newCPProjects){
        List<CP_Project__c>cpProjectList = new List<CP_Project__c>();
        
        for(CP_Project__c cp: newCPProjects){
            if(cp.Project__c != null && cp.Channel_Partner__c != null){
                cpProjectList.add(cp);
            }
        }
        if(cpProjectList != null && !cpProjectList.isEmpty()){
            Ex_CPProjectTriggerHandlerServices.duplicationCheck(cpProjectList);
        } 
    }
    
    
    public static void beforeUpdate(Map<Id, CP_Project__c> oldMap, Map<Id, CP_Project__c> newMap) {
        List<CP_Project__c> cpProjectList = new List<CP_Project__c>();
        
        
        for(CP_Project__c oldCpProject: oldMap.values()) {
            CP_Project__c newCpProject= newMap.get(oldCpProject.Id);
            
            if(oldCpProject.Project__c != newCpProject.Project__c || oldCpProject.Channel_Partner__c != newCpProject.Channel_Partner__c && newCpProject.Project__c != null && newCpProject.Channel_Partner__c != null )
            {
                cpProjectList.add(newCpProject);
            }
        }
        if(cpProjectList != null && !cpProjectList.isEmpty())
            Ex_CPProjectTriggerHandlerServices.duplicationCheck(cpProjectList);
        
    }
}