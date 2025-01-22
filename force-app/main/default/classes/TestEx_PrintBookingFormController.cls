//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 30-11-2023
//-------------------------------------------//
@Istest
public class TestEx_PrintBookingFormController {
    @isTest
    public static void testConstructor() {
    Booking__c b = new Booking__c();
    b.Agreement_Value__c = 100;
    insert b;
        
        Applicant__c ap = new Applicant__c();
        ap.Booking__c = b.Id;
        insert ap;      
        
        
    Test.startTest();
    ApexPages.currentPage().getParameters().put('bId', b.Id);
    Ex_PrintBookingFormController controller = new Ex_PrintBookingFormController();
    Test.stopTest();
    }
}