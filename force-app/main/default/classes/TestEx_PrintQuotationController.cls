//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 1-12-2023
//-------------------------------------------//
@Istest   
public class TestEx_PrintQuotationController {
     @isTest
    public static void testPrintDemand() {
        Project__c p = new Project__c();
        p.Name = 'test p';
        insert p;
        
        Tower__c t = new Tower__c();
        t.Name = 'Test t';
        t.Project__c = p.id;
        
        Unit__c u = new Unit__c();
        u.Name = 'Test u';
        u.Project__c = p.id;
        u.Tower__c = u.Id;
        u.Configuration__c = '1 BHK';
        insert u;
        
        Booking__c b = new Booking__c();
        b.Agreement_Value__c = 100;
        insert b;
        
        
        Quotation__c q = new Quotation__c();
        q.Project__c = p.id;
        q.Tower__c = t.id;
        q.Unit__c = u.Id;
        q.Booking__c = b.Id;
        insert q;
        
        Charge_Detail__c cd = new Charge_Detail__c();
        cd.Name = 'Registration Charges';
        cd.Charge_Amount__c = 1000;
        cd.Quotation__c = q.id;
        insert cd;
        
        
        Charge_Detail__c cd1 = new Charge_Detail__c();
        cd1.Name = 'Floor Rise';
        cd1.Charge_Amount__c = 1000;
        cd1.Quotation__c = q.id;
        insert cd1;
        
        
        Charge_Detail__c cd2 = new Charge_Detail__c();
        cd2.Name = 'Stamp Duty';
        cd2.Charge_Amount__c = 1000;
        cd2.Quotation__c = q.id;
        insert cd2;
        
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Milestone_Name__c = 'Test Pm';
        pm.Charge_Bucket_1_Percentage__c = 0;
        pm.Charge_Bucket_1_Amount__c = 0;
        pm.Charge_Bucket_1_Total_Tax__c = 0;
        pm.Quotation__c = q.Id;
        insert pm;
       
         Test.startTest();
        ApexPages.currentPage().getParameters().put('qId', q.Id);
        Ex_PrintQuotationController controller = new Ex_PrintQuotationController();
        Test.stopTest();
    }

}