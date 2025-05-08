public class Ex_BookingChecklistHandlerServices {
      public static void handleAfterInsertOrUpdate(List<Booking_Checklist__c> checklistItems) {
        
        system.debug('checklistItems is::'+checklistItems);
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        List<Booking_Checklist__c> bookingChecklistToUpdate = new List<Booking_Checklist__c>();
        Boolean allAccepted;
        
        List<Booking_Checklist__c> checklistRecords = [SELECT Id, Action__c, Booking__c,Checklist_Status__c 
                                                       FROM Booking_Checklist__c
                                                       WHERE Booking__c =:checklistItems[0].Booking__c];
        system.debug('checklistRecords is::'+checklistRecords);
        
        Booking__c booking = [SELECT Id, Welcome_Call_Done__c, Opportunity__r.OwnerId, Tower__r.RM_User__c,  Sales_Manager__c, Welcome_Call_Done_DateTime__c
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
            booking.Assign_to_RM__c = true;
            booking.OwnerId = booking.Tower__r.RM_User__c;
            //booking.Booking_Stage__c = 'Booking Confirmed';
            
        } else if (allAccepted == False) {
            booking.OwnerId = booking.Sales_Manager__c;
            booking.Assign_to_MIS__c = false;
           // booking.OwnerId = booking.Closing_Manager__c;
        }
        
        bookingsToUpdate.add(booking);
        system.debug('bookingsToUpdate is::'+bookingsToUpdate);
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
          
          if( bookingChecklistToUpdate != null &&  !bookingChecklistToUpdate.isEmpty()){
              update  bookingChecklistToUpdate;
          }  
    }
    
    public static void updateBookingOwner(Set<Id> bookingIdSet){
        System.debug('Inside UpdteBooking::');
       List<Booking_Checklist__c> checklistRecords = [SELECT Id, Action__c, Booking__c,Checklist_Status__c 
                                                       FROM Booking_Checklist__c
                                                       WHERE Booking__c IN:bookingIdSet];
        
      Set<Id> bookingIds = new Set<Id>();  
     List<Booking__c> bkListToUpdate = new List<Booking__c>();  
        boolean allAcceptedByRM = null;
        if(checklistRecords != null && !checklistRecords.isEmpty()){
            for(Booking_Checklist__c bkChecklist : checklistRecords){
                if(bkChecklist.Checklist_Status__c.equalsIgnoreCase('Rejected by RM')){
                    allAcceptedByRM = false;
                    bookingIds.add(bkChecklist.Booking__c);
                    break;
                }else{
                    allAcceptedByRM = true;
                }
                
            }
            
            if(bookingIds != null && !bookingIds.isEmpty()){
                List<Booking__c> bkList = [Select Id, ownerId, Tower__r.MIS_User__c from Booking__c Where Id IN : bookingIds];
                
                if(bkList != null && !bkList.isEmpty()){
                    for(Booking__c bk : bkList){
                        bk.OwnerId = bk.Tower__r.MIS_User__c;
                        bkListToUpdate.add(bk);
                    }
                }
            }
        }
        
        if(bkListToUpdate != null && !bkListToUpdate.isEmpty()){
            update bkListToUpdate;
        }
        
    }

}