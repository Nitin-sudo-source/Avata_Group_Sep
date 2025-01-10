@isTest
public class TestEx_GREUpdateDetails {

    @testSetup
    static void setupTestData() {
        // Query for the existing Channel Partner Record Type
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner' LIMIT 1];
        
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'Aadhaar Card,Pan Card,GST Registration Certificate,RERA Certificate,RERA Competency Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'Aadhaar Card,Pan Card';
        insert cpd2;

        // Create an Account with the Channel Partner Record Type
        Account channelPartner = new Account(
            Name = 'Test Channel Partner',
            RecordTypeId = rt.Id,
            PAN_NO__c='6774',
            RERA_Available__c='Yes',
            MahaRERA_Registration_No__c = '7878756'
        );
        insert channelPartner;
        
        Document__c cpDoc = new Document__c();
        cpDoc.CP_Account__c = channelPartner.Id;
        cpDoc.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByDeveloperName().get('CP_Document').getRecordTypeId();        
        cpDoc.Uploaded__c = false;
        cpDoc.Document_Type__c = 'Pan Card';
        cpDoc.Document_Upload_Required__c='yes';
        insert cpDoc;

       
        
        
        
        
        // Create a Project
        Project__c project = new Project__c(
            Name = 'Test Project'
        );
        insert project;

        // Create a CP_Project__c record
        CP_Project__c cpProject = new CP_Project__c(
            Channel_Partner__c = channelPartner.Id,
            Project_Name__c = project.Id
        );
        insert cpProject;

        // Create a Site Visit record
        Site_Visit__c siteVisit = new Site_Visit__c(
            //Name = 'Test Site Visit',
            Lead_Source__c = 'Channel Partner',
            Channel_Partner__c = channelPartner.Id,
            Project__c = project.Id
        );
        insert siteVisit;
    }

    @isTest
    static void testFetchLookupData_Account() {
        Test.startTest();
        // Test the Account lookup functionality
        List<sObject> accounts = Ex_GREUpdateDetails.fetchLookupData('Test', 'Account');
        Test.stopTest();
    }

    @isTest
    static void testFetchLookupData_User() {
        Test.startTest();
        // Test the User lookup functionality
        List<sObject> users = Ex_GREUpdateDetails.fetchLookupData('Test', 'User');
        Test.stopTest();
    }

    @isTest
    static void testGetSVWrapper() {
        // Query the created Site Visit from setup data
        Site_Visit__c siteVisit = [SELECT Id FROM Site_Visit__c LIMIT 1];

        Test.startTest();
        // Call the method
        Ex_GREUpdateDetails.SVWrapper svWrapper = Ex_GREUpdateDetails.getSVWrapper(siteVisit.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateSiteVisit() {
        // Query the created Site Visit from setup data
        Site_Visit__c siteVisit = [SELECT Id, Lead_Source__c, Channel_Partner__c, Project__c FROM Site_Visit__c LIMIT 1];

        // Create a wrapper
        Ex_GREUpdateDetails.SVWrapper svWrapper = new Ex_GREUpdateDetails.SVWrapper();
        svWrapper.sv = siteVisit;

        Test.startTest();
        // Call the updateSiteVisit method
        Ex_GREUpdateDetails.updateSiteVisit(svWrapper);

        // Verify that the Site Visit is updated
        Site_Visit__c updatedSV = [SELECT Id, CP_Project__c FROM Site_Visit__c WHERE Id = :siteVisit.Id];
        Test.stopTest();
    }
}