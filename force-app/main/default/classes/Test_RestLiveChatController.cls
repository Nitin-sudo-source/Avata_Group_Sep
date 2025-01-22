@isTest
private class Test_RestLiveChatController {
    
    @isTest
    static void testLiveChat() {
        // Test data setup
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/LiveChat/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;

        
        
        Lead__c cl = new Lead__c();
        cl.isConverted__c = false;
        cl.Mobile__c = '1234567890';
        cl.Project__c = pro.id;
        insert cl;
        
        
        
        // Create Person Account
        Account acc = new Account();
        acc.LastName = 'abc';
        acc.Phone = '1234567890';
        acc.Opted_In__c = true;
        acc.PersonEmail = 'example@example.com';
        acc.PersonMobilePhone = '9876543210';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); // Provide the Record Type Id for Person Account
        insert acc;
        
       /* Opportunity__c opp = new Opportunity__c();
        // opp.Mobile__c = '1234567890';
        opp.Account__c = acc.Id;
        // opp.Opted_In__c = true;
        insert opp;*/
        
        
        // Create Person Account
        Account acc1 = new Account();
        acc1.LastName = 'abc';
        acc1.Phone = '9112345678';
        acc1.Opted_In__c = true;
        acc1.PersonEmail = 'example@example.com';
        acc1.PersonMobilePhone = '8877665544';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); // Provide the Record Type Id for Person Account
        insert acc1;
        
        Opportunity__c opp1 = new Opportunity__c();
        // opp.Mobile__c = '1234567890';
        opp1.Account__c = acc1.Id;
        opp1.Opted_In__c = true;
        opp1.Project__c = pro.Id;
        insert opp1;
        
        Opportunity__c opp = new Opportunity__c();
        // opp.Mobile__c = '1234567890';
        opp.Account__c = acc1.Id;
        opp.Project__c = pro.id;
        // opp.Opted_In__c = true;
        insert opp;
        
        Booking__c bk = new Booking__c();
        bk.Opportunity__c = opp1.id;
        bk.Project__c = pro.Id;
        insert bk;
        
        WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
        whatsappMessage.Customer_Phone__c = '1234567890';
        whatsappMessage.Success__c = true;
        whatsappMessage.Message_Id__c = '2123432123';
        whatsappMessage.API_Status__c = 'Success';
        whatsappMessage.Message_Type__c = 'Normal';
        whatsappMessage.Lead__c = cl.id;
        insert whatsappMessage;
        
        WhatsApp_Message__c whatsappMessage1 = new WhatsApp_Message__c();
        whatsappMessage1.Customer_Phone__c = '1234567890';
        whatsappMessage1.Success__c = true;
        whatsappMessage1.Message_Id__c = '2123432123';
        whatsappMessage1.API_Status__c = 'Success';
        whatsappMessage1.Message_Type__c = 'Normal';
        whatsappMessage1.Opportunity__c = opp1.id;
        insert whatsappMessage1;
        
        WhatsApp_Message__c whatsappMessage2 = new WhatsApp_Message__c();
        whatsappMessage2.Customer_Phone__c = '1234567890';
        whatsappMessage2.Success__c = true;
        whatsappMessage2.Message_Id__c = '2123432123';
        whatsappMessage2.API_Status__c = 'Success';
        whatsappMessage2.Message_Type__c = 'Normal';
        whatsappMessage2.Booking__c = bk.id;
        insert whatsappMessage2;
        
        WhatsApp_Message__c whatsappMessage3 = new WhatsApp_Message__c();
        whatsappMessage3.Customer_Phone__c = '8877665544';
        whatsappMessage3.Success__c = true;
        whatsappMessage3.Message_Id__c = '2123432123';
        whatsappMessage3.API_Status__c = 'Success';
        whatsappMessage3.Message_Type__c = 'Normal';
        whatsappMessage3.Opportunity__c = opp.id;
        insert whatsappMessage3;

        WA_API_Details_Gupshup__c apiDetails = new WA_API_Details_Gupshup__c(
            Name__c = 'App1',
            Project_Name__c = 'Project A'
        );
        insert apiDetails;
        
        
        // Mock request body
        LiveChatController testData = new LiveChatController();
        testData.payload = new LiveChatController.Payload();
        testData.payload.sender = new LiveChatController.Sender();
        testData.payload.sender.phone = '1234567890';
        testData.payload.payload = new LiveChatController.PayloadData(); 
        testData.payload.payload.text = 'Test message'; 
        testData.payload.payload.url = 'http://example.com/testfile'; 
        testData.payload.phone = '1234567890';
        testData.payload.type = 'user-event';
        testData.payload.id = '2123432123';
        testData.payload.destination = '1234567890';
        testData.app = 'App1'; 
        // testData.payload.payload.text ='adc';
        //  testData.payload.payload.url = 'www.google.com';
        
        String requestBody = JSON.serialize(testData);
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the REST endpoint
        Test.startTest();
        RestLiveChatController.LiveChat();
        RestLiveChatController.handleUserEvent(testData);
        RestLiveChatController.handleMessageStatus(testData);
        RestLiveChatController.handleMessage(testData);
        RestLiveChatController.createWhatsAppMessage(testData , '911234567890','2123432123','87722332','2123432123','2123432123','2123432123');
        RestLiveChatController.createWhatsAppMessage(testData , '911234998877','2123432123','87722332','2123432123','2123432123','2123432123');
        RestLiveChatController.createWhatsAppMessage(testData , '911234998877','2123432123','87722332','2123432123','2123432123','2123432123');
        RestLiveChatController.createWhatsAppMessage(testData , '918877665544','2123432123','87722332','2123432123','2123432123','2123432123');
        RestLiveChatController.userevent(testData,'911234567890','opted-in');
        RestLiveChatController.userevent(testData,'911234567890','opted-out');
        RestLiveChatController.userevent(testData,'91911234567890','opted-out');
        RestLiveChatController.userevent(testData,'918965764543','opted-out');
        RestLiveChatController.userevent(testData,'1234567890','opted-in');
        //RestLiveChatController.userevent(testData,'918877665544','opted-in');
        RestLiveChatController.UpdateWhatsAppMessage(testData ,'2123432123','2123432123','2123432123');
        
        Test.stopTest();
        
        
    }

    @isTest
    static void testLiveChat1() {
        // Test data setup
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/LiveChat/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        insert pro;

        
        // Create Person Account
        Account acc = new Account();
        acc.LastName = 'abc';
        acc.Phone = '1234567890';
        acc.Opted_In__c = true;
        acc.PersonEmail = 'example@example.com';
        acc.PersonMobilePhone = '9876543210';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); // Provide the Record Type Id for Person Account
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        // opp.Mobile__c = '1234567890';
        opp.Account__c = acc.Id;
        opp.Project__c = pro.Id;
        insert opp;
        
        WhatsApp_Message__c whatsappMessage1 = new WhatsApp_Message__c();
        whatsappMessage1.Customer_Phone__c = '9876543210';
        whatsappMessage1.Success__c = true;
        whatsappMessage1.Message_Id__c = '2123432123';
        whatsappMessage1.API_Status__c = 'Success';
        whatsappMessage1.Message_Type__c = 'Normal';
        whatsappMessage1.Opportunity__c = opp.id;
        insert whatsappMessage1;
        
        WA_API_Details_Gupshup__c apiDetails = new WA_API_Details_Gupshup__c(
            Name__c = 'App1',
            Project_Name__c = 'Project A'
        );
        insert apiDetails;
        
        // Mock request body
        LiveChatController testData = new LiveChatController();
        testData.payload = new LiveChatController.Payload();
        testData.payload.sender = new LiveChatController.Sender();
        testData.payload.sender.phone = '1234567890';
        testData.payload.payload = new LiveChatController.PayloadData(); 
        testData.payload.payload.text = 'Test message'; 
        testData.payload.payload.url = 'http://example.com/testfile'; 
        testData.payload.phone = '1234567890';
        testData.payload.type = 'user-event';
        testData.payload.id = '2123432123';
        testData.payload.destination = '1234567890';
        testData.app = 'App1'; 
        // testData.payload.payload.text ='adc';
        //  testData.payload.payload.url = 'www.google.com';
        
        String requestBody = JSON.serialize(testData);
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        RestLiveChatController.LiveChat();
        RestLiveChatController.handleUserEvent(testData);
        RestLiveChatController.handleMessageStatus(testData);
        RestLiveChatController.handleMessage(testData);
        RestLiveChatController.createWhatsAppMessage(testData , '919876543210','2123432123','87722332','2123432123','2123432123','2123432123');
       
        
        
    }

    
    
    // Add more test methods for other scenarios as needed
}