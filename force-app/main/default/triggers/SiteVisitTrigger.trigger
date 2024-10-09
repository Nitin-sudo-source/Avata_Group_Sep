//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
trigger SiteVisitTrigger on Site_Visit__c (after update) {
    if(trigger.isAfter && trigger.isUpdate)
        SiteVisitTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
}