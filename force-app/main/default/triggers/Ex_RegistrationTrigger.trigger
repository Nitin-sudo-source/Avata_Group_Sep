trigger Ex_RegistrationTrigger on Registration__c (after insert, after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_RegistrationTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}