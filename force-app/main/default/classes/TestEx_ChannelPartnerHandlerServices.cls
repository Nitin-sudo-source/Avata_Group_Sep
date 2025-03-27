@isTest
public class TestEx_ChannelPartnerHandlerServices {

   @isTest
    static void testCPduplicationCheck(){
        Test.startTest();
        CP_Document__c cpDoc = new CP_Document__c();
        cpDoc.Name = 'Yes';
        cpDoc.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpDoc;
        
        CP_Document__c cpDoc1 = new CP_Document__c();
        cpDoc1.Name = 'No';
        cpDoc1.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpDoc1;
        
        // Create test data
        Channel_Partner__c cp1 = new Channel_Partner__c(
            Name = 'CP1',
            Mobile__c = '1234567891',
            MahaRERA_Registration_No__c = 'MH123',
            PAN_No__c = 'ABCDE1234F',
            RERA_Available__c = 'Yes'
        );
        insert cp1;
        
        Channel_Partner__c cp2 = new Channel_Partner__c(
            Name = 'CP2',
            Mobile__c = '1234567890', 
            MahaRERA_Registration_No__c = 'MH124',
            PAN_No__c = 'ABCDE1234E'
           
        );
        insert cp2;
        
        Channel_Partner__c cp3 = new Channel_Partner__c(
            Name = 'CP3',
            Mobile__c = '0987654321',
            MahaRERA_Registration_No__c = 'MH125',
            PAN_No__c = 'FGHIJ5678K'
        );
        insert cp3;
            
        cp3.Mobile__c = '0987654328';
        update cp3;
        
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
        cppPr1.Project__c = p.id;
        insert cppPr1;
        
         cppPr1.Project__c = p2.id;
        update cppPr1;
        
        cp_Project__c cppPr2 = new cp_Project__c ();
        
        cppPr2.Channel_Partner__c = cp1.id;
        cppPr2.Project__c = p.id;
        insert cppPr2;
        
         cppPr2.Project__c = p2.id;
        update cppPr2;
        
        
        Test.stopTest();
    }
}