public class Ex_WhatsappMsgTriggerHandler {
    
    public static void beforeInsert(List<WhatsApp_Message__c> whatsappMessageList) {
        // Sets to collect unique customer IDs for each type
        Set<Id> leadIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> bookingIds = new Set<Id>();
    
        // Loop through the list of new messages to collect the customer IDs
        for (WhatsApp_Message__c message : whatsappMessageList) {
            if (message.Lead__c != null) {
                leadIds.add(message.Lead__c);
            }
            if (message.Opportunity__c != null) {
                opportunityIds.add(message.Opportunity__c);
            }
            if (message.Booking__c != null) {
                bookingIds.add(message.Booking__c);
            }
        }
    
        // Query for the latest WhatsApp messages for leads
        Map<Id, WhatsApp_Message__c> latestLeadMessagesMap = new Map<Id, WhatsApp_Message__c>();
        if (!leadIds.isEmpty()) {
            for (WhatsApp_Message__c latestMessage : [
                SELECT Id, Lead__c, Customer_Phone__c 
                FROM WhatsApp_Message__c 
                WHERE Lead__c IN :leadIds 
                ORDER BY CreatedDate DESC LIMIT 1
            ]) {
                latestLeadMessagesMap.put(latestMessage.Lead__c, latestMessage);
            }
        }
    
        // Query for the latest WhatsApp messages for opportunities
        Map<Id, WhatsApp_Message__c> latestOpportunityMessagesMap = new Map<Id, WhatsApp_Message__c>();
        if (!opportunityIds.isEmpty()) {
            for (WhatsApp_Message__c latestMessage : [
                SELECT Id, Opportunity__c, Customer_Phone__c 
                FROM WhatsApp_Message__c 
                WHERE Opportunity__c IN :opportunityIds 
                ORDER BY CreatedDate DESC LIMIT 1
            ]) {
                latestOpportunityMessagesMap.put(latestMessage.Opportunity__c, latestMessage);
            }
        }
    
        // Query for the latest WhatsApp messages for bookings
        Map<Id, WhatsApp_Message__c> latestBookingMessagesMap = new Map<Id, WhatsApp_Message__c>();
        if (!bookingIds.isEmpty()) {
            for (WhatsApp_Message__c latestMessage : [
                SELECT Id, Booking__c, Customer_Phone__c 
                FROM WhatsApp_Message__c 
                WHERE Booking__c IN :bookingIds 
                ORDER BY CreatedDate DESC LIMIT 1
            ]) {
                latestBookingMessagesMap.put(latestMessage.Booking__c, latestMessage);
            }
        }
    
        // Loop through the list of new messages again to compare and set the checkbox
        for (WhatsApp_Message__c message : whatsappMessageList) {
            if (message.Lead__c != null && latestLeadMessagesMap.containsKey(message.Lead__c)) {
                WhatsApp_Message__c latestMessage = latestLeadMessagesMap.get(message.Lead__c);
                if (message.Customer_Phone__c != latestMessage.Customer_Phone__c) {
                    message.Number_Changed__c = true;
                }
            }
            if (message.Opportunity__c != null && latestOpportunityMessagesMap.containsKey(message.Opportunity__c)) {
                WhatsApp_Message__c latestMessage = latestOpportunityMessagesMap.get(message.Opportunity__c);
                if (message.Customer_Phone__c != latestMessage.Customer_Phone__c) {
                    message.Number_Changed__c = true;
                }
            }
            if (message.Booking__c != null && latestBookingMessagesMap.containsKey(message.Booking__c)) {
                WhatsApp_Message__c latestMessage = latestBookingMessagesMap.get(message.Booking__c);
                if (message.Customer_Phone__c != latestMessage.Customer_Phone__c) {
                    message.Number_Changed__c = true;
                }
            }
        }
    }
    
    public static void sendCustomNotificationtoUser(Set<Id> wIds){
        System.debug('Ids.: '+wIds);
        List<WhatsApp_Message__c> wList = [Select Id, Customer_Phone__c,Lead__r.First_Name__c,Lead__r.Last_Name__c, Lead__c, Lead__r.Name, Lead__r.OwnerId,Booking__r.Name,Booking__r.OwnerId,
                                           Opportunity__c,Opportunity__r.Name,Booking__r.Opportunity__r.Name, Opportunity__r.OwnerId, Account__c, Account__r.Name, Message_Text__c 
                                           from WhatsApp_Message__c 
                                           WHERE Id in: wIds];
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Whatsapp_Notification'];
        String userIds;
        Set<String> recipientsIds = new Set<String>();
                
        System.debug('Whatsapp Message List.: '+wList);
        
        if(!wList.isEmpty()){
            
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            for(WhatsApp_Message__c w : wList){
                
                System.debug('Type Id.: '+type.id);
                
                if(w.Lead__r.Name != null){
                    
                    userIds = w.Lead__r.OwnerId;
                    String message = w.Lead__r.Name + ':' + w.Lead__r.Last_Name__c + '\n Message : '+w.Message_Text__c;
                    notification.setBody('Whatsapp message from: ' + message );
                    notification.setTitle('New Whatsapp Notification');
                    notification.setNotificationTypeId(type.id);
                    notification.setTargetId(w.Lead__c); // Set the Lead's Id as the target
                    //notification.setNavigationLinkUrl('/' + w.Lead__c);
                    
                }
               if(w.Opportunity__r.Name != null){
                    
					userIds = w.Opportunity__r.OwnerId;
                    String message = w.Opportunity__r.Name +'\n Message : '+w.Message_Text__c;
                    notification.setBody('Whatsapp message from: ' + message);
                    notification.setTitle('New Whatsapp Notification');
                    notification.setNotificationTypeId(type.id);
                    notification.setTargetId(w.Opportunity__c);
                    
                }
                if(w.Booking__r.Name != null){
                    
                    userIds = w.Booking__r.OwnerId;
                    String message = w.Booking__r.Name + ':' + w.Booking__r.Opportunity__r.Name +'\n Message : '+w.Message_Text__c;
                    notification.setBody('Whatsapp message from: ' + message);
                    notification.setTitle('New Whatsapp Notification');
                    notification.setNotificationTypeId(type.id);
                    notification.setTargetId(w.Booking__c);
                    
                }
                
                //Set Recipent Id's
				recipientsIds.add(userIds);
                
            }
            
            try {
                 System.debug('recipientsIds .: '+recipientsIds);
                 notification.send(recipientsIds);
                 System.debug('Success');
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
           }
        }
    }
    
    @AuraEnabled
    public static SObject getRecordById(String recordId) {
        SObject record;
        
        try {
            Id recId = (Id)recordId;
            record = Database.query('SELECT Id FROM ' + recId.getSObjectType().getDescribe().getName() + ' WHERE Id = :recId LIMIT 1');
        } catch (Exception e) {
            record = null;
        }
        System.debug('Record Type .: '+record);
        
        return record;
    }
    
    public static void checkSessionStatus(Set<Id> Ids){
        Set<Id> lIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
		Set<Id> bookIds = new Set<Id>();
        
        List<Lead__c> updateLead = new List<Lead__c>();
        //List<Account> updateAccount = new List<Account>();
                
        List<Booking__c> updateBooking = new List<Booking__c>();

        List<Opportunity__c> updateOppo = new List<Opportunity__c>();
        List<WhatsApp_Message__c> wMsg = [SELECT Id, Name, Lead__c, Opportunity__c, Account__c, Booking__c, Customer_Phone__c 
                                          FROM WhatsApp_Message__c
                                          WHERE Id in: Ids];
        for(WhatsApp_Message__c w : wMsg){
            if(w.Lead__c != null)
                lIds.add(w.Lead__c);
            
            if(w.Account__c != null)
                accIds.add(w.Account__c);
            
            if(w.Opportunity__c != null)
                oppIds.add(w.Opportunity__c);
            
            if(w.Booking__c != null)
                bookIds.add(w.Booking__c);
            
        }
        
        if(!lIds.isEmpty()){
            List<Lead__c> lList = [SELECT Id, Name, Session_Status__c, Conversation_Start_Date_Time__c, 
                                Conversation_End_Date_Time__c FROM Lead__c
                                WHERE Id in: lIds];
            for(Lead__c l : lList){
                if(l.Session_Status__c == 'Inactive'){
                    l.Conversation_Start_Date_Time__c = System.now();
                    updateLead.add(l);
                }
            }
        }
        /*if(!accIds.isEmpty()){
            List<Account> accList = [SELECT Id, Name, Session_Status__c, Conversation_Start_Date_Time__c, 
                                     Conversation_End_Date_Time__c FROM Account
                                     WHERE Id in: accIds];
            for(Account a : accList){
                if(a.Session_Status__c == 'Inactive'){
                    a.Conversation_Start_Date_Time__c = System.now();
                    updateAccount.add(a);
                }
            }
        }*/
        
        if(!oppIds.isEmpty()){
            List<Opportunity__c> oppList = [SELECT Id, Name, Session_Status__c, Conversation_Start_Date_Time__c, 
                                         Conversation_End_Date_Time__c FROM Opportunity__c
                                         WHERE Id in: oppIds];
            for(Opportunity__c o : oppList){
                if(o.Session_Status__c == 'Inactive'){
                    o.Conversation_Start_Date_Time__c = System.now();
                    updateOppo.add(o);
                }
            }
        }
        
        if(!bookIds.isEmpty()){
            List<Booking__c> bookList = [SELECT Id, Name, Session_Status__c, Conversation_Start_Date_Time__c, 
                                         Conversation_End_Date_Time__c FROM Booking__c
                                         WHERE Id in: bookIds];
            for(Booking__c b : bookList){
                if(b.Session_Status__c == 'Inactive'){
                    b.Conversation_Start_Date_Time__c = System.now();
                    updateBooking.add(b);
                }
            }
        }
        
        
        try{
            if(!updateLead.isEmpty())
                update updateLead;
            
            /*if(!updateAccount.isEmpty())
                update updateAccount;*/
            if(!updateOppo.isEmpty())
                update updateOppo;
            
            if(!updateBooking.isEmpty())
                update updateBooking;
            
        }catch(Exception e){
            System.debug('Error .: '+e.getMessage());
        }
    } 

}