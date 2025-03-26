trigger Ex_PaymentSchemeTrigger on Payment_Scheme__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        Ex_PaymentSchemeTriggerHandler.afterInsert(trigger.new);
    }
    
}