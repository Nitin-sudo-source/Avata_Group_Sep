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
    
    public static void updateBookingOwnerWhenRMReject(Map<Id, Booking_Checklist__c> newBookingMap, Map<Id, Booking_Checklist__c> oldBookingMap){
        Set<Id> bookingIdSet = new Set<Id>();
        
        for(Booking_Checklist__c oldBkChecklist : oldBookingMap.values()){
            Booking_Checklist__c newChecklist = newBookingMap.get(oldBkChecklist.Id);
            
            if(oldBkChecklist.Checklist_Status__c != newChecklist.Checklist_Status__c && newChecklist.Checklist_Status__c.equalsIgnoreCase('Rejected by RM')){
                bookingIdSet.add(newChecklist.Booking__c);
            }
        }
        
        if(bookingIdSet != null && !bookingIdSet.isEmpty()){
            Ex_BookingChecklistHandlerServices.updateBookingOwner(bookingIdSet);
        }
    }

}