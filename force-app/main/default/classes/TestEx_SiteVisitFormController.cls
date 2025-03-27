//-------------------------------------------//
//  Project: Unmanaged Package 
//  Created By: Priyanshu Agarkar
//  Created Date: 15-09-2024
//-------------------------------------------//
@isTest
public class TestEx_SiteVisitFormController {
    
    
    public static Lead__c getLead(){
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        l1.Email__c = 'customer12321@test.in';
        //l1.Project__c = p.id;
        l1.Lead_Source__c = 'Channel Partner';
        l1.Lead_Sub_Source__c = 'Channel Partner';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Marital_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Alternate_Email__c = 'Test2@gmail.com';
        l1.Mobile__c = '9372082791';
        l1.Age_Group__c = '25 to 30 Years';
        l1.Configuration_Required__c = '1 BHK';
        l1.OwnerId = userInfo.getuserId();
        l1.Project_Type__c = 'Residential';
        l1.Budget_Range__c = 'Budget of 30 to 40 lakhs';
        l1.Current_Resident_Status__c = 'Self-owned';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Industry__c = 'Agriculture';
        l1.Current_Resident_Configuration__c = '1 RK';
        l1.Ethnicity__c = 'Marathi';
        l1.Source_Description__c = 'NA';
        l1.Possession_Timeframe_Required__c = 'RTMI (Ready to Move in)';
        //l1.Channel_Partner__c = acc1.Id;
        l1.Family_Size__c = 'Joint Family';
        l1.Company_Name__c = 'Test Comapny';
        //l1.CP_Project__c = cpp.Id;
        
        return l1;
    }
    
    @isTest
    public static void testLeadFound(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Site_Head__c = sysAdminUser.Id;
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        
        //Account acc1 = new Account();
        //acc1.OwnerId = userInfo.getUserId();
        //acc1.Name = 'test account';
        // acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        //insert acc1;
        
        Channel_Partner__c channelPartner = new Channel_Partner__c();
        channelPartner.Name = 'Test CP';
        channelPartner.Mobile__c = '9372082791';
        insert channelPartner;
        
        CP_Project__c cpp = new CP_Project__c();
        // cpp.Account__c = acc1.Id;
        cpp.Channel_Partner__c = channelPartner.Id;
        cpp.Project__c = p.Id;
        insert cpp; 
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = channelPartner.Id;
        l1.CP_Project__c =  cpp.Id;
        l1.Phone__c = '9372082791';
        l1.Source_of_Finance__c = 'Loan';
        l1.Current_Resident_Configuration__c = '1 RK';
        l1.Walkin_Source__c = 'Channel Partner';
        l1.Walkin_Sub_Source__c = 'Channel Partner';
        l1.Clash__c = true;
        l1.Clash_Details__c = 'Different Lead Source and walkin source';
        insert l1;
        
        
        Team__c t =new Team__c();
        t.Team_Type__c = 'Sales Team';
        t.Project__c = p.Id;
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.id;
        tm.User__c = UserInfo.getUserId();
        tm.Availability__c = false;
        insert tm;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Comments__c = 'Test Fresh Sv';
        insert sv;
        sv.Comments__c = 'Test Revisit';
        sv.Sales_Manager__c = UserInfo.getUserId();
        sv.Phone__c = '5646541658';
        update sv;
        
        test.startTest();
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , null ,null);
        List<String> resultsubmit1 = Ex_SiteVisitFormController.submit(l1.Project__c, l1.Id, null, null, svwrapperResult , true, '', true);
        //List<String> resultsubmit2 = Ex_SiteVisitFormController.submit(null, null, null, null, svwrapperResult , false, '', false);
        String resultsubmit3 = Ex_SiteVisitFormController.getSiteName(sv.Id);
        test.stopTest();
        
    }
    
    @isTest
    public static void testAccountFound(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Site_Head__c = sysAdminUser.Id;
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        //Account acc1 = new Account();
        //acc1.OwnerId = userInfo.getUserId();
        //acc1.Name = 'test account';
       // acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        //insert acc1;
        
        Id personAccountRTId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SObjectType = 'Account' LIMIT 1].Id;
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
       // acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.RecordTypeId = personAccountRTId; 
        acc2.Alternate_Mobile__c = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Occupation__c = 'Employed in Pvt. company  ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Industry__c = 'Agriculture';
        acc2.Current_Resident_Status__c = 'Self-owned';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Family_Size__c = 'Joint Family';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        acc2.State__c = 'Mh';
        acc2.Country__c = 'India';
        acc2.Locality_1__c = 'Pune';
        acc2.Pincode_1__c = '422610';
        acc2.City_1__c = 'Pune';
        acc2.State_1__c = 'Mh';
        acc2.Country_1__c = 'India';
        acc2.Flat_No__c = '4/203';
        insert acc2;
        
        Channel_Partner__c channelPartner = new Channel_Partner__c();
        channelPartner.Name = 'Test CP';
        channelPartner.Mobile__c = '9372082791';
        insert channelPartner;
        
        CP_Project__c cp = new CP_Project__c();
        // cp.Account__c = acc1.Id;
        cp.Channel_Partner__c = channelPartner.Id;
        cp.Project__c = p.Id;
        insert cp;
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.OwnerId = userInfo.getUserId();
        // cp1.Account__c = acc1.Id;
        cp1.Channel_Partner__c = channelPartner.Id;
        cp1.Project__c = p.Id;
        insert cp1;
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = channelPartner.Id;
        l1.CP_Project__c = cp1.Id;
        l1.Walkin_Source__c = 'Channel Partner';
        l1.Walkin_Sub_Source__c = 'Channel Partner';
        insert l1;
        
        Lead__c l2 = TestEx_SiteVisitFormController.getLead();
        l2.Project__c = p.Id;
        l2.Channel_Partner__c = channelPartner.Id;
        l2.CP_Project__c = cp.Id;
        l2.Walkin_Source__c = 'Reference';
        l2.Walkin_Sub_Source__c = 'Reference';
        l2.Referrer_Name__c = sysAdminUser.Id;
        insert l2;
        
        test.startTest();
        Date addDaysToDate = Ex_SiteVisitFormController.addDaysToDate(system.now(), 10.0);
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , null ,acc2.Id);
        List<String> resultsubmit2 = Ex_SiteVisitFormController.submit(l1.Project__c, null, null, acc2.Id, svwrapperResult , false, '', false);
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult2 = Ex_SiteVisitFormController.getSVWrapper(p.Id , l2.Id , null ,acc2.Id);
        List<String> resultsubmit3 = Ex_SiteVisitFormController.submit(l2.Project__c, null, null, acc2.Id, svwrapperResult2 , true, '', true);
        test.stopTest();
        
    }
    
    @isTest
    public static void testLeadAndOpportunityFound(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Site_Head__c = sysAdminUser.Id;
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        //Account acc1 = new Account();
        //acc1.OwnerId = userInfo.getUserId();
        //acc1.Name = 'test account';
        //acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        // insert acc1;
        
        Channel_Partner__c channelPartner = new Channel_Partner__c();
        channelPartner.Name = 'Test CP';
        channelPartner.Mobile__c = '9372082791';
        insert channelPartner;  
        
        CP_Project__c cp = new CP_Project__c();
        // cp.Account__c = acc1.Id;
        cp.Channel_Partner__c = channelPartner.Id;
        cp.Project__c = p.Id;
        insert cp;
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = channelPartner.Id;
        l1.CP_Project__c = cp.Id;
        l1.Project_Type__c ='Residential';
        l1.Clash__c = true;
        l1.Clash_Details__c = 'Different lead source and walkin source';
        l1.Project_Type__c = 'Residential';
        l1.Source_of_Finance__c = 'Loan'; 
        l1.Lead_Stage__c = 'Visit Done';
        l1.Lead_Sub_Stage__c = 'Visit Done';
        insert l1;
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.Alternate_Mobile__c= '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.Alternate_Email__c = 'prasad@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Family_Size__c = 'Nuclear Family without Elders';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company  ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
        acc2.Industry__c = 'Agriculture';
        acc2.Current_Resident_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Family_Size__c = 'Joint Family';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        acc2.State__c = 'Mh';
        acc2.Country__c = 'India';
        insert acc2;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = acc2.Id;
        opp.CP_Project__c = cp.Id;
        opp.Project__c = p.Id;
        opp.Project_Type__c = 'Residential';
        opp.Buying_Purpose__c = 'Both';
        opp.Possession_Timeframe_Required__c = 'RTMI (Ready to Move in)';
        opp.Lead_Source__c = 'Channel Partner';
        opp.Lead_Sub_Source__c = 'Channel Partner';
        opp.Source_Description__c = 'Test Discription';
        opp.Budget__c = 'Budget of 30 to 40 lakhs';
        opp.Presales_Manager__c = UserInfo.getUserId();
        opp.Sourcing_Manager__c = Userinfo.getUserId();
        opp.Configuration_Required__c = '1 BHK';
        opp.First_Site_Visit_Date__c = system.today();
        opp.Channel_Partner__c = channelPartner.Id;
        insert opp;
        
        Opportunity__c newopp =[select id, Account__c, Project__c from Opportunity__c where Id =: opp.Id];
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.OwnerId = userInfo.getUserId();
        // cp1.Account__c = acc1.Id;
        cp1.Channel_Partner__c = channelPartner.Id;
        cp1.Project__c = p.Id;
        insert cp1;
        
        Test.startTest();
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , null ,acc2.Id);
        List<String> resultsubmit2 = Ex_SiteVisitFormController.submit(l1.Project__c, l1.Id, newopp.Id, acc2.Id, svwrapperResult , true, '', true);
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestAccountandOpportunityFound(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Site_Head__c = sysAdminUser.Id;
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        // Account acc = new Account();
        // acc.Name = 'test account';
        // acc.City__c = 'Pune';
        //acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('PersonAccount').getRecordTypeId();
        // insert acc;
        
        // Account acc1 = new Account();
        // acc1.OwnerId = userInfo.getUserId();
        // acc1.Name = 'test account';
        // acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        // insert acc1;
        // 
        
        Channel_Partner__c channelPartner3 = new Channel_Partner__c();
        channelPartner3.Name = 'Test CP';
        channelPartner3.Mobile__c = '9372082791';
        insert channelPartner3; 
        
        CP_Project__c cp = new CP_Project__c();
        // cp.Account__c = acc1.Id;
        cp.Channel_Partner__c = channelPartner3.Id;
        cp.Project__c = p.Id;
        insert cp;
        
        CP_Document__c cd1 = new CP_Document__c();
        cd1.Name = 'Yes';
        cd1.Document_Required__c = 'Pan Card';
        insert cd1;
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.OwnerId = userInfo.getUserId();
        // cp1.Account__c = acc1.Id;
        cp1.Channel_Partner__c = channelPartner3.Id;
        cp1.Project__c = p.Id;
        insert cp1;
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.PersonEmail = 'prasad@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Family_Size__c = 'Nuclear Family without Elders';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company  ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
        acc2.Industry__c = 'Agriculture';
        acc2.Current_Resident_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Family_Size__c = 'Joint Family';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        acc2.State__c = 'Mh';
        acc2.Country__c = 'India';
        acc2.Phone = '5465665574';
        acc2.Flat_No__c = '4/203';
        acc2.City_1__c = 'Thane';
        acc2.Locality_1__c = 'Thane';
        acc2.Country_1__c = 'India';
        acc2.State_1__c = 'MH';
        acc2.Pincode_1__c = '345672';
        insert acc2;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Close_Date__c = system.today().addDays(2);
        opp.Account__c = acc2.Id;
        opp.CP_Project__c = cp1.Id;
        opp.Project__c = p.Id;
        opp.Project_Type__c = 'Residential';
        opp.Buying_Purpose__c = 'Both';
        opp.Possession_Timeframe_Required__c = 'RTMI (Ready to Move in)';
        opp.Lead_Source__c = 'Channel Partner';
        opp.Lead_Sub_Source__c = 'Channel Partner';
        opp.Source_Description__c = 'Test Discription';
        opp.Budget__c = 'Budget of 30 to 40 lakhs';
        opp.Opportunity_Stage__c = 'In Follow-up';
        opp.Presales_Manager__c = UserInfo.getUserId();
        opp.Sourcing_Manager__c = Userinfo.getUserId();
        opp.Configuration_Required__c = '1 BHK';
        opp.First_Site_Visit_Date__c = system.today();
        opp.Walkin_Source__c = 'Channel Partner';
        opp.Walkin_Sub_Source__c = 'Channel Partner';
        opp.Actual_Budget__c = '415984';
        opp.Preferred_Location__c = 'Thane';
        opp.Source_of_Finance__c = 'Loan';
        opp.Channel_Partner__c = channelPartner3.Id;
        insert opp;
        
        Opportunity__c opp2 = new Opportunity__c();
        opp2.Close_Date__c = system.today().addDays(2);
        opp2.Account__c = acc2.Id;
        opp2.CP_Project__c = cp1.Id;
        opp2.Project__c = p.Id;
        opp2.Lead_Source__c = 'Reference';
        opp2.Lead_Sub_Source__c = 'Reference';
        opp2.Walkin_Source__c = 'Channel Partner';
        opp2.Walkin_Sub_Source__c = 'Channel Partner';
        opp2.SV_Count__c = 5;
        insert opp2;
        
        Opportunity__c newopp =[select id, Account__c, Project__c from Opportunity__c where Id =: opp.Id];
        
        Channel_Partner__c channelPartner4 = new Channel_Partner__c();
        channelPartner4.Name = 'Test CP';
        channelPartner4.Mobile__c = '9702536061';
        insert channelPartner4; 
        
        CP_Project__c cp11 = new CP_Project__c();
        cp11.Project__c = p.id;
        //cp11.Account__c = acc1.Id;
        cp11.Channel_Partner__c = channelPartner4.Id;
        insert cp11;
        
        Lead__c ld = new Lead__c();
        ld.Last_Name__c = 'Test';
        ld.Lead_Source__c = 'Channel Partner';
        ld.Channel_Partner__c = channelPartner4.Id;
        ld.CP_Project__c = cp11.Id;
        ld.Project__c = p.Id;
        ld.IsConverted__c = true;
        ld.Mobile__c = '9637576210';
        insert ld;
        
        Channel_Partner__c channelPartner2 = new Channel_Partner__c();
        channelPartner2.Name = 'Test CP';
        channelPartner2.Mobile__c = '8767954821';
        insert channelPartner2; 
        
        Lead__c ld1 = new Lead__c();
        ld1.Last_Name__c = 'Test';
        ld1.Lead_Source__c = 'Channel Partner';
        ld1.Clash__c = true;
        ld1.Clash_Details__c = 'Different';
        ld1.Channel_Partner__c = channelPartner2.Id;
        ld1.CP_Project__c = cp11.Id;
        ld1.Project__c = p.Id;
        ld1.IsConverted__c = false;
        ld1.Mobile__c = '9637576100';
        insert ld1;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Salutation__c = 'Mr.';
        sv.Mobile__c = '9637576100';
        insert sv;
        
        Channel_Partner__c channelPartner = new Channel_Partner__c();
        channelPartner.Name = 'Test CP';
        channelPartner.Mobile__c = '9786523140';
        insert channelPartner;  
        
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c =  channelPartner.Id;
        l1.CP_Project__c = cp.Id;
        insert l1;
        leadList.add(l1);
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '1122334005';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'customer12321@test.in';
        a.Company_Name__c = 'test';
        a.City__c = 'Pune';
        a.State__c = 'MH';
        a.Country__c = 'India';
        a.Pincode__c = '422610';
        a.Locality__c = 'Mundwa Road';
        a.Current_Resident_Status__c = 'Self-owned';
        a.Current_Residence_Configuration__c = '3 BHK';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert a;
        a.Salutation = 'Mr.';
        update a;
        
        test.startTest();
        Map<string,string> selectProject = Ex_SiteVisitFormController.selectProject();
        String projectImage = Ex_SiteVisitFormController.projectImage(p.Id);
        Lead__c getCodeDetails = Ex_SiteVisitFormController.getCodeDetails(p.Id, 'Test');
        Ex_SiteVisitFormController.AccountWrapper acwrapperResult = Ex_SiteVisitFormController.getAccountWrapper();
        Ex_SiteVisitFormController.ChannelPartnerWrapper cpwrapperResult = Ex_SiteVisitFormController.getChannelPartnerWrapper();
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , opp.Id ,acc2.Id);
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult2 = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , opp2.Id ,acc2.Id);
        Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , opp2.Id ,acc2.Id);
        Map<String, List<SObject>> result2 = Ex_SiteVisitFormController.searchForData(l1.Mobile__c,l1.Email__c,l1.Project__c);
        Map<String, List<SObject>> result3 = Ex_SiteVisitFormController.searchForData(ld.Mobile__c,l1.Email__c,l1.Project__c);
        Ex_SiteVisitFormController.submit(p.Id, l1.Id, opp2.Id, acc2.Id, svwrapperResult2, true, '', true);
        List<String> resultsubmit1 = Ex_SiteVisitFormController.submit(newopp.Project__c, newopp.Id, opp.Id, acc2.Id, svwrapperResult , true, '', true);
        
        Map<Id, Account> result = Ex_LeadConversionServices.getLeadIdAccountMap(leadList);  
        Ex_LeadConversionServices.convertLead(leadList);
        Ex_SiteVisitFormController.fetchLookupData('sWildCardText','User',p.Id);
        Ex_SiteVisitFormController.fetchDefaultRecord(opp.Id,'Opportunity__c',p.Id);
        Ex_SiteVisitFormController.getCPProject(channelPartner4.Id,p.Id);
        Ex_SiteVisitFormController.getCPProject(null,null);
        test.stopTest();
    }   
    
    @isTest
    public static void TestLeadandAccountFound(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Site_Head__c = sysAdminUser.Id;
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        // Account acc1 = new Account();
        //acc1.OwnerId = userInfo.getUserId();
        // acc1.Name = 'test account';
        // acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        // insert acc1;
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.Salutation = 'Mr.';
        acc2.FirstName = 'First Name';
        acc2.LastName = 'Last Name';
        acc2.Phone = '8954671230';
        acc2.Flat_No__c = '789';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.PersonEmail = 'prasad@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Family_Size__c = 'Nuclear Family without Elders';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company  ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
        acc2.Industry__c = 'Agriculture';
        acc2.Current_Resident_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Family_Size__c = 'Joint Family';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        acc2.State__c = 'Mh';
        acc2.Country__c = 'India';
        acc2.City_1__c = 'Thane';
        acc2.Locality_1__c = 'Thane';
        acc2.Country_1__c = 'India';
        acc2.State_1__c = 'MH';
        acc2.Pincode_1__c = '345672';
        insert acc2;
        
        Channel_Partner__c channelPartner = new Channel_Partner__c();
        channelPartner.Name = 'Test CP';
        channelPartner.Mobile__c = '9372082791';
        insert channelPartner;  
        
        CP_Project__c cp = new CP_Project__c();
        // cp.Account__c = acc1.Id;
        cp.Channel_Partner__c = channelPartner.Id;
        cp.Project__c = p.Id;
        insert cp;
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.OwnerId = userInfo.getUserId();
        // cp1.Account__c = acc1.Id;
        cp1.Channel_Partner__c = channelPartner.Id;
        cp1.Project__c = p.Id;
        insert cp1;
        
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = channelPartner.Id;
        l1.CP_Project__c = cp1.Id;
        l1.Phone__c = '8965472031';
        l1.Walkin_Source__c = 'Channel Partner';
        l1.Walkin_Sub_Source__c = 'Channel Partner';
        l1.Project_Type__c = 'Residential';
        insert l1;
        
        Lead__c l2 = TestEx_SiteVisitFormController.getLead();
        l2.Project__c = p.Id;
        l2.CP_Project__c = cp1.Id;
        l2.Phone__c = '8965472031';
        l2.Lead_Source__c = 'Reference';
        l2.Lead_Sub_Source__c = 'Reference';
        l2.Referrer_Name__c = 'Test';
        l2.Source_of_Finance__c = 'Loan';
        l2.Clash__c = true;
        l2.Clash_Details__c = 'Test';
        l2.Project_Type__c = 'Residential';
        insert l2;
        
        String apiKey = 'AIzaSyBHwqzLKYNX1Ih3Jhcz2JvM0YIkIsSaaM8';
        
        test.startTest();
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult = Ex_SiteVisitFormController.getSVWrapper(p.Id , l1.Id , null ,acc2.Id);
        List<String> resultsubmit2 = Ex_SiteVisitFormController.submit(l1.Project__c, l1.Id, null, acc2.Id, svwrapperResult , false, '', false);
        
        Ex_SiteVisitFormController.SiteVisitWrapper svwrapperResult2 = Ex_SiteVisitFormController.getSVWrapper(p.Id , l2.Id , null ,acc2.Id);
        List<String> resultsubmit3 = Ex_SiteVisitFormController.submit(l2.Project__c, l2.Id, null, acc2.Id, svwrapperResult2 , false, '', false);
        
        Ex_SiteVisitFormController.getKey(apiKey);
        test.stopTest();
    }
    
    /*
@isTest
//public static void TestGetLocationSuggestions(){
test.startTest();
String getLocationSuggestions = Ex_SiteVisitFormController.getLocationSuggestions('AIzaSyBHwqzLKYNX1Ih3Jhcz2JvM0YIkIsSaaM8', 'Thane');
test.stopTest();
}
*/
    @isTest
    public static void TestcreateChannelPartner() {
        // Create a test project record
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Sourcing_Manager__c = userInfo.getUserId();
        insert p;
        
       //Channel_Partner__c cp = new Channel_Partner__c();
        //cp.Name = 'New CP';
        //cp.Mobile__c = '9372082791';
        //insert cp;
        CP_Document__c cpDoc = new CP_Document__c();
        cpDoc.Name = 'Yes';
        cpDoc.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpDoc;
        
        CP_Document__c cpDoc1 = new CP_Document__c();
        cpDoc1.Name = 'No';
        cpDoc1.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpDoc1;
        
        
                
        // Prepare ChannelPartnerWrapper data
        Ex_SiteVisitFormController.ChannelPartnerWrapper cpWrapper = new Ex_SiteVisitFormController.ChannelPartnerWrapper();
        cpWrapper.cp = new Channel_Partner__c();
        cpWrapper.cp.Name = 'Test Channel Partner';
        cpWrapper.cp.Mobile__c = '1234567860';
        cpWrapper.cp.CP_Firm_Type__c = 'Individual';
        cpWrapper.cp.PAN_No__c = 'ABCDE1234F';
        cpWrapper.cp.RERA_Available__c = 'Yes';
        cpWrapper.cp.MahaRERA_Registration_No__c = 'test234333321';
        
        Test.startTest();        
        /*CP_Project__c createdCPProject;
        createdCPProject = */ 
        Ex_SiteVisitFormController.createChannelPartner(cpWrapper, p.Id);
        Ex_SiteVisitFormController.getChannelPartnerWrapper();
        //Ex_SiteVisitFormController.getLocationSuggestions('test345','test pune');
        
        Test.stopTest();
    }
    
    @isTest
    public static void TestCreateAccount(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Ex_SiteVisitFormController.AccountWrapper acWrapper = new Ex_SiteVisitFormController.AccountWrapper();
        acWrapper.ac = new Account();
        acWrapper.ac.Name = 'Test Account';
        acWrapper.ac.Firm_Name__c = 'Test Firm';
        acWrapper.ac.Phone = '1234567890';
                
        test.startTest();
        // Ex_SiteVisitFormController.createAccount(acWrapper, p.Id);
        test.stopTest();
        
        
    }
    
        @isTest
    static void testGetPlaceInfo() {
        // Mock API response
        String mockResponse = '{ "result": { "name": "Test Place", "formatted_address": "123 Test St" } }';

        Test.startTest();
        // Create a mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200));

        // Call the method
        String result = Ex_SiteVisitFormController.getPlaceInfo('dummyApiKey', 'dummyPlaceId');
        String result1 = Ex_SiteVisitFormController.getLocationSuggestions('dummyApiKey','Test');

        // Assertions
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assert(result.contains('Test Place'), 'Response should contain the place name');

        Test.stopTest();
    }

    @isTest
    static void testGetResponse() {
        // Mock API response
        String mockResponse = '{ "status": "OK" }';

        Test.startTest();
        // Create a mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse, 200));

        // Call the method
        String response = Ex_SiteVisitFormController.getResponse('https://dummyurl.com');

        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assert(response.contains('"status": "OK"'), 'Response should contain status OK');

        Test.stopTest();
    }

    @isTest
    static void testGetKey() {
        // Call method
        String result = Ex_SiteVisitFormController.getKey('dummyApiKey');

        // Assertion
        System.assertEquals('&key=dummyApiKey', result, 'Key format is incorrect');
    }

    // Mock class for HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;

        MockHttpResponse(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }

}