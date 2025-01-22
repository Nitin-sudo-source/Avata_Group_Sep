//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 27-10-2023
//-------------------------------------------//
trigger Ex_OpportunityTrigger on Opportunity__c (before insert,after insert, before update, after update) {
     if(trigger.isBefore && trigger.isInsert)
        Ex_OpportunityTriggerHandler.beforeInsert(trigger.new);
     if(trigger.isAfter && trigger.isInsert)
        Ex_OpportunityTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_OpportunityTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_OpportunityTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    
}