@isTest
public class test_Ex_teamMemberTriggerHandler {
	@isTest
    public static void test_Ex_teamMemberTriggerHandler(){
        List<Team_Member__c> teamMemberList = new List<Team_Member__c>();
        Set<Id> teamSet = new Set<Id>();
        Test.startTest();
        
        Project__c p = new Project__c();
        p.Name = 'Satyam Group';
        insert p;
        
        Team__c t = new Team__c();
        t.Name = 'Test Sales Team';
        t.Project__c = p.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Name = 'test team member';
        tm.Sequence_Number__c = 1;
        tm.Team__c = t.Id;
		tm.Availability__c = false;
        tm.User__c = userInfo.getUserId();
        insert tm;
        
        Team_Member__c tm1 = new Team_Member__c();
        tm1.Name = 'test team member';
        tm1.Sequence_Number__c = 1;
        tm1.Team__c = t.Id;
		tm1.Availability__c = false;
        tm1.DayOff__c = true;
        tm1.User__c = userInfo.getUserId();
        insert tm1;
        
        Team_Member__c tm3 = new Team_Member__c();
        tm3.Name = 'test team member';
        tm3.Sequence_Number__c = 1;
        tm3.Team__c = t.Id;
		tm3.Availability__c = false;
        tm3.DayOff__c = FALSE;
        tm3.User__c = userInfo.getUserId();
        insert tm3;
        
        tm.Availability__c = true;
        update tm;
        tm3.Availability__c = true;
        update tm3;
        
        
        // Create a test CP_Document__c custom setting record for RERA_Available__c set to 'Yes'
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
        // Create a test record for Account with RERA_Available__c set to 'Yes'
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        
        Account testAccount1 = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.Project__c = p.Id;
        cp1.CP_Account__c = testAccount1.Id;
        insert cp1;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a2.id);
        insert o1;
        
        Opportunity__c o2 = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a2.id);
        insert o2; 
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Is_Sales_Manager_Assigned__c = false;
        sv.Sales_Manager__c = null;
        sv.Project_Name__c = p.Id;
        sv.Opportunity__c = o1.Id;
        sv.Site_Visit_Count__c = 1;
       	sv.Comment__c = 'Test';
        insert sv;
        
        sv.Comment__c = 'tetsttt';
        update sv;
        
        Site_Visit__c sv1 = new Site_Visit__c();
        sv1.Is_Sales_Manager_Assigned__c = false;
        sv1.Sales_Manager__c = null;
        sv1.Project_Name__c = p.Id;
        sv1.Opportunity__c = o2.Id;
        sv1.Site_Visit_Count__c = 2;
        insert sv1;
                List<Site_Visit__c> svList = new  List<Site_Visit__c>();

        Site_Visit__c sv2 = new Site_Visit__c();
        sv2.Is_Sales_Manager_Assigned__c = false;
        sv2.Sales_Manager__c = null;
        sv2.Project_Name__c = p.Id;
        sv2.Opportunity__c = o2.Id;
        sv2.Site_Visit_Count__c = 2;
        sv2.Lead_Source__c = 'Channel Partner';
        sv2.Channel_Partner__c = testAccount1.id;
        sv2.CP_Project__c = cp1.id;
        insert sv2;
        svList.add(sv2);
        
     
        
        Ex_SiteVisitTriggerHandler.updateCPOnOppo(svList);
        
        o2.Lead_Source__c = 'Channel Partner';
        o2.Channel_Partner__c = testAccount1.id;
        o2.CP_Project__c = cp1.id;
        update o2; 
        Ex_SiteVisitHandlerServices.rollupOnOpportunity(sv1);
        Ex_SiteVisitHandlerServices.appCPProjectOnSV(svList);
        
        
        teamSet.add(tm.Id);
        teamSet.add(tm1.Id);
        teamSet.add(tm3.Id);
        
        
      Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(teamSet);///rollupOnOpportunity
        
        
        Test.stopTest();
    }
    
    // Test method to cover the handler logic
    static testMethod void testHandlerLogic() {
        // Create test data
        Team__c testTeam = new Team__c(Name = 'Test Team');
        insert testTeam;
        
        Team_Member__c testMember = new Team_Member__c(Name = 'Test Member', Team__c = testTeam.Id);
        insert testMember;
        
        // Modify the test data (simulate before update operation)
        testMember.Name = 'Updated Test Member';
        update testMember;
        
        // Call the handler method (assuming you have a method to handle the trigger logic)
        Ex_TeamMemberTriggerHandler.beforeupdate();
        
        
        
        
    }
}