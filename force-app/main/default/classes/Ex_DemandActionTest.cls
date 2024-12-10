@isTest
public class Ex_DemandActionTest {

    @isTest
    static void testDemandRecordUpdate() {
        
        Booking__c b=new Booking__c();
        b.Primary_Applicant_Mobile__c='9011722426';
        insert b;
        
        // Create a Demand__c record for testing without setting the Name field
        Demand__c demand = new Demand__c(
            Demand_Status__c = 'Raised',
            Remarks__c = 'Initial remarks',
            Booking__c=b.id
        );
        insert demand;
        String did=demand.id;
        Test.startTest();
        // Test the method with status update (not 'Delete')
        boolean result = Ex_DemandAction.demandrecord('Raised', 'Updated remarks',did);
        Test.stopTest();

        // Assertions
        // Fetch the updated Demand record
        Demand__c updatedDemand = [SELECT Demand_Status__c, Remarks__c FROM Demand__c WHERE Id = :demand.Id];
        
      
    }

    @isTest
    static void testDemandRecordDelete() {
        // Create a Demand__c record for testing without setting the Name field
        
        Booking__c b=new Booking__c();
        b.Primary_Applicant_Mobile__c='9011722426';
        insert b;
        
        Demand__c demand = new Demand__c(
            Demand_Status__c = 'Raised',
            Remarks__c = 'Initial remarks before deletion',
            Booking__c=b.id
        );
        insert demand;

        String did=demand.id;
        Test.startTest();
        // Test the method with 'Delete' status
        boolean result = Ex_DemandAction.demandrecord('Delete', 'Remarks for deletion',did);
        Test.stopTest();

         }

    @isTest
    static void testDemandRecordErrorHandling() {
        // Test invalid recordId to trigger an exception
        Test.startTest();
        boolean result = Ex_DemandAction.demandrecord('Approved', 'Invalid Remarks', 'invalidId');
        Test.stopTest();

      
    }
}