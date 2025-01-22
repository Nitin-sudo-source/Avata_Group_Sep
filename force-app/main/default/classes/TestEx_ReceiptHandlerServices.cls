@isTest
public class testEx_ReceiptHandlerServices {
    @isTest 
    static void Test_ReceiptHandler() { 

        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Last_Demand_No__c = 123;
        p.Starting_Demand_No__c = 100;
        p.Rate_of_Interest__c = 7;
        p.TDS__c = 6;
        insert p;

        Tower__c t = new Tower__c();
        t.Name = 'TowerA';
        t.Project__c = p.Id;
        insert t; 
        
        Unit__c un = new Unit__c();
        un.Name = '1BHK501';
        un.Sale_Status__c = 'Vacant';
        un.Configuration__c = '1 BHK';
        un.Inventory_Type__c = 'Residential';
        un.Floor__c = 5;
        un.Project__c = p.Id;
        un.Tower__c = t.Id;
        un.Saleable_Area__c = 1000;
        un.RERA_Carpet_Area_Sq_Ft__c = 800;
        insert un;

        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 1';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = t.id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Actual_Completion_Date__c = system.today() - 10;
        cs1.Expected_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
        
        Test.startTest();
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Site_Visit_Count__c = 1 ;
        insert op ;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = op.id;
        q.Tower__c = t.Id;
        q.Project__c = p.Id;
        q.Unit__c = un.Id;
        insert q;
        
        Payment_Milestone__c pm = New Payment_Milestone__c();
        pm.Quotation__c = q.id;
        pm.Construction_Stage__c = cs1.Id;
        insert pm;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Mode_Of_Funding__c = 'Self Funding';
        b.Tower__c = t.Id;
        b.Project__c = p.Id;
        b.Quotation__c = q.id;
        b.Opportunity__c = op.id;
        b.Unit__c = un.Id;
        b.Generate_Welcome_Call_Checklist_Master__c = false;
        b.Welcome_Call_Status__c = 'Welcome Call Pending';
        b.Welcome_Call_Done__c = false;
        b.Welcome_Call_Comments__c = 'test';
        b.Welcome_Call_Completion_Date__c = System.today();
        b.Generate_Welcome_Call_Checklist_Master__c = false;
        insert b;         
        
        Receipt__c rc1 = new Receipt__c();
        rc1.Booking__c =b.id;
        rc1.Transaction_ID__c = '123';
        rc1.Amount__c = 55000;
        rc1.Token_Amount_Received__c =true;
        rc1.Receipt_Type__c	 = 'Flat Cost';
        rc1.Payment_Mode__c = 'Cheque';
        rc1.Payment_Status__c = 'Payment Successful';
        rc1.Receipt_Date__c = system.today();
        rc1.Date__c = system.today();
        rc1.Receipt_Status__c = 'Processed';
        rc1.Total_Money_Apportioned__c = 10000;
        insert rc1;
        
        Receipt__c rc2 = new Receipt__c();
        rc2.Booking__c =b.id;
        rc2.Transaction_ID__c = '123';
        rc2.Amount__c = 55000;
        rc2.Token_Amount_Received__c =false;
        rc2.Receipt_Type__c	 = 'Tax';
        rc2.Payment_Mode__c = 'Cheque';
        rc2.Payment_Status__c = 'Payment Successful';
        rc2.Receipt_Date__c = system.today();
        rc2.Date__c = system.today();
        rc2.Receipt_Status__c = 'Processed';
        rc2.Total_Money_Apportioned__c = 10000;
        insert rc2;
        
        Demand__c d = New Demand__c();
        d.Booking__c= b.id;
        d.Quotation__c = q.id;
        d.Payment_Milestone__c = pm.id;
        d.Demand_Status__c = 'Raised';
        d.Total_Amount_Demanded__c = 100000;
        d.Total_Amount_Paid__c = 50000;
        Date dueDate = Date.today().addDays(-5);
        d.Due_Date__c = dueDate;
        d.Total_Interest_Amount__c = 1200;
        d.Invoice_Number__c = '123';
        d.Agreement_Value_Tax_Demanded__c = 100000;
        d.Agreement_Value_Tax_Paid__c = 50000;
        
        insert d;     
        
        Set<Id> receiptIdSet1 = new Set<Id>();
        Set<Id> receiptIdSet2 = new Set<Id>();
        receiptIdSet1.add(rc1.Id); 
        receiptIdSet2.add(rc2.Id);
        
        Ex_ReceiptHandlerServices.receiptApporation(receiptIdSet1);
        Ex_ReceiptHandlerServices.receiptApporation(receiptIdSet2);
        
        Set<Id> reverseReceiptIdSet1 = new Set<Id>();
        reverseReceiptIdSet1.add(rc1.Id);
        
        Ex_ReceiptHandlerServices.reverseReceiptCalculation(reverseReceiptIdSet1);
        
        test.stopTest();
        
    }
    
    @isTest 
    static void Test_ReceiptHandler2() { 
        Test.startTest();
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Last_Demand_No__c = 123;
        p.Starting_Demand_No__c = 100;
        p.Rate_of_Interest__c = 7;
        p.TDS__c = 6;
        insert p;

        Tower__c t = new Tower__c();
        t.Name = 'TowerA';
        t.Project__c = p.Id;
        insert t; 
        
        Unit__c un = new Unit__c();
        un.Name = '1BHK501';
        un.Sale_Status__c = 'Vacant';
        un.Configuration__c = '1 BHK';
        un.Inventory_Type__c = 'Residential';
        un.Floor__c = 5;
        un.Project__c = p.Id;
        un.Tower__c = t.Id;
        un.Saleable_Area__c = 1000;
        un.RERA_Carpet_Area_Sq_Ft__c = 800;
        insert un;

        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 1';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = t.id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Actual_Completion_Date__c = system.today() - 10;
        cs1.Expected_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Site_Visit_Count__c =1 ;
        insert op ;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = op.id;
        q.Tower__c = t.Id;
        q.Project__c = p.Id;
        q.Unit__c = un.Id;
        insert q;
        
        Payment_Milestone__c pm = New Payment_Milestone__c();
        pm.Quotation__c = q.id;
        pm.Construction_Stage__c = cs1.Id;
        insert pm;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Mode_Of_Funding__c = 'Self Funding';
        b.Tower__c = t.Id;
        b.Project__c = p.Id;
        b.Quotation__c = q.id;
        b.Opportunity__c = op.id;
        b.Unit__c = un.Id;
        b.Generate_Welcome_Call_Checklist_Master__c = false;
        b.Welcome_Call_Status__c = 'Welcome Call Pending';
        b.Welcome_Call_Done__c = false;
        b.Welcome_Call_Comments__c = 'test';
        b.Welcome_Call_Completion_Date__c = System.today();
        b.Generate_Welcome_Call_Checklist_Master__c = false;
        insert b;         
        
        Receipt__c rc1 = new Receipt__c();
        rc1.Booking__c =b.id;
        rc1.Transaction_ID__c = '123';
        rc1.Amount__c = 55000;
        rc1.Total_Money_Apportioned__c = 0;
        rc1.Token_Amount_Received__c =true;
        rc1.Receipt_Type__c	 = 'Flat Cost';
        rc1.Payment_Mode__c = 'Cheque';
        rc1.Payment_Status__c = 'Payment Successful';
        rc1.Receipt_Date__c = system.today();
        rc1.Date__c = system.today();
        rc1.Receipt_Status__c = 'Processed';
        insert rc1;
        rc1.Payment_Status__c = 'Payment Successful';
        rc1.Receipt_Status__c = 'Reverse';
        update rc1;
        
        Receipt__c rc2 = new Receipt__c();
        rc2.Booking__c =b.id;
        rc2.Transaction_ID__c = '123';
        rc2.Amount__c = 55000;
        rc2.Total_Money_Apportioned__c = 0;
        rc2.Token_Amount_Received__c =true;
        rc2.Receipt_Type__c	 = 'GST';
        rc2.Payment_Mode__c = 'Cheque';
        rc2.Payment_Status__c = 'Other';
        rc2.Receipt_Date__c = system.today();
        rc2.Date__c = system.today();
        rc2.Receipt_Status__c = 'Processed';
        insert rc2;
        
        
        
        boolean result2 = Ex_ReceiptAction.receiptrecord('Delete', 'Test Remarks', rc1.Id);
        
        //ReceiptPrint
        PageReference pRef3 = Page.Ex_PrintReceipt;
        pRef3.getParameters().put('rId', rc2.Id);
        Test.setCurrentPage(pRef3);
        Ex_PrintReceiptController controller = new Ex_PrintReceiptController();
        test.stopTest();
    }

}