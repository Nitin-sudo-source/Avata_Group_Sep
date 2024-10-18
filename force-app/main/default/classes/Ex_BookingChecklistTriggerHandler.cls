public class Ex_BookingChecklistTriggerHandler {
      public static void updateBookingStatusAfterInsert(List<Booking_Checklist__c> bcList){
        system.debug('bcList is::'+bcList);
        if(!bcList.isEmpty() && bcList != null){
            Ex_BookingChecklistHandlerServices.handleAfterInsertOrUpdate(bcList);
        }
    }
    public static void updateBookingStatusAfterUpdate(List<Booking_Checklist__c> bcList){
        system.debug('bcList is::'+bcList);
        if(!bcList.isEmpty() && bcList != null){
            Ex_BookingChecklistHandlerServices.handleAfterInsertOrUpdate(bcList);
        }
    }

}