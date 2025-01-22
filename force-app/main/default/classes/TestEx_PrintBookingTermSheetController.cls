//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 30-11-2023
//-------------------------------------------//
@Istest
public class TestEx_PrintBookingTermSheetController {
    @isTest
    public static void testTermSheet() {
        Booking__c b = new Booking__c();
        b.Agreement_Value__c = 100;
        insert b;
        
        Terms_Sheet__c tm = new Terms_Sheet__c();
        tm.Booking__c = b.Id;
        insert tm;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('bId', b.Id);
        Ex_PrintBookingTermSheetController controller = new Ex_PrintBookingTermSheetController();
        Test.stopTest();
    }
    

}