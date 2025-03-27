// -------------------------------------------
//   Project: Unmanaged Package 
//   Created By: Exceller Tech
//   Created Date: 20-08-2024
//   Author: Harshal More    
// -------------------------------------------
trigger Ex_SiteVisitTrigger on Site_Visit__c (after update, after insert, before update) {
    if(trigger.isAfter && trigger.isInsert) 
        Ex_SiteVisitTriggerHandler.afterInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_SiteVisitTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_SiteVisitTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
   
}