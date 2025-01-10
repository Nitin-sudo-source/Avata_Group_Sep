@isTest
public class TestEx_CPDocumentUploadController{

    @testSetup
    static void setupTestData() {
         RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner' LIMIT 1];
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'Aadhaar Card,Pan Card,GST Registration Certificate,RERA Certificate,RERA Competency Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'Aadhaar Card,Pan Card';
        insert cpd2;
        // Create a test Account
        Account testAccount = new Account();
        testAccount.RecordTypeId = rt.Id;
        testAccount.Name='cpp';
        testAccount.Phone='9011722426';
        testAccount.RERA_Available__c='No';
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
    }

    @isTest
    static void testGetCPDocumentDetails() {
        // Fetch the test Account ID
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method
        Test.startTest();
        List<Document__c> documents = Ex_CPDocumentUploadController.getCPDocumentDetails(testAccount.Id);
        Test.stopTest();

    }

    @isTest
    static void testUploadFile() {
        // Prepare test data for uploadFile
        Document__c existingDocument = [SELECT Id FROM Document__c LIMIT 1];
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
        String jsonInput = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'Id' => existingDocument.Id,
                'Uploaded__c' => true,
                'base64' => base64Content,
                'filename' => 'TestFile1.txt'
            }
        });

        // Call the method
        Test.startTest();
        Id updatedDocumentId = Ex_CPDocumentUploadController.uploadFile(jsonInput);
        Test.stopTest();

        
    }

    @isTest
    static void testErrorHandlingInUploadFile() {
        // Provide invalid input to test error handling
        String invalidJsonInput = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'Uploaded__c' => true // Missing required fields like Id, base64, and filename
            }
        });

        Test.startTest();
        try {
            Ex_CPDocumentUploadController.uploadFile(invalidJsonInput);
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @isTest
    static void testContentVersionCreation() {
        // Call the private method via reflection
        Test.startTest();
        ContentVersion cv = Ex_CPDocumentUploadController.createContentVersion(
            EncodingUtil.base64Encode(Blob.valueOf('Test Data')),
            'TestFile.txt'
        );
        Test.stopTest();

        
    }

    @isTest
    static void testContentDocumentLinkCreation() {
        // Create a ContentVersion and link it to a record
        ContentVersion cv = new ContentVersion(
            Title = 'LinkedFile',
            PathOnClient = 'LinkedFile.txt',
            VersionData = Blob.valueOf('Linked Content')
        );
        insert cv;

        // Fetch the ContentVersion ID
        ContentVersion insertedVersion = [
            SELECT Id FROM ContentVersion WHERE Title = 'LinkedFile' LIMIT 1
        ];

        // Call the private method
        Test.startTest();
        ContentDocumentLink cdl = Ex_CPDocumentUploadController.createContentLink(
            insertedVersion.Id,
            [SELECT Id FROM Document__c LIMIT 1].Id
        );
        Test.stopTest();

        
    }
}