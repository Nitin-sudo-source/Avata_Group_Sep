trigger Ex_LedgerTrigger on Ledger__c (before delete) {
    if(trigger.isBefore && trigger.isDelete)
        Ex_LedgerTriggerHandler.beforeDelete(trigger.oldMap, trigger.newMap);
}