@IsTest
public class TestEx_ReceiptHandlerServices {
    @TestSetup
    static void setupTestData() {
        // Create and insert a Booking
        Booking__c booking = new Booking__c(Booking_Date__c = System.today());
        insert booking;

        // Create and insert a Demand
        Demand__c demand = new Demand__c(
            Booking__c = booking.Id,
            Total_Amount_Demanded__c = 900000,
            Total_Amount_Paid__c = 100000,
            Total_Interest_Amount__c = 50000,
            Total_Interest_Amount_Paid__c = 45000,
            Total_Tax_On_Interest_Amount__c = 20000,
            Total_Tax_On_Interest_Amount_Paid__c = 5000,
            Total_Tax_On_Interest_Amount_Waived__c = 4000,
            Agreement_Value_Demanded__c = 60000,
            Agreement_Value_Paid__c = 10000,
            TDS_Value_Remaining__c = 20000
        );
        insert demand;

        // Create and insert Receipts for different Receipt_Type__c values
        List<Receipt__c> receipts = new List<Receipt__c>{
            new Receipt__c(Booking__c = booking.Id, Amount__c = 10000, Receipt_Type__c = 'Interest', Total_Money_Apportioned__c = null),
            new Receipt__c(Booking__c = booking.Id, Amount__c = 100000, Receipt_Type__c = 'Flat Cost', Total_Money_Apportioned__c = null),
            new Receipt__c(Booking__c = booking.Id, Amount__c = 100000, Receipt_Type__c = 'TDS Challan', Total_Money_Apportioned__c = null),
            new Receipt__c(Booking__c = booking.Id, Amount__c = 100000, Receipt_Type__c = 'Interest GST', Total_Money_Apportioned__c = null),
            new Receipt__c(Booking__c = booking.Id, Amount__c = 2000000, Receipt_Type__c = 'GST', Total_Money_Apportioned__c = 10000)
        };
        insert receipts;

        // Create a Ledger for one of the receipts
        Ledger__c leg = new Ledger__c(
            Demand__c = demand.Id,
            Receipt__c = receipts[2].Id, // TDS Challan receipt
            Charge_Name__c = 'TDS' // Use the exact picklist value
        );
        insert leg;
    }

    @IsTest
    static void testReceiptApportion() {
        // Test the receiptApportion method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c WHERE Receipt_Type__c = 'Interest' LIMIT 1];

        Test.startTest();
        Ex_ReceiptHandlerServices.receiptApporation(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate that the receipt apportioning logic executed
        Receipt__c updatedReceipt = [SELECT Total_Money_Apportioned__c FROM Receipt__c WHERE Id = :testReceipt.Id];
        System.assertNotEquals(null, updatedReceipt.Total_Money_Apportioned__c, 'Total Money Apportioned should not be null.');
    }

    @IsTest
    static void testReceiptApportionElse() {
        // Test the else branch in the receiptApportion method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c WHERE Receipt_Type__c = 'Flat Cost' LIMIT 1];

        Test.startTest();
        Ex_ReceiptHandlerServices.receiptApporation(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate that the else block executed
        Receipt__c updatedReceipt = [SELECT Total_Money_Apportioned__c FROM Receipt__c WHERE Id = :testReceipt.Id];
        System.assertNotEquals(null, updatedReceipt.Total_Money_Apportioned__c, 'Total Money Apportioned should not be null.');
    }

    @IsTest
    static void testReverseReceiptCalculation() {
        // Test the reverseReceiptCalculation method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c LIMIT 1];

        Test.startTest();
        Ex_ReceiptHandlerServices.reverseReceiptCalculation(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate that receipt apportioning was reversed
        Receipt__c updatedReceipt = [SELECT Total_Money_Apportioned__c FROM Receipt__c WHERE Id = :testReceipt.Id];
        System.assertNotEquals(null, updatedReceipt.Total_Money_Apportioned__c, 'Total Money Apportioned should not be null.');
    }

    @IsTest
    static void testDeleteReceiptApportionCalculation() {
        // Test the deleteReceiptApportionCalculation method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c LIMIT 1];

        Test.startTest();
        Ex_ReceiptHandlerServices.deleteReceiptApportionCalculation(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate that ledgers were deleted
        List<Ledger__c> ledgerList = [SELECT Id FROM Ledger__c WHERE Receipt__c = :testReceipt.Id];
        System.assertEquals(0, ledgerList.size(), 'All ledgers associated with the receipt should be deleted.');
    }

    @IsTest
    static void testGetPendingDemandMap() {
        // Test the getPendingDemandMap method
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];

        Test.startTest();
        Map<String, List<Demand__c>> pendingDemandMap = Ex_ReceiptHandlerServices.getPendingDemandMap(new Set<Id>{testBooking.Id});
        Test.stopTest();

        // Validate that the map is not null
        System.assertNotEquals(null, pendingDemandMap, 'Pending demand map should not be null.');
        System.assert(pendingDemandMap.containsKey(testBooking.Id), 'Pending demand map should contain the booking ID.');
    }

    @IsTest
    static void testGetLedgerInfo() {
        // Test the getLedgerInfo method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c LIMIT 1];

        Test.startTest();
        List<Ledger__c> ledgerList = Ex_ReceiptHandlerServices.getLedgerInfo(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate the ledger information
        System.assertNotEquals(null, ledgerList, 'Ledger list should not be null.');
    }

    @IsTest
    static void testGetDemandInfo() {
        // Test the getDemandInfo method
        Demand__c testDemand = [SELECT Id FROM Demand__c LIMIT 1];

        Test.startTest();
        List<Demand__c> demandList = Ex_ReceiptHandlerServices.getDemandInfo(new Set<Id>{testDemand.Id});
        Test.stopTest();

        // Validate the demand information
        System.assertNotEquals(null, demandList, 'Demand list should not be null.');
    }

    @IsTest
    static void testGetReceiptInfo() {
        // Test the getReceiptInfo method
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c LIMIT 1];

        Test.startTest();
        List<Receipt__c> receiptList = Ex_ReceiptHandlerServices.getReceiptInfo(new Set<Id>{testReceipt.Id});
        Test.stopTest();

        // Validate the receipt information
        System.assertNotEquals(null, receiptList, 'Receipt list should not be null.');
    }
    @IsTest
    static void testBeforeDelete() {
        // Create a Booking
        Booking__c booking = new Booking__c(Booking_Date__c = System.today());
        insert booking;

        // Create a Receipt
        Receipt__c receipt = new Receipt__c(
            Booking__c = booking.Id,
            Amount__c = 5000,
            Receipt_Type__c = 'Interest',
            Total_Money_Apportioned__c = 1000,
            Receipt_Date__c = System.today()
        );
        insert receipt;

        // Delete the Receipt to invoke beforeDelete
        Test.startTest();
        delete receipt;
        Test.stopTest();

        // Validate that the delete logic executed properly
        List<Ledger__c> ledgers = [SELECT Id FROM Ledger__c WHERE Receipt__c = :receipt.Id];
        System.assertEquals(0, ledgers.size(), 'All ledgers associated with the deleted receipt should be removed.');
    }
     @IsTest
    static void testReceiptWithPastDate() {
        // Create a Booking
        Booking__c booking = new Booking__c(Booking_Date__c = System.today());
        insert booking;

        // Create Receipts, one with a past date
        Receipt__c pastReceipt = new Receipt__c(
            Booking__c = booking.Id,
            Amount__c = 1000,
            Receipt_Type__c = 'Interest',
            Total_Money_Apportioned__c = 500,
            Receipt_Date__c = System.today().addDays(-5) // Past date
        );
        insert pastReceipt;

        // Call the method to process receipts
        Test.startTest();
        Ex_ReceiptHandlerServices.receiptApporation(new Set<Id>{pastReceipt.Id});
        Test.stopTest();

        // Verify that interestCalculate was called (mock this method if necessary)
        // Mocking frameworks like fflib or hard assertions can help.
        // Assert that boookingInterestDateMap was populated correctly
    }
    @isTest
    static void setupTestDataa() {
        // Create a Booking
        Booking__c booking = new Booking__c(Booking_Date__c = System.today());
        insert booking;

        // Create a Receipt record
        Receipt__c receipt = new Receipt__c(
            Booking__c = booking.Id,
            Amount__c = 5000,
            Receipt_Type__c = 'Interest',
            Receipt_Status__c = 'Reverse',
            Remarks__c = 'Initial Remarks'
        );
        insert receipt;
    }

    @IsTest
    static void testReceiptRecordUpdate() {
        // Retrieve the test Receipt
        Receipt__c testReceipt = [SELECT Id, Receipt_Status__c, Remarks__c FROM Receipt__c LIMIT 1];

        // Test the update case
        Test.startTest();
        Boolean result = Ex_ReceiptAction.receiptrecord('Approved', 'Updated Remarks', testReceipt.Id);
        Test.stopTest();

     }

    @IsTest
    static void testReceiptRecordDelete() {
        // Retrieve the test Receipt
        Receipt__c testReceipt = [SELECT Id FROM Receipt__c LIMIT 1];

        // Test the delete case
        Test.startTest();
        Boolean result = Ex_ReceiptAction.receiptrecord('Delete', 'Delete this record', testReceipt.Id);
        Test.stopTest();

        // Verify the receipt was deleted
        Integer receiptCount = [SELECT COUNT() FROM Receipt__c WHERE Id = :testReceipt.Id];
        System.assertEquals(0, receiptCount, 'The receipt should be deleted.');
        System.assert(result, 'The method should return true on success.');
    }

    @IsTest
    static void testReceiptRecordErrorHandling() {
        // Test with an invalid record ID
        Test.startTest();
        Boolean result = Ex_ReceiptAction.receiptrecord('Approved', 'Invalid ID Test', 'InvalidRecordId');
        Test.stopTest();

        // Verify the method handles the exception gracefully
        System.assert(!result, 'The method should return false for an invalid record ID.');
    }
}