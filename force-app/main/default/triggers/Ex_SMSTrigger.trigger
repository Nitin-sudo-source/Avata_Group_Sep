trigger Ex_SMSTrigger on SMS__c (after insert) {
    if(trigger.isAfter && trigger.isInsert)
    {
        Ex_SMSTriggerHandler.AfterInsert(trigger.new);
    }

}