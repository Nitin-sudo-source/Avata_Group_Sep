@isTest
public class TestEx_StarConnectServices_API{
    
    @isTest
    static void testGetData() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        // Mock the request parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('name', 'Test Name');
        RestContext.request.addParameter('email', 'test@example.com');
        RestContext.request.addParameter('mobile', '1234567890');
        RestContext.request.addParameter('alternateNo', '0987654321');
        RestContext.request.addParameter('projectId', p.Id);
        RestContext.request.addParameter('Location', 'Test Location');
        RestContext.request.addParameter('callType', 'Inbound');
        RestContext.request.addParameter('AgentName', 'Test Agent');
        RestContext.request.addParameter('virtualNo', '1112223333');
        RestContext.request.addParameter('callStatus', 'Completed');
        RestContext.request.addParameter('subStage', 'Budget does not match');
        RestContext.request.addParameter('audioFile', 'test_audio.mp3');
        RestContext.request.addParameter('callDuration', '300');
        RestContext.request.addParameter('NextfollupDate', '2024-07-02 14:10:00');
        RestContext.request.addParameter('proposedVisitDate', '2024-07-05 14:10:00');
        RestContext.request.addParameter('proposedVisitTime', '11:40:00 AM');
        RestContext.request.addParameter('remarks', 'Test Remarks');
        Test.StartTest();
        RestContext.response = new RestResponse();
       Ex_StarConnectServices.Rest_result result = Ex_StarConnectServices.getData();
        Test.StopTest();
        
        
    }
        
    @isTest
    static void testDuplicationHandler() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Lead__c existingLead = new Lead__c();
        existingLead.Last_Name__c = 'Test Name';
        existingLead.Mobile__c = '1234567890';
        existingLead.Project__c = p.Id;
        existingLead.Lead_Created_From__c = 'Start Connect';
        existingLead.Lead_Identifier__c = 'CTI';
        insert existingLead;
       
        Set<Id> leadSet = new Set<Id>();
        leadSet.add(existingLead.Id);
        Ex_GetStartConnectAPIServices.getStartConnectData(leadSet);
        
        // Mock the request parameters
        RestContext.request = new RestRequest();
        RestContext.request.addParameter('name', 'Test Name');
        RestContext.request.addParameter('email', 'test@example.com');
        RestContext.request.addParameter('mobile', '1234567890');
        RestContext.request.addParameter('alternateNo', '0987654321');
        RestContext.request.addParameter('projectId', p.Id);
        RestContext.request.addParameter('Location', 'Test Location');
        RestContext.request.addParameter('callType', 'Inbound');
        RestContext.request.addParameter('AgentName', 'Test Agent');
        RestContext.request.addParameter('virtualNo', '1112223333');
        RestContext.request.addParameter('callStatus', 'Completed');
        RestContext.request.addParameter('subStage', 'Budget does not match');
        RestContext.request.addParameter('audioFile', 'test_audio.mp3');
        RestContext.request.addParameter('callDuration', '300');
        RestContext.request.addParameter('NextfollupDate', '2024-07-02 14:10:00');
        RestContext.request.addParameter('proposedVisitDate', '2024-07-05 14:10:00');
        RestContext.request.addParameter('proposedVisitTime', '11:40:00 AM');
        RestContext.request.addParameter('remarks', 'Test Remarks');
        Test.StartTest();
        RestContext.response = new RestResponse();
        Ex_StarConnectServices.Rest_result result = Ex_StarConnectServices.getData();
        Test.StopTest();
        
    }
    
     @isTest
    public static void opportunityPresent() {
        Project__c project = new Project__c(Name = 'Test Project Opp');
        insert project;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        
        Opportunity__c op = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Site_Visit_Count__c = 1,  Project__c = project.Id, Account__c = a2.id);
        insert op;
        
       RestContext.request = new RestRequest();
        RestContext.request.addParameter('name', 'Test Name');
        RestContext.request.addParameter('email', 'lead2@test.in');
        RestContext.request.addParameter('mobile', '911122334456');
        RestContext.request.addParameter('alternateNo', '1122334456');
        RestContext.request.addParameter('projectId', project.Id);
        RestContext.request.addParameter('Location', 'Test Location');
        RestContext.request.addParameter('callType', 'Inbound');
        RestContext.request.addParameter('AgentName', 'Test Agent');
        RestContext.request.addParameter('virtualNo', '1112223333');
        RestContext.request.addParameter('callStatus', 'Completed');
        RestContext.request.addParameter('subStage', 'Budget does not match');
        RestContext.request.addParameter('audioFile', '');
        RestContext.request.addParameter('callDuration', '300');
        RestContext.request.addParameter('NextfollupDate', '2024-07-02 14:10:00');
        RestContext.request.addParameter('proposedVisitDate', '2024-07-05 14:10:00');
        RestContext.request.addParameter('proposedVisitTime', '11:40:00 AM');
        RestContext.request.addParameter('remarks', 'Test Remarks');
        Test.StartTest();
        RestContext.response = new RestResponse();
        Ex_StarConnectServices.Rest_result result = Ex_StarConnectServices.getData();
        Test.StopTest();
    }
}