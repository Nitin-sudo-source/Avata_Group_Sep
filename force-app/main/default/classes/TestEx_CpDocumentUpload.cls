@isTest
public class TestEx_CpDocumentUpload {
    @isTest
    Public static void testCpDocument()  {
        Test.startTest();
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
         CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
        Id cpAccountRecordTypeId = SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        
         //if(cp.RERA_Available__c != null){
        Account cpAccount = new Account();
        cpAccount.Name = 'Test CP1';
        cpAccount.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cpAccount.RERA_Available__c = 'No';
        cpAccount.Phone = '9876543210';
        cpAccount.PAN_No__c = 'ABCDE1234A';
        cpAccount.RecordTypeId =cpAccountRecordTypeId;
        insert cpAccount;
        
         // Insert Project
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        // Insert Project2
        Project__c p2 = new Project__c();
        p2.Name = 'Test Project2';
        insert p2;
        
        cp_Project__c cppPr1 = new cp_Project__c ();
        cppPr1.Channel_Partner__c = cpAccount.id;
        cppPr1.Project_Name__c = p.id;
        insert cppPr1;
        
        cppPr1.Project_Name__c = p2.id;
        update cppPr1;
        
         Account cpAccount1 = new Account();
        cpAccount1.Name = 'Test CP2';
        cpAccount1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cpAccount1.RERA_Available__c = 'No';
        cpAccount1.Phone = '9876543210';
        cpAccount1.PAN_No__c = 'ABCDE1234A';
        cpAccount1.RecordTypeId =cpAccountRecordTypeId;
        insert cpAccount1;
         
        Account cpAccount2 = new Account();
        cpAccount2.Name = 'Test CP3';
        cpAccount2.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cpAccount2.RERA_Available__c = 'Yes';
        cpAccount2.MahaRERA_Registration_No__c = '1232123ASAS';
        cpAccount2.Phone = '9876543210';
        cpAccount2.PAN_No__c = 'ABCDE1234A';
        cpAccount2.RecordTypeId =cpAccountRecordTypeId;
        insert cpAccount2;
        
        
        cpAccount.Phone = '9876543211';
        cpAccount.PAN_No__c = 'ABCDE1234A';
        update cpAccount;
        
        Account cpAccount4 = new Account();
        cpAccount4.Name = 'Test CP4';
        cpAccount4.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cpAccount4.RERA_Available__c = 'Yes';
        cpAccount4.MahaRERA_Registration_No__c = '1232123ASAS';
        cpAccount4.Phone = '9876543210';
        cpAccount4.PAN_No__c = 'ABCDE1234A';
        cpAccount4.RecordTypeId =cpAccountRecordTypeId;
        insert cpAccount4;
        
        Document__c doc = new Document__c();
        doc.Document_Type__c = 'RERA Certificate';
        doc.RecordTypeId = SObjectType.Document__c.getRecordTypeInfosByName().get('Applicant Document').getRecordTypeId();
        doc.CP_Account__c = cpAccount4.Id;
		insert doc;
        
        String cpDocList ='[{"Id":"'+ String.valueOf(doc.Id) +'","Name":"D-0242","Document_Type__c":"RERA Certificate","Channel_Partner__c":"' + String.valueOf(cpAccount4.Id) + '","Uploaded__c":true,"isUploadedFalse":true,"isUploadedTrue":false,"filename":"Aadhar.png","base64":"base64"}]';
        Ex_CPDocumentUploadController.getCPDocumentDetails(cpd.id);
        Ex_CPDocumentUploadController.uploadFile(cpDocList);
        
      
         Test.StopTest();
    }
}