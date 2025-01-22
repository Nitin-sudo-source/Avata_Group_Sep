trigger Ex_ApplicantTrigger on Applicant__c (after update) {
    if(trigger.isAfter && trigger.isUpdate){
        Ex_ApplicantTriggerHandler.afterUpdate(Trigger.oldMap,Trigger.NewMap);
    }

}