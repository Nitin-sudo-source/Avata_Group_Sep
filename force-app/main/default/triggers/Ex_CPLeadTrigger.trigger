trigger Ex_CPLeadTrigger on CP_Lead__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_CPLeadTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_CPLeadTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    /*if(trigger.isAfter && trigger.isInsert)
        Ex_CPLeadTriggerHandler.afterInsert(trigger.new);
    
    if(trigger.isAfter && trigger.isUpdate)
        Ex_CPLeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);*/
}