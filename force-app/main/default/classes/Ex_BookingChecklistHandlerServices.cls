public class Ex_BookingChecklistHandlerServices {
      public static void handleAfterInsertOrUpdate(List<Booking_Checklist__c> checklistItems) {
        
        system.debug('checklistItems is::'+checklistItems);
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        Boolean allAccepted;
        
        List<Booking_Checklist__c> checklistRecords = [SELECT Id, Action__c, Booking__c 
                                                       FROM Booking_Checklist__c
                                                       WHERE Booking__c =:checklistItems[0].Booking__c];
        system.debug('checklistRecords is::'+checklistRecords);
        
        Booking__c booking = [SELECT Id, Welcome_Call_Done__c, Welcome_Call_Done_DateTime__c
                              FROM Booking__c 
                              WHERE Id = :checklistRecords[0].Booking__c LIMIT 1];
        system.debug('booking is::'+booking);
        
        for (Booking_Checklist__c record : checklistRecords) {
            system.debug('record is::'+record);
            if (record.Action__c == 'Reject') {
                allAccepted = False;
                break;
            }else{
                allAccepted = True;
            }
        }
        
        system.debug('allAccepted is::'+allAccepted);
        if (allAccepted == True) {
            booking.Welcome_Call_Done__c = True;
            booking.Welcome_Call_Done_DateTime__c = Datetime.now(); 
            booking.Booking_Stage__c = 'Booking Confirmed';
            
        } else if (allAccepted == False) {
           // booking.Handover_To_CRM__c = False;
           // booking.OwnerId = booking.Closing_Manager__c;
        }
        
        bookingsToUpdate.add(booking);
        system.debug('bookingsToUpdate is::'+bookingsToUpdate);
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
    }

}