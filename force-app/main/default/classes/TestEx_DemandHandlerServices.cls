@isTest 
public class TestEx_DemandHandlerServices {
    // Helper method to create mock data for testing
    private static void createTestData() {
        // Create Project records
        Project__c project1 = new Project__c(Name = 'Project 1');
        Project__c project2 = new Project__c(Name = 'Project 2');
        insert new List<Project__c>{ project1, project2 };

        // Create Booking records (needed for the Demand relation)
        Booking__c booking1 = new Booking__c(Project__c = project1.Id);
        Booking__c booking2 = new Booking__c(Project__c = project2.Id);
        insert new List<Booking__c>{ booking1, booking2 };

        // Create Demand records (Note: Removed Name assignment for Demand)
        Demand__c demand1 = new Demand__c(
            Invoice_Date__c = Date.today(), 
            Invoice_Number__c = 'D-001', 
            Agreement_Value_Demanded__c = 1000, 
            Agreement_Value_Tax_Demanded__c = 100, 
            Booking__c = booking1.Id // Booking reference to associate with Demand
        );
        Demand__c demand2 = new Demand__c(
            Invoice_Date__c = Date.today(), 
            Invoice_Number__c = 'D-002', 
            Agreement_Value_Demanded__c = 500, 
            Agreement_Value_Tax_Demanded__c = 50, 
            Booking__c = booking2.Id // Booking reference to associate with Demand
        );
        insert new List<Demand__c>{ demand1, demand2 };
            //Create Payment Scheme
       
              
    }

    @isTest
    static void testCreateDebitLedgerAndUpdateLastDemandNo() {
        createTestData();

        // Get test Demand Ids
        Set<Id> demandIds = new Set<Id>();
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        for (Demand__c d : demands) {
            demandIds.add(d.Id);
        }

        // Call the method to test
        Test.startTest();
        Ex_DemandHandlerServices.createDebitLedgerAndUpdateLastDemandNo(demandIds);
        Test.stopTest();

         }

    @isTest
    static void testReverseDemandCalculation() {
        createTestData();

        // Get test Demand Ids
        Set<Id> demandIds = new Set<Id>();
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        for (Demand__c d : demands) {
            demandIds.add(d.Id);
        }

        // Call the method to test
        Test.startTest();
        Ex_DemandHandlerServices.reverseDemandCalculation(demandIds);
        Test.stopTest();

         }

    @isTest
    static void testDeletedDemandCalculation() {
        createTestData();

        // Get test Demand Ids
        Set<Id> demandIds = new Set<Id>();
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        for (Demand__c d : demands) {
            demandIds.add(d.Id);
        }

        // Call the method to test
        Test.startTest();
        Ex_DemandHandlerServices.deletedDemandCalculation(demandIds);
        Test.stopTest();

          }

    @isTest
    static void testGetDemandInfo() {
        createTestData();

        // Get test Demand Ids
        Set<Id> demandIds = new Set<Id>();
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        for (Demand__c d : demands) {
            demandIds.add(d.Id);
        }
        
         Map<Id, Demand__c> oldMap = new Map<Id, Demand__c>();
        for (Demand__c demand : demands) {
            oldMap.put(demand.Id, demand);
        }
        Map<Id, Demand__c> newMap = new Map<Id, Demand__c>(); // Empty for before delete

    

        // Call the method to test
        Test.startTest();
        List<Demand__c> demandList = Ex_DemandHandlerServices.getDemandInfo(demandIds);
         Ex_DemandTriggerHandler.beforeDelete(oldMap, newMap);
        Test.stopTest();
  }

    @isTest
    static void testGetLedgerInfo() {
        createTestData();

        // Get test Demand Ids
        Set<Id> demandIds = new Set<Id>();
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        for (Demand__c d : demands) {
            demandIds.add(d.Id);
        }

        // Call the method to test for Debit Ledger
        Test.startTest();
        List<Ledger__c> debitLedgers = Ex_DemandHandlerServices.getLedgerInfo(demandIds, 'Debit');
        
     
       
        List<Ledger__c> creditLedgers = Ex_DemandHandlerServices.getLedgerInfo(demandIds, 'Credit');
        Test.stopTest();

        
    }
     
}