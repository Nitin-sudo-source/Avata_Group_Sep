@isTest
public class Test_Ex_InterestCalculateMgmtService {
    
    @isTest
    public static void testInterestCalculate() {
          Map<String,Id> recordIdMap =Ex_MasterDataController.createMaster();
         Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Step 2: Create a test user
        User testUser = new User(
            LastName = 'Test User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        Map<Id, Date> boookingInterestDateMap = new Map<Id, Date>();
        Set<Id> bookingIdSet = new Set<Id>();
        
        
        Project__c p= new Project__c();
        p.Name='prj';
        p.User__c=testUser.id;
        p.Rate_of_Interest__c = 12 ;
        p.Last_Demand_No__c='55';
        insert p ;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Stage__c = 'Booking In-Process';
        op.Close_Date__c = system.today().addDays(30);
        op.SV_Count__c =1 ;
        //op.c = 1 ;
        insert op ;

        Quotation__c q = new Quotation__c();
        q.Opportunity__c = op.id;
        q.Tower__c = recordIdMap.get('TOWER');
        q.Project__c =recordIdMap.get('PROJECT');
        q.Unit__c = recordIdMap.get('UNIT');
        insert q;       
        
        Booking__c b = new Booking__c();
        b.Project__c = p.Id ;
        bookingList.add(b);
        insert bookingList;
        
         Payment_Milestone__c paymentMilestone = new Payment_Milestone__c(
     
            Quotation__c = q.Id,
            Due_Date__c = System.today(),
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Amount__c = 100000,
            Charge_Bucket_1_Total_Tax__c = 5000,
            Milestone_Type__c = 'Date Linked',
            Sequence_No__c = 1,
            Demand_Raised_Date__c = System.today()
        );
        insert paymentMilestone;
        
         Demand__c d = new Demand__c();
        d.Booking__c = b.Id ;
        d.Quotation__c=q.id;
        d.Payment_Milestone__c=paymentMilestone.id;
        d.Due_Date__c = system.today().addDays(-2);
        d.Total_Amount_Demanded__c = 200 ;
        d.Total_Amount_Demanded__c = 200 ;
        d.Total_Amount_Paid__c = 100;
        d.Invoice_Number__c='666774';
 
        demandList.add(d);
        insert demandList;
        
        bookingIdSet.add(b.Id);
        boookingInterestDateMap.put(b.Id , system.today());
        Test.startTest();
        Ex_InterestCalculateManagementServices.interestCalculate(boookingInterestDateMap);
        Map<String, List<Demand__c>> result = Ex_InterestCalculateManagementServices.getPendingDemandMap(bookingIdSet);
        String jobId = System.schedule('Test Ex_InterestCalculationBatch', '0 0 0 * * ?', new Ex_InterestCalculationBatch());
        Ex_InterestCalculationBatch batchInstance = new Ex_InterestCalculationBatch();
        batchInstance.execute(null, demandList);
        Test.stopTest();
        
        
    }

}