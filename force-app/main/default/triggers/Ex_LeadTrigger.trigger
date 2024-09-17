//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_LeadTrigger on Lead__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_LeadTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        Ex_LeadTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_LeadTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_LeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}