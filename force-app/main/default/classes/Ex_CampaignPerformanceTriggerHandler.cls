//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_CampaignPerformanceTriggerHandler {
    public static void afterUpdate(Map<Id, Campaign_Performance__c> oldMap, Map<Id, Campaign_Performance__c> newMap) {
        Set<Id> cIdSet = new Set<Id>();
        
        for(Campaign_Performance__c oldCP: oldMap.values()) {
            Campaign_Performance__c newCP = newMap.get(oldCP.Id);
            
            if(newCP.Campaign__c != null && (oldCP.Amount_Spend__c != newCP.Amount_Spend__c || oldCP.Lead_Count__c != newCP.Lead_Count__c || oldCP.Enquiry_Count__c != newCP.Enquiry_Count__c))
                cIdSet.add(newCP.Campaign__c);
        }
        if(!cIdSet.isEmpty() && cIdSet != null)
            Ex_CampaignPerformanceHandlerServices.updateCampaignDetails(cIdSet);
    }
}