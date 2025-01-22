//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_AccountTrigger on Account (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_AccountTriggerHandler.beforeInsert(trigger.new);
    if(Trigger.isAfter && Trigger.isInsert)
        Ex_AccountTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_AccountTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(Trigger.isAfter && Trigger.isUpdate)
       Ex_AccountTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}