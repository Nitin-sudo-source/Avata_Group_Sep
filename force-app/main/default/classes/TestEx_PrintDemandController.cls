//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 1-12-2023
//-------------------------------------------//
@Istest
public class TestEx_PrintDemandController {
    @isTest
    public static void testPrintDemand() {
        
        Booking__c b = new Booking__c();
        b.Agreement_Value__c = 100;
        insert b;
        
        Demand__c d = new Demand__c();
        d.Booking__c = b.Id;
        insert d;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('dId', d.Id);
        Ex_PrintDemandController controller = new Ex_PrintDemandController();
        Test.stopTest();
    }
    
}