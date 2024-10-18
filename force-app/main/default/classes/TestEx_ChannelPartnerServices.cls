@isTest
public class TestEx_ChannelPartnerServices {
    @isTest
    Public static void testCpDocument()  {
        Test.startTest();
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        List<Account> accList = new List<Account>();
        
         CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
         //if(cp.RERA_Available__c != null){
         Account cp1 = new Account();
        cp1.Name = 'cp1';
        cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp1.RERA_Available__c = 'No';
        cp1.Phone = '9876543210';
        cp1.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId = SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cp1.RecordTypeId =cpRecordTypeId;
        insert cp1;
         // Insert Project
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        // Insert Project2
        Project__c p2 = new Project__c();
        p2.Name = 'Test Project2';
        insert p2;
        
        cp_Project__c cppPr1 = new cp_Project__c ();
        cppPr1.Channel_Partner__c = cp1.id;
        cppPr1.Project_Name__c = p.id;
        insert cppPr1;
        
         cppPr1.Project_Name__c = p2.id;
        update cppPr1;
        
         Account cp3 = new Account();
        cp3.Name = 'cp3';
        cp3.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp3.RERA_Available__c = 'No';
        cp3.Phone = '9876543210';
        cp3.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId3 = SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cp3.RecordTypeId =cpRecordTypeId3;
        insert cp3;
         
        Account cp = new Account();
        cp.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp.Name='cp';
        cp.RERA_Available__c = 'Yes';
        cp.MahaRERA_Registration_No__c = '1232123ASAS';
        cp.Phone = '9876543210';
        cp.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId2 = SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cp.RecordTypeId =cpRecordTypeId2;
         insert cp;
        
        
        cp.Phone = '9876543211';
        cp.PAN_No__c = 'ABCDE1234A';
        update cp;
        
         Account cp4 = new Account();
        cp4.Name = 'cp4';
        cp4.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp4.RERA_Available__c = 'Yes';
        cp4.MahaRERA_Registration_No__c = '1232123ASAS';
        cp4.Phone = '9876543210';
        cp4.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId4 = SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cp.RecordTypeId =cpRecordTypeId4;
         insert cp4;
        accList.add(cp4);
        
        Document__c doc = new Document__c();
        doc.Document_Type__c = 'RERA Certificate';
        doc.RecordTypeId = SObjectType.Document__c.getRecordTypeInfosByName().get('Applicant Document').getRecordTypeId();
        doc.CP_Account__c = cp4.Id;
		insert doc;
        
        String cpDocList ='[{"Id":"'+ String.valueOf(doc.Id) +'","Name":"D-0242","Document_Type__c":"RERA Certificate","Channel_Partner__c":"' + String.valueOf(cp4.Id) + '","Uploaded__c":true,"isUploadedFalse":true,"isUploadedTrue":false,"filename":"Aadhar.png","base64":"base64"}]';
        Ex_CPDocumentUploadController.getCPDocumentDetails(cpd.id);
        Ex_CPDocumentUploadController.uploadFile(cpDocList);
        Ex_AccountHandlerServices.updateDocument(accList);
        
        
         Test.StopTest();
        
    }    
}