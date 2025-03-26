@isTest
public class TestEx_BookingTriggerHandler {
    @isTest
    public static void testUpdateBookingDetails() {
        // Create a test user
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create Project
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;
        
        // Create Tower
        Tower__c tower = new Tower__c(Name = 'Test Tower', Project__c = project.Id);
        insert tower;
        
        // Create Unit
        Unit__c unit = new Unit__c(
            Tower__c = tower.Id,
            Project__c = project.Id,
            Total_carpet_Sq_Ft__c = 10,
            Configuration_Type__c = '4 BHK',
            Floor__c = 1,
            Sales_Status__c = 'Vacant'
        );
        insert unit;
        
        // Create Quotation
        Quotation__c quotation = new Quotation__c(
            Unit__c = unit.Id,
            Project__c = project.Id,
            Tower__c = tower.Id,
            AV_GST_Percentage__c = 4
        );
        insert quotation;
        
        Charge_Details__c cd=new Charge_Details__c();
        cd.Quotation__c = quotation.id;
        cd.Name = 'Stamp Duty';
        cd.Charge_Type__c = 'Percentage';
        cd.Calculation_Area_Type__c = 'Carpet Area';
        cd.Charge_Amount__c=60000;
        cd.Charge_Bucket__c='Statutory Charges';
        cd.Charge_Percentage__c=10;
        cd.Charge_Rate__c=6767;
        insert cd;
        
        Payment_Milestone__c pm=new Payment_Milestone__c();
        pm.Quotation__c=quotation.id;
        pm.Milestone_Name__c='mile 1';
        pm.Is_Raised__c=true;
        pm.Milestone_Type__c='Date Linked';
        insert pm;
        
        
        // Create Booking
        Booking__c booking = new Booking__c(
            Booking_Date__c = System.today(),
            Mode_Of_Funding__c = 'Self Funding',
            Project__c = project.Id,
            Tower__c = tower.Id,
            Booking_Stage__c = 'Booking In-Process',
            Quotation__c = quotation.Id,
            Unit__c = unit.Id,
            Remarks__c = 'Test Booking',
            Loan_Bank_Name__c = 'HDFC Bank',
            Loan_Amount__c = 700.00,
            CRM_Head__c = testUser.Id
        );
        insert booking;
        
        
        Opportunity__c op1=new Opportunity__c();
        op1.Stage__c='Booking Cancelled';
        op1.Booking__c=booking.id;
        insert op1;
        
        Unit__c unit1= new Unit__c();
        unit1.Total_carpet_Sq_Ft__c = 10;
        unit1.Configuration_Type__c = '4 BHK';
        unit1.Floor__c = 1;
        unit1.Sales_Status__c = 'Vacant';
        unit1.Opportunity__c=op1.id;
        unit1.Booking__c=booking.id;
        insert unit1;
        
        // Create a list containing the single Booking__c record
        List<Booking__c> bookingList = new List<Booking__c>{booking};
            
            // Use the list to initialize the map
            Map<Id, Booking__c> quotationBookingMap = new Map<Id, Booking__c>(bookingList);
        // Update Booking to trigger the afterUpdate logic
        booking.Booking_Stage__c = 'Booking Confirmed';
        booking.Welcome_Call_Done__c = true;
        update booking;
        
        set<Id> bookset=new set<Id>();
        bookset.add(booking.id);
        
        set<Id> qset=new set<Id>();
        qset.add(quotation.id);
        
        set<id> tset=new set<id>();
        tset.add(tower.id);
        
        // Validate the trigger actions
        Booking__c updatedBooking = [SELECT Id, Booking_Stage__c, Welcome_Call_Done__c FROM Booking__c WHERE Id = :booking.Id];
        System.assertEquals('Booking Confirmed', updatedBooking.Booking_Stage__c, 'Booking Stage should be updated');
        System.assertEquals(true, updatedBooking.Welcome_Call_Done__c, 'Welcome Call Done should be true');
        
        Ex_BookingHanldlerServices.getbookingCancellationUpdate(bookset);
        Ex_BookingHanldlerServices.getBookingDetailMap(bookset);
        Map<Id, Unit__c> unitMap = Ex_BookingHanldlerServices.getUnitMap(bookset);
        Ex_BookingHanldlerServices.getChargeDetailsMap(qset);
        Ex_BookingHanldlerServices.getQuotationDetailMap(qset);
        Ex_BookingHanldlerServices.getUnDemandedPaymentMilestoneMap(qset);
        Ex_BookingHanldlerServices.updatePaymentMilestoneDueDate(quotationBookingMap, tset);
        
        
        Ex_BookingFormController.getReceipts();
        Ex_BookingFormController.getBookingWrapper(op1.Id);
    }
    
    @isTest
    public static void testBookingTrigger(){
        Project__c  pr = createProject();
        list<Booking__c> bookingList = new list<Booking__c>();
         RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner' LIMIT 1];
        
        Applicant_Document__c cpd = new Applicant_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Upload_Required__c = 'Yes';
        cpd.Nationality__c = 'Indian';
        insert cpd;
        
        Applicant_Document__c cpd1 = new Applicant_Document__c();
        cpd1.Name = 'Yes';
        cpd1.Document_Upload_Required__c = 'No';
        cpd1.Nationality__c = 'NRI';
        insert cpd1;
        
         CP_Document__c cpdd1 = new CP_Document__c();
        cpdd1.Name = 'No';
        cpdd1.Document_Required__c = 'Aadhaar Card,Pan Card';
        insert cpdd1;
        
        CP_Document__c cpdd2 = new CP_Document__c();
        cpdd2.Name = 'Yes';
        cpdd2.Document_Required__c = 'Aadhaar Card,Pan Card,GST Registration Certificate,RERA Certificate,RERA Competency Certificate';
        insert cpdd2;
        
       
        // Create a test Account
        Account testAccount = new Account();
        testAccount.RecordTypeId = rt.Id;
        testAccount.Name='cpp';
        testAccount.Phone='9011722426';
        testAccount.RERA_Available__c='Yes';
        testAccount.PAN_No__c='6578767';
        insert testAccount;

        // Create test Document__c records linked to the test Account
        List<Document__c> documents = new List<Document__c>{
            new Document__c(
                Document_Type__c = 'Pan Card',
                CP_Account__c = testAccount.Id,
                Uploaded__c = false
            ),
            new Document__c(
                Document_Type__c = 'Pan Card',
                CP_Account__c = testAccount.Id,
                Uploaded__c = true
            )
        };
        insert documents;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Stage__c = 'In Follow-up';
        op.SV_Count__c =1 ;
        op.Channel_Partner__c = testAccount.id;
        insert op ;
        
        Booking__c bk = new Booking__c ();
        bk.Primary_Applicant_Title__c ='Mrs.';
        bk.Primary_Applicant_Name__c = 'Test Test';
        bk.Primary_Applicant_Email__c = 'Test.Test@exceller.tech';
        bk.Primary_Applicant_Mobile__c ='9899996545';
        //bk.Booking_Stage__c = 'Booking In-Process';
        insert bk ;
        bk.Opportunity__c = op.Id;
        bk.Booking_Stage__c = 'Booking Confirmed';
        
        try{
            update bk;
        }catch(exception e){
        }
        Booking__c bk1 = new Booking__c ();
        bk1.Opportunity__c = op.Id;
        bk1.Total_Amount_Received__c = 87;
        bk1.Booking_Stage__c = 'Booking Confirmed';
        insert bk1 ;
        
        
        
        Receipt__c rc = new Receipt__c();
        rc.Booking__c = bk1.Id ;
        insert rc ;
        
        Unit__c unit = new Unit__c();
        unit.Name = 'Unit';
        unit.Floor__c = 1;
        unit.booking__c = bk1.Id;
        insert unit;
        
   
        
        Set<Id> bookingIds = new Set<Id>();
        bookingIds.add(bk1.Id);
        bookingList.add(bk1);
        
        Quotation__c q = new Quotation__c();
        q.Quotation_Status__c ='Valid';
        q.Opportunity__c = op.Id;
        q.Unit__c=unit.id;
        insert q ;
        
        Charge_Details__c cd=new Charge_Details__c();
        cd.Quotation__c = q.id;
        cd.Name = 'Stamp Duty';
        cd.Charge_Type__c = 'Percentage';
        cd.Calculation_Area_Type__c = 'Carpet Area';
        cd.Charge_Amount__c=60000;
        cd.Charge_Bucket__c='Statutory Charges';
        cd.Charge_Percentage__c=10;
        cd.Charge_Rate__c=6767;
        insert cd;
        
        Set<Id> testIdSet = new Set<Id>{q.Id};
            
            
            
            Legal_Entity__c newLegalEntity = new Legal_Entity__c(
                Name = ' Project',
                Account_Name_Flat_Cost__c = 'Test Estate Collection Account',
                Account_Name_Tax__c = 'Test Estate Private Limited',
                Account_Number_Flat_Cost__c = '76665',
                Account_Number_Tax__c = '655',
                Bank_Name_Flat_Cost__c = 'HDFC Bank Ltd',
                Bank_Name_Tax__c = 'HDFC BANK',
                Branch_Name_Flat_Cost__c = 'Nesbit Road, Mazgaon Branch',
                Branch_Name_Tax__c = 'Nesbit Road, Mazgaon Branch',
                IFSC_Code_Flat_Cost__c = '101010',
                IFSC_Code_Tax__c = '101010'
            );
        
        insert newLegalEntity;
        
        
        String alternation = 'Test Alternation';
        String remarks = 'Test Remarks';
        String offerValue = 'Test Offer Value';
        String modeOfFunding = 'Loan';
        Date D = Date.today();
        String applicantData = '[{"key":"Applicant 1","ap":{"Type_of_Applicant__c":"Corporate Buyer", "Applicant_Number__c": "Primary Applicant", "Applicant_Title__c": "Mr.", "Name": "Mr.", "Residential_Status__c":"For Company","PAN_Number__c":"6","Nationality__c":"Indian"},"documents":[{"Name":"One Passport Size Color Photograph.","Type_Of_Applicant__c":"Corporate Buyer","Residential_Status__c":"For Company","Id":"a0a0T000001bReWQAU","filename":"gdd.jpg","base64":"jHxsXEw8LBwL++vby7urq5uLe2tbSzsrGwr66trKuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1","fileData":null,"fileUploader":null,"index":1}]}]';
        List<Quotation__c> quotationDetails = new List<Quotation__c>();
        quotationDetails.add(q);
        String receiptData = '[{"key":"Receipt 1","rc":{"rc":{},"Mode_Of_Payment__c":"Debit Card","Is_Token_Amount_Received__c":true,"Amount__c":"66","Receipt_Date__c":"2023-09-19","Receipt_Type__c":"Flat Cost","Transaction_ID__c":"345678"}}]';
        List<Map<String, Object>> documentsdata = new List<Map<String, Object>>();
        List<Legal_Entity__c> bookingAccount = new List<Legal_Entity__c>();
        bookingAccount.add(newLegalEntity);
        Test.startTest();
        Ex_BookingFormController.getQuotationDetails(q.Id);
        Ex_BookingFormController.getLegalEntityDetails(q.Id);
        //Ex_BookingPageControllerLwc.getApplicants('Indian National');
        Ex_BookingFormController.ApplicantdocumentDetails('Yes', 'Indian', op.Id, 'Applicant 1'); 
         Ex_BookingFormController.ApplicantdocumentDetails('No', 'NRI', op.Id, 'Applicant 1'); 
        //Ex_BookingPageControllerLwc.getReceipts();
        Ex_BookingFormController.createContentVersion('tests' ,'test');
        
        
        
        
        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>();
        date getTentativeDate = system.today();
        String getSelfFunding = 'Yes';
        String getHomeLoanpick = 'Yes';
        Decimal getAmount = 3456;
        Decimal  getTokenAmt = 789;
        Date  getTokenAmtDate  = system.today();
        Decimal getownContributiona = 578;
        Date getownContributionaDate = system.today();
        Decimal getownContributionb = 134;
        Date getownContributionbDate = system.today();
        Decimal getHomeLoan = 800; 
        Date getHomeLoanDate = system.today();
        Decimal getGSTAmount = 90;
        Date getGSTAmountDate = system.today();
        Decimal getSDRAmount = 567;
        Date getSDRAmountDate = system.today();
        Decimal getSelfFundingAmount = 871;
        String getpayementRemarks = 'TEST BOOKING';
        Ex_BookingFormController.BookWrapper bm = Ex_BookingFormController.getBookingWrapper(op.Id);
        bm.bk.Mode_of_Funding__c = 'Loan';
        List<Legal_Entity__c> llist =  Ex_BookingFormController.getLegalEntityDetails(q.Id);
        Id result = Ex_BookingFormController.createBookingRecord(bm, applicantData, quotationDetails[0], receiptData, bookingAccount);
       
        
        
        List<Applicant__c> applicantList = [Select Id, Name, Mobile__c from Applicant__c where Booking__c =: result ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('applicantList::'+applicantList);
        if(!applicantList.isEmpty() && applicantList != null) {
            applicantList[0].Mobile__c = '4477889922';
            applicantList[0].Applicant_Number__c ='Primary Applicant';
            update applicantList[0];
        }
        
        unitMap.put(bk1.Id, unit);
        String fieldName = 'Amount';
        
        Test.stopTest();
    }
    
    @isTest
    public static void updatePaymentMilestoneDueDate(){
        Project__c  pr = createProject();
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
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
        op.Stage__c = 'Booked';
        op.Project__c = pr.Id;
        op.SV_Count__c = 1 ;
        insert op ;
        
        
        Tower__c t = new Tower__c();
        t.Name = 'Test t';
        t.Project__c = pr.id;
        
        Unit__c u = new Unit__c();
        u.Name = 'Test u';
        u.Project__c = pr.id;
        u.Tower__c = u.Id;
        u.Configuration_Type__c = '1 BHK';
        insert u;
        Quotation__c q = new Quotation__c();
        q.Tower__c = t.Id;
        q.Project__c = pr.Id;
        q.Unit__c = u.Id;
        q.Charge_Bucket_1_Amount__c=5000;
        q.Charge_Bucket_1__c='Agreement Value';
        
        insert q;
        
        Payment_Milestone__c pm = New Payment_Milestone__c();
        pm.Quotation__c = q.id;
        pm.Is_Due__c = false;
        pm.Due_Date__c = system.today();
        pm.Is_Raised__c = false;
        pm.Milestone_Type__c = 'Date Linked';
        pm.Milestone_Name__c = 'On Booking';
        pm.Number_of_Days__c = 10;
        insert pm;
        
        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 1';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = t.id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Unit_Wise_Milestone__c = true;
        cs1.Actual_Completion_Date__c = system.today() - 10;
        cs1.Expected_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
        
        Payment_Milestone__c pm1 = New Payment_Milestone__c();
        pm1.Quotation__c = q.id;
        pm1.Is_Due__c = false;
        pm1.Due_Date__c = system.today();
        pm1.Is_Raised__c = false;
        pm1.Milestone_Type__c = 'Construction Linked';
        pm1.Construction_Stage__c = cs1.Id;
        pm1.Milestone_Name__c = 'Completion of Plinth';
        insert pm1;
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Mode_Of_Funding__c = 'Self Funding';
        b.Tower__c = t.Id;
        b.Project__c = pr.Id;
        b.Quotation__c = q.id;
        b.Booking_Stage__c = 'Booking Confirmed';
        b.Opportunity__c = op.id;
        b.Unit__c = u.Id;
        b.Agreement_Value__c=10000;
        b.Agreement_Value_Tax__c=1000;
        insert b;  
        
        q.Booking__c=b.Id;
        update q;
        List<Booking__c> testBookingList = new List<Booking__c>{b};
        
        q = [SELECT Id, Name, Charge_Bucket_1__c,Booking__c,Charge_Bucket_1_Amount__c FROM Quotation__c WHERE Id = :q.Id];
        b = [SELECT Id, Name,Tower__c, Agreement_Value__c, Agreement_Value_Tax__c FROM Booking__c WHERE Id = :b.Id];
        List<Payment_Milestone__c> testPaymentMilestones = [SELECT Id, Name, Charge_Bucket_1__c,Charge_Bucket_2__c,Charge_Bucket_3__c,Charge_Bucket_4__c,Charge_Bucket_5__c,
                                                            Charge_Bucket_1_Amount__c FROM Payment_Milestone__c WHERE Quotation__c = :q.Id];
        



        Set<Id> testIdSet = new Set<Id>{q.Id};
            Set<Id> bookingIdSet = new Set<Id>{b.Id};
                
                Test.startTest();
        Map<Id, Booking__c> qIdBookingMap = new Map<Id, Booking__c>{q.Id => b};
            Set<Id> tIdSet = new Set<Id>{b.Tower__c};
                Test.stopTest();
    }
    
    @isTest
    public static Project__c createProject()
    {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        return p;
    }
}