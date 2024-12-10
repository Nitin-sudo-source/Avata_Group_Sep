@IsTest
public class Ex_BookingFormControllerTest {
    
    // Test data setup method
    @TestSetup
    static void setupTestData() {
        // Create a test Opportunity
        Opportunity__c testOpportunity = new Opportunity__c(Name = 'Test Opportunity', Stage__c = 'In Follow-up', Close_Date__c = Date.today().addDays(30));
        insert testOpportunity;

        // Create a test Quotation without setting the Name field
        Quotation__c testQuotation = new Quotation__c(Opportunity__c = testOpportunity.Id);
        insert testQuotation;

        // Create test Legal Entity
        Legal_Entity__c testLegalEntity = new Legal_Entity__c(Name = 'Test Legal Entity');
        insert testLegalEntity;

        // Create a test Applicant_Document
        Applicant_Document__c testDocument = new Applicant_Document__c(
            Name = 'Test Document',
            Document_Upload_Required__c = 'Yes',
            Nationality__c = 'Indian'
        );
        insert testDocument;
    }

    @IsTest
    static void testGetQuotationDetails() {
        // Retrieve the test Quotation Id
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];

        // Call the method
        Quotation__c result = Ex_BookingFormController.getQuotationDetails(testQuotation.Id);

        // Assertions
        System.assertNotEquals(null, result, 'Expected Quotation to be returned');
        System.assertEquals(testQuotation.Id, result.Id, 'Quotation ID should match');
    }

    @IsTest
    static void testGetLegalEntityDetails() {
        // Retrieve the test Quotation Id
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];

        // Call the method
        List<Legal_Entity__c> result = Ex_BookingFormController.getLegalEntityDetails(testQuotation.Id);

        // Assertions
        System.assertNotEquals(null, result, 'Expected Legal Entity list to be returned');
        System.assertEquals(1, result.size(), 'Expected one Legal Entity');
    }

    @IsTest
    static void testGetBookingWrapper() {
        // Retrieve the test Opportunity Id
        Opportunity__c testOpportunity = [SELECT Id FROM Opportunity__c LIMIT 1];

        // Call the method
        Ex_BookingFormController.BookWrapper wrapper = Ex_BookingFormController.getBookingWrapper(testOpportunity.Id);

        // Assertions
        System.assertNotEquals(null, wrapper, 'Expected BookWrapper to be returned');
        System.assertEquals(Date.today(), wrapper.bk.Booking_Date__c, 'Booking date should be today');
    }

    @IsTest
    static void testGetReceipts() {
        // Call the method
        List<Ex_BookingFormController.ReceiptWrapper> receipts = Ex_BookingFormController.getReceipts();

        // Assertions
        System.assertNotEquals(null, receipts, 'Expected Receipt list to be returned');
        System.assertEquals(1, receipts.size(), 'Expected one Receipt');
    }

    @IsTest
    static void testApplicantDocumentDetails() {
        // Retrieve the test Opportunity Id
        Opportunity__c testOpportunity = [SELECT Id FROM Opportunity__c LIMIT 1];

        // Call the method
        List<Ex_BookingFormController.ApplicantWrapper> applicants = Ex_BookingFormController.ApplicantdocumentDetails(
            'Yes', 'Indian', testOpportunity.Id, 'Applicant 1'
        );

       
    }

    @IsTest
    static void testCreateBookingRecord() {
        // Retrieve the test Quotation Id
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];

        // Create a wrapper
        Ex_BookingFormController.BookWrapper wrapper = new Ex_BookingFormController.BookWrapper();
        wrapper.bk.Booking_Date__c = Date.today();

       
    }

    @IsTest
    static void testGetChargeListInfo() {
        // Retrieve the test Quotation Id
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];

        // Call the method
        List<Charge_Details__c> charges = Ex_BookingFormController.getChargeListInfo(testQuotation.Id);

        // Assertions
       // System.assertNotEquals(null, charges, 'Expected Charge Details to be returned');
    }
}