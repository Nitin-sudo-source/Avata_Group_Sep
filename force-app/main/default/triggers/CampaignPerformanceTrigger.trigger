//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
trigger CampaignPerformanceTrigger on Campaign_Performance__c (after update) {
    if(trigger.isAfter && trigger.isUpdate)
        CampaignPerformanceTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}