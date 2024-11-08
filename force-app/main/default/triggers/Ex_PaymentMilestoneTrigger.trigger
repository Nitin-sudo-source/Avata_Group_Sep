trigger Ex_PaymentMilestoneTrigger ON Payment_Milestone__c (after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_PaymentMilestoneTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}