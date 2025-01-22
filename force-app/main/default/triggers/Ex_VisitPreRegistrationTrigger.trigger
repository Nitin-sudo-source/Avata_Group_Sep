// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 09-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
trigger Ex_VisitPreRegistrationTrigger on Visit_Pre_Registration__c (before insert, before update) {
    if (Trigger.isInsert && Trigger.isBefore) 
        Ex_VisitPreRegistrationHandler.beforeInsert(trigger.new);
    if (Trigger.isBefore && Trigger.isUpdate) 
        Ex_VisitPreRegistrationHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
}