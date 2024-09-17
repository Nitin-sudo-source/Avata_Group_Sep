//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_CampaignTriggerHandler {
    public static void afterInsert(List<Campaign__c> campaignList) {
        Set<Id> cIdSet = new Set<Id>();
        
        for(Campaign__c c: campaignList) {
            if(c.Active__c)
                cIdSet.add(c.Id);
        }
        if(!cIdSet.isEmpty() && cIdSet != null)
            Ex_CampaignHandlerServices.createCampaignPerformance(cIdSet);
    }
}