trigger Ex_CPProject on CP_Project__c (before insert, before Update) {
    if(Trigger.isbefore && Trigger.isInsert){
        Ex_CPProjectTriggerHandler.beforeInsert(Trigger.new);
    }
    if(Trigger.isbefore && Trigger.isUpdate){
        Ex_CPProjectTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}