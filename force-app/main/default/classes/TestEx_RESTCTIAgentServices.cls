@isTest
public class TestEx_RESTCTIAgentServices {
    
    static testMethod void testGetAgentId() {
        Project__c p = new Project__c();
        p.Name = 'Nitin P';
        insert p;
        
        // Create mock Campaign__c record
        Campaign__c campaign = new Campaign__c(
            Virtual_Number__c = '1234567890',
            Lead_Source__c = 'Google',
            Lead_Sub_Source__c = 'Google Search',
            Source_Description__c = 'Description',
            Project__c = p.Id,
            Campaign_Code__c = 'Code',
            Start_Date__c = System.today(),
            Is_CTI_Campaign__c = true,
             Approval_Status__c = 'Approved'
        );
        insert campaign;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a1 = new Account( Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455' ,RecordTypeId  = RecTypeId);
        insert a1;
        
        // Create mock Lead__c record
        Lead__c lead = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Lead',
            Mobile__c = '0987654321',
            IsConverted__c = false,
            OwnerId = UserInfo.getUserId()
        );
        insert lead;
        
        // Create mock User record with Agent_Id__c and MobilePhone
        User user = [SELECT Id, Agent_Id__c, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
        user.Agent_Id__c = 'AGENT123';
        user.MobilePhone = '9876543210';
        update user;
        
        // Set up the RestContext parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('fromnumber', '009876543210');
        RestContext.request.addParameter('landingnumber', '1234567890');
        RestContext.response = new RestResponse();
        
        // Execute the method
        Test.startTest();
        Ex_RESTCTIAgentServices.REST_result result = Ex_RESTCTIAgentServices.getAgentId();
        Test.stopTest();
        
       
    }
    
    static testMethod void testGetAgentId_NoAccountOrLead() {
        Project__c p = new Project__c();
        p.Name = 'Nitin P';
        insert p;
        
        // Create mock Campaign__c record
        Campaign__c campaign = new Campaign__c(
            Virtual_Number__c = '1234567890',
            Lead_Source__c = 'Google',
            Lead_Sub_Source__c = 'Google Search',
            Source_Description__c = 'Description',
            Project__c = p.Id,
            Campaign_Code__c = 'Code',
            Start_Date__c = System.today(),
            Is_CTI_Campaign__c = true,
            Approval_Status__c = 'Approved'
        );
        insert campaign;
        
        // Set up the RestContext parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('fromnumber', '0987654321');  // No matching Account or Lead
        RestContext.request.addParameter('landingnumber', '1234567890');
        RestContext.response = new RestResponse();
        
        // Execute the method
        Test.startTest();
        Ex_RESTCTIAgentServices.REST_result result = Ex_RESTCTIAgentServices.getAgentId();
        Test.stopTest();
        
        // Verify the lead was created as there was no existing account or lead
        Lead__c createdLead = [SELECT Id, First_Name__c, Last_Name__c, Mobile__c FROM Lead__c WHERE Mobile__c = '0987654321' LIMIT 1];
        
    }
    
    static testMethod void testGetAgentId_NoCampaignOrAgent() {
        // Set up the RestContext parameters with a landing number that does not match any Campaign__c record
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('fromnumber', '0987654321');
        RestContext.request.addParameter('landingnumber', '1111111111');  // No matching campaign
        RestContext.response = new RestResponse();
        
        // Execute the method
        Test.startTest();
        Ex_RESTCTIAgentServices.REST_result result = Ex_RESTCTIAgentServices.getAgentId();
        Test.stopTest();
        
        
    }
    
    static testMethod void testCPProject() {
        
        User user = [SELECT Id, Agent_Id__c, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
        user.Agent_Id__c = 'AGENT123';
        user.MobilePhone = '9090902345';
        update user;
        
        Project__c p = new Project__c();
        p.Name = 'Nitin P';
        p.Pre_Sales_TL__c = UserInfo.getUserId();
        insert p;
        
        CP_Project__c cp = new CP_Project__c();
        cp.Project_Name__c = p.Id;
        cp.DID_1__c = '09090909344';
        cp.DID_2__c = '9090902345';
        
        insert cp;
        
        CP_Lead__c cpl = new CP_Lead__c();
        cpl.Mobile__c = '8989898888';
        cpl.CP_Project__c = cp.Id;
        cpl.ownerId = UserInfo.getUserId();
        cpl.Project__c = p.Id;
        insert cpl;
        
        // Set up the RestContext parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('fromnumber', '8989898888');
        RestContext.request.addParameter('landingnumber', '09090909344');
        RestContext.response = new RestResponse();
        
         // Set up the RestContext parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('fromnumber', '8989898899');
        RestContext.request.addParameter('landingnumber', '09090909344');
        RestContext.response = new RestResponse();
        
        // Execute the method
        Test.startTest();
        Ex_RESTCTIAgentServices.REST_result result = Ex_RESTCTIAgentServices.getAgentId();
        Test.stopTest();
        
        
        
        
    }
    
    
}