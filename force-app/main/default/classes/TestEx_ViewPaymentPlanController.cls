@isTest
public class TestEx_ViewPaymentPlanController {
    
    @isTest
    public static void testGetBooking() {
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
        
        Test.startTest();
        List<Booking__c> result = Ex_ViewPaymentPlanController.getBooking(booking.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testGetPaymentScheme() {
        
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
        
        Payment_Scheme__c pms = new Payment_Scheme__c(Name = 'Test Payment Scheme');
        insert pms;
        
        // Create Quotation
        Quotation__c quotation = new Quotation__c(
            Unit__c = unit.Id,
            Project__c = project.Id,
            Tower__c = tower.Id,
            AV_GST_Percentage__c = 4,
            Payment_Scheme__c = pms.id
            
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
        pm.Quotation__c = quotation.id;
        pm.Milestone_Name__c='mile 1';
        pm.Is_Raised__c=true;
        pm.Milestone_Type__c='Date Linked';
        insert pm;
        
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
        
        Test.startTest();
        String result = Ex_ViewPaymentPlanController.getPaymentScheme(pms.Id);
        Test.stopTest();       
        
    }
    
    @isTest
    public static void testGetPaymentMilestone() {
        
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
        
        Test.startTest();
        List<Payment_Milestone__c> milestones = Ex_ViewPaymentPlanController.getPaymentMilestone(booking.Id);
        Test.stopTest();
        
    }
    
}