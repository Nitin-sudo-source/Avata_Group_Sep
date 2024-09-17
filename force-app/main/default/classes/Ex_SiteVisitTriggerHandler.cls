// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_SiteVisitTriggerHandler {
     public static void afterUpdate(Map<Id, Site_Visit__c> oldMap, Map<Id, Site_Visit__c> newMap) {
        Set<Id> uIdSet = new Set<Id>();
        
        for(Site_Visit__c oldSV: oldMap.values()) {
            Site_Visit__c newSV = newMap.get(oldSV.Id);
            
            if(oldSV.Comments__c != newSV.Comments__c && newSV.Comments__c != null)
                uIdSet.add(newSv.Sales_Manager__c);   
        }

        if(!uIdSet.isEmpty() && uIdSet != null){
         	Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);   
        }
       
    }

}