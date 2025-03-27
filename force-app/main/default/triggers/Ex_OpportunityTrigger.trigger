//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_OpportunityTrigger on Opportunity__c (before insert, before update, after insert, after update) {
	if(trigger.isBefore && trigger.isInsert)
        Ex_OpportunityTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        Ex_OpportunityTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isupdate)
        Ex_OpportunityTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_OpportunityTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}