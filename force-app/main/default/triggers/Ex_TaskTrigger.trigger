//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
trigger Ex_TaskTrigger on Task (before insert, after insert, before update, after update) {
   if(trigger.isBefore && trigger.isInsert)
        Ex_TaskTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        Ex_TaskTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_TaskTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_TaskTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}