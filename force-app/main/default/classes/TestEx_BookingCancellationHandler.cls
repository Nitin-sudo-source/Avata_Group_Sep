@isTest
public class TestEx_BookingCancellationHandler {
    @isTest
    public static void CreateCancellationBooking(){
        Map<String,Id> recordIdMap =Ex_MasterDataController.createMaster();
        
        Profile salesManagerProfile = [SELECT Id FROM Profile LIMIT 1];
        if (salesManagerProfile == null) {
            System.assert(false, 'Profile "Sales Manager" not found in the org.');
        }
        
        // Create a User record for Sales Manager
        User salesManager = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Username = 'john.doe@example.com.salesforce', // Ensure this is unique
            Alias = 'jdoe',
            CommunityNickname = 'jdoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesManagerProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert salesManager;

        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc1';
        acc.Phone = '99854857584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc1@gmail.com';
        acc.PersonEmail = 'acc11@gmail.com';
        insert acc;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Account__c = acc.id;
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
        b.Booking_Date__c = system.today();
        b.Mode_Of_Funding__c = 'Self Funding';
        b.Tower__c = recordIdMap.get('TOWER');
        b.Project__c = recordIdMap.get('PROJECT');
        b.Quotation__c = q.id;
        b.Opportunity__c = op.id;
        b.Booking_Stage__c = 'Cancellation in-process';
        b.Unit__c = recordIdMap.get('UNIT');
        //b.Generate_Welcome_Call_Checklist_Master__c = false;
        //b. = 'Welcome Call Pending';
        b.Welcome_Call_Done__c = false;
       // b.Welcome_Call_Comments__c = 'test';
        b.Welcome_Call_Done_DateTime__c = System.today();
        b.Registration_Done__c=false;
       // b.Generate_Welcome_Call_Checklist_Master__c = false;
        b.Sales_Manager__c=salesManager.id;
        insert b;
        
        Booking__c b1=new Booking__c();
         b1.Booking_Date__c = system.today();
        b1.Mode_Of_Funding__c = 'Self Funding';
        b1.Tower__c = recordIdMap.get('TOWER');
        b1.Project__c = recordIdMap.get('PROJECT');
        b1.Quotation__c = q.id;
        b1.Opportunity__c = op.id;
        b1.Booking_Stage__c = 'Cancellation in-process';
        b1.Unit__c = recordIdMap.get('UNIT');
        //b.Generate_Welcome_Call_Checklist_Master__c = false;
        //b. = 'Welcome Call Pending';
        b1.Welcome_Call_Done__c = true;
       // b.Welcome_Call_Comments__c = 'test';
        b1.Welcome_Call_Done_DateTime__c = System.today();
        b1.Registration_Done__c=false;
       // b.Generate_Welcome_Call_Checklist_Master__c = false;
        b1.OwnerId=salesManager.id;
        insert b1;
        
        Car_Park__c cp = new Car_Park__c();
        cp.Status__c = 'Booked';
        insert cp;
        
        String ctype ='Unit Cancellation';
        String remarks = 'Test Unit Cancellation';
        Decimal amt = 100000;
        String qid=q.id;
        String oppId=op.id;
        
        Id unitId = recordIdMap.get('UNIT');
        Id projectId = recordIdMap.get('PROJECT');
        Id towerId = recordIdMap.get('TOWER'); 
       
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
        
        Map<String, List<String>> priceListGroupMap = new Map<String, List<String>>();
        Map<String, Charge_Details__c> priceListMap = new Map<String, Charge_Details__c>();
        
        Test.startTest();
        
      //  Ex_UpdateAVDetails.getBookingInfo(b1.id);
       // Ex_UpdateAVDetails.getAVDetails(b1.id);
       // Ex_UpdateAVDetails.getPriceListMapDetails(unitId);
       // Ex_UpdateAVDetails.getPriceListGroupMapDetails(unitId);
        /*Map<String, Decimal> allPriceInfo = Ex_UpdateAVDetails.getAllPriceMapDetails(
            unitId,
            500000, 5, 18, 
            priceListGroupMap, priceListMap, 10000, 5000
        );*/
        
       /* Ex_DemandManagementServices.getOnAccountBalance(b1.id);
              Ex_DemandManagementServices.getOnAccountBalanceReceipts(b1.id);
              Ex_DemandManagementServices.raiseDemand(paymentMilestone);*/
        
        Ex_BookingCancellationHandler.fetchBooking(b, ctype, amt, remarks);
        Ex_BookingCancellationHandler.fetchBooking(b1, ctype, amt, remarks);
        Ex_BookingFormController.getReceipts();
        Ex_BookingFormController.getQuotationDetails(qid);
        Ex_BookingFormController.getBookingWrapper(oppId);
        Ex_BookingFormController.getLegalEntityDetails(qid);
        Ex_BookingFormController.getChargeListInfo(q.id);
        //Ex_BookingFormController.createBookingRecord(bkWrapper, applicantData, quotationDetails, receiptData, bookingAccount)
       
       /* Ex_AfterBookingPriceManagementServices.getPaymentMilestoneInfo(qid);
        Ex_AfterBookingPriceManagementServices.getPriceListInfo(unitId);
        Ex_AfterBookingPriceManagementServices.getConstructionStagesMap(projectId, towerId);
        Ex_AfterBookingPriceManagementServices.getConsturctionStageList(projectId, towerId);
       Ex_AfterBookingPriceManagementServices.getPriceListGroupMap(unitId);
        Ex_AfterBookingPriceManagementServices.getPriceListMap(unitId);
        Ex_AfterBookingPriceManagementServices.getQuotationInfo(unitId);
        Ex_AfterBookingPriceManagementServices.getUnitInfo(unitId);*/
       // Ex_AfterBookingPriceManagementServices.
        Test.stopTest();

    }
    @isTest
static void testFetchBooking_RegistrationNotDone() {
    // Create Sales Manager user
    User manager = new User(
        FirstName = 'Manager',
        LastName = 'Sales',
        Email = 'manager.sales@example.com',
        Username = 'manager.sales@example.com.salesforce',
        Alias = 'msales',
        CommunityNickname = 'msales',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        LanguageLocaleKey = 'en_US'
    );
    insert manager;

    // Create Sales Manager
    User salesManager = new User(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'john.doe@example.com',
        Username = 'john.doe@example.com.salesforce',
        Alias = 'jdoe',
        CommunityNickname = 'jdoe',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        ManagerId = manager.Id, // Assign Manager
        LanguageLocaleKey = 'en_US'
    );
    insert salesManager;

    // Create Booking record
    Booking__c booking = new Booking__c(
       // Name = 'Test Booking',
        Registration_Done__c = false,
        Sales_Manager__c = salesManager.Id
    );
    insert booking;

    // Call the method
    String result = Ex_BookingCancellationHandler.fetchBooking(
        booking,
        'Test Cancellation',
        10000,
        'Test Remarks'
    );

    //System.assertEquals('success', result, 'The cancellation process should succeed.');
}


}