public class Ex_BookingCancellationHandler {
    
    @AuraEnabled(cacheable=false)
    public static String fetchBooking(Booking__c dataVal, String ctype, decimal amt,string remarks){
        try{
            Booking__c bk = [SELECT Id, Unit__c , Booking_Stage__c, ownerId, Sales_Manager__r.ManagerId, Registration_Done__c, Opportunity__c, Project__c, Project__r.Booking_Cancellation_Approver__c
                             FROM Booking__c WHERE Id=:dataVal.Id];
            System.debug('Booking Record: '+ bk);
            //  system.debug('Booking_Cancellation_Approver__c is: '+ bk.Project__r.Booking_Cancellation_Approver__c);
            if(bk!=null){
                bk.Booking_Stage__c = 'Cancellation in-process';
                bk.Cancellation_Type__c = ctype;
                bk.Refund_Amount__c = amt;
                bk.Cancellation_Remark__c = remarks;
                
                if(!bk.Registration_Done__c){
                    // if registration not done then level 1 sales head & level 2 CRM head
                    if(bk.Sales_Manager__r.ManagerId != null){
                       bk.Booking_Cancellation_Approver__c = bk.Sales_Manager__r.ManagerId;    
                    }
                }else{
                    // if registration done then level 1 CRM Manager & level 2 CRM head
                    if(bk.ownerId != null){
                        bk.Booking_Cancellation_Approver__c = bk.ownerId;    
                    }
                    
                }
                update bk;
                
               /* system.debug('unit--->'+bk.Unit__c);
                Unit__c un = [SELECT Id, Sales_Status__c, Opportunity__c, Booking__c FROM Unit__c WHERE Id = :bk.Unit__c];
                if(un!=null){
                    un.Sales_Status__c = 'Vacant';
                    un.Opportunity__c = null;
                    un.Booking__c = null;
                    update un;
                }                
                
                // update Opportunity record
                Opportunity__c opp = [SELECT Id, Stage__c, Booking__c FROM Opportunity__c WHERE Id=:bk.Opportunity__c];
                if (opp != null) {
                    opp.Stage__c = 'Booking Cancelled';
                    opp.Booking__c = null;
                    update opp;
                }*/
                
                return 'success';
            }
            else{
                return 'error';
            }
        }
        catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            return 'error';
        }
    }

}