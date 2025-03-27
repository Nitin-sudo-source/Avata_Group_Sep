@isTest
public class TestEx_DuplicationHandlerServices {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Mock response');
            return res;
        }
    }
    
    
    @isTest
    public static void leadMobileDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        List<Lead__c> leadList2 = new List<Lead__c>(); 
        
        Project__c pro = new Project__c();
        pro.Name = 'Project A';
        pro.Lead_validity_in_days__c = 45;
        insert pro;
        
        Lead__c l3 = new Lead__c();
        l3.First_Name__c = 'Lead1';
        l3.Last_Name__c = 'Lead__c 1';
        l3.Mobile__c = '1122334455';
        l3.Phone__c = '7887755663';
        l3.Alternate_Email__c = 'Test@gmail.com';
        l3.Email__c = 'Test2@gmail.com';
        l3.Project__c = pro.Id;
        l3.Last_Presales_Call_Date__c = System.Today();
        l3.Presales_Call_Count__c = 0;
        l3.Lead_Stage__c = 'Incoming';
        //l3.Lead_Sub_Stage__c = 'Unserviced';
        l3.Presales_Next_Follow_up_Date__c = System.Today();
        insert l3;
        
        l3.Alternate_Email__c = 'Test@gmail.com';
        l3.Email__c = 'Test2@gmail.com';
        l3.Mobile__C = '1122334455';
        l3.Phone__c = '7887755663';
        l3.Presales_Call_Count__c = 1;
        l3.Lead_Stage__c = 'Visit Confirmed';
        l3.Lead_Sub_Stage__c = 'Visit Confirmed';
        //l3.Presales_Next_Follow_up_Date__c = System.Today().addDays(2);
        
        update l3;
        leadList.add(l3);
        
        Lead__c l1 = new Lead__c( Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455' ,Last_Presales_Call_Date__c = System.Today(),Project__c = pro.id);
        insert l1;
        Lead__c l11 = new Lead__c( Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455',Last_Presales_Call_Date__c = System.Today(),Project__c = pro.id);
        insert l11;
        leadList2.add(l11);
        Lead__c l2 = new Lead__c( Last_Name__c = 'Lead__c 2', Mobile__C = '1122334455',Last_Presales_Call_Date__c = System.Today(),Project__c = pro.id);
        leadList.add(l2);
        
        Set<Id> leadIds = new Set<Id>{l3.Id};
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        Set<Id> leadset = new Set<Id>();
        leadset.add(l2.id);
        
    }
    
    @isTest
    public static void leadEmailDuplicate() {
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c(Last_Name__c = 'Lead__c 2', Mobile__C = '1122334456', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void leadPhoneDuplicate() {
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455',Phone__c ='9528442628', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c( Last_Name__c = 'Lead__c 2', Mobile__C = '1122334456',Phone__c = '9528442628', Email__c = 'lead1@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void leadAlternateEmailDuplicate() {
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = new Lead__c( Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455', Email__c = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c(Last_Name__c = 'Lead__c 2',  Mobile__C = '1122334456', Email__c = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void accountMobileDuplicate() {
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<Lead__c> leadList2 = new List<Lead__c>();
        
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        
        Lead__c l1 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l11 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l11;
        leadList2.add(l11);
        Lead__c l2 = new Lead__c(Last_Name__c = 'Lead__c 2', Mobile__C = '1122334455',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = recordTypeId);
        insert a1;
        Id recordTypenewId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a11 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455',RecordTypeId = recordTypenewId);
        insert a11;
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead__c 2', PersonMobilePhone = '1122334455');
        accList.add(a2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void accountEmailDuplicate() {
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        
        Lead__c l1 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c(Last_Name__c = 'Lead__c 2', Mobile__C = '1122334456', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = recordTypeId);
        insert a1;
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead__c 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead@test.in');
        accList.add(a2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void accountPhoneDuplicate() {
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        
        Lead__c l1 = new Lead__c( Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455',Phone__c ='9528442628', Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c( Last_Name__c = 'Lead__c 2', Mobile__C = '1122334456',Phone__c = '9528442628', Email__c = 'lead1@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = recordTypeId);
        insert a1;
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead__c 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead1@test.in', Phone = '6677889900');
        accList.add(a2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void accountAlternateEmailDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        List<Account> accList = new List<Account>();
        
        Project__c pro1 = new Project__c();
        pro1.Name = 'Project A';
        pro1.Lead_validity_in_days__c = 45;
        insert pro1;
        
        
        Lead__c l1 = new Lead__c(Last_Name__c = 'Lead__c 1', Mobile__C = '1122334455', Email__c = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        insert l1;
        Lead__c l2 = new Lead__c(Last_Name__c = 'Lead__c 2', Mobile__C = '1122334456', Email__c = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',Last_Presales_Call_Date__c = System.Today(),Project__c = pro1.id);
        leadList.add(l2);
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = recordTypeId);
        insert a1;
        a1.Phone = '6677889900';
        update a1;
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead__c 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        accList.add(a2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        
    }
    
    @isTest
    public static void testDuplicationCheckAcccount() {
        List<Account> accList = new List<Account>();
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = recordTypeId);
        insert a1;
        a1.Phone = '6677889900';
        update a1;
        Account a2 = new Account(FirstName = 'Test', LastName = 'Lead__c 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in');
        accList.add(a2);
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> result = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
        
    } 
    
}