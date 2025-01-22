@isTest
public class TestEx_RestWebIntegration {
    @isTest
    public static Map<String, Id> createCampaign() {
        Map<String, Id> returnMap = new Map<String,Id>();
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        returnMap.put('Project', p.Id);
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.Campaign_Code__c = '123';
        insert c2;
        c2.Campaign_Code__c = c2.Id;
        update c2;
        returnMap.put('Child Campaign 1', c2.Id);
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.Campaign_Code__c = '123';
        insert c4;
        c4.Campaign_Code__c = c4.id;
        update c4;
        returnMap.put('Child Campaign 2',c4.Id);
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.Campaign_Code__c = '123';
        insert c3;
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
        cpl.Lead_Count__c = 1;
        update cpl;
        
        return returnMap;
    }
    
    @isTest
    public static void freshLead() {
        Map<String, Id> resultMap = createCampaign();
        
        Ex_RESTWebIntegration.REST_Request req1 = new Ex_RESTWebIntegration.REST_Request();
        req1.firstName = 'Test Lead';
        req1.mobile = '1122334455';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 1');
        req1.email = 'lead@test.in';
            
            
        
        Ex_RESTWebIntegration.REST_Request req2 = new Ex_RESTWebIntegration.REST_Request();
        req2.firstName = 'Test Lead';
        req2.mobile = '1122334455';
        req2.LeadIdentifier = 'Web';
        req2.campaignCode = resultMap.get('Child Campaign 2');
        req2.email = 'lead@test.in';

        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Ex_RESTWebIntegration.createLead(req1);
        Ex_RESTWebIntegration.createLead(req2);
        Test.stopTest();
    }
    
    @isTest
    public static void opportunityPresent() {
        Map<String, Id> resultMap = createCampaign();
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in',RecordTypeId = RecTypeId);
        insert a2;
        
        Opportunity__c op = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Campaign__c = resultMap.get('Child Campaign 2'),  Project__c = resultMap.get('Project'), Account__c = a2.id);
        insert op;
        
        Ex_RESTWebIntegration.REST_Request req1 = new Ex_RESTWebIntegration.REST_Request();
        req1.firstName = 'Test Lead';
        req1.mobile = '1122334456';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 2');
        req1.email = 'lead@test.in';
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Ex_RESTWebIntegration.createLead(req1);
        Test.stopTest();
    }
    
    
    @isTest
    public static void LeadPresent() {
        Map<String, Id> resultMap = createCampaign();
        
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'Test';
        Ld.Mobile__c = '7788002233';
        Ld.Email__c = 'Test2@gmail.com';
        Ld.Project__c = resultMap.get('Project');
        Ld.Campaign_Code__c = '1234';
        Ld.Apply_round_robin__c = true;
        insert Ld;
        
        Ex_RESTWebIntegration.REST_Request req1 = new Ex_RESTWebIntegration.REST_Request();
        req1.firstName = 'Test';
        req1.mobile = '7788002233';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 1');
        req1.email = 'Test2@gmail.com';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Ex_RESTWebIntegration.createLead(req1);
        Test.stopTest();
    } 
    @isTest
    public static Project__c createProject() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        return p;
    }
    
    @isTest
    public static void roundRobin() {   
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Team__c t =new Team__c();
        t.Team_Type__c = 'Sales Team';
        t.Project__c = p.Id;
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.id;
        tm.User__c = UserInfo.getUserId();
        tm.Availability__c = true;
        insert tm;
        
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'Test';
        Ld.Mobile__c = '7788002233';
        Ld.Email__c = 'Test2@gmail.com';
        Ld.Project__c = p.id;
        Ld.Campaign_Code__c = '1234';
        Ld.Apply_round_robin__c = true;
        insert Ld;
        Ld.OwnerId =  UserInfo.getUserId();
        update ld;
        
    }
    
}