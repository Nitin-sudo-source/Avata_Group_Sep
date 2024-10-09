//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
trigger AccountTrigger on Account (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert)
        AccountTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        AccountTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
}