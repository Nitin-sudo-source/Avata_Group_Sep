trigger Ex_TeamMemberTrigger on Team_Member__c (after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_TeamMemberTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}