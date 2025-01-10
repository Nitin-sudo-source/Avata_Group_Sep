@isTest
public class Ex_BookingHanldlerServicesTest {
    @isTest
    static void testBookingCancellationUpdate() {
        // Create test data for Booking__c
        Booking__c booking = new Booking__c(
            Primary_Applicant_Name__c = 'Test Applicant',
            Primary_Applicant_Email__c = 'test@example.com',
            Primary_Applicant_Mobile__c = '1234567890',
            Agreement_Value__c = 100000,
            GST__c = 18,
            Stamp_Duty__c = 5,
            Booking_Approval_Status__c='Pending For Approval'
        );
        insert booking;

        // Create test data for Quotation__c
        Quotation__c quotation = new Quotation__c(
            Booking__c = booking.Id
        );
        insert quotation;

        // Create test data for Unit__c
        Unit__c unit = new Unit__c(
            Booking__c = booking.Id,
            Sales_Status__c = 'Booked'
        );
        insert unit;

        // Create test data for Opportunity__c
        Opportunity__c opportunity = new Opportunity__c(
            
            Booking__c = booking.Id,
            Stage__c = 'In Follow-up'
        );
        insert opportunity;

        // Test the getbookingCancellationUpdate method
        Set<Id> bookingIds = new Set<Id>{booking.Id};
        Test.startTest();
        Ex_BookingHanldlerServices.getbookingCancellationUpdate(bookingIds);
        Test.stopTest();
    }
}