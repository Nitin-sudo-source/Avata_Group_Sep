//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 30-10-2023
//-------------------------------------------//
trigger Ex_BookingTrigger on Booking__c (after insert, after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_BookingTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    if(trigger.isAfter && trigger.isInsert) 
        Ex_BookingTriggerHandler.afterInsert(trigger.new);
    
    
}