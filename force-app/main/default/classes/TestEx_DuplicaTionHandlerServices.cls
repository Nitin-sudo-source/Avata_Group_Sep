@isTest
public class TestEx_DuplicaTionHandlerServices {
    
    @isTest
    public static Project__c createProject()  {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        return p;
    } 
    
    
    @isTest
    public static void leadMobileDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        List<Lead__c> leadList2 = new List<Lead__c>();
        Project__c p = createProject();
        
        Team__c t = new Team__c();
        t.Team_Type__c = 'Presales Team';
        t.Project__c = p.Id;
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.id;
        tm.User__c = UserInfo.getUserId();
        tm.Availability__c = true;
        insert tm;
        
        
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Start_Date__c = system.today();
        //   c2.End_Date__c = system.today().addDays(4);
        //     c2.Status__c = 'Approved';
        c2.Actual_Leads__c = 0;
        c2.Actual_Enquiries__c= 0;
        c2.Actual_Visits__c = 2;
        c2.Actual_Bookings__c = 0;
        c2.Planned_Leads__c = 20;
        c2.Planned_Visits__c = 10;
        c2.Planned_Cost__c = 100;
        
        insert c2;
        c2.Campaign_Code__c = c2.Id;
        update c2;
        
        
        Lead__c l1 = new Lead__c();
        //   l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Lead 1';
        l1.Campaign__c = c2.id;
        l1.Apply_Round_Robin__c = true;
        l1.Lead_Stage__c = 'Incoming';
        // l1.Lead_Sub_stage__c = 'Not Answering';
        l1.Mobile__c = '1122334455';
        l1.Alternate_Mobile__c = '7887755663';
        l1.OwnerId = tm.User__c;
        l1.Project__c = p.Id;
        //  l1.Alternate_Email__c = 'Test@gmail.com';
        l1.Email__c = 'Test2@gmail.com';
        l1.Presales_Call_Count__c = 1;
        l1.IsConverted__c = true ;
        insert l1;
        
        l1.Campaign__c = c2.id;
        l1.Apply_Round_Robin__c = true;
        // l1.Alternate_Email__c = 'Test@gmail.com';
        l1.Email__c = 'Test2@gmail.com';
        l1.Mobile__c = '1122334455';
        l1.Alternate_Mobile__c = '7887755663';
        
        update l1;
        leadList.add(l1);
        String recordId = l1.Id;
        
        Lead__c l11 = new Lead__c( First_Name__c = 'Test',Last_Name__c = 'test2', ownerId = userInfo.getUserId(),Campaign__c = c2.id , Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id);
        insert l11;
        leadList2.add(l11);
        Lead__c l2 = new Lead__c(First_Name__c = 'Test',Last_Name__c = 'test2' , Campaign__c = c2.id ,  Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id,ownerId = userInfo.getUserId());
        leadList.add(l2);
        Lead__c l3= new Lead__c(First_Name__c = 'Test',Last_Name__c = 'test2' , Campaign__c = c2.id ,  Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id,ownerId = userInfo.getUserId());
        leadList.add(l3);
        test.startTest();
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
        // Ex_LeadConversionServices.convertLead(leadList2);
        // Ex_LeadConversionPopup.isChecked(leadList[0].Id);
        test.stopTest();
        
    }
    @isTest
    public static void ConvertLeadTest(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Start_Date__c = system.today();
        //   c2.End_Date__c = system.today().addDays(4);
        //     c2.Status__c = 'Approved';
        c2.Actual_Leads__c = 0;
        c2.Actual_Enquiries__c= 0;
        c2.Actual_Visits__c = 2;
        c2.Actual_Bookings__c = 0;
        c2.Planned_Leads__c = 20;
        c2.Planned_Visits__c = 10;
        c2.Planned_Cost__c = 100;
        
        insert c2;
        c2.Campaign_Code__c = c2.Id;
        update c2;
        Lead__c l11 = new Lead__c( 
            Salutation__c ='Mr.',
            First_Name__c = 'Test',
            Last_Name__c = 'test2',
            ownerId = userInfo.getUserId(),
            Campaign__c = c2.id ,
            Apply_Round_Robin__c = true, 
            Lead_Stage__c = 'Incoming',
            Mobile__c = '1122334455',
            Project__c = p.Id, 
            Lead_Source__c='Google',
            Lead_Sub_Source__c = 'Google Search');
        insert l11;
        
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a1 = new Account( Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455' ,RecordTypeId  = RecTypeId);
        insert a1;
        
        List<Lead__c>leadList = [ Select Id , name, Salutation__c, First_Name__c,Last_Name__c , Email__c,Current_Resident_Status__c,
                                 ownerId,Campaign__c , Apply_Round_Robin__c , Lead_Stage__c, Mobile__c ,Alternate_Mobile__c, Project__c,Alternate_Email__c,Current_Residence_Configuration__c,
                                 Designation__c,Ethnicity__c,Gender__c,Marital_Status__c,Occupation__c,Company_Name__c,Possession_Timeframe__c,
                                 Lead_Source__c,Source_Description__c,Budget_Range__c,Buying_Purpose__c,Configuration_Required__c,
                                 Presales_Next_Follow_up_Date__c,Presales_Call_Count__c,Presales_Last_Call_Date__c,Presales_Proposed_Visit_Date__c,
                                 Presales_Last_Call_Comment__c,Presales_Call_Comment_History__c,Is_Serviced__c,Campaign_Code__c,Lead_Sub_Source__c
                                 
                                 
                                 From Lead__C where Id =:l11.id];
        
        
        Test.startTest();
        //Ex_LeadConversionServices.convertLead(leadList);
        Test.stopTest();
    }
    
    @isTest
    public static void leadEmailDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1',  Apply_Round_Robin__c = true,Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Email__c = 'lead@test.in', Project__c = p.Id);
        insert l1;
        Lead__c l2 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 2', Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334456', Email__c = 'lead@test.in', Project__c = p.Id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    @isTest
    public static void leadPhoneDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1',  Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Email__c = 'lead@test.in', Alternate_Mobile__c = '6677889900', Project__c = p.Id);
        insert l1;
        Lead__c l2 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 2', Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334456', Email__c = 'lead1@test.in', Alternate_Mobile__c = '6677889900', Project__c = p.Id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void leadAlternateEmailDuplicate() {
        List<Lead__c> leadList = new List<Lead__c>();
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Apply_Round_Robin__c = true,Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Email__c = 'lead1@test.in', Alternate_Email__c = 'lead@test.in', Project__c = p.Id);
        insert l1;
        Lead__c l2 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 2', Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334456', Email__c = 'lead2@test.in', Alternate_Email__c = 'lead@test.in', Project__c = p.Id);
        leadList.add(l2);
        
        Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheck(leadList);
    }
    
    @isTest
    public static void accountMobileDuplicate() {
        List<Account> accList = new List<Account>();
        List<Lead__c> leadList = new List<Lead__c>();
        Project__c p = createProject();
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a1 = new Account( Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455' ,RecordTypeId  = RecTypeId);
        insert a1;
        Account a11 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455' , RecordTypeId = RecTypeId );
        insert a11;
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334455' ,RecordTypeId = RecTypeId );
        accList.add(a2);
        
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        // duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
        
    }
    @isTest
    public static void testOpportunityDuplicateCheck() {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        
        Project__c p = new Project__c();
        p.Name = 'test Project';
        insert p;
        
        Project__c p1 = new Project__c();
        p1.Name = 'test Project';
        insert p1;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a2.id);
        insert o1;
        Opportunity__c o2 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a2.id);
        insert o2; 
        Opportunity__c o3 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Project__c = p1.Id,Account__c = a2.id);
        update o2; 
    }   
    
    
    
    
    @isTest
    public static void accountEmailDuplicate() {
        List<Account> accList = new List<Account>();
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a1 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead@test.in' ,RecordTypeId  = RecTypeId);
        insert a1;
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead@test.in' ,RecordTypeId  = RecTypeId);
        accList.add(a2);
        
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
    }
    @isTest
    public static void accountPhoneDuplicate() {
        List<Account> accList = new List<Account>();
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a1 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead@test.in', Phone = '6677889900',RecordTypeId  = RecTypeId);
        insert a1;
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead1@test.in', Phone = '6677889900',RecordTypeId  = RecTypeId);
        accList.add(a2);
        
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
    }
    @isTest
    public static void accountAlternateEmailDuplicate() {
        List<Account> accList = new List<Account>();
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a1 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455', PersonEmail = 'lead1@test.in', Alternate_Email__c = 'lead@test.in' , RecordTypeId = RecTypeId);
        insert a1;
        a1.Phone = '6677889900';
        update a1;
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        accList.add(a2);
        
        Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<Ex_DuplicationHandlerServices.duplicateWrapper>>();
        duplicateWrapperMap = Ex_DuplicationHandlerServices.duplicationCheckAcccount(accList);
    }
    
    @isTest
    public static void  OpportunityEmailDuplicate() {
        Project__c p = createProject();
        
        Project__c p1 = new Project__c();
        p1.Name = 'Test Project';
        insert p1;
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project camp 1';
        c2.Campaign_Code__c = '12345';
        c2.Start_Date__c = system.today();
        c2.Project__c = p.Id;
        c2.Actual_Visits__c = 0 ;
        
        insert c2;
        // c2.Approver_Status__c = 'Approved';
        update c2;
        
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Lead__c l11 = new Lead__c( First_Name__c = 'Test',Last_Name__c = 'test2', ownerId = userInfo.getUserId(),Campaign__c = c2.id , Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id);
        insert l11;
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project camp 2';
        c3.Campaign_Code__c = '123456';
        c3.Start_Date__c = system.today();
        c3.Project__c = p.Id;
        
        insert c3;
        // c2.Approver_Status__c = 'Approved';
        update c3;
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a2 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Account a3 = new Account(Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334466', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'leady@test.in',RecordTypeId = RecTypeId);
        insert a3;
        
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', SV_Count__c = 1, Campaign__c = c2.id, Project__c = p.Id,Account__c = a2.id);
        insert o1;
        oppList.add(o1);
        
        Opportunity__c o2 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', SV_Count__c = 1, Campaign__c = c3.id, Project__c = p.Id,Account__c = a3.id);
        insert o2;
        oppList.add(o2);
        
        o2.Account__c = a2.id;
        o2.Project__c = p1.Id ;
        o2.Campaign__c = c2.id;
        update o2 ;
        
        /* Site_Visit__c sv = new Site_Visit__c();
sv.Site_Visit_Count__c = 2 ;
sv.Opportunity__c = o1.Id ;
//   sv.Comment__c = 'Test' ;
insert sv ;*/
        
        
        Campaign_Performance__c camP = new Campaign_Performance__c();
        camP.Campaign__c = l11.Campaign__c ;
        camP.date__c = l11.Created_Date__c ;
        insert camP;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
        t1.Subject = 'CP Call';
        // t1.WhatId = cp.Id;
        t1.Campaign__c = c2.Id ;
        t1.Status = 'Open';
        t1.Priority = 'Normal';
        t1.Call_Status__c = 'Answered';
        t1.Stage__c = 'Lost';
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
        
        Campaign_Performance__c camP1 = new Campaign_Performance__c();
        camP1.Campaign__c = t1.Campaign__c ;
        camP1.date__c = t1.Created_Date__c ;
        insert camP1;
        
        Ex_CampaignBatchClass cont = new Ex_CampaignBatchClass();
        Database.executeBatch(cont,200);
        String jobId = System.schedule('Test Ex_CampaignBatchClass', 
                                       '0 0 0 1 1 ? 2099', 
                                       new Ex_CampaignBatchClass());
        
        Map<Opportunity__c, List<Opportunity__c>> result = new Map<Opportunity__c, List<Opportunity__c>>();
        result = Ex_DuplicationHandlerServices.duplicationCheckOpportunity(oppList);
        
    }
    
    @isTest
    public static void OpportunityPhoneDuplicate() {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        Project__c p = createProject();
        
        List<Lead__c> leadList = new List<Lead__c>();
        
        
        Lead__c l2 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 2', Apply_Round_Robin__c = true, Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Email__c = 'lead2@test.in', Alternate_Email__c = 'lead@test.in', Project__c = p.Id);
        leadList.add(l2);
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a2 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334456', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead@test.in',RecordTypeId = RecTypeId);
        insert a2;
        Account a3 = new Account(Salutation = 'Mr.' , FirstName = 'Test', LastName = 'Lead 2', PersonMobilePhone = '1122334458', PersonEmail = 'lead2@test.in', Alternate_Email__c = 'lead1@test.in',RecordTypeId = RecTypeId);
        insert a3;
        
        Opportunity__c o1 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a2.id);
        insert o1;
        
        Opportunity__c o2 = new Opportunity__c(Name = 'Test1', Stage__c = 'In Follow-up', Project__c = p.Id,Account__c = a3.id);
        oppList.add(o2);
        
        Map<Opportunity__c, List<Opportunity__c>> result = new Map<Opportunity__c, List<Opportunity__c>>();
        result = Ex_DuplicationHandlerServices.duplicationCheckOpportunity(oppList);
        
    }
    
    @isTest
    public static void testBeforeUpdateOpportunity() {
        // Create test data for beforeUpdate scenario
        Map<Id, Opportunity__c> oldMap = new Map<Id, Opportunity__c>();
        Map<Id, Opportunity__c> newMap = new Map<Id, Opportunity__c>();
        // Add test data to oldMap and newMap
        
        // Call the method
        Test.startTest();
        //Ex_OpportunityTriggerHandler.beforeUpdate(oldMap, newMap);
        Test.stopTest();
        
        // Add your assertions here based on the expected behavior of the method
        // For example:
        // System.assertEquals(expectedValue, actualValue);
    }
    
    @isTest
    public static void testCPLeadDup() {
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.CRM_Head__c = UserInfo.getUserId();
        insert p;
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
        Account cpacc = new Account();
        cpacc.OwnerId = userInfo.getUserId();
        cpacc.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc.Phone = '9011722426';
        cpacc.Email__c = 'prasad.alamwar@test.com';
        cpacc.PAN_No__c = '676747';
        cpacc.MahaRERA_Registration_No__c = '112233';
        cpacc.RERA_Available__c = 'Yes';
        insert cpacc;
        
        Account cpacc1 = new Account();
        cpacc1.OwnerId = userInfo.getUserId();
        cpacc1.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc1.Phone = '9011722426';
        cpacc1.Email__c = 'prasad.alamwar@test.com';
        cpacc1.PAN_No__c = '676747';
        cpacc1.MahaRERA_Registration_No__c = '112233';
        
        cpacc1.RERA_Available__c = 'Yes';
        insert cpacc1;
        
        List<Account> accList = new List<Account>();
        accList.add(cpacc1);
        accList.add(cpacc);
        
        
        CP_Lead__c cpl1=new CP_Lead__c();
        cpl1.Channel_Partner_Name__c = cpacc.Id;
        cpl1.Project__c = p.Id;
        cpl1.Mobile__c = '8889898111';
        cpl1.Phone__c = '8887776766';
        cpl1.Email__c = 'nitinc77@gmail.com';
        cpl1.Alternate_Email__c = 'nitinc77@gmail.com';
        // cpl.CP_Project__c = cpp.id;
        insert cpl1;
        
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.Channel_Partner_Name__c = cpacc.Id;
        cpl.Project__c = p.Id;
        cpl.Mobile__c = '8889898111';
        cpl.Phone__c = '8887776766';
        cpl.Email__c = 'nitinc77@gmail.com';
        cpl.Alternate_Email__c = 'nitinc77@gmail.com';
        insert cpl;
        List<CP_Lead__c> cpList = new List<CP_Lead__c>();
        Test.startTest();
        cpList.add(cpl);
        cpList.add(cpl1);
        Ex_DuplicationHandlerServices.duplicationCheckCPAcccount(accList);
        Ex_DuplicationHandlerServices.duplicationCheckCPLead(cpList);
        Test.stopTest();
    }
    
    
    
    
    
    
}