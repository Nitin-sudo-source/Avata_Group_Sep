@isTest
public class Test_Ex_DigitalLeadHandler {
    @isTest
    public static void testDigitalHandler(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        List<Digital_Lead__c> dLeadList   = new  List<Digital_Lead__c> ();
        Digital_Lead__c dLead = new Digital_Lead__c();
        dLead.Full_Name__c = 'Test';
        dLead.Mobile__c = '7676565654';
        dLead.Email__c = 'test@g.com';
        dLead.Form_Id__c ='7010T0000002lFAQAY';
        dLead.Platform__c = 'Test';
        dLead.Executed__c = True;
        dLeadList.add(dLead);
        insert dLeadList ;
        
        
        Campaign__c c1 = new Campaign__c();
        c1.Name = 'Parent Campaign';
        c1.Start_Date__c = System.today();
        c1.Approver_Status__c = 'Approved' ;
        c1.Project__c = p.id;
        c1.Campaign_Code__c = dLeadList[0].Form_Id__c;
        insert c1;
        
        Set<Id> dlIds = new Set<Id>();
        for (Digital_Lead__c dl : dLeadList) {
            dlIds.add(dl.Id);
        }
        
        Lead__c l = new Lead__c(
            Mobile__c = dLeadList[0].Mobile__c,
            Email__c = dLeadList[0].Email__c,
            Configuration_Required__c = dLeadList[0].Configuration__c,
            Project__c =  c1.Project__c,
            Campaign_Code__c = dLeadList[0].Form_Id__c,
            Campaign__c = c1.Id,
            Apply_Round_Robin__c = true
        );
        insert l ;
        Ex_DigitalLeadHandlerServices.fbLeadProcess(dlIds);
        
        
    }
    @isTest
    public static void testdataopp(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        CP_Document__c cpdoc = new CP_Document__c();
        cpdoc.Name = 'Yes';
        cpdoc.Document_Required__c = 'Aadhaar Card, PAN Card, Passport, GST Registration Certificate, RERA Certificate';
        insert cpdoc;
        
        CP_Document__c cpdocn = new CP_Document__c();
        cpdocn.Name = 'No';
        cpdocn.Document_Required__c = 'Aadhaar Card, PAN Card, Passport, GST Registration Certificate, RERA Certificate';
        insert cpdocn;
        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '7218415285',  PersonEmail ='lead1@test.in',RecordTypeId = devRecordTypeId);
        insert a;
        system.debug('Test: '+a.PersonContactId);
        
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Opportunity_Stage__c = 'In Follow-up');
        insert op;
        system.debug('Opportunity::'+op);
        op.Site_Visit_Count__c = 10;
        update op;
        
        List<Digital_Lead__c> dLeadList1  = new  List<Digital_Lead__c> ();
        Digital_Lead__c dLead1= new Digital_Lead__c();
        dLead1.Full_Name__c = 'Test';
        dLead1.Mobile__c = '7218415285';
        dLead1.Email__c = 'lead1@test.in';
        dLead1.Form_Id__c ='7010T0000002lFAQAY';
        dLead1.Opportunity__c =op.Id ;
        dLead1.Account__c =a.Id;
        dLead1.Executed__c = True;
        dLeadList1.add(dLead1);
        insert dLeadList1;
        
        dLeadList1[0].Executed__c = false ;
        update dLeadList1 ;
        
        Set<Id> dlId = new Set<Id>();
        for (Digital_Lead__c dl : dLeadList1) {
            dlId.add(dl.Id);
        }
        
        
        Ex_DigitalLeadHandlerServices.fbLeadProcess(dlId);
    }
}