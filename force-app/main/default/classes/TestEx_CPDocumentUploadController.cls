@isTest
public class TestEx_CPDocumentUploadController {
	@isTest
    public static void testMethod1(){
        test.startTest();
        Channel_Partner__c acc = new Channel_Partner__c();
        acc.Name = 'Test Account';
        acc.Mobile__c = '1234567892';
        acc.MahaRERA_Registration_No__c = 'abcdefghijklm';
        acc.PAN_No__c = 'ABCDE6312P';
        insert acc;
        
        Channel_Partner__c acc1 = new Channel_Partner__c();
        acc1.Name = 'Test Account2';
        acc1.Mobile__c = '1234567892';
        acc1.MahaRERA_Registration_No__c = 'abcdefghijkln';
        acc1.PAN_No__c = 'ABCDE2312O';
        insert acc1;
        
         Channel_Partner__c acc2 = new Channel_Partner__c();
        acc2.Name = 'Test Account2';
        acc2.Mobile__c = '1234567802';
        acc2.PAN_No__c = 'ABCDE2312O';
        acc2.MahaRERA_Registration_No__c = 'abcdefghijklo';
        insert acc2;
        
        Channel_Partner__c acc3 = new Channel_Partner__c();
        acc3.Name = 'Test Account2';
        acc3.Mobile__c = '1234567809';
        acc3.PAN_No__c = 'ABCDE2312I';
        acc3.MahaRERA_Registration_No__c = 'abcdefghijklo';
        insert acc3;

        
        Document__c d = new Document__c();
        d.Document_Type__c = 'Pan Card';
        d.Channel_Partner__c = acc.Id;
        d.Uploaded__c = false;
        insert d;
        
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
        String cpDocumentList = '[{"Uploaded__c": true, "Id": "' + d.Id + '", "base64": "' + base64Data + '", "filename": "testfile.txt"}]';
        
        Id resultId = Ex_CPDocumentUploadController.uploadFile(cpDocumentList);
        Document__c updatedDocument = [SELECT Id, Uploaded__c FROM Document__c WHERE Id = :resultId];
        
        ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Title = 'testfile.txt'];
        
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :updatedDocument.Id];
        
        Ex_CPDocumentUploadController.getCPDocumentDetails(d.Channel_Partner__c);
        test.stopTest();
    }
}