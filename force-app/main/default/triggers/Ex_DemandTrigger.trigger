/*-------------------------------------------
Project: AVANT Group 
Created By: Exceller Tech
Created Date: 07-11-2024
//-------------------------------------------*/
trigger Ex_DemandTrigger on Demand__c (after insert, after update, before delete, before update) {
    if(trigger.isAfter && trigger.isInsert)
        Ex_DemandTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_DemandTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isBefore && trigger.isDelete)
        Ex_DemandTriggerHandler.beforeDelete(trigger.oldMap, trigger.newMap);
    
}