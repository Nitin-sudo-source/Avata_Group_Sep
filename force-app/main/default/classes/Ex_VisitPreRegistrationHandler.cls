// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 09-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_VisitPreRegistrationHandler {
    public static void beforeInsert(List<Visit_Pre_Registration__c> preList){
        List<Visit_Pre_Registration__c> vprLeadList = new List<Visit_Pre_Registration__c>();
        List<Visit_Pre_Registration__c> vprCPList = new List<Visit_Pre_Registration__c>();
        
        if(!preList.isEmpty() && preList != null){
            for (Visit_Pre_Registration__c vpr : preList) {
                if(vpr.Lead__c != null){
                    vprLeadList.add(vpr);
                }
                if(vpr.CP_Lead__c != null){
                    vprCPList.add(vpr);
                }
            }
        }
        
        if(!vprLeadList.isEmpty() && vprLeadList != null){
            Ex_VisitPreRegistrationHandlerServices.createVPRLead(vprLeadList);
        }
        if(!vprCPList.isEmpty() && vprCPList != null){
            Ex_VisitPreRegistrationHandlerServices.createVPRLead(vprCPList);
        }
    }
    
    public static void beforeUpdate(Map<Id, Visit_Pre_Registration__c> oldMap, Map<Id, Visit_Pre_Registration__c> newMap) {
        List<Visit_Pre_Registration__c> vprlList = new List<Visit_Pre_Registration__c>();
        
        for(Visit_Pre_Registration__c oldVpr: oldMap.values()) {
            Visit_Pre_Registration__c newVpr = newMap.get(oldVpr.Id);
            
            if(newVpr.Extend_Validity_In_Hours__c != null && newVpr.Pre_Registration_Expiry__c != null){
                vprlList.add(newvpr);
                
            }
                
        }
         if(!vprlList.isEmpty() && vprlList != null){
            Ex_VisitPreRegistrationHandlerServices.updateVpr(vprlList);
        }
        
    }
    
    
    
    
    
}