@isTest
public class TestEx_OpportunityHandlerServices {
    @isTest
    public static void testMethod1() {
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Project__c proj2 = new Project__c();
        proj.Name = 'Test Project';
        insert proj2;
        
        Account acc = new Account();
        acc.Alternate_Mobile__c = '1234567890';
        acc.PersonEmail = 'dummy@gmail.com';
        acc.LastName = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        // Create and insert a Project__c record (assuming CP_Project__c is a custom object)
        CP_Project__c cpProject = new CP_Project__c();
        cpProject.Project__c = proj.Id;
        insert cpProject;
        
        Opportunity__c opp2 = new Opportunity__c();
        opp2.Name = 'Test Opporunity 2';
        opp2.Account__c = acc.Id;
        opp2.Opportunity_Stage__c = 'In Follow-up';
        opp2.Sourcing_Manager__c = sysAdminUser.Id;
        opp2.CP_Project__c = cpProject.Id;
        insert opp2;
        
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Opporunity';
        opp.Account__c = acc.Id;
        opp.Opportunity_Stage__c = 'In Follow-up';
        opp.Sourcing_Manager__c = sysAdminUser.Id;
        opp2.CP_Project__c = cpProject.Id;
        insert opp;
        opp.Project__c = proj.Id;
        opp.SV_Count__c = 1;
        opp.Sourcing_Manager__c = UserInfo.getUserId();
        opp.Closing_Manager__c = UserInfo.getUserId();    
        opp2.CP_Project__c = cpProject.Id;
        update opp;
        
        Opportunity__c opp1 = new Opportunity__c();
        opp1.Name = 'Test Opporunity';
        opp1.Account__c = acc.Id;
        opp1.Opportunity_Stage__c = 'In Follow-up';
        opp1.Project__c = proj.Id;
        insert opp1;
        opp1.Opportunity_Stage__c = 'Booked';
        update opp1;
        
        Set<Id> oppIds = new Set<Id> {opp.Id,opp1.Id,opp2.Id};
        
        
        // Testing the Booking scenario
        // Create and insert another CP_Project__c record for testing
        CP_Project__c cpProject2 = new CP_Project__c();
        cpProject2.Project__c = proj.Id;
        insert cpProject2;
        
        // Call the method to update Booking_Count__c and Last_Booking_Date__c
        Set<Id> cppIds = new Set<Id>{cpProject2.Id};
       
        Test.startTest();          
        Ex_OpportunityHandlerServices.calulateNoofOpporunity(cppIds, 'Booking');
        Ex_OpportunityHandlerServices.removeSharingWithSourcingManager(oppIds);
        Ex_OpportunityHandlerServices.apexSharingWithSalesManager(oppIds);
        Test.stopTest();
        
        // Verify that the Booking_Count__c and Last_Booking_Date__c fields are updated
        //CP_Project__c updatedCpProject2 = [SELECT Booking_Count__c, Last_Booking_Date__c FROM CP_Project__c WHERE Id = :cpProject2.Id];
        
       // System.assertEquals(1, updatedCpProject2.Booking_Count__c, 'Booking Count should be incremented by 1.');
        //System.assertEquals(System.today(), updatedCpProject2.Last_Booking_Date__c, 'Last Booking Date should be updated to today.');
    }
    
    
}