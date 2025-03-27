trigger Ex_LeadTrigger on Lead__c (before insert, after insert, before update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_LeadTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_LeadTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
}