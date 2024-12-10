@IsTest
public class TestEx_WelcomeCallEmailController {

    @TestSetup
    static void setupTestData() {
        // Create a test User to serve as CRM Head
        User crmHead = new User(
            FirstName = 'Test',
            LastName = 'CRM Head',
            Email = 'test.crmhead@example.com',
            Username = 'test.crmhead' + System.currentTimeMillis() + '@example.com',
            Alias = 'crmhead',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert crmHead;

        // Create a related Project__c record
        Project__c project = new Project__c(
            Name = 'Test Project',
            Company_Name__c = 'Test Company',
            Pan_No__c = 'ABCDE1234F',
            Email_ID__c = 'test@company.com',
            Company_Address__c = '123 Test Street',
            Contact_No__c = '9876543210'
        );
        insert project;

        // Create a related Unit__c record
        Unit__c unit = new Unit__c(
            Name = 'Unit 101',
            RERA_Carpet_Area_Sq_Ft__c = 1200,
            Floor__c = 10,
            Inventory_Type__c = 'Residential',
            Configuration_Type__c = '3 BHK'
        );
        insert unit;

        // Create a related Tower__c record
        Tower__c tower = new Tower__c(Name = 'Tower A');
        insert tower;

        // Create a Booking__c record
        Booking__c booking = new Booking__c(
            Primary_Applicant_Name__c = 'John Doe',
            Primary_Applicant_Mobile__c = '9876543210',
            Primary_Applicant_Email__c = 'johndoe@example.com',
            Tower__c = tower.Id,
            Unit__c = unit.Id,
            Project__c = project.Id,
            CRM_Head__c = crmHead.Id,
            Welcome_Call_Done_DateTime__c = DateTime.now()
        );
        insert booking;

        // Create Applicant__c records
        List<Applicant__c> applicants = new List<Applicant__c>{
            new Applicant__c(
                Name = 'Applicant 1',
                Applicant_Number__c = 'Second Applicant',
                Applicant_Title__c = 'Mr.',
                Mobile__c = '1234567890',
                Email__c = 'applicant1@example.com',
                Permanent_Address__c = 'Permanent Address 1',
                Country__c = 'India',
                State__c = 'State 1',
                City__c = 'City 1',
                PIN__c = '111111',
                Booking__c = booking.Id
            ),
            new Applicant__c(
                Name = 'Applicant 2',
                Applicant_Number__c = 'Second Applicant',
                Applicant_Title__c = 'Ms.',
                Mobile__c = '0987654321',
                Email__c = 'applicant2@example.com',
                Permanent_Address__c = 'Permanent Address 2',
                Country__c = 'India',
                State__c = 'State 2',
                City__c = 'City 2',
                PIN__c = '222222',
                Booking__c = booking.Id
            )
        };
        insert applicants;

        
  }

    @IsTest
    static void testControllerInitializationWithBookingId() {
        // Set the page parameters with a valid Booking__c Id
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Test.setCurrentPage(Page.Ex_WelcomeCallPrint); // Replace 'YourVisualforcePage' with the actual VF page
        ApexPages.currentPage().getParameters().put('bId', booking.Id);

        Test.startTest();
        Ex_WelcomeCallEmailController controller = new Ex_WelcomeCallEmailController();
       
        Test.stopTest();

        // Assertions
        System.assertNotEquals(controller.bkList, null, 'Booking list should not be null');
        System.assert(controller.bkList.size() == 1, 'Booking list should contain one record');
        System.assert(controller.unitName != null, 'Unit Name should be populated');
        System.assert(controller.tdsCompanyName != null, 'TDS Company Name should be populated');
        System.assert(controller.ApplicantWrapperList.size() == 2, 'ApplicantWrapperList should have two records');
    }

    @IsTest
    static void testControllerInitializationWithoutBookingId() {
        Test.setCurrentPage(Page.Ex_WelcomeCallPrint); // Replace 'YourVisualforcePage' with the actual VF page
        ApexPages.currentPage().getParameters().remove('bId');

        Test.startTest();
        Ex_WelcomeCallEmailController controller = new Ex_WelcomeCallEmailController();
        Test.stopTest();

        // Assertions
        System.assert(controller.bkList.isEmpty(), 'Booking list should be empty');
        System.assert(controller.ApplicantWrapperList.isEmpty(), 'ApplicantWrapperList should be empty');
    }

    @IsTest
    static void testApplicantWrapperInitialization() {
        Test.startTest();
        Ex_WelcomeCallEmailController.ApplicantWrapper wrapper = new Ex_WelcomeCallEmailController.ApplicantWrapper(
            'Mr.',
            'Secondary Applicant',
            'Applicant Name',
            'Male',
            Date.today(),
            Date.today(),
            'Engineer',
            '1234567890',
            'ABCDE1234F',
            'applicant@example.com',
            'Comm Address',
            'State',
            'Country',
            'City',
            '111111',
            'Perm Address',
            'Perm State',
            'Perm Country',
            'Perm City',
            '222222'
        );
        Test.stopTest();

        // Assertions
        System.assertEquals(wrapper.applicantName, 'Applicant Name', 'Applicant Name should match');
        System.assertEquals(wrapper.applicantPAN, 'ABCDE1234F', 'Applicant PAN should match');
    }
}