//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 30-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_CampaignTrigger on Campaign__c (after insert, after update) {
	if(trigger.isAfter && trigger.isInsert)
        Ex_CampaignTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_CampaignTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}