//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_CampaignPerformanceTrigger on Campaign_Performance__c (after update) {
	if(trigger.isAfter && trigger.isUpdate)
        Ex_CampaignPerformanceTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}