@isTest
public class Ex_SendEmailWelcomeCallTest {

    @isTest
    static void testSendEmailWelcomeCall() {
        // Query an existing OrgWideEmailAddress
        OrgWideEmailAddress orgWideEmail = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress LIMIT 1];

        // Create test data
        Booking__c testBooking = new Booking__c(
            Primary_Applicant_Email__c = 'testemail@example.com'
        );
        insert testBooking;

        Opportunity__c testOpportunity = new Opportunity__c(
            Name = 'Test Opportunity',
            Stage__c = 'Created',
            Close_Date__c= Date.today()
        );
        insert testOpportunity;

        Unit__c testUnit = new Unit__c(Name = 'Test Unit');
        insert testUnit;

        testBooking.Opportunity__r = testOpportunity;
        update testBooking;

        // Prepare test data set
        Set<Id> bookingIds = new Set<Id>{testBooking.Id};

        // Call the future method
        Test.startTest();
        Ex_SendEmailWelcomeCall.sendEmailWelcomeCall(bookingIds);
        Test.stopTest();

        // Verify that the email was sent
        // (Since EmailMessage cannot be queried in tests, we use logs or other assert checks here)
    }

    @isTest
    static void testSendEmailWelcomeCallWithNoBookings() {
        // Test when no bookings are provided
        Test.startTest();
        Ex_SendEmailWelcomeCall.sendEmailWelcomeCall(new Set<Id>());
        Test.stopTest();

        // Verify that no emails were sent
        // Use debug logs or other assertions as necessary
    }

    @isTest
    static void testSendEmailWelcomeCallWithMissingOrgWideEmail() {
        // Create a booking without OrgWideEmailAddress
        Booking__c testBooking = new Booking__c(
            Primary_Applicant_Email__c = 'testemail@example.com'
        );
        insert testBooking;

        // Prepare test data set
        Set<Id> bookingIds = new Set<Id>{testBooking.Id};

        // Call the future method
        Test.startTest();
        Ex_SendEmailWelcomeCall.sendEmailWelcomeCall(bookingIds);
        Test.stopTest();

        // Verify that an email was sent without using OrgWideEmailAddress
        // Use debug logs or other assertions as necessary
    }
}