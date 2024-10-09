@isTest
public class TestWebToLeadRest {

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
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Campaign_Code__c = '123';
        c2.Master_Source__c = 'Digital';
        c2.Status__c = 'Completed';
        insert c2;
        c2.Campaign_Code__c = c2.Id;
                c2.Active__c = true;
        update c2;
        returnMap.put('Child Campaign 1', c2.Id);
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Weekly';
        c4.Campaign_Code__c = '123';
        c4.Master_Source__c = 'Digital';
        c4.Status__c = 'Completed';
        insert c4;
       // c4.Campaign_Code__c = c4.Id;
       // update c4;
		returnMap.put('Child Campaign 3', c4.Id); 
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';
        c3.Campaign_Code__c = '123';
        c3.Master_Source__c = 'Digital';
        c3.Status__c = 'Completed';
        insert c3;
        returnMap.put('Child Campaign 2', c3.Id); 
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
        cpl.Lead_Count__c = 1;
        update cpl;
       
        //update c3;
		
       
        return returnMap;
    }
    
	@isTest
    public static void freshLead() {
        Map<String, Id> resultMap = createCampaign();
        
        REST_WebIntegration.REST_Request req1 = new REST_WebIntegration.REST_Request();
        req1.name = 'Test Lead';
        req1.mobile = '1122334455';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 1');
        req1.email = 'lead@test.in';
        req1.remarks = 'Web Created Lead.';
        req1.url = 'www.test.com';
        req1.UTM_Source = 'Google';
        req1.UTM_Medium = 'Ads';
        
        REST_WebIntegration.REST_Request req2 = new REST_WebIntegration.REST_Request();
        req2.name = 'Test Lead';
        req2.mobile = '1122334455';
        req2.LeadIdentifier = 'Web';
        req2.campaignCode = resultMap.get('Child Campaign 2');
        req2.email = 'lead@test.in';
        req2.remarks = 'Web Created Lead.';
        req2.url = 'www.test.com';
        req2.UTM_Source = 'Google';
        req2.UTM_Medium = 'Ads';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        REST_WebIntegration.createLead(req1);
        REST_WebIntegration.createLead(req2);
        Test.stopTest();
    }
    
    @isTest
    public static void opportunityPresent() {
        Map<String, Id> resultMap = createCampaign();
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '1122334455', RecordTypeId = devRecordTypeId);
        insert a;
        system.debug('Test: '+a.PersonContactId);
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Stage__c = 'In Follow-up', Project__c = resultMap.get('Project'));
        insert op;
        
        REST_WebIntegration.REST_Request req1 = new REST_WebIntegration.REST_Request();
        req1.name = 'Test Lead';
        req1.mobile = '1122334455';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 1');
        req1.email = 'lead@test.in';
        req1.remarks = 'Web Created Lead.';
        req1.url = 'www.test.com';
        req1.UTM_Source = 'Google';
        req1.UTM_Medium = 'Ads';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        REST_WebIntegration.createLead(req1);
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
        Ld.Description__c = 'Test244';
        Ld.Campaign_Code__c = '1234';
        Ld.Apply_round_robin__c = true;
        insert Ld;
        
        REST_WebIntegration.REST_Request req1 = new REST_WebIntegration.REST_Request();
        req1.name = 'Test';
        req1.mobile = '7788002233';
        req1.LeadIdentifier = 'Web';
        req1.campaignCode = resultMap.get('Child Campaign 1');
        req1.email = 'Test2@gmail.com';
        req1.remarks = 'Web Created Lead.';
        req1.url = 'www.test.com';
        req1.UTM_Source = 'Google';
        req1.UTM_Medium = 'Ads';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/CreateLead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        REST_WebIntegration.createLead(req1);
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
        tm.Is_User_Active__c = true;
        insert tm;
        
       Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'Test';
        Ld.Mobile__c = '7788002233';
        Ld.Email__c = 'Test2@gmail.com';
        Ld.Project__c = p.id;
        Ld.Description__c = 'Test244';
        Ld.Campaign_Code__c = '1234';
        Ld.Apply_round_robin__c = true;
        insert Ld;
        Ld.OwnerId =  UserInfo.getUserId();
        update ld;
       
    }
}