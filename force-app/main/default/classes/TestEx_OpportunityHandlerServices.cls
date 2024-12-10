@isTest
public class TestEx_OpportunityHandlerServices {
    @isTest
    public static void testMethod1(){
        Campaign__c cc = new Campaign__c();
        cc.Name = 'Test Campaign';
        insert cc;
        
        Campaign__c cc1 = new Campaign__c();
        cc1.Name = 'Test Campaign';
        insert cc1;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Account acc = new Account();
        acc.Phone = '1234567890';
        acc.PersonEmail = 'dummy@gmail.com';
        acc.LastName = 'Test';
        //acc.Alternate_Email__c = 'dummy1@gmail.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Opporunity';
        opp.Campaign__c = cc.Id;
        opp.Account__c = acc.Id;
        opp.Stage__c = 'In Follow-up';
        insert opp;
        opp.Project__c = proj.Id;
        opp.Campaign__c = cc1.Id;
        opp.SV_Count__c = 1;
        update opp;
        
        Opportunity__c opp1 = new Opportunity__c();
        opp1.Name = 'Test Opporunity';
        opp1.Account__c = acc.Id;
        opp1.Stage__c = 'In Follow-up';
        opp1.Project__c = proj.Id;
        insert opp1;
        opp1.Stage__c = 'Booked';
        opp1.Campaign__c = cc1.Id;
        update opp1;
        
        List<Opportunity__c> oppList = [Select Id , Name, Project__c,Account__c From Opportunity__c Where Id =:opp1.id ];
        
        Test.startTest();
       
        Ex_OpportunityHandlerServices.duplicationCheck(oppList);
        Test.stopTest();   
    }
}