public class Ex_ApplicantHandlerServices {
    public static void updateApplicantsonBooking(Map<Id, List<Applicant__c>> newBookMap){
        System.debug('newBookMap: '+newBookMap);
        List<Booking__c> bkList = new List<Booking__c>();
        List<Booking__c> updatedBookings = new List<Booking__c>();
        
        bkList  = [Select Id, Name, Primary_Applicant_Mobile__c, All_Applicant_Name__c, Primary_Applicant_Email__c, Applicant_Address__c, Primary_Applicant_Name__c, Primary_Applicant_Title__c
                   from Booking__c where Id =: newBookMap.keySet()] ;
        System.debug('bkList: '+bklist);
        if(bklist != null && !bklist.isEmpty()){
            for(Booking__c bk: bkList){
                List<Applicant__c> applicants = newBookMap.get(bk.Id);
                System.debug('applicants: '+applicants);
                if(applicants != null && !applicants.isEmpty()){
                    String AllApplicantName = '';
                    for(Applicant__c ap: applicants){
                        if(ap.Applicant_Number__c.equalsIgnoreCase('Primary Applicant') && ap.Applicant_Number__c != null){
                            bk.Primary_Applicant_Title__c = ap.Applicant_Title__c;
                            bk.Primary_Applicant_Name__c = ap.Name;
                            bk.Primary_Applicant_Mobile__c = ap.Mobile_Number__c;
                            bk.Primary_Applicant_Email__c = ap.Applicant_Email__c;
                            bk.Applicant_Address__c = ap.Permanent_Address__c;
                            AllApplicantName += ap.Applicant_Title__c + ' '+ ap.Name ; 
                            if(applicants.indexOf(ap) < applicants.size() - 1){
                                AllApplicantName += ', ';
                            }
                        }
                    }
                    if(String.isNotBlank(AllApplicantName)){
                        bk.All_Applicant_Name__c = AllApplicantName;
                    }
                }
                updatedBookings.add(bk);
            }
        }
        System.debug('updatedBookings: '+updatedBookings);
        if (!updatedBookings.isEmpty() && updatedBookings  != null) {
            try {
                update updatedBookings;
                System.debug('Updated Bookings: ' + updatedBookings);
            } catch (DmlException e) {
                System.debug('Error updating bookings: ' + e.getMessage());
            }
        }
    }
}