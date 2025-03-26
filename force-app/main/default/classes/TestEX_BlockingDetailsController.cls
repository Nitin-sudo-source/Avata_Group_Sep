@isTest
public class TestEX_BlockingDetailsController {

    @testSetup
    static void setupTestData() {
        // Create a Project
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;

        // Create a Tower
        Tower__c tower = new Tower__c(Name = 'Test Tower', Project__c = project.Id);
        insert tower;

        // Create a Unit
        Unit__c unit = new Unit__c(Name = 'Test Unit', Tower__c = tower.Id, Project__c = project.Id, Sales_Status__c = 'Vacant');
        insert unit;

        // Create an Opportunity
        Opportunity__c opportunity = new Opportunity__c(Name = 'Test Opportunity');
        insert opportunity;

        // Create a Blocking Detail
        Blocking_Details__c blockingDetail = new Blocking_Details__c(
            Unit__c = unit.Id,
            Status__c = 'Blocked',
            Blocked_with_token__c = true,
            Amount__c = 1000,
            Transaction_ID__c = 'TXN123',
            Blocking_Comments__c = 'Initial Blocking'
        );
        insert blockingDetail;
    }

    @isTest
    static void testGetBlockDetails() {
        // Retrieve a Unit for testing
        Unit__c testUnit = [SELECT Id FROM Unit__c LIMIT 1];

        Test.startTest();
        Blocking_Details__c result = EX_BlockingDetailsController.getBlockDetails(testUnit.Id);
        Test.stopTest();

        }

    @isTest
    static void testFetchUnits() {
        // Retrieve a Unit for testing
        Unit__c testUnit = [SELECT Id FROM Unit__c LIMIT 1];

        Test.startTest();
        List<Unit__c> result = EX_BlockingDetailsController.fetchUnits(testUnit.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected at least one unit to be retrieved.');
        System.assertEquals(testUnit.Id, result[0].Id, 'The retrieved unit should match the test unit.');
    }

    @isTest
    static void testGetOppName() {
        // Retrieve an Opportunity for testing
        Opportunity__c testOpportunity = [SELECT Id FROM Opportunity__c LIMIT 1];

        Test.startTest();
        List<Opportunity__c> result = EX_BlockingDetailsController.getOppName(testOpportunity.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected at least one opportunity to be retrieved.');
        System.assertEquals(testOpportunity.Id, result[0].Id, 'The retrieved opportunity should match the test opportunity.');
    }

    @isTest
    static void testGetModeOfFundingPicklist() {
        Test.startTest();
        Map<String, List<String>> result = EX_BlockingDetailsController.getModeOfFundingPicklist();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected picklist values to be retrieved.');
        System.assert(result.containsKey('Mode_of_Payment__c'), 'Expected Mode_of_Payment__c key in the picklist map.');
    }

    @isTest
    static void testCreateBlockingRecord() {
        // Retrieve test Unit and Opportunity
        Unit__c testUnit = [SELECT Id FROM Unit__c LIMIT 1];
        Opportunity__c testOpportunity = [SELECT Id FROM Opportunity__c LIMIT 1];

        Test.startTest();
        Blocking_Details__c result = EX_BlockingDetailsController.createBlockingRecord(
            true, 2000, 'New Blocking Comment', 'CHK123', testUnit.Id, testOpportunity.Id, 'Cheque'
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected Blocking_Details__c to be created.');
        System.assertEquals('Blocked', result.Status__c, 'Expected Blocking_Details__c to have status Blocked.');

        Unit__c updatedUnit = [SELECT Sales_Status__c FROM Unit__c WHERE Id = :testUnit.Id];
        System.assertEquals('Blocked', updatedUnit.Sales_Status__c, 'Expected Unit__c to have status Blocked.');
    }

    @isTest
    static void testUnblockLogic() {
        // Retrieve test Blocking_Details__c
        Blocking_Details__c testBlock = [SELECT Id, Unit__c FROM Blocking_Details__c WHERE Status__c = 'Blocked' LIMIT 1];

        Test.startTest();
        Blocking_Details__c result = EX_BlockingDetailsController.unblockLogic(testBlock.Id, 'Unblocking Comment');
        Test.stopTest();

        System.assertEquals('Released', result.Status__c, 'Expected Blocking_Details__c to have status Released.');

        Unit__c updatedUnit = [SELECT Sales_Status__c FROM Unit__c WHERE Id = :testBlock.Unit__c];
        System.assertEquals('Vacant', updatedUnit.Sales_Status__c, 'Expected Unit__c to have status Vacant.');
    }
}