//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
trigger CampaignTrigger on Campaign__c (after insert, after update) {
   // if(trigger.isAfter && trigger.isInsert){
     // CampaignTriggerHandler.afterInsert(trigger.new);
   // }
     if(trigger.isAfter && trigger.isupdate)
        CampaignTriggerHandler.afterupdate(trigger.oldMap, trigger.newMap);

}