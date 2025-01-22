//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
public class Ex_CampaignTriggerHandler {
    /*public static void afterInsert(List<Campaign__c> campaignList) {
        Set<Id> cIdSet = new Set<Id>();
        
        for(Campaign__c c: campaignList) {
            if(c.IsActive__c == true)
                cIdSet.add(c.Id);
        }
        if(!cIdSet.isEmpty() && cIdSet != null)
            Ex_CampaignHandlerServices.createCampaignPerformance(cIdSet);
    }*/
    
    public static void beforeupdate(Map<Id, Campaign__c> oldMap, Map<Id, Campaign__c> newMap){
        Set<Id> cIdSet = new Set<Id>();
        for(Campaign__c oldCampaign: oldMap.values()) {
            Campaign__c newCampaign = newMap.get(oldCampaign.Id);
            if((oldCampaign.Approver_Status__c != newCampaign.Approver_Status__c ) &&
               newCampaign.Approver_Status__c != null && newCampaign.Approver_Status__c == 'Approved' ){
                   cIdSet.add(newCampaign.Id);
               }
            
        }
        system.debug('cIdSet: '+cIdSet);
        if(!cIdSet.isEmpty() && cIdSet != null)
            Ex_CampaignHandlerServices.createCampaignPerformance(cIdSet);
    }
}