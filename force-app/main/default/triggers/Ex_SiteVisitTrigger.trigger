// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
trigger Ex_SiteVisitTrigger on Site_Visit__c (after insert,after update) {
    if(trigger.isAfter && trigger.isInsert)
        Ex_SiteVisitTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_SiteVisitTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);

}