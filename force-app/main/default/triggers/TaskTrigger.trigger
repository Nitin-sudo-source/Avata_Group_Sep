//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
trigger TaskTrigger on Task (before insert, after insert, before update, after update) {
   if(trigger.isBefore && trigger.isInsert)
        TaskTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        TaskTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        TaskTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        TaskTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}