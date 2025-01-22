@isTest
public class TestEx_DemandManagementServices 
{
    @isTest
    public static void testRaiseDemand()
    {
        String acRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Project__c p= new Project__c(); 
        p.Name ='Test Project';
        insert p;
        
        Tower__c twr=new Tower__c();
        twr.Name='Test Tower';
        twr.Project__c=p.Id;
        insert twr;
        
        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead__c 1',RecordTypeId = acRecordTypeID, PersonMobilePhone = '1122334455');
        insert a1;
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', Opportunity_Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a1.id);
        insert o1;
        
        Unit__c unt=new Unit__c();
        unt.Name='Test Unit';
        unt.Tower__c=twr.Id;
        unt.Project__c=p.Id;
        insert unt;
        
        Payment_Scheme__c ps=new Payment_Scheme__c();
        ps.Name='Test';
        ps.Scheme_Code__c='101';
        insert ps;
        
        Quotation__c qt = new Quotation__c();
        qt.Payment_Scheme__c=ps.Id;
        qt.Unit__c=unt.Id;
        qt.Opportunity__c=o1.Id;  
        insert qt; 
        
        Payment_Milestone__c pm=new Payment_Milestone__c();
        pm.Is_Raised__c = true;
        pm.Demand_Raised_Date__c = system.today();
        pm.Quotation__c=qt.Id;
        pm.Charge_Bucket_1__c = 'Agreement Value' ;
        pm.Charge_Bucket_1_Amount__c = 1000 ;
        pm.Due_Date__c= system.today();
        insert pm;
        
        Payment_Milestone__c pm1=new Payment_Milestone__c();
        pm1.Is_Raised__c = true;
        pm1.Demand_Raised_Date__c = system.today();
        pm1.Quotation__c=qt.Id;
        pm1.Charge_Bucket_1__c = 'Statutory Charges' ;
        pm1.Charge_Bucket_1_Amount__c = 1000 ;
        pm1.Due_Date__c= system.today();
        insert pm1;
        
        Payment_Milestone__c pm2=new Payment_Milestone__c();
        pm2.Is_Raised__c = true;
        pm2.Demand_Raised_Date__c = system.today();
        pm2.Quotation__c=qt.Id;
        pm2.Charge_Bucket_1__c = 'other Charges' ;
        pm2.Charge_Bucket_1_Amount__c = 1000 ;
        pm2.Due_Date__c= system.today();
        insert pm2;
        
        Booking__c bk=new Booking__c();
        bk.Project__c=p.Id;
        bk.Quotation__c=qt.Id;
        bk.Project__c=p.Id;
        bk.Tower__c=twr.Id;
        bk.Opportunity__c=o1.Id;
        insert bk;
        
        Demand__c d = new Demand__c();
        d.Demand_Type__c = 'Flat Cost';
        d.Booking__c = bk.Id;
        d.Quotation__c = pm.Quotation__c;
        d.Payment_Milestone__c = pm.Id;
        d.Demand_Status__c = 'Raised';
        d.Agreement_Value_Demanded__c=45000.00;
        d.Demand_Status__c = 'Raised';
        insert d;
        update pm;
        Ex_DemandAction.demandrecord('Reverse' , 'Test' , d.Id) ;
        
        d.Demand_Status__c = 'Reverse';
        update d ;
        delete d ;
        
        Ledger__c ledg = new Ledger__c();
        ledg.Charge_Name__c='Flat cost';
        ledg.Type__c = 'Debit';
        ledg.Amount__c=d.Agreement_Value_Demanded__c;
        
        Ex_DemandManagementServices.raiseDemand(pm);
        Ex_DemandManagementServices.raiseDemand(pm2);  
        Ex_DemandManagementServices.raiseDemand(pm1);
        Ex_DemandManagementServices.getOnAccountBalanceReceipts(bk.Id);
        Ex_DemandAction.demandrecord('Raised' , 'Test' , d.Id) ;
        Ex_DemandRaiseBatch cont = new Ex_DemandRaiseBatch();
        Database.executeBatch(cont,200);
        String jobId = System.schedule('Test Ex_DemandRaiseBatch', 
                                       '0 0 0 1 1 ? 2099', 
                                       new Ex_DemandRaiseBatch());
        
    }
    
}