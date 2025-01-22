public class Ex_RegistrationTriggerHandler {
    
     public static void afterUpdate(Map<Id, Registration__c> oldMap, Map<Id, Registration__c> newMap) {
        Set<Id> rcSetId = new Set<Id>();
        
        for(Registration__c oldRegistration: oldMap.values()) {
            Registration__c newRegistration = newMap.get(oldRegistration.Id);
            
            if(oldRegistration.Registration_Stage__c != newRegistration.Registration_Stage__c && newRegistration.Registration_Stage__c != null && (newRegistration.Registration_Stage__c.equalsIgnoreCase('Registration Scheduled') || newRegistration.Registration_Stage__c.equalsIgnoreCase('Registration Completed'))){
                rcSetId.add(newRegistration.Id);
            }
        }
         if(!rcSetId.isEmpty() && rcSetId != null){
            Ex_RegistrationTriggerHandlerServices.sendEmailRegistrationSchedule(rcSetId);
        }
         
     }

}