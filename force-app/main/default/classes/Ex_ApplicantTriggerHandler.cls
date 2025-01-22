public class Ex_ApplicantTriggerHandler {
    public static void afterUpdate(Map<Id, Applicant__c> oldMap, Map<Id, Applicant__c> newMap) {
        Map<Id, List<Applicant__c>> newBookMap = new Map<Id, List<Applicant__c>>();
        List<Booking__c> updateBooking = new List<Booking__c>();
        for(Applicant__c oldApplicant: oldMap.values()) {
            Applicant__c newApplicant = newMap.get(oldApplicant.Id);
            
            if(newApplicant.Booking__c != null && (oldApplicant.Applicant_Number__c != newApplicant.Applicant_Number__c || oldApplicant.Mobile_Number__c != newApplicant.Mobile_Number__c 
               || oldApplicant.Applicant_Email__c != newApplicant.Applicant_Email__c || oldApplicant.Name != newApplicant.Name
               || oldApplicant.Applicant_Title__c != newApplicant.Applicant_Title__c || oldApplicant.Permanent_Address__c != newApplicant.Permanent_Address__c)){
                  
                   if(!newBookMap.containskey(newApplicant.Booking__c)){
                       List<Applicant__c> newList = new List<Applicant__c>();
                       newList.add(newApplicant);
                       newBookMap.put(newApplicant.Booking__c, newList);
                   }else{
                       newBookMap.get(newApplicant.Booking__c).add(newApplicant);
                   }
              }
        }
        System.debug('newBookMap: '+newBookMap);
        if(!newBookMap.isEmpty() && newBookMap != null){
            Ex_ApplicantHandlerServices.updateApplicantsonBooking(newBookMap);
        }
    }
}