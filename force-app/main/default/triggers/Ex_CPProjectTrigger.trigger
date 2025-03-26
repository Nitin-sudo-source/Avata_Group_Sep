trigger Ex_CPProjectTrigger on CP_Project__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_CPProjectTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_CPProjectTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);

}