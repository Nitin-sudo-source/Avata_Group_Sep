trigger Ex_TeamMemberTrigger on Team_Member__c (before update){  
    Ex_TeamMemberTriggerHandler.beforeupdate();
    /*
if(trigger.isAfter && trigger.isUpdate)
Ex_teamMemberTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);

*/
    
    
}