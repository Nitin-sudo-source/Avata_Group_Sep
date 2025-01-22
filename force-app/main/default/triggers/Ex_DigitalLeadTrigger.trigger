//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 05-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_DigitalLeadTrigger on Digital_Lead__c (after insert, after update) {
	if(trigger.isAfter && trigger.isInsert)
        Ex_DigitalLeadTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_DigitalLeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}