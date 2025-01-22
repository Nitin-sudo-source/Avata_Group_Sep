//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 18-10-2023
//-------------------------------------------//
trigger Ex_AccountTrigger on Account (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert)
        Ex_AccountTriggerHandler.beforeInsert(trigger.new);
    if(trigger.isBefore && trigger.isUpdate)
        Ex_AccountTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
}