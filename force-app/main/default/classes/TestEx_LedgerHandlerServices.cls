@isTest
public class TestEx_LedgerHandlerServices {
    @isTest
    public static void testReverseCalculationOnDemandAndReceipt() {
        Booking__c bk = new Booking__c();
        insert bk ;
        
        List<Demand__c> demandRecords = new List<Demand__c>();
        Demand__c demandRecord = new Demand__c();
        demandRecord.Booking__c = bk.Id ;
        demandRecord.Total_Interest_Amount_Paid__c= 200 ;
        demandRecords.add(demandRecord); 
        
        insert demandRecords; 
        
        List<Ledger__c> ledgerRecords = new List<Ledger__c>();
        Ledger__c  le = new Ledger__c();
        le.Type__c = 'Credit';
        le.Demand__c = demandRecords[0].Id ;
        le.Charge_Name__c = 'Interest';
        le.Amount__c = 100 ;
        le.Cancelled__c = false;
        ledgerRecords.add(le);
        
        insert ledgerRecords;
        
        delete ledgerRecords ;
        
        List<Receipt__c> receiptRecords = new List<Receipt__c>();
        insert receiptRecords;
    }
}