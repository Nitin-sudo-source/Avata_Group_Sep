trigger Ex_ChannelPartnerTrigger on Channel_Partner__c (before insert, before update, after insert, after update) {
    
    if(trigger.isInsert && trigger.isafter){
        Ex_ChannelPartnerTriggerHandler.afterInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        Ex_ChannelPartnerTriggerHandler.afterUpdate(trigger.oldmap, trigger.newmap);
    }
    
}