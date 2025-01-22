@isTest
public class TestEx_RESTCTIAgentServices {
    @isTest
    public static void getFreshLeadAgentId() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Campaign__c c = new Campaign__c();
        c.Name = 'Test CTI Campaign';
        c.Start_Date__c = system.today();
        c.Is_CTI_Campaign__c = true;
        c.Offline_Campaign__c = true;
        c.Ozontel_Campaign_Name__c = 'CTI Campaign';
        c.Virtual_Number__c = '1234';
        c.Project__c = p.Id;
        c.Lead_Source__c = 'Hoarding';
        c.Lead_Sub_Source__c = 'Billboard';
        c.Source__c = 'Bus Stand';
        c.Approver_Status__c = 'Approved';
        insert c;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        String json = '{"mobileNo":"1234567890", "did":"1234"}';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = res;
      
        Test.startTest();   
            Ex_RESTCTIAgentServices.getAgentId('01234567890', '1234');
        Test.stopTest();
    }
}