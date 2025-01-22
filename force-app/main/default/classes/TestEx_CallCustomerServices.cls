@isTest
public class TestEx_CallCustomerServices {
    
    @isTest
    public static void testClickToCallforLead() {
        
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        
        Campaign__c c = new Campaign__c();
        c.Virtual_Number__c = '912245811703';
        c.Is_CTI_Campaign__c = true;
        c.Project__c = pr.id;
        c.Approver_Status__c = 'Approved';
        c.Start_Date__c = System.today();
        c.Approver_Name__c = UserInfo.getuserId();
        c.Ozontel_Campaign_Name__c = 'Inbound_912245811703';
        c.Offline_Campaign__c = false;
        insert c;
        
        Campaign__c c2 = new Campaign__c();
        c2.Virtual_Number__c = '912245811701';
        c2.Is_CTI_Campaign__c = true;
        c2.Project__c = pr.id;
        c2.Approver_Status__c = 'Approved';
        c2.Start_Date__c = System.today();
        c2.Approver_Name__c = UserInfo.getuserId();
        c2.Offline_Campaign__c = true;
        c2.Ozontel_Campaign_Name__c = 'Inbound_912245811701';
        insert c2;
        
        Lead__c ld = new Lead__c();
        ld.Last_Name__c = 'Test Lead';
        ld.IsConverted__c = false;
        ld.Mobile__c = '08871430235';
        insert ld;
        System.debug('uui: '+ld.Id);
        
        List<Ex_CallCustomerServices.campWrapper> resultLeadCamp = Ex_CallCustomerServices.getCampaign(ld.Id, 'Large');
        List<Ex_CallCustomerServices.campWrapper> resultLeadOffline = Ex_CallCustomerServices.getCampaign(ld.Id, 'Small');
        List<Ex_CallCustomerServices.callWrapper> resultLeadMobile = Ex_CallCustomerServices.getMobileNumber(ld.id);
        String resultLead = Ex_CallCustomerServices.ClickToCall('1122334456', c2.Name, c2.Virtual_Number__c, 'Small', ld.Id);        
    }
    
    @isTest
    public static void testClickToCallforOpportunity() {
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        
        Campaign__c c2 = new Campaign__c();
        c2.Virtual_Number__c = '912245811701';
        c2.Is_CTI_Campaign__c = true;
        c2.Project__c = pr.id;
        c2.Approver_Status__c = 'Approved';
        c2.Start_Date__c = System.today();
        c2.Approver_Name__c = UserInfo.getuserId();
        c2.Offline_Campaign__c = true;
        c2.Ozontel_Campaign_Name__c = 'Inbound_912245811701';
        insert c2;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Opportunity__c op = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Project__c = pr.Id,Account__c = a2.id);
        insert op;
        System.debug('op: '+op);  
        
        List<Ex_CallCustomerServices.campWrapper> resultoppcamp = Ex_CallCustomerServices.getCampaign(op.Id, 'Large');
        List<Ex_CallCustomerServices.campWrapper> resultoppoffline = Ex_CallCustomerServices.getCampaign(op.Id, 'Small');
        List<Ex_CallCustomerServices.callWrapper> resultoppMobile = Ex_CallCustomerServices.getMobileNumber(op.id);
        String resultopp = Ex_CallCustomerServices.ClickToCall('1122334456', c2.Name, c2.Virtual_Number__c, 'Small', op.Id);
        
    }
    
    @isTest
    public static void testClickToCallforOla() {
        
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        
        Campaign__c c2 = new Campaign__c();
        c2.Virtual_Number__c = '912245811701';
        c2.Is_CTI_Campaign__c = true;
        c2.Project__c = pr.id;
        c2.Approver_Status__c = 'Approved';
        c2.Start_Date__c = System.today();
        c2.Approver_Name__c = UserInfo.getuserId();
        c2.Offline_Campaign__c = true;
        c2.Ozontel_Campaign_Name__c = 'Inbound_912245811701';
        insert c2;
        
        Ola_Pickup__c ola = new Ola_Pickup__c();
        ola.Primary_Mobile__c = '7878787877';
        ola.Alternate_Mobile__c = '8888000000';
        insert ola;
        
        List<Ex_CallCustomerServices.campWrapper> resultolaCamp = Ex_CallCustomerServices.getCampaign(ola.Id, 'Large');
        List<Ex_CallCustomerServices.campWrapper> resultLolaOffline = Ex_CallCustomerServices.getCampaign(ola.Id, 'Small');
        List<Ex_CallCustomerServices.callWrapper> resultolaMobile = Ex_CallCustomerServices.getMobileNumber(ola.id);
        String resultola = Ex_CallCustomerServices.ClickToCall('1122334456', c2.Name, c2.Virtual_Number__c, 'Small', ola.Id);
        
    }    
}