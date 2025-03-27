trigger Ex_AccountTrigger on Account (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_AccountTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_AccountTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
   
}