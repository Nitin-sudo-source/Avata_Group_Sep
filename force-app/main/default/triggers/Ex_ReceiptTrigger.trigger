trigger Ex_ReceiptTrigger on Receipt__c (before insert, after insert, after update, before delete) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_ReceiptTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isAfter && trigger.isInsert)
        Ex_ReceiptTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_ReceiptTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isBefore && trigger.isDelete)
        Ex_ReceiptTriggerHandler.beforeDelete(trigger.oldMap, trigger.newMap);
}