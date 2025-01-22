@isTest
public class Test_Ex_BookingTriggerHandler {
    @isTest
    public static void testBookingTrigger(){
        Project__c  pr = createProject();
        list<Booking__c> bookingList = new list<Booking__c>();
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Opportunity_Stage__c = 'In Follow-up';
        op.Site_Visit_Count__c =1 ;
        insert op ;
        
        Booking__c bk = new Booking__c ();
        bk.Generate_Welcome_Call_Checklist_Master__c = false ;
        bk.Primary_Applicant_Title__c ='Mrs.';
        bk.Primary_Applicant_Name__c = 'Test Test';
        bk.Primary_Applicant_Email__c = 'Test.Test@exceller.tech';
        bk.Primary_Applicant_Mobile__c ='9899996545';
        //bk.Booking_Stage__c = 'Booking In-Process';
        insert bk ;
        bk.Opportunity__c = op.Id;
        bk.Generate_Welcome_Call_Checklist_Master__c = true ;
        bk.Booking_Stage__c = 'Booking Confirmed';
        
        try{
            update bk;
        }catch(exception e){
        }
        Booking__c bk1 = new Booking__c ();
        bk1.Opportunity__c = op.Id;
        bk1.Total_Amount_Received__c = 87;
        bk1.Generate_Welcome_Call_Checklist_Master__c = true ;
        bk1.Booking_Stage__c = 'Booking Confirmed';
        insert bk1 ;
        
        
        
        Receipt__c rc = new Receipt__c();
        rc.Booking__c = bk1.Id ;
        rc.Token_Amount_Received__c = true;
        insert rc ;
        
        Unit__c unit = new Unit__c();
        unit.Name = 'Unit';
        unit.Floor__c = 1;
        unit.booking__c = bk1.Id;
        insert unit;
        
        Welcome_Call_Checklist_Master__c wc = new Welcome_Call_Checklist_Master__c();
        wc.Name = 'Test';
        insert wc;
        
        Set<Id> bookingIds = new Set<Id>();
        bookingIds.add(bk1.Id);
        bookingList.add(bk1);
        
        Quotation__c q = new Quotation__c();
        q.Quotation_Status__c ='Valid';
        q.Opportunity__c = op.Id;
        q.Unit__c=unit.id;
        insert q ;
        
        Set<Id> testIdSet = new Set<Id>{q.Id};
            
            
            
            Legal_Entity__c newLegalEntity = new Legal_Entity__c(
                Name = 'Satyam Project',
                Account_Name_Flat_Cost__c = 'Test Estate Collection Account',
                Account_Name_Tax__c = 'Test Estate Private Limited',
                Account_Number_Flat_Cost__c = '76665',
                Account_Number_Tax__c = '655',
                Bank_Name_Flat_Cost__c = 'HDFC Bank Ltd',
                Bank_Name_Tax__c = 'HDFC BANK',
                Branch_Name_Flat_Cost__c = 'Nesbit Road, Mazgaon Branch',
                Branch_Name_Tax__c = 'Nesbit Road, Mazgaon Branch',
                GSTIN__c = '0974258TGR987',
                IFSC_Code_Flat_Cost__c = '101010',
                IFSC_Code_Tax__c = '101010',
                PAN_No__c = '9876530946'
            );
        
        insert newLegalEntity;
        
        
        String alternation = 'Test Alternation';
        String remarks = 'Test Remarks';
        String offerValue = 'Test Offer Value';
        String modeOfFunding = 'Loan';
        Date D = Date.today();
        String applicantData = '[{"key":"Applicant 1","ap":{"Type_Of_Applicant__c":"Corporate Buyer","Residential_Status__c":"For Company","PAN_Number__c":"6","Nationality__c":"Indian"},"documents":[{"Name":"One Passport Size Color Photograph.","Type_Of_Applicant__c":"Corporate Buyer","Residential_Status__c":"For Company","Id":"a0a0T000001bReWQAU","filename":"gdd.jpg","base64":"jHxsXEw8LBwL++vby7urq5uLe2tbSzsrGwr66trKuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1","fileData":null,"fileUploader":null,"index":1}]}]';
        List<Quotation__c> quotationDetails = new List<Quotation__c>();
        quotationDetails.add(q);
        String receiptData = '[{"key":"Receipt 1","rc":{"rc":{},"Payment_Mode__c":"Debit Card","Token_Amount_Received__c":true,"Amount__c":"66","Date__c":"2023-09-19","Receipt_Type__c":"Flat Cost","Transaction_ID__c":"345678"}}]';
        List<Map<String, Object>> documentsdata = new List<Map<String, Object>>();
        List<Legal_Entity__c> bookingAccount = new List<Legal_Entity__c>();
        bookingAccount.add(newLegalEntity);
        Test.startTest();
        Ex_BookingPageControllerLwc.getQuotationDetails(q.Id);
        Ex_BookingPageControllerLwc.getLegalEntityDetails(q.Id);
        //Ex_BookingPageControllerLwc.getApplicants('Indian National');
        Ex_BookingPageControllerLwc.ApplicantdocumentDetails('Indian National');  
        //Ex_BookingPageControllerLwc.getReceipts();
        Ex_BookingHanldlerServices.insertWelcomeCallChecklist(bookingList);
        Ex_BookingPageControllerLwc.createContentVersion('tests' ,'test');
        
        
        Map<Id, Unit__c> resultss = Ex_BookingHanldlerServices.getBookingUnitMap(bookingIds);
        
        
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
        Ex_BookingPageControllerLwc.BookingWrapper bm = Ex_BookingPageControllerLwc.getBookingWrapper();
        bm.bk.Mode_of_Funding__c = 'Loan';
        bm.bk.Payment_Remarks__c = 'Loan';
        List<Legal_Entity__c> llist =  Ex_BookingPageControllerLwc.getLegalEntityDetails(q.Id);
        
        Ex_BookingPageControllerLwc.termSheetWrapper ts = Ex_BookingPageControllerLwc.getTermSheetWrapper();
        
        Id result = Ex_BookingPageControllerLwc.createBookingRecord(quotationDetails, applicantData, llist, bm, ts);
        
        List<Applicant__c> applicantList = [Select Id, Name, Mobile_Number__c from Applicant__c where Booking__c =: result ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('applicantList::'+applicantList);
        if(!applicantList.isEmpty() && applicantList != null) {
            applicantList[0].Mobile_Number__c = '4477889922';
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
        op.Opportunity_Stage__c = 'Booking Confirmed';
        op.Project__c = pr.Id;
        op.Site_Visit_Count__c =1 ;
        insert op ;
        
        
        Tower__c t = new Tower__c();
        t.Name = 'Test t';
        t.Project__c = pr.id;
        
        Unit__c u = new Unit__c();
        u.Name = 'Test u';
        u.Project__c = pr.id;
        u.Tower__c = u.Id;
        u.Configuration__c = '1 BHK';
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
        pm.No_of_Days__c = 10;
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
            Ex_BookingHanldlerServices.insertWelcomeCallChecklist(testBookingList);  
        
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