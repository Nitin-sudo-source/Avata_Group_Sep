@isTest
public class testEx_SiteVisitForm {
    @isTest
    public static void testselectProject(){
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Replace 'Standard User' with the desired profile name
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com', // Unique username
            CommunityNickname = 'TestUser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', // Adjust as needed
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        insert testUser;
        
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Project_Logo__c = 'Test image';
        p.SV_OTP_Template_ID__c = 'TEETTETETE';
        p.SMS_Company_Name__c = 'Satyam Developer';
        insert p;
        
        CP_Document__c cd = new CP_Document__c();
        cd.Name = 'Yes';
        cd.Document_Required__c = 'Pan Card';
        insert cd;
        
        Account acc = new Account();
        acc.Name = 'test account';
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();
        insert acc;
        
        CP_Project__c cp = new CP_Project__c();
        cp.CP_Account__c = acc.Id;
        cp.Project__c = p.Id;
        insert cp;
        
        CP_Document__c cd1 = new CP_Document__c();
        cd1.Name = 'Yes';
        cd1.Document_Required__c = 'Pan Card';
        insert cd1;
        
        Account acc1 = new Account();
        acc1.OwnerId = userInfo.getUserId();
        acc1.Name = 'test account';
        acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();
        insert acc1;
        
        CP_Project__c cp1 = new CP_Project__c();
        cp1.OwnerId = userInfo.getUserId();
        cp1.CP_Account__c = acc1.Id;
        cp1.Project__c = p.Id;
        insert cp1;
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576100';
        insert acc2;
        
        CP_Project__c cp11 = new CP_Project__c();
        cp11.Project__c = p.id;
        cp11.CP_Account__c = acc1.Id;
        cp11.CP_Accounts__c = 'Test';
        insert cp11;
        
        
        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = acc2.Id;
        opp.Project__c = p.Id;
        opp.Project_Type__c = 'Residential';
        opp.Budget__c = 'Budget less than 20 lakhs';
        opp.Buying_Purpose__c = 'Both';
        opp.Possession_Timeframe_Required__c = 'RTMI (Ready to Move in)';
        opp.Alternate_Email_Id__c = 'teste123@gmail.com';
        opp.Channel_Partner__c = acc1.Id;
        opp.CP_Project__c = cp11.Id;
        insert opp;
        
        opp.Is_Opp_Share__c = true;
        opp.Sourcing_Manager__c = testUser.Id;
        update opp;
        
        
        Lead__c ld = new Lead__c();
        ld.Last_Name__c = 'Test';
        ld.Lead_Source__c = 'Channel Partner';
        ld.Channel_Partner__c = acc1.Id;
        ld.CP_Project__c = cp11.Id;
        ld.Project__c = p.Id;
        ld.Configuration_required__c = '2 BHK';
        ld.IsConverted__c = true;
        ld.Mobile__c = '9637576100';
        insert ld;
        
        Lead__c ld1 = new Lead__c();
        ld1.Last_Name__c = 'Test';
        ld1.Lead_Source__c = 'Channel Partner';
        ld1.Channel_Partner__c = acc1.Id;
        ld1.CP_Project__c = cp11.Id;
        ld1.Project__c = p.Id;
        ld1.Configuration_required__c = '2 BHK';
        ld1.IsConverted__c = false;
        ld1.Mobile__c = '9637576100';
        insert ld1;
        
        Visit_Pre_Registration__c vp = new Visit_Pre_Registration__c();
        vp.Pre_registration_OTP__c = '1234';
        vp.Project__c = p.Id;
        vp.CP_Project__c = cp1.Id;
        vp.Customer_Name__c = 'Prasad Alamwar';
        vp.Mobile__c = '9637576100';
        vp.Budget__c = 'Budget of 40 to 50 lakhs';
        vp.Configuration_required__c = '2 BHK';
        vp.SPOC__c = 'Prasad';
        vp.Status__c = 'Valid';
        insert vp;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Salutation__c = 'Mr.';
        sv.Mobile__c = '9637576100';
        sv.Project_Name__c = p.Id;
        sv.Lead_Source__c = 'Channel Partner';
        sv.CP_Project__c = cp1.Id;
        sv.Sourcing_Manager__c = testUser.Id;
        sv.Opportunity__c = opp.Id;
        
        insert sv;
        sv.CP_Project__c = cp11.Id;
        sv.Sourcing_Manager__c = UserInfo.getUserId();
        sv.Comment__c = 'Test';
        sv.Sales_Manager__c = UserInfo.getUserId();
        
        update sv;
        
         Site_Visit__c sv1 = new Site_Visit__c();
        sv1.Salutation__c = 'Mr.';
        sv1.Mobile__c = '9637576100';
        sv1.Project_Name__c = p.Id;
        sv1.Lead_Source__c = 'Channel Partner';
        sv1.CP_Project__c = cp1.Id;
        sv1.Sourcing_Manager__c = cp1.OwnerId;
        
        
        insert sv1;
        sv1.Is_Share__c = true;
        
        update sv1;
        
        
        Id ldId = ld.Id;
        Id opId = opp.Id;
        Id acId = acc2.Id;
        String cp0 = ld.Channel_Partner__c;
        String CPProjectOwner = cp1.OwnerId;
        String Mobile = '9637576100';
        String project = p.Id;
        String email = 'prasad.alamwar@exceller.tech';
        String mastersource = 'Google';
        String fname = 'Prasad';
        String lname = 'Alamwar';
        String salutation = 'Mr.';
        String configuration = '2 BHK';
        String country = 'India';
        String cityType = 'Mumbai';
        String cityName = 'Thane';
        String locality = 'Central';
        String locDetails = 'Bhandup';
        String rrName = 'Prasad Test';
        Boolean status = true;
        String otp = '1234';
        
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = new Lead__c();
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        // l1.Mobile__c = '1122334005';
        l1.Email__c = 'customer12321@test.in';
        l1.Project__c = p.id;
        l1.Age_Group__c = '25 to 30 Years';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Marital_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Family_Size__c = 'Joint Family';
        l1.Industry__c = 'Consulting';
        l1.Configuration_Required__c = '2 BHK';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Alternate_Email_Id__c = 'Test2@gmail.com';
        l1.Mobile__c = '9637576100';
        l1.OwnerId = userInfo.getuserId();
        //l1.IsConverted__c = false;
        insert l1;
        leadList.add(l1);
        
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '1122334005';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'customer12321@test.in';
        a.Company_Name__c = 'test';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert a;
        a.Salutation = 'Mr.';
        update a;
        
        
        // leadIdAccountMap.put(l1.Id, a);
        
        
        
        test.startTest();
        Ex_SiteVisitForm.selectProject();
        Ex_SiteVisitForm.getConfigPicklistValues();
        Ex_SiteVisitForm.projectImage(p.Id);
        Ex_SiteVisitForm.getChannelPartners(p.Id,'test');
        Ex_SiteVisitForm.getCPProjectOwner(acc1.Id, p.Id);
        Ex_SiteVisitForm.checkCPData('1234',p.Id);
        Ex_SiteVisitForm.searchForData('9637576100',p.Id);
        Ex_SiteVisitForm.createSMS(Mobile, p.Id);
        /* Ex_SiteVisitForm.submits(ldId,opId,acId,cp0,CPProjectOwner,Mobile,project,email,mastersource,lname,fname,salutation,configuration,status,otp,
country,cityType,cityName,locality,locDetails,rrName,false);*/
        Ex_SiteVisitForm.submits(l1.Id, opId, acId, cp0, CPProjectOwner, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        Ex_SiteVisitForm.submits(l1.Id, null, null, cp0, CPProjectOwner, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        Ex_SiteVisitForm.submits(ld.Id, opp.Id, acc2.Id, cp0, CPProjectOwner, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        Ex_SiteVisitForm.submits(ld1.Id, null, acc2.Id, cp0, CPProjectOwner, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        Ex_SiteVisitForm.submits(null, null, null, cp0, CPProjectOwner, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        
        Ex_SiteVisitForm.getSiteName(sv.Id);
        
        Map<Id, Account> result = Ex_LeadConversionServices.getLeadIdAccountMap(leadList);  
        Ex_LeadConversionServices.convertLead(leadList);
        Set<Id> newSet = new Set<Id>();
        newSet.add(sv.Id);
        
     Ex_SiteVisitHandlerServices.updateSiteVisitDetailsOnCPProject(newSet);
        
        
        
        test.stopTest();
    }
    
    @isTest
    public static void accFoundLeadFound(){
        test.startTest();
        Project__c p = new Project__c();
        p.Name = 'Test Project1';
        p.Project_Logo__c = 'Test image1';
        insert p;
        
        String Mobile = '9637576100';
        String project = p.Id;
        String email = 'prasad.alamwar@exceller.tech';
        String mastersource = 'Google';
        String fname = 'Test';
        String lname = 'Test';
        String salutation = 'Mr.';
        String configuration = '2 BHK';
        String country = 'India';
        String cityType = 'Mumbai';
        String cityName = 'Thane';
        String locality = 'Central';
        String locDetails = 'Bhandup';
        String rrName = 'Prasad Test';
        Boolean status = true;
        String otp = '1234';
                
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9090101105';
        insert acc2;
        
        
        Lead__c l1 = new Lead__c();
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        // l1.Mobile__c = '1122334005';
        l1.Email__c = 'customer12321@test.in';
        l1.Project__c = p.id;
        l1.Age_Group__c = '25 to 30 Years';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Marital_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Family_Size__c = 'Joint Family';
        l1.Industry__c = 'Consulting';
        l1.Configuration_Required__c = '2 BHK';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Alternate_Email_Id__c = 'Test2@gmail.com';
        l1.Mobile__c = '9090101105';
        l1.OwnerId = userInfo.getuserId();
        l1.IsConverted__c = false;
        insert l1;
        
        Ex_SiteVisitForm.submits(l1.Id, null, acc2.Id, null, null, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        test.stopTest();
        
    }
    
     @isTest
    public static void leadFound(){
        test.startTest();
        Project__c p = new Project__c();
        p.Name = 'Test Project1';
        p.Project_Logo__c = 'Test image1';
        insert p;
        
        String Mobile = '9637576100';
        String project = p.Id;
        String email = 'prasad.alamwar@exceller.tech';
        String mastersource = 'Google';
        String fname = 'Test';
        String lname = 'Test';
        String salutation = 'Mr.';
        String configuration = '2 BHK';
        String country = 'India';
        String cityType = 'Mumbai';
        String cityName = 'Thane';
        String locality = 'Central';
        String locDetails = 'Bhandup';
        String rrName = 'Prasad Test';
        Boolean status = true;
        String otp = '1234';
                
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9090101105';
        insert acc2;
        
        
        Lead__c l1 = new Lead__c();
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        // l1.Mobile__c = '1122334005';
        l1.Email__c = 'customer12321@test.in';
        l1.Project__c = p.id;
        l1.Age_Group__c = '25 to 30 Years';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Marital_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Family_Size__c = 'Joint Family';
        l1.Industry__c = 'Consulting';
        l1.Configuration_Required__c = '2 BHK';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Alternate_Email_Id__c = 'Test2@gmail.com';
        l1.Mobile__c = '9090101105';
        l1.OwnerId = userInfo.getuserId();
        l1.IsConverted__c = false;
        insert l1;
        
        Ex_SiteVisitForm.submits(null, null, null, null, null, null, Mobile, project, email, mastersource,
                                 lname, fname, salutation, configuration, country, cityType, status, otp,
                                 cityName,locality,locDetails,rrName,false);
        test.stopTest();
        
    }
    
    
}