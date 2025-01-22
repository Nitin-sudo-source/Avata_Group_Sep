trigger Ex_WhatsappMsgTrigger on WhatsApp_Message__c (after insert, before insert) {
    Set<Id> waIds = new Set<Id>();
    
    if(trigger.isAfter && trigger.isInsert){
        for(WhatsApp_Message__c msg : trigger.new){
            System.debug('Record Id .:'+msg.Id); 
            if(msg.Contains_File__c != true && msg.Message_Type__c == 'Normal'){
                //waIds.add(msg.Id);
            }
            if(msg.Outbound__c == false){
               waIds.add(msg.Id); 
            }
             //Ex_WhatsappMsgTriggerHandler.sendMessage(msg.Id);
        }
        if(!waIds.isEmpty()) {
            Ex_WhatsappMsgTriggerHandler.sendCustomNotificationtoUser(waIds);
            Ex_WhatsappMsgTriggerHandler.checkSessionStatus(waIds);
        }
    }
    
    if(trigger.isBefore && trigger.isInsert){
        
        List<WhatsApp_Message__c> WhatsappMessageList = new List<WhatsApp_Message__c>();
        
        for(WhatsApp_Message__c msg : trigger.new){
            
            if(msg.Outbound__c == true){
               WhatsappMessageList.add(msg); 
            }
             //Ex_WhatsappMsgTriggerHandler.sendMessage(msg.Id);
        }
        if(!WhatsappMessageList.isEmpty() && WhatsappMessageList != null) {
            Ex_WhatsappMsgTriggerHandler.beforeInsert(WhatsappMessageList);
        }
    }
    
}