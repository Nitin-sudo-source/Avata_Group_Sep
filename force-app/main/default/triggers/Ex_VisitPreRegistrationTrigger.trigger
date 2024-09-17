// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 09-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
trigger Ex_VisitPreRegistrationTrigger on Visit_Pre_Registration__c (before insert, after insert) {
    if (Trigger.isInsert && Trigger.isBefore) 
        Ex_VisitPreRegistrationHandler.beforeInsert(trigger.new);
}