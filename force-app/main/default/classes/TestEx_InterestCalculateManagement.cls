@isTest
public class TestEx_InterestCalculateManagement {
    @isTest
    public static void testInterestCalculate() {
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        Map<Id, Date> boookingInterestDateMap = new Map<Id, Date>();
        Set<Id> bookingIdSet = new Set<Id>();
        
        Project__c p= new Project__c();
        p.Rate_of_Interest__c = 12 ;
        insert p ;
        
        Booking__c b = new Booking__c();
        b.Project__c = p.Id ;
        bookingList.add(b);
        insert bookingList;
        
        Demand__c d = new Demand__c();
        d.Booking__c = b.Id ;
        d.Due_Date__c = system.today().addDays(-2);
        d.Total_Amount_Demanded__c = 200 ;
        d.Total_Amount_Demanded__c = 200 ;
        d.Total_Amount_Paid__c = 100;
        demandList.add(d);
        insert demandList;
        
        bookingIdSet.add(b.Id);
        boookingInterestDateMap.put(b.Id , system.today());
        Test.startTest();
        Ex_InterestCalculateManagementServices.interestCalculate(boookingInterestDateMap);
        Map<String, List<Demand__c>> result = Ex_InterestCalculateManagementServices.getPendingDemandMap(bookingIdSet);
        String jobId = System.schedule('Test Job', '0 0 0 1 1 ?', new Ex_InterestCalculationBatch());
        Ex_InterestCalculationBatch batchInstance = new Ex_InterestCalculationBatch();
        batchInstance.execute(null, demandList);
        Test.stopTest();
        
        
    }
    
}