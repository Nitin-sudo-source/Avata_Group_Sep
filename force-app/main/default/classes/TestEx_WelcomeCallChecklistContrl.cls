@isTest
public class TestEx_WelcomeCallChecklistContrl {
    
    @isTest
    static void testGetRejectedChecklist() {
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
        
        Payment_Scheme__c paymentScheme = new Payment_Scheme__c(Name = 'Installments',Tower__c = tower.id);
        insert paymentScheme;

        
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
            AV_GST_Percentage__c = 4,
            Quotation_Status__c = 'Approved',
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Amount__c = 100000,
            Charge_Bucket_1_Total_Tax__c = 5000,
            Charge_Bucket_2__c = 'Statutory Charges',
            Charge_Bucket_2_Amount__c = 20000,
            Charge_Bucket_2_Total_Tax__c = 1000,
            Charge_Bucket_3__c = 'Other Charges',
            Charge_Bucket_3_Amount__c = 15000,
            Charge_Bucket_3_Total_Tax__c = 750,
            Car_Park_Required_Count__c = 2            
        );
        insert quotation;
        
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
            CRM_Head__c = testUser.Id,
            Source__c = 'Google'
        );
        insert booking;
        
        Applicant__c testApplicant = new Applicant__c(
            Booking__c = booking.Id,
            Applicant_Number__c = 'Primary Applicant',
            Name = 'John Doe',
            Mobile__c = '1234567890',
            Email__c = 'johndoe@example.com',
            PAN_Number__c = 'ABCDE1234F',
            Aadhar_Number__c = '123456789101'
        );
        insert testApplicant;
        
        Document__c doc = new Document__c(
            Applicant__c = testApplicant.Id,
            Document_Type__c = 'ID Proof',
            Document_View_Link__c = 'https://example.com',
            RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('Applicant_Document').getRecordTypeId()
        );
        insert doc;
        
        List<Receipt__c> receipts = new List<Receipt__c>{
            new Receipt__c(Booking__c = booking.Id, Amount__c = 100000, Receipt_Type__c = 'Flat Cost', Total_Money_Apportioned__c = null),
                new Receipt__c(Booking__c = booking.Id, Amount__c = 2000000, Receipt_Type__c = 'GST', Total_Money_Apportioned__c = 10000)
                };
                    insert receipts;    
        
        Booking_Checklist__c checklistItem22 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Google',
            Action__c = 'Reject'
        );
        insert checklistItem22;
        
        Booking_Checklist__c checklistItem2 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Source of Booking',
            Item__c = 'Booking Source - Offline',
            Action__c = 'Reject'
        );
        insert checklistItem2;
        
        Booking_Checklist__c checklistItem3 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Tower/Building Name and Unit Details',
            Item__c = 'Tower Name - Old Tower',
            Action__c = 'Reject'
        );
        insert checklistItem3;
        
        Booking_Checklist__c checklistItem4 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Tower/Building Name and Unit Details',
            Item__c = 'Unit Name - Old Unit',
            Action__c = 'Reject'
        );
        insert checklistItem4;
        
        Booking_Checklist__c checklistItem5 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Agreement Value - 50000/-',
            Action__c = 'Reject'
        );
        insert checklistItem5;
        
        Booking_Checklist__c checklistItem6 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'SDR - 10000/-',
            Action__c = 'Reject'
        );
        insert checklistItem6;
        
        Booking_Checklist__c checklistItem7 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Other Charges - 5000/-',
            Action__c = 'Reject'
        );
        insert checklistItem7;
        
        Booking_Checklist__c checklistItem8 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'GST on Agreement Value - 2000/-',
            Action__c = 'Reject'
        );
        insert checklistItem8;
        
        Booking_Checklist__c checklistItem9 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Total Agreement Value Bucket - 52000/-',
            Action__c = 'Reject'
        );
        insert checklistItem9;
        
        Booking_Checklist__c checklistItem10 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'GST on Other Charges - 750/-',
            Action__c = 'Reject'
        );
        insert checklistItem10;
        
        Booking_Checklist__c checklistItem11 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Total Other Charges - 5750/-',
            Action__c = 'Reject'
        );
        insert checklistItem11;
        
        Booking_Checklist__c checklistItem12 = new Booking_Checklist__c(
            Booking__c = booking.Id,
            Section__c = 'Agreement Value and Total Cost of the Unit',
            Item__c = 'Total Car Park Amount - 2/-',
            Action__c = 'Reject'
        );
        insert checklistItem12;
        
        List<Booking_Checklist__c> checklistList = [SELECT Id FROM Booking_Checklist__c WHERE Booking__c = :booking.Id];          
       
        
        Test.startTest();
        List<Booking_Checklist__c> result = Ex_WelcomeCallChecklistController.getRejectedChecklist(booking.Id);
        Ex_WelcomeCallChecklistController.updateChecklistAction(checklistList);
        List<Quotation__c> quotationList = Ex_WelcomeCallChecklistController.getQuotationDetails(booking.Id);
        Decimal totalTokenAmount = Ex_WelcomeCallChecklistController.getTokenAmount(booking.Id);
        List<Booking__c> sourceDetails = Ex_WelcomeCallChecklistController.getSourceDetails(booking.Id);
        List<Applicant__c> applicants = Ex_WelcomeCallChecklistController.getApplicants(booking.Id);
        List<Ex_WelcomeCallChecklistController.AttachmentWrapper> attachments =
        Ex_WelcomeCallChecklistController.getApplicantDocuments(testApplicant.Id);        
        Test.stopTest();
        
    }   
    
    @IsTest
    static void testSaveMethod() {
        
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
        
        Payment_Scheme__c paymentScheme = new Payment_Scheme__c(Name = 'Installments',Tower__c = tower.id);
        insert paymentScheme;

        
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
            AV_GST_Percentage__c = 4,
            Quotation_Status__c = 'Approved',
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Amount__c = 100000,
            Charge_Bucket_1_Total_Tax__c = 5000,
            Charge_Bucket_2__c = 'Statutory Charges',
            Charge_Bucket_2_Amount__c = 20000,
            Charge_Bucket_2_Total_Tax__c = 1000,
            Charge_Bucket_3__c = 'Other Charges',
            Charge_Bucket_3_Amount__c = 15000,
            Charge_Bucket_3_Total_Tax__c = 750,
            Car_Park_Required_Count__c = 2            
        );
        insert quotation;
        
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
            CRM_Head__c = testUser.Id,
            Source__c = 'Google'
        );
        insert booking;
        
        List<Booking_Checklist__c> checklistList = new List<Booking_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            checklistList.add(new Booking_Checklist__c(
                Booking__c = booking.Id
            ));
        }
        
        Test.startTest();
        String result = Ex_WelcomeCallChecklistController.save(checklistList); 
        Test.stopTest();
        
    }
}