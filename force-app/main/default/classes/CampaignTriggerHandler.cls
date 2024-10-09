//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class CampaignTriggerHandler {
	public static void afterUpdate(Map<Id, Campaign__c> oldMap, Map<Id, Campaign__c> newMap) {
        Set<Id> cIdSet = new Set<Id>();
        
         for(Campaign__c oldCamp: oldMap.values()) {
            Campaign__c newCamp = newMap.get(oldCamp.Id);
            
            if(oldCamp.Active__c != newCamp.Active__c && newCamp.Active__c == true)
                cIdSet.add(newCamp.Id);
        }
       
        if(!cIdSet.isEmpty() && cIdSet != null)
           CampaignHandlerServices.createCampaignPerformance(cIdSet);
    }
}