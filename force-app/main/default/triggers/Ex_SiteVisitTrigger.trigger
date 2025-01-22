trigger Ex_SiteVisitTrigger on Site_Visit__c (after insert,before update, before insert,after update) {
    if(trigger.isBefore && trigger.isInsert){
        Ex_SiteVisitTriggerHandler.beforeInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
     	Ex_SiteVisitTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);   
    }
     if(Trigger.isBefore && Trigger.isUpdate)
        Ex_SiteVisitTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    
    if(trigger.isAfter && trigger.isInsert){
        Ex_SiteVisitTriggerHandler.afterInsert(trigger.new);
        //Ex_SiteVisitTriggerHandler.updateCPOnOppo(trigger.new);
    }
}