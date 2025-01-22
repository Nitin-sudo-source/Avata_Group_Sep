@isTest
public class TestEx_ReceiptTriggerHandler {

    @isTest
    public static void testReceiptTrigger(){
        Booking__c bk = new Booking__c();
        insert bk ;
        
        Receipt__c rc = new Receipt__c();
        rc.Booking__c = bk.Id ;
        rc.Date__c = system.today().addDays(-2);
        rc.Payment_Status__c = 'Payment Successful';
        rc.Total_Money_Apportioned__c = 100;
        rc.Amount__c = 100;
        insert rc ;
        rc.Receipt_Status__c = 'Reverse';
        update rc;
        
        Receipt__c rc1 = new Receipt__c();
        rc1.Booking__c = bk.Id ;
        rc1.Date__c = system.today().addDays(-2);
        rc1.Payment_Status__c = 'Other';
        rc1.Total_Money_Apportioned__c = 100;
        rc1.Amount__c = 100;
        insert rc1;
        rc.Payment_Status__c = 'Payment Successful';
        update rc;
        
        Demand__c d = new Demand__c();
        d.Booking__c = rc.Booking__c;
        insert d;
    }
}