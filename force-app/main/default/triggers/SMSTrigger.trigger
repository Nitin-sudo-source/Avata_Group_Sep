trigger SMSTrigger on SMS__c (after insert) {
    if(trigger.isAfter && trigger.isInsert) { 
        SMSTriggerHandler.afterInsert(Trigger.New);
    }  
}