@isTest
public class Ex_CPDocumentUploadControllerTest {

    
    private static Id createTestData() {
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
            RERA_Available__c='No',
            MahaRERA_Registration_No__c = '7878756'
        );
        insert channelPartner;
        
        channelPartner.RERA_Available__c = 'Yes';
        update channelPartner;
        
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
        
        RETURN cpDoc.iD;

    }

    @isTest
    static void testGetCPDocumentDetails() {
        // Create test data
        Id testDocumentId = createTestData();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Call the method
        List<Document__c> result = Ex_CPDocumentUploadController.getCPDocumentDetails(testAccount.Id);
        Test.stopTest();

    }

    @isTest
    static void testUploadFile() {
        // Create test data
        Id testDocumentId = createTestData();

        // Create a JSON payload for the cpDocumentList parameter
        String jsonPayload = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'Id' => testDocumentId,
                'Uploaded__c' => true,
                'base64' => EncodingUtil.base64Encode(Blob.valueOf('Test Content')),
                'filename' => 'TestFile.txt'
            }
        });

        Test.startTest();
        // Call the uploadFile method
        Id resultId = Ex_CPDocumentUploadController.uploadFile(jsonPayload);
        Test.stopTest();

    }

    @isTest
    static void testCreateContentVersion() {
        Test.startTest();
        // Call the createContentVersion method
        ContentVersion cv = Ex_CPDocumentUploadController.createContentVersion(
            EncodingUtil.base64Encode(Blob.valueOf('Sample Content')),
            'SampleFile.txt'
        );
        Test.stopTest();

       
    }

    @isTest
    static void testCreateContentLink() {
        // Create test data
        Id testDocumentId = createTestData();

        // Create a ContentVersion record
        ContentVersion cv = Ex_CPDocumentUploadController.createContentVersion(
            EncodingUtil.base64Encode(Blob.valueOf('Sample Content')),
            'SampleFile.txt'
        );

        Test.startTest();
        // Call the createContentLink method
        ContentDocumentLink cdl = Ex_CPDocumentUploadController.createContentLink(cv.Id, testDocumentId);
        Test.stopTest();

       
    }
}