@isTest
public class TestEx_DemandRaiseBatch {
    @testSetup
    static void setupTestData() {
        // Create Project
        Project__c project = new Project__c(
            Name = 'Test Project',
            Last_Demand_No__c = '10',
            Starting_Demand_No__c = '1'
        );
        insert project;

        // Create Tower
        Tower__c tower = new Tower__c(
            Name = 'Test Tower',
            Project__c = project.Id
        );
        insert tower;

        // Create Unit
        Unit__c unit = new Unit__c(
            Name = 'Unit 101',
            Tower__c = tower.Id,
            Project__c = project.Id,
            Sales_Status__c = 'Booked'
        );
        insert unit;

        // Create Booking
        Booking__c booking = new Booking__c(
           
            Project__c = project.Id,
            Unit__c = unit.Id,
            Booking_Stage__c = 'Booking Confirmed',
            Primary_Applicant_Title__c = 'Mr.',
            Primary_Applicant_Name__c = 'John Doe',
            Primary_Applicant_Mobile__c = '1234567890',
            Primary_Applicant_Email__c = 'john.doe@example.com'
        );
        insert booking;

        // Create Quotation
        Quotation__c quotation = new Quotation__c(
        
            Booking__c = booking.Id,
            Quotation_Status__c = 'Approved',
            Unit__c = unit.Id
        );
        insert quotation;

        // Create Payment Milestone
        Payment_Milestone__c paymentMilestone = new Payment_Milestone__c(
           
            Quotation__c = quotation.Id,
            Milestone_Type__c = 'Date Linked',
            Due_Date__c = System.today(),
            Is_Due__c = true,
            Is_Raised__c = false,
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Amount__c = 100000,
            Charge_Bucket_1_Total_Tax__c = 5000
        );
        insert paymentMilestone;

        // Create Construction Stage
        Construction_Stage__c constructionStage = new Construction_Stage__c(
            Name = 'Slab Completion',
            Tower__c = tower.Id,
            Is_Completed__c = true
        );
        insert constructionStage;
    }

    @isTest
    public static void testBatchExecution() {
        // Query Payment Milestones for testing
        List<Payment_Milestone__c> pmList = [
            SELECT Id FROM Payment_Milestone__c WHERE Is_Raised__c = false
        ];
      //  System.assert(pmList.size() > 0, 'Test data should include Payment Milestones.');

        // Instantiate the batch
        Ex_DemandRaiseBatch batch = new Ex_DemandRaiseBatch();

        Test.startTest();
        // Execute the batch
        Database.executeBatch(batch, 1);
        Test.stopTest();

           }

    @isTest
    public static void testSchedulableExecution() {
        // Instantiate the schedulable class
        Ex_DemandRaiseBatch schedulableBatch = new Ex_DemandRaiseBatch();

        Test.startTest();
        // Execute the schedulable logic
        String cronExpression = '0 0 12 * * ?';
        System.schedule('Test Demand Raise Batch', cronExpression, schedulableBatch);
        Test.stopTest();


    }
}