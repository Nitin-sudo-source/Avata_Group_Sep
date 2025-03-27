@isTest
public class TestEx_SMAssignmentController {
    @isTest
    public static void testMethod1(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        User u = new User();
        u.IsActive = true;
        u.Username = 'test2@email.com'; // Ensure this email is unique in your org
        u.LastName = 'test';
        u.Email = 'test@email.com';
        u.Alias = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles'; // Set appropriate timezone
        u.LocaleSidKey = 'en_US'; // Set appropriate locale
        u.EmailEncodingKey = 'UTF-8'; // Set email encoding
        u.ProfileId = sysAdminProfile.Id; // Assign the fetched profile
        u.LanguageLocaleKey = 'en_US'; // Set language
        
         Project__c p = new Project__c();
        p.Name = 'Test';
        p.Assignment_TAT__c = 30;
        insert p;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test';
        opp.Closing_Manager__c =  sysAdminUser.Id;
        opp.Project__c = p.Id;
        insert opp;
        
       
        
        Team__c t = new Team__c();
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        
        Team_Member__c tm = new Team_Member__c();
        tm.User__c = opp.Closing_Manager__c;
        tm.Team__c = t.Id;
        tm.Availability__c = true;
        insert tm;
        
        
        Team_Member__c tm1 = new Team_Member__c();
        tm1.User__c = sysAdminUser.Id;
        tm1.Availability__c = true;
        tm1.Assignment_Counter__c = 3;
        insert tm1;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Opportunity__c = opp.Id;
        sv.SV_Count__c = 2;
        sv.Project__c = p.Id;
        sv.OwnerId = sysAdminUser.Id;
        insert sv;
        
        
        test.startTest();
        Ex_SMAssignmentController.getSVRecord(sv.Id);
        Ex_SMAssignmentController.getAllSalesManager(sv);
        Ex_SMAssignmentController.getAllSalesManagerTL(sv);
        Ex_SMAssignmentController.getPreferredSalesManager(sv);
        Ex_SMAssignmentController.assignSalesManager(sv,tm1);
        Ex_SMAssignmentController.reAssignSalesManager(sv,tm1,false);
        Ex_SMAssignmentController.checkUserAvailability(tm.Id);
        test.stopTest();
        
    } 
    
    @isTest
    public static void testMethod2() {
        // Create a System Administrator user
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id, IsActive FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        sysAdminUser.IsActive = true;
        
        // Create Opportunity
        Opportunity__c opp = new Opportunity__c(Name = 'Test', Closing_Manager__c = sysAdminUser.Id);
        insert opp;

        // Create Project
        Project__c p = new Project__c(Name = 'Test Project');
        insert p;

        // Create Team and link it to the project
        Team__c t = new Team__c(Team_Type__c = 'Sales Team', Project__c = p.Id);
        insert t;

        // Active team member for the sales team with availability and active status
        Team_Member__c tm = new Team_Member__c(User__c = sysAdminUser.Id, Team__c = t.Id, 
                                               Availability__c = true, DayOff__c = false); 
        insert tm;

        // Another team member for testing scenarios
        Team_Member__c tm1 = new Team_Member__c(User__c = sysAdminUser.Id, Availability__c = true, 
                                                DayOff__c = false);
        insert tm1;

        // Create a Site Visit record
        Site_Visit__c sv = new Site_Visit__c(Opportunity__c = opp.Id, SV_Count__c = 2, 
                                             Project__c = p.Id, OwnerId = sysAdminUser.Id);
        insert sv;

        // Start testing the methods
        test.startTest();
        Ex_SMAssignmentController.getSVRecord(sv.Id);
        Ex_SMAssignmentController.getAllSalesManager(sv);
        Ex_SMAssignmentController.getPreferredSalesManager(sv);
        Ex_SMAssignmentController.assignSalesManager(sv, tm1);
        // Ex_SMAssignmentController.checkUserAvailability(sysAdminUser.Id);
        test.stopTest();
    }
    
    @isTest
    public static void testMethodNullReturn() {
        Site_Visit__c sv = new Site_Visit__c();
        insert sv;
        
        test.startTest();
        Site_Visit__c svRecord = Ex_SMAssignmentController.getSVRecord(sv.Id);
        test.stopTest();
    }
}