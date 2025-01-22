//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 11-12-2023
//-------------------------------------------//
trigger Ex_PaymentMilestoneTrigger on Payment_Milestone__c (after update) {
    if(trigger.isAfter && trigger.isUpdate)
        Ex_PaymentMilestoneTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}