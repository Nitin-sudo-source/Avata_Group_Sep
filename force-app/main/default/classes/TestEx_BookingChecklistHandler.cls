@isTest
public class TestEx_BookingChecklistHandler {
    @isTest
    static void testcheckList(){
        Test.startTest();
        Booking__c bk = new Booking__c();
        insert bk;
        
        Booking_Checklist__c b = new Booking_Checklist__c();
        b.Booking__c = bk.Id;
        insert b;
        update b;
        
        Ex_CheckRecursive.runOnce();
        Test.StopTest();
    }
}