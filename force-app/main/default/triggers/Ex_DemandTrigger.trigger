//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
trigger Ex_DemandTrigger on Demand__c (after insert, after update, before delete) {
    if(trigger.isAfter && trigger.isInsert)
        Ex_DemandTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_DemandTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isBefore && trigger.isDelete)
        Ex_DemandTriggerHandler.beforeDelete(trigger.oldMap, trigger.newMap);
}