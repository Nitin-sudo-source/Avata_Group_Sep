@isTest
public class TestEx_DemandManagementServices {
    /*
    // Helper method to create test data for Payment_Milestone__c and related records
    private static Payment_Milestone__c createPaymentMilestone(String milestoneName, Date dueDate, Decimal amount, Decimal taxAmount) {
        // Create a test Booking record
        Booking__c booking = new Booking__c(Primary_Applicant_Name__c = 'John Doe', Primary_Applicant_Mobile__c = '1234567890', Primary_Applicant_Email__c = 'john.doe@example.com');
        insert booking;
        
        // Create a test Quotation record
        Quotation__c quotation = new Quotation__c(Booking__c = booking.Id);
        insert quotation;
        
        // Create a test Project record
        Project__c project = new Project__c();
        insert project;
        
        // Update the Booking and Project with necessary references
        booking.Project__c = project.Id;
        update booking;
        
        // Create the Payment_Milestone__c record with charge buckets
        Payment_Milestone__c pm = new Payment_Milestone__c(
            Due_Date__c = dueDate,
            Quotation__c = quotation.Id,
            Quotation__r = quotation,
            Milestone_Name__c = milestoneName,
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Amount__c = amount,
            Charge_Bucket_1_Total_Tax__c = taxAmount
        );
        insert pm;
        
        return pm;
    }
    
    @isTest
    static void testRaiseDemandValidInput() {
        // Create Payment_Milestone__c record for testing
        Payment_Milestone__c pm = createPaymentMilestone('Milestone 1', system.today(), 1000.00, 100.00);
        
        // Simulate the raise demand process
        Test.startTest();
        Ex_DemandManagementServices.raiseDemand(pm);
        Test.stopTest();
        
        // Verify Demand__c record creation
        List<Demand__c> demands = [SELECT Id, Demand_Type__c, Booking__c, Payment_Milestone__c, Milestone_Name__c, Invoice_Date__c FROM Demand__c];
        System.assertEquals(1, demands.size(), 'Demand record should be created.');
        System.assertEquals('Flat Cost', demands[0].Demand_Type__c, 'Demand type should be Flat Cost.');
        System.assertEquals(pm.Quotation__c, demands[0].Quotation__c, 'Quotation should be set.');
        
        // Verify that the Payment_Milestone__c was updated
        pm = [SELECT Is_Raised__c, Demand_Raised_Date__c FROM Payment_Milestone__c WHERE Id = :pm.Id];
        System.assert(pm.Is_Raised__c, 'Payment Milestone should be marked as raised.');
    }
    
    @isTest
    static void testRaiseDemandNullInput() {
        // Test with null Payment_Milestone__c
        Test.startTest();
        Ex_DemandManagementServices.raiseDemand(null);
        Test.stopTest();
        
        // No Demand should be created for null input
        List<Demand__c> demands = [SELECT Id FROM Demand__c];
        System.assertEquals(0, demands.size(), 'No Demand should be created when Payment_Milestone__c is null.');
    }
    
    @isTest
    static void testRaiseDemandInvoiceNumberLogic() {
        // Create test data
        Payment_Milestone__c pm = createPaymentMilestone('Milestone 1', system.today(), 1000.00, 100.00);
        
        // Set up a Project record with Last_Demand_No__c and Starting_Demand_No__c
        Project__c project = [SELECT Id, Last_Demand_No__c, Starting_Demand_No__c FROM Project__c WHERE Id = :pm.Quotation__r.Booking__r.Project__c LIMIT 1];
        project.Last_Demand_No__c = 'ab';
        update project;
        
        // Simulate the raise demand process
        Test.startTest();
        Ex_DemandManagementServices.raiseDemand(pm);
        Test.stopTest();
        
        // Verify that the invoice number is incremented correctly
        List<Demand__c> demands = [SELECT Invoice_Number__c FROM Demand__c];
        
        // Correct the invoice number logic to convert integer to string
        String expectedInvoiceNumber = 'Test Project-' + String.valueOf(project.Last_Demand_No__c + 1); // Convert the integer to a string
        System.assertEquals(expectedInvoiceNumber, demands[0].Invoice_Number__c, 'Invoice Number should be correctly generated.');
    }
    
    @isTest
    static void testOnAccountBalanceCalculation() {
        // Create necessary records for testing
        Booking__c booking = new Booking__c();
        insert booking;
        
        // Create a Receipt__c record with On_Account_Money__c
        // Commenting out this part if On_Account_Money__c is not writable
        // Receipt__c receipt = new Receipt__c(Booking__c = booking.Id, On_Account_Money__c = 500.00);
        // insert receipt;
        
        // Test getOnAccountBalance method
        Test.startTest();
        Decimal balance = Ex_DemandManagementServices.getOnAccountBalance(booking.Id);
        Test.stopTest();
        
        // Assert the balance calculation is correct
        System.assertEquals(500.00, balance, 'The on account balance should be calculated correctly.');
    }
    
    @isTest
    static void testOnAccountBalanceReceipts() {
        // Create necessary records for testing
        Booking__c booking = new Booking__c();
        insert booking;
        
        // Create Receipt__c records
        // Receipt__c receipt1 = new Receipt__c(Booking__c = booking.Id, On_Account_Money__c = 500.00);
        // Receipt__c receipt2 = new Receipt__c(Booking__c = booking.Id, On_Account_Money__c = 300.00);
        // insert new List<Receipt__c> { receipt1, receipt2 };
        
        // Test getOnAccountBalanceReceipts method
        Test.startTest();
        Set<Id> receiptIds = Ex_DemandManagementServices.getOnAccountBalanceReceipts(booking.Id);
        Test.stopTest();
        
        // Assert that the correct set of receipt IDs is returned
        System.assertEquals(2, receiptIds.size(), 'Two receipts should be returned.');
    }*/
}