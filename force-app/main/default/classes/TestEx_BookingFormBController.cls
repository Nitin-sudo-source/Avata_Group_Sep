@isTest
public class TestEx_BookingFormBController {
    @isTest
    public static void testBooking() {
        Booking__c b = new Booking__c();
        b.Agreement_Value__c = 100;
        b.Sanctioned_Loan_Amount__c = 65 ;
        b.Advance_maintenance_24_months_GST_18__c = 18;
        insert b;
        
        Applicant__c ap = new Applicant__c();
        ap.Booking__c = b.Id ;
        ap.Applicant_Number__c = '655';
        insert ap ;
        
        Receipt__c rc = new Receipt__c();
        rc.Booking__c = b.Id ;
        rc.Receipt_Date__c = system.today();
        rc.Bank_Name__c = 'Andhra Pradesh Grameena Vikas Bank' ;
        rc.Amount__c = 7655;
        rc.Transaction_Id__c = '6555';
        insert rc ;
            
            
        Test.startTest();
        ApexPages.currentPage().getParameters().put('bId', b.Id);
        Ex_BookingFormBController controller = new Ex_BookingFormBController();
        Ex_BookingFormBController.calculateAge(system.today());
        Test.stopTest();
    }
}