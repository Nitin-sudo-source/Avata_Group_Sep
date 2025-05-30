public class Ex_BookingTriggerHandler {
    public static void afterInsert(List<Booking__c> bList) {
        Map<Id, Booking__c> quotationBookingMap = new Map<Id, Booking__c>();
        Set<Id> towerIdSet = new Set<Id>();
        Set<Id> bkIdSet = new Set<Id>();
        
        for(Booking__c b: bList) {
            if(b.Booking_Date__c != null && b.Tower__c != null) {
                quotationBookingMap.put(b.Quotation__c, b);
                towerIdSet.add(b.Tower__c);
            }
            if(b.Project__c != null){
                bkIdSet.add(b.Id);
            }
        }
      
        if(quotationBookingMap != null && !towerIdSet.isEmpty())
            Ex_BookingHanldlerServices.updatePaymentMilestoneDueDate(quotationBookingMap, towerIdSet);
    }
    
    public static void afterUpdate(Map<Id, Booking__c> oldMap, Map<Id, Booking__c> newMap) {
        Map<Id, Booking__c> quotationBookingMap = new Map<Id, Booking__c>();
        Set<Id> towerIdSet = new Set<Id>();
        Boolean isBatchReq2 = false;
        
        Set<Id> bkSetId = new Set<Id>();
        Set<Id> cancellBkSet = new Set<Id>();
        List<Booking__c> bList = new List<Booking__c>();
        
        for(Booking__c oldBooking: oldMap.values()) {
            Booking__c newBooking = newMap.get(oldBooking.Id);
            
            if(oldBooking.Welcome_Call_Done__c != newBooking.Welcome_Call_Done__c && newBooking.Welcome_Call_Done__c == True ){
                bkSetId.add(newBooking.Id);
            }
            
            if(oldBooking.Booking_Stage__c != newBooking.Booking_Stage__c && newBooking.Booking_Stage__c != null && newBooking.Booking_Stage__c.equalsIgnoreCase('Booking Cancelled')){
                cancellBkSet.add(newBooking.Id);
            }
            
            if(oldBooking.Booking_Stage__c != newBooking.Booking_Stage__c && newBooking.Booking_Stage__c != null && newBooking.Booking_Stage__c.equalsIgnoreCase('Booking Confirmed')){
                isBatchReq2 = true;
            }
            
            
            
            if(oldBooking.Updated_Agreement_Value__c != newBooking.Updated_Agreement_Value__c || oldBooking.GST__c != newBooking.GST__c || oldBooking.Stamp_Duty__c != newBooking.Stamp_Duty__c) {
                bList.add(newBooking);
            }
            
            if(oldBooking.Booking_Date__c != newBooking.Booking_Date__c && newBooking.Quotation__c != null && newBooking.Tower__c != null) {
                quotationBookingMap.put(newBooking.Quotation__c, newBooking);
                towerIdSet.add(newBooking.Tower__c);
            }
        }
        
        if (isBatchReq2) {
            if (!Test.isRunningTest()){
              //  Database.executeBatch(new Ex_DemandRaiseBatch(),1);
            }
        }
        
        if(!bkSetId.isEmpty() && bkSetId != null){
            Ex_SendEmailWelcomeCall.sendEmailWelcomeCall(bkSetId);
        }
        if(!cancellBkSet.isEmpty() && cancellBkSet != null){
            Ex_BookingHanldlerServices.getbookingCancellationUpdate(cancellBkSet);
        }

        
        if(!bList.isEmpty() && bList != null) {
           // Ex_BookingHanldlerServices.handleAgreementValueChange(bList);
        }
        
    }
    
}