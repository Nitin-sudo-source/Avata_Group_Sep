//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 04-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
trigger Ex_TaskTrigger on Task(before insert, after insert, before update, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_TaskTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        Ex_TaskTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_TaskTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_TaskTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}