//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 23-10-2023
//-------------------------------------------//
trigger Ex_DigitalLeadTrigger on Digital_Lead__c  (after insert, after update) {
    if(trigger.isAfter && trigger.isInsert)
        Ex_DigitalLeadTriggerHandler.afterInsert(trigger.new);
    if(trigger.isAfter && trigger.isUpdate)
        Ex_DigitalLeadTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}