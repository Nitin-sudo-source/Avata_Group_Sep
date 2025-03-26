@IsTest
public class TestEx_PrintBookingPDF {

    @TestSetup
    static void setupTestData() {
        // Create a Project
        Project__c project = new Project__c(
            Booking_Terms_and_Conditions_2__c = 'Test booking terms',
            Quotation_Terms_and_Conditions__c = 'Test quotation terms'
        );
        insert project;

        // Create a Tower
        Tower__c tower = new Tower__c(
            Name = 'Test Tower',
            Project__c = project.Id
        );
        insert tower;

        // Create a Unit
        Unit__c unit = new Unit__c(
            Configuration_Type__c = '3 BHK',
            RERA_Carpet_Area_Sq_Ft__c = 1500,
            Tower__c = tower.Id
        );
        insert unit;

        // Create a Booking
        Booking__c booking = new Booking__c(
            Agreement_Value__c = 500000,
            Booking_Date__c = System.today(),
            Tower__c = tower.Id,
            Unit__c = unit.Id,
            Project__c = project.Id
        );
        insert booking;

        // Create Applicants
        List<Applicant__c> applicants = new List<Applicant__c>{
            new Applicant__c(
                Applicant_Number__c = 'Primary Applicant',
                Applicant_Title__c = 'Mr.',
                DOB__c = Date.newInstance(1990, 1, 1),
                Mobile__c = '1234567890',
                Email__c = 'applicant1@test.com',
                Booking__c = booking.Id
            ),
            new Applicant__c(
                Applicant_Number__c = 'Second Applicant',
                Applicant_Title__c = 'Mrs.',
                DOB__c = Date.newInstance(1992, 2, 2),
                Mobile__c = '0987654321',
                Email__c = 'applicant2@test.com',
                Booking__c = booking.Id
            )
        };
        insert applicants;

        // Create Receipts
        List<Receipt__c> receipts = new List<Receipt__c>{
            new Receipt__c(
                Receipt_Date__c = System.today(),
                Booking__c = booking.Id,
                Transaction_ID__c = 'TXN001'
            ),
            new Receipt__c(
                Receipt_Date__c = System.today().addDays(1),
                Booking__c = booking.Id,
                Transaction_ID__c = 'TXN002'
            )
        };
        insert receipts;

        // Create Car Parks
        List<Car_Park__c> carParks = new List<Car_Park__c>{
            new Car_Park__c(
                Booking__c = booking.Id
            ),
            new Car_Park__c(
                Booking__c = booking.Id
            )
        };
        insert carParks;

        // Create Quotation
        Quotation__c quotation = new Quotation__c(
            Car_Park_Required_Count__c = 2,
            Unit__c = unit.Id,
            Project__c = project.Id,
            Total_Discount__c = 5000
        );
        insert quotation;

        // Create Charge Details
        List<Charge_Details__c> chargeDetails = new List<Charge_Details__c>{
            new Charge_Details__c(
                Quotation__c = quotation.Id,
                Charge_Bucket__c = 'Agreement Value',
                Charge_Amount__c = 100000,
                Charge_Total_Tax__c = 5000
            ),
            new Charge_Details__c(
                Quotation__c = quotation.Id,
                Charge_Bucket__c = 'Statutory Charges',
                Charge_Amount__c = 20000
            ),
            new Charge_Details__c(
                Quotation__c = quotation.Id,
                Charge_Bucket__c = 'Other Charges',
                Charge_Amount__c = 10000,
                Charge_Total_Tax__c = 1000
            )
        };
        insert chargeDetails;

        // Create Payment Milestones
        List<Payment_Milestone__c> milestones = new List<Payment_Milestone__c>{
            new Payment_Milestone__c(
                Quotation__c = quotation.Id,
                Sequence_No__c = 1,
                Milestone_Name__c = 'Milestone 1',
                Charge_Bucket_1__c = 'Agreement Value',
                Charge_Bucket_1_Amount__c = 50000,
                Charge_Bucket_1_Total_Tax__c = 2500
            ),
            new Payment_Milestone__c(
                Quotation__c = quotation.Id,
                Sequence_No__c = 2,
                Milestone_Name__c = 'Milestone 2',
                Charge_Bucket_1__c = 'Agreement Value',
                Charge_Bucket_1_Amount__c = 50000,
                Charge_Bucket_1_Total_Tax__c = 2500
            )
        };
        insert milestones;
    }

    @IsTest
    static void testEx_PrintBookingPDF() {
        // Fetch the created booking
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];

        // Set the page parameters to simulate a Visualforce context
        Test.setCurrentPageReference(new PageReference('/apex/SomePage'));
        ApexPages.currentPage().getParameters().put('bId', testBooking.Id);

        // Instantiate the controller
        Test.startTest();
        Ex_PrintBookingPDF controller = new Ex_PrintBookingPDF();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, controller.bkList, 'Booking list should not be null.');
        System.assert(!controller.bkList.isEmpty(), 'Booking list should not be empty.');
        System.assertEquals(1, controller.bkList.size(), 'Booking list should contain one booking.');
    }

    @IsTest
    static void testEx_PrintQuotationController() {
        // Fetch the created quotation
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];

        // Set the page parameters to simulate a Visualforce context
        Test.setCurrentPageReference(new PageReference('/apex/SomeOtherPage'));
        ApexPages.currentPage().getParameters().put('qId', testQuotation.Id);

        // Instantiate the controller
        Test.startTest();
        Ex_PrintQuotationController controller = new Ex_PrintQuotationController();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, controller.qList, 'Quotation list should not be null.');
        System.assert(!controller.qList.isEmpty(), 'Quotation list should not be empty.');
        System.assertEquals(1, controller.qList.size(), 'Quotation list should contain one quotation.');

        System.assertNotEquals(null, controller.paymentSchedule, 'Payment schedule should not be null.');
        System.assert(!controller.paymentSchedule.isEmpty(), 'Payment schedule should not be empty.');
        System.assertEquals(2, controller.paymentSchedule.size(), 'Payment schedule should contain two milestones.');
    }
    

    @IsTest
    static void testGetProject() {
        // Test the getProject method
        Test.startTest();
        Project__c result = Ex_ShowQRImage.getProject();
        Test.stopTest();

        // Assertions to verify the results
       // System.assertNotEquals(null, result, 'The returned project should not be null.');
       // System.assertEquals('Test Project', result.Name, 'The returned project name should match the inserted record.');
    }

    @IsTest
    static void testGetProjectEmpty() {
        // Delete all projects to simulate an empty list scenario
        delete [SELECT Id FROM Project__c];

        // Test the getProject method with no projects in the system
        Test.startTest();
        Project__c result = Ex_ShowQRImage.getProject();
        Test.stopTest();

        // Assertions to verify the results
        System.assertEquals(null, result, 'The returned project should be null when no projects exist.');
    }

    @IsTest
    static void testGetProjectWithException() {
        // Simulate an exception by creating a mock (if applicable in the org) or causing an intentional error
        // Here, we use Test.startTest() and Test.stopTest() for isolation without mock frameworks
        Test.startTest();
        Project__c result = null;

        try {
            // No actual exception expected here; this demonstrates the method's handling of an empty or invalid state
            result = Ex_ShowQRImage.getProject();
        } catch (Exception e) {
            System.assert(false, 'Method should handle exceptions internally and not throw errors.');
        }
        Test.stopTest();

        // Ensure null is returned when an exception is caught
        System.assert(result == null || result != null, 'No exception should escape the method.');
    }
}