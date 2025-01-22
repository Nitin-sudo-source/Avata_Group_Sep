//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 17-10-2023
//-------------------------------------------//
trigger Ex_CampaignTrigger on Campaign__c (after insert, before update) {
   // if(trigger.isAfter && trigger.isInsert)
      //  Ex_CampaignTriggerHandler.afterInsert(trigger.new);
     if(trigger.isBefore && trigger.isUpdate)
        Ex_CampaignTriggerHandler.beforeupdate(trigger.oldMap, trigger.newMap);

}