//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 18-10-2023
//-------------------------------------------//
trigger Ex_LeadTrigger on Lead__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_LeadTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert) 
        Ex_LeadTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_LeadTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    /*if(trigger.isAfter && trigger.isUpdate)
        LeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);*/
}