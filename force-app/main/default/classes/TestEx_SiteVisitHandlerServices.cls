@isTest
public class TestEx_SiteVisitHandlerServices {
    
    @isTest
    public static void testupdateSalesManagerAvailability() {
        
        // Create and insert a Project__c record
        Project__c p = new Project__c();
        p.Name = 'Test Project 1';
        p.Assignment_TAT__c = 45;
        p.Source_TAT__c = 60;
        insert p;
        
        // Create and insert a Team__c record
        Team__c t = new Team__c();
        t.Name = 'Sales Team';
        t.Project__c = p.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        // Get System Administrator Profile and User
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        // Create and insert a Team_Member__c record
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.Id;
        tm.Availability__c = false;
        tm.Sequence_Number__c = 1;
        tm.Assignment_Counter__c = 10;
        tm.Last_Assignment_DateTime__c = system.now();
        tm.Last_Assignment_Milliseconds__c = 100;
        tm.User__c = sysAdminUser.Id;
        insert tm;
        
        tm.User__c = UserInfo.getUserId();
        tm.Availability__c = true;
        update tm;
        
        // Create and insert a Site_Visit__c record
        Site_Visit__c sv = new Site_Visit__c();
        sv.Project__c = p.Id;
        sv.Comments__c = 'Comment 1';
        sv.Sales_Manager__c = tm.User__c;
        sv.Sourcing_Manager__c = tm.User__c; // Setting Sourcing_Manager__c
        insert sv;
        
        sv.Sales_Manager__c = userInfo.getUserId();
        sv.Sourcing_Manager__c = sysAdminUser.Id;
        update sv;
        
        // Start test context
        Test.startTest();
        
        // Call the afterInsert method directly to simulate the trigger behavior
        Ex_SiteVisitTriggerHandler.afterInsert(new List<Site_Visit__c>{sv});
        
        // Update Team_Member__c record to change Availability
        tm.Availability__c = false;
        update tm;
        
        // Update Site_Visit__c record
        sv.Comments__c = 'Comment 2';
        update sv;
        
        // Call the afterUpdate method directly to simulate the trigger behavior
        Map<Id, Site_Visit__c> oldMap = new Map<Id, Site_Visit__c>{sv.Id => new Site_Visit__c(Id = sv.Id, Comments__c = 'Comment 1', Sourcing_Manager__c = tm.User__c)};
        Map<Id, Site_Visit__c> newMap = new Map<Id, Site_Visit__c>{sv.Id => new Site_Visit__c(Id = sv.Id, Comments__c = 'Comment 2', Sourcing_Manager__c = '005dN000001I9NeQAK')};
        Ex_SiteVisitTriggerHandler.afterUpdate(oldMap, newMap);
        
        Set<Id> oldMapId = new Set<Id>{sv.Id};
        Set<Id> newMapId = new Set<Id>{userInfo.getUserId()};
            Ex_SiteVisitHandlerServices.reAssignmentofSalesManager(newMapId);
        Ex_SiteVisitHandlerServices.removeSharingWithSourcingManager(oldMapId);
        
        // Stop test context
        Test.stopTest();
        
        // Assert that the methods were called and the results are as expected
        // (Assertions should be added based on the actual implementation and expected results)
    }
}