//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
public class Ex_BookingCancellationHandler {
    @AuraEnabled(cacheable=false)
    public static String fetchBooking(Booking__c dataVal, String ctype, decimal amt,string remarks){
        try{
            Booking__c bk = [SELECT Id, Unit__c , Booking_Stage__c,Opportunity__c,Project__c,Project__r.Booking_Cancellation_Approver__c,
                             Total_Amount_Received__c FROM Booking__c WHERE Id=:dataVal.Id];
            System.debug('Booking Record: '+ bk);
          //  system.debug('Booking_Cancellation_Approver__c is: '+ bk.Project__r.Booking_Cancellation_Approver__c);
            if(bk!=null){
                bk.Booking_Stage__c = 'Cancellation in-process';
                bk.Cancellation_Type__c = ctype;
                bk.Refund_Amount__c = amt;
                bk.Cancellation_Remark__c = remarks;
                if(bk.Project__r.Booking_Cancellation_Approver__c != null){
                    bk.Booking_Cancellation_Approver__c = bk.Project__r.Booking_Cancellation_Approver__c;
                }
                update bk;
                
                /*system.debug('unit--->'+bk.Unit__c);
                Unit__c un = [SELECT Id, Sale_Status__c, Opportunity__c, Booking__c FROM Unit__c WHERE Id = :bk.Unit__c];
                if(un!=null){
                    un.Sale_Status__c = 'Vacant';
                    un.Opportunity__c = null;
                    un.Booking__c = null;
                    update un;
                }                
                
                // update Opportunity record
                Opportunity__c opp = [SELECT Id, Opportunity_Stage__c, Booking__c FROM Opportunity__c WHERE Id=:bk.Opportunity__c];
                if (opp != null) {
                    opp.Opportunity_Stage__c = 'Booking Cancelled';
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