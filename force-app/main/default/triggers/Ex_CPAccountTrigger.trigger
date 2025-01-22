//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 03-11-2023
//-------------------------------------------//
trigger Ex_CPAccountTrigger on Account  (before insert, before update , after insert , after update) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        Ex_CPAccountTriggerHandler.AfterInsert(trigger.new);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        Ex_CPAccountTriggerHandler.BeforeInsert(trigger.new);
    }
    if (Trigger.IsBefore && Trigger.isUpdate){
        Ex_CPAccountTriggerHandler.BeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}