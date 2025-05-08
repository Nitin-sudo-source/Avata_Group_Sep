trigger Ex_BookingChecklistTrigger on Booking_Checklist__c (after insert,after update) {
    if(trigger.isAfter && trigger.isInsert){
        Ex_BookingChecklistTriggerHandler.updateBookingStatusAfterInsert(Trigger.new);   
    }  
    if(trigger.isAfter && trigger.isUpdate){
        Ex_BookingChecklistTriggerHandler.updateBookingStatusAfterUpdate(Trigger.new);   
    }
    if(Trigger.isAfter && trigger.isUpdate){
        Ex_BookingChecklistTriggerHandler.updateBookingOwnerWhenRMReject(trigger.newmap,trigger.oldmap);
    }
    
}