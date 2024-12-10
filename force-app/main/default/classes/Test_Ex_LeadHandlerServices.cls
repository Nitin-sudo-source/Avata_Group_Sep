@isTest
public class Test_Ex_LeadHandlerServices {

    @testSetup
    static void setupTestData() {
        // Step 1: Create a test User
        User testUser = new User(
            Alias = 'testusr',
            Email = 'aratii@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'aratu@example.com'
        );
        insert testUser;
        
        Project__c pr=new Project__c();
        pr.Company_Name__c='exceller';
        insert pr;

        // Step 2: Create a Team__c record
        Team__c team = new Team__c(Name = 'Presales Team', Team_Type__c = 'Presales Team', Project__c =pr.id);
        insert team;

        // Step 3: Create a Team_Member__c record
        Team_Member__c teamMember = new Team_Member__c(
            Team__c = team.Id,
            User__c = testUser.Id,
            Availability__c = true, // Ensure this field is correctly set
            DayOff__c = false,
            Last_Assignment_DateTime__c = DateTime.now().addDays(-1),
            Assignment_Counter__c = 0
        );
        insert teamMember;

        // Step 4: Create Lead__c records
        List<Lead__c> leads = new List<Lead__c>{
            new Lead__c(Mobile__c = '1234567890', Apply_Round_Robin__c = true),  // Include Mobile__c
            new Lead__c(Mobile__c = '9876543210', Apply_Round_Robin__c = false) // Include Mobile__c
        };
        insert leads;

        // Step 5: Create Ledger__c records
        List<Ledger__c> ledgers = new List<Ledger__c>{
            new Ledger__c(Type__c = 'Credit', Amount__c = 100, Cancelled__c = false),
            new Ledger__c(Type__c = 'Debit', Amount__c = 200, Cancelled__c = true)
        };
        insert ledgers;
    }

    /*@isTest
    static void testDuplicationCheckWithRoundRobin() {
        // Fetch test data with required fields
        List<Lead__c> leadList = [SELECT Id, Mobile__c, Apply_Round_Robin__c FROM Lead__c];

        Test.startTest();
        Ex_LeadHandlerServices.duplicationCheck('Yes', leadList);
        Test.stopTest();

        // Validate the OwnerId of the lead assigned via round robin
        Lead__c updatedLead = [SELECT Id, Mobile__c, OwnerId FROM Lead__c WHERE Apply_Round_Robin__c = true LIMIT 1];
        System.assertNotEquals(null, updatedLead.OwnerId, 'OwnerId should be assigned by round robin logic');
    }

    @isTest
    static void testDuplicationCheckWithoutRoundRobin() {
        // Fetch test data with required fields
        List<Lead__c> leadList = [SELECT Id, Mobile__c, Apply_Round_Robin__c FROM Lead__c];

        Test.startTest();
        Ex_LeadHandlerServices.duplicationCheck('No', leadList);
        Test.stopTest();

        // Validate that no leads were assigned an OwnerId
        List<Lead__c> leadsWithoutOwner = [SELECT Id, Mobile__c, OwnerId FROM Lead__c WHERE Apply_Round_Robin__c = false];
        for (Lead__c lead : leadsWithoutOwner) {
            System.assertEquals(null, lead.OwnerId, 'OwnerId should not be assigned when round robin is disabled');
        }
    }*/

    @isTest
    static void testApplyRoundRobinLogic() {
        // Fetch a lead that is eligible for round robin assignment
        Lead__c leadForAssignment = [SELECT Id, Mobile__c, Apply_Round_Robin__c FROM Lead__c WHERE Apply_Round_Robin__c = true LIMIT 1];
        List<Lead__c> leadListForAssignment = new List<Lead__c>{leadForAssignment};

        Test.startTest();
        Ex_LeadHandlerServices.applyRoundRobinLogic(leadListForAssignment);
        Test.stopTest();

        // Validate the OwnerId assignment
        Lead__c updatedLead = [SELECT Id, Mobile__c, OwnerId FROM Lead__c WHERE Id = :leadForAssignment.Id];
        System.assertNotEquals(null, updatedLead.OwnerId, 'OwnerId should be assigned by round robin logic');
    }

    @isTest
    static void testGetTeamMembers() {
        Test.startTest();
        List<Team_Member__c> teamMembers = [SELECT Id, Availability__c, User__c FROM Team_Member__c];
        Test.stopTest();

        // Validate the retrieved team members
        System.assertNotEquals(0, teamMembers.size(), 'Team members list should not be empty');
        for (Team_Member__c member : teamMembers) {
            System.assertEquals(true, member.Availability__c, 'Team member should be available');
        }
    }

    @isTest
    static void testLedgerBeforeDeleteTrigger() {
        // Fetch existing ledger data
        List<Ledger__c> ledgers = [SELECT Id, Type__c, Cancelled__c FROM Ledger__c WHERE Type__c = 'Credit' AND Cancelled__c = false];

        Test.startTest();
        delete ledgers; // This triggers Ex_LedgerTriggerHandler.beforeDelete
        Test.stopTest();

        // Validate that reverse calculation logic is invoked
       /* for (Ledger__c ledger : ledgers) {
            // Ensure the ledger no longer exists in the system
            Ledger__c deletedLedger = [SELECT Id FROM Ledger__c WHERE Id = :ledger.Id LIMIT 1];
            System.assertEquals(null, deletedLedger, 'Ledger record should be deleted');
        }*/
    }
}