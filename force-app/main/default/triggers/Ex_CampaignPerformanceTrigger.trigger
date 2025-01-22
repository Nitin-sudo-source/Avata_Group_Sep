//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
trigger Ex_CampaignPerformanceTrigger on Campaign_Performance__c(after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_CampaignPerformanceTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}