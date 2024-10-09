trigger DigitalLeadTrigger on Digital_Lead__c (after insert, after update) {
    if(trigger.isAfter && trigger.isInsert)
        DigitalLeadTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        DigitalLeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);

}