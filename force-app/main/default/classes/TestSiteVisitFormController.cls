@isTest
public class TestSiteVisitFormController {
    @isTest
    public static Project__c createProject() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        
        
        User u = new User(
            Username = uniqueName + '@test' + orgId + '.org',
            Email = uniqueName + '@test' + orgId + '.org',
            LastName = 'LastName',
            FirstName = 'FirstName',
            Alias = uniqueName.substring(18, 23),
            ProfileId = UserInfo.getProfileId(),
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Country = 'US',
            Title = 'Territory Manager'
        );
        insert u;
        
        Project__c p = new Project__c();
        p.Name = 'Project';
        p.Default_Owner_For_CP__c = u.Id;
        insert p;
        
        Team__c t = new Team__c();
        t.Name = 'Project Sales Team';
        t.Project__c = p.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.Id;
        tm.Availability__c = true;
        tm.User__c = u.Id;
        insert tm;
        
        return p; 
    }
    
    
    public static void  createLead() {
        
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p; 
        
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        // c2.Type__c = 'Event'; 
        c2.Project__c = p.Id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        insert c2;


        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1478596300'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('sv@test.in'));
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        a.Phone = 'Testq@gmail.com';
        system.debug('a.IsPersonAccount'+a.IsPersonAccount);
        
        insert a;
        
        /* Channel_Partner__c cp = new Channel_Partner__c();
cp.Name = 'Test';
cp.CP_Type__c = 'ICP';
cp.CP_Firm_Type__c = 'Individual';
cp.Alternate_Email__c = 'Test@gmail.com';
insert cp;*/
        
        Lead__c l = new Lead__c();
        l.First_Name__c = 'Test';
        l.Last_Name__c = 'Customer';
        l.Mobile__c = '1122334455';
        l.Email__c = 'customer@test.in';
        l.Project__c = p.id;
       // l.Channel_Partner__c = cp.id;
        // l.Age_Group__c = '25 to 30 Years';
        l.Gender__c = 'Male';
        l.Designation__c = 'Owner';
        l.Martial_Status__c = 'Married';
        l.Occupation__c = 'Shop owner';
        l.Current_Residence_Configuration__c = '1 BHK';
        l.Configuration_Required__c = '2 BHK';
        l.Budget__c = 'Budget of 50 to 60 lakhs';
        l.Referrer_Name__c = a.Id;
        l.Campaign_Custom__c = c2.Id;
        l.IsConverted__c = true;
        insert l;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Customer';
        opp.Account__c = a.id;
        opp.Campaign_Custom__c = c2.id;
        opp.Project__c = p.id;
        opp.Stage__c = 'In Follow-up';
        opp.Referrer_Name__c = userinfo.getName();
        opp.Presales_Manager__c = userinfo.getUserId();
        insert opp;
        
        opp.Site_Visit_Count__c = 1;
        opp.Last_SV_Date__c = system.today();
        //opp.Last_SV_Comment__c ='tetttsss';
        opp.Last_SV_attended_by__c = UserInfo.getUserId();
        opp.Last_Source_Changed_By__c = system.today();
        update opp;
       
        
        
        Lead__c l2 = new Lead__c();
        l2.First_Name__c = 'Test';
        l2.Last_Name__c = 'Customer';
        l2.Mobile__c = '1122334455';
        l2.Email__c = 'customer@test.in';
        l2.Alternate_Email_Id__c = 'customer24@test.in';
        l2.Project__c = p.id;
        
        l2.Gender__c = 'Male';
        l2.Designation__c = 'Owner';
        l2.Martial_Status__c = 'Married';
        l2.Occupation__c = 'Shop owner';
        
        l2.Current_Residence_Configuration__c = '1 BHK';
        
        l2.Configuration_Required__c = '2 BHK';
        l2.Budget__c = 'Budget of 50 to 60 lakhs';
        l2.Referrer_Name__c = a.Id;
        l2.Campaign_Custom__c = c2.Id;
        l2.Account__c = a.id;
        l2.Opportunity__c = opp.id;
        l2.IsConverted__c = true;
        insert l2;
    }
    
    /* @isTest
public static Account createCP() {
Account a = new Account();
a.RecordTypeId =Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();

a.Name = 'Test CP';
a.Phone = '1212121212';
// a.PAN_No__c = 'ASDFR1234E';
insert a;
return a;
}*/
    
    @isTest
    public static void freshWalkIn() {
        Test.startTest();
        
        // Account a = createCP();
        Project__c p = createProject();
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        insert p1;
        
        PageReference pageRef = Page.SearchPage;
        Test.setCurrentPage(pageRef);        
        SearchPageController sp = new SearchPageController();
        sp.l.Mobile__c = '1478596300';
        sp.l.Email__c = 'sv@test.in';
        sp.cancel();
        sp.search();
        sp.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1478596300'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('sv@test.in'));
        SiteVisitFormController svf = new SiteVisitFormController();
        svf.sv.Salutation__c = 'Mr.';
        svf.sv.First_Name__c = 'SV';
        svf.sv.Last_Name__c = 'Test';
        svf.sv.Email__c = 'Test@gmail.com';
        // svf.sv.Purchase_Timeframe__c = 'Ready to move-in';
        //svf.sv.Project_Type__c = 'RTMI';
        svf.sv.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        svf.sv.Buying_Purpose__c = 'Self-Use';
        // svf.sv.Citizenship__c = 'Indian';
        svf.sv.Street_1__c = 'Test1';
        svf.sv.Locality__c = 'IND';
        svf.sv.City__c = 'Test24'; 
        svf.sv.State__c = 'MH';
        svf.sv.Country__c = 'India';
        svf.sv.Pincode__c = '450331';
        svf.sv.House_No__c = '787q';
        svf.sv.Master_Source__c = 'Digital';
        system.debug('testt'+svf.sv.Master_Source__c);

        svf.sv.Lead_Source__c = 'Native';
        svf.sv.Mobile2__c = '9891132145';
        svf.sv.Email2__c = 'Nativ@etest.com';
        svf.sv.Company_Name__c = 'Test';
        // svf.sv.Age_Group__c = '25 to 30 Years';
        svf.sv.Company_Name__c = 'Test Company';
        svf.sv.Occupation__c = 'Shop owner';
        svf.sv.Designation__c = 'Owner';
        svf.sv.Configuration_Required__c = '1 BHK';
        svf.sv.Budget__c = 'Budget of 50 to 60 lakhs';
        svf.sv.Is_Source_Conflict__c = 'Yes';
        // svf.sv.Household_Income_Annual__c = 'Rs. 16 Lakhs to 20 Lakhs';
        
        // svf.cpName = 'Test CP-1212121212';
        
        svf.closeForm();
        ApexPages.currentPage().getParameters().put('currentTab', '0');
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '1');
        svf.validateInput();
        svf.submit();
        
        PageReference pageRef1 = Page.SearchPage;
        Test.setCurrentPage(pageRef1);        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '1478596300';
        sp1.l.Email__c = 'sv@test.in';
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1478596300'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('sv@test.in'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
       // svf1.getCPAccount('Testt', '1212121212', 'firmName', 'CPCode', 'RERANumber', UserInfo.getUserId());
        svf1.submit();
        
        Site_Visit__c sv = [Select Id , Referrer_Name__c,Company_Name__c,House_No__c,Street_1__c,Locality__c,City__c,State__c,Mobile__c,Email__c,
                            Country__c,Pincode__c,Master_Source__c, Comment__c, Opportunity_Stage__c, Sub_Stage__c,Opportunity__c,Site_Visit_Attended_By__c
                            from Site_Visit__c ORDER BY CreatedDate ASC LIMIT 1];
        
        Site_Visit__c cSV = SM_AssignmentController.getSVRecord(sv.Id);
        List<Team_Member__c> tmList = SM_AssignmentController.getAllSalesManager(cSV);
        Team_Member__c tm = SM_AssignmentController.checkUserAvailability(tmList[0].Id);
        Boolean result = SM_AssignmentController.assignSalesManager(cSV, tmList[0]);
        
        //sv.Comment__c = 'Test SV';
        sv.Opportunity_Stage__c = 'In Follow-up';
        sv.Sub_Stage__c = 'Hot';
        sv.Sub_Stage_Reason__c = 'All Good Expected Closure';
        sv.Next_Follow_up_Date__c = system.now().addDays(1);
        sv.Site_Visit_Attended_By__c = 'Rahul';
        update sv;
        
        PageReference pageRef2 = Page.SearchPage;
        Test.setCurrentPage(pageRef2);        
        SearchPageController sp2 = new SearchPageController();
        sp2.l.Mobile__c = '1478596300';
        sp2.l.Email__c = 'sv@test.in';
        sp2.search();
        sp2.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1478596300'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('sv@test.in'));
        
        
        SiteVisitFormController svf2 = new SiteVisitFormController();
        svf2.sv.Configuration_Required__c = '1 BHK';
        svf2.sv.Budget__c = '50 Lakhs and above';
        svf2.sv.Master_Source__c = 'Recommended by Friends/Relatives';
        svf2.submit();
        
        Test.stopTest();
    }
    
    @isTest
    public static void walkInforLead() {
        Test.startTest();
        
      //  Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        Project__c p1 = new Project__c();
        p1.Name = ' NnnnProject';
        p1.Default_Owner_For_CP__c = UserInfo.getUserId();
        p1.OwnerId = UserInfo.getUserId();
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Id cpRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Marketing Partner Account').getRecordTypeId();
  
       
        
        Account a = new Account();
        a.OwnerId = UserInfo.getUserId();
        system.debug('a.OwnerId:::'+a.OwnerId);
        a.RecordTypeId = cpRecordTypeId;
        a.Name = 'CPAccount';
       // a.LastName = 'CPAccount';
        a.Mobile__c = '1122334455';
        a.Email__c = 'customer@test.in';
        a.Firm_Name__c = 'Testttt';
       // a.CP_Code__c = '2476vv';
        a.MahaRERA_Registration_No__c = '4376bbsjfh';
        insert a;
        
      
        
        
        Lead__c l = new Lead__c();
        l.Name = 'Nitintetst';
        l.Salutation__c = 'Mr.';
        l.First_Name__c = 'Test1';
        l.Last_Name__c = 'Customer';
        l.Mobile__c = '1122334455';
        l.Email__c = 'customer@test.in';
        l.Project__c = p1.id;
        l.Configuration_Required__c = '1 BHK';
        l.Gender__c = 'Male';
        l.Designation__c = 'Owner';
        l.Martial_Status__c = 'Married';
        l.Occupation__c = 'Shop owner';
        l.Other_Occupation__c = 'Testtt';
        l.House_No__c = 'Test1';
        l.Street__c = 'Test1';
        l.Building__c = 'Test1';
        l.Locality__c = 'Test1';
        l.City__c = 'Test1';
        l.State__c = 'Test1';
        l.PostalCode__c = '41231';
        l.Company_Name__c = 'ABC';
        l.Channel_Partner__c = a.Id;
        //l.Referrer_Name__c = 'ABc';
        //l.Management_Name__c = 'XYz';
      
        l.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        //l.Highest_Education__c = 'Engineer';
        l.Current_Residence_Configuration__c = '1 BHK';
        // l.Current_Residence_Status__c = 'Rented';
        // l.Ethinicity__c = 'Marathi';
        // l.Household_Income_Annual__c = 'Rs. 16 Lakhs to 20 Lakhs';
        // l.Industry__c = 'Consulting';
        l.Configuration_Required__c = '2 BHK';
        l.Budget__c = 'Budget of 50 to 60 lakhs';
        insert l;
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        //c2.Type__c = 'Event'; 
        c2.Project__c = p1.id;
        //c2.Marketing_Brief__c = Mb.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
        //c2.Amount__c = 0;
        //c2.GST__c = 'GST 5%';
        //c2.Discount__c = 0;
        c2.Actual_Cost__c = 0;
        c2.Budgeted_Cost__c = 0;
        //c2.Actual_Bookings__c = 0;
        c2.Targeted_Leads__c = 20;
        // c2.Planned_Visits__c = 10;
        //c2.Planned_Cost__c = 100;
        c2.Campaign_Code__c = 'AVJH7';
        c2.Master_Source__c = 'Marketing Partner';
        insert c2;
        
        Project__c p2 = new Project__c();
        p2.Name = 'New Project';
        insert p2;
        //Lead l1 = createLead(p1.Id);
        
        
        
        Lead__c l1 = new Lead__c();
        l1.Name = 'Nitintetst';
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test2';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122334455';
        l1.Email__c = 'customer@test.in';
        l1.Project__c = p2.id;
        l1.Configuration_Required__c = '1 BHK';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Other_Occupation__c = 'Testtt';
        l1.Current_Residence_Configuration__c = '1 BHK';
        // l1.Current_Residence_Status__c = 'Rented';
        // l1.Ethinicity__c = 'Marathi';
        // l1.Household_Income_Annual__c = 'Rs. 16 Lakhs to 20 Lakhs';
        // l1.Industry__c = 'Consulting';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Master_Source__c = 'Marketing Partner';
        l1.Channel_Partner__c = a.Id;
        insert l1;
        
        PageReference pageRef = Page.SearchPage;
        Test.setCurrentPage(pageRef);        
        SearchPageController sp = new SearchPageController();
        sp.l.Mobile__c = '1122334455';
        sp.l.Email__c = 'customer@test.in';
        sp.l.Project__c = p1.Id;
        //sp.l.Name = 'Testtttt';
        sp.l.Master_Source__c = 'Marketing Partner';
        
        sp.search();
        sp.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.Id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1122334455'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('customer@test.in'));
        SiteVisitFormController svf = new SiteVisitFormController();
        svf.sv.Master_Source__c = 'Marketing Partner';
        svf.sv.Channel_Partner__c = a.id;
        svf.sv.CP_Name__c = a.Name;
        svf.sv.Firm_Name__c = a.Firm_Name__c;
        //svf.sv.CP_Unique_Code__c = a.CP_Code__c;
        svf.sv.RERA_Number__c = a.MahaRERA_Registration_No__c;
        svf.submit();
        
        Opportunity__c op = [Select Id,Channel_Partner__c,Last_Source_Changed_By__c, Campaign_Custom__c,Account__c,Project__c,Stage__c from Opportunity__C ORDER BY CreatedDate ASC LIMIT 1];
        op.Campaign_Custom__c = c2.Id;
        op.Name = 'Oppp22';
        op.Account__c = a.id;
        op.Project__c = p1.id;
        op.Stage__c = 'In Follow-up';
        op.Last_Source_Changed_By__c  = op.Last_Source_Changed_By__c.addDays(45) ;
        op.Channel_Partner__c = a.id;
        
        update op;
        
        PageReference pageRef1 = Page.SearchPage;
        Test.setCurrentPage(pageRef1);        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '1122334455';
        sp1.l.Email__c = 'customer@test.in';
        sp1.search();
        sp1.continueMethod();
        
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1122334455'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('customer@test.in'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Marketing Partner';
        svf1.sv.Channel_Partner__c = a.id;
        svf1.sv.CP_Name__c = a.Name;
        svf1.sv.Firm_Name__c = a.Firm_Name__c;
        svf1.isSourceNotEditable = false;
        //SiteVisitFormController.getCPAccount(cp.Name);
        //SiteVisitFormController.getReferrerName(a.Name);
        svf1.submit();
        Test.stopTest();
    }
    
    @isTest
    public static void wlakInforLeadSource2(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test3';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Management Reference'; 
        l1.Management_Name__c = 'Testtt' ;
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Management Reference'; 
        svf1.sv.Management_Name__c = 'testtt' ;  
        svf1.submit();
        Test.stopTest();        
    }
    
    
     @isTest
    public static void wlakInforLeadSource21(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 33';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test4';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Referral and Loyalty Programme'; 
        l1.Lead_Source__c = 'NonSales Staff';
        l1.Name__c = 'Test ';
        l1.Mobile2__c = '8877665555';
        l1.Departments__c = 'Test Dep';
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Referral and Loyalty Programme'; 
        svf1.sv.Lead_Source__c = l1.Lead_Source__c;
        svf1.sv.Name__c = 'Test';
        svf1.sv.Mobile2__c = '8877665555';
        svf1.sv.Departments__c = 'Test Dep';
        svf1.submit();
        Test.stopTest();        
    }
    
    @isTest
    public static void wlakInforLeadSource36(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 36';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test5';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Referral and Loyalty Programme'; 
        l1.Lead_Source__c = 'Existing Tenants';
        l1.Name__c = 'Test ';
        l1.Mobile2__c = '8877665555';
        l1.Email2__c = 'test23@gmail.com';
        l1.Current_Project_Name__c = 'Monopoli';
        l1.Comments__c = 'Testt';
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Referral and Loyalty Programme'; 
        svf1.sv.Lead_Source__c = l1.Lead_Source__c;
        svf1.sv.Name__c = 'Test';
        svf1.sv.Mobile2__c = '8877665555';
        svf1.sv.Departments__c = 'Test Dep';
        svf1.sv.Current_Project_Name__c = 'Monopoli';
        svf1.sv.Comments__c = 'Test';
        svf1.submit();
        Test.stopTest();        
    }
    
     @isTest
    public static void wlakInforLeadSource368(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 368';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test7';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Referral and Loyalty Programme'; 
        l1.Lead_Source__c = 'Vendor Reference';
        l1.Name__c = 'Test ';
        l1.Mobile2__c = '8877665555';
        l1.Email2__c = 'test23@gmail.com';
        l1.Vendor_Company__c = 'testc';
        l1.Staff_Name__c = 'test';
        l1.Departments__c = 'Departments';
        l1.Comments__c = 'Testt';
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Referral and Loyalty Programme'; 
        svf1.sv.Lead_Source__c = l1.Lead_Source__c;
        svf1.sv.Name__c = 'Test';
        svf1.sv.Mobile2__c = '8877665555';
        svf1.sv.Email2__c = 'test23@gmail.com';
        svf1.sv.Comments__c = 'Test';
        svf1.sv.Vendor_Company__c = 'testc';
        svf1.sv.Staff_Name__c = 'test';
        svf1.sv.Departments__c = 'Departments';        
        svf1.submit();
        Test.stopTest();        
    }
    
      @isTest
    public static void wlakInforLeadSource44(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 44';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test8';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Referral and Loyalty Programme'; 
        l1.Lead_Source__c = 'Sales Staff'; //Existing Clients
        l1.Name__c = 'Test ';
        l1.Mobile2__c = '8877665555';
        l1.Comments__c = 'Testt';
        l1.Locations__c = 'Thane';
        
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Referral and Loyalty Programme'; 
        svf1.sv.Lead_Source__c = l1.Lead_Source__c;
        svf1.sv.Name__c = 'Test';
        svf1.sv.Mobile2__c = '8877665555';
        svf1.sv.Comments__c = 'Test';
        svf1.sv.Location__c = 'Thane';
        svf1.submit();
        Test.stopTest();        
    }
    
     @isTest
    public static void wlakInforLeadSource55(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 55';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test9';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Referral and Loyalty Programme'; 
        l1.Lead_Source__c = 'Existing Clients'; //
        l1.Name__c = 'Test ';
        l1.Mobile2__c = '8877665555';
        l1.Email2__c = 'rtest@gmail.com';
        l1.Comments__c = 'Testt';
        l1.Locations__c = 'Thane';
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Referral and Loyalty Programme'; 
        svf1.sv.Lead_Source__c = l1.Lead_Source__c;
        svf1.sv.Name__c = 'Test';
        svf1.sv.Mobile2__c = '8877665555';
        svf1.sv.Email2__c = 'test123@gmail.com';
        svf1.sv.Location__c = 'Thane';
        svf1.sv.Comments__c = 'Test';
        svf1.submit();
        Test.stopTest();        
    }
    
    
     @isTest
    public static void wlakInforLeadSource212(){
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project 336';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122377488';
        l1.Email__c = 'customer1122@test.in';
        l1.Project__c = p1.id;
        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.Master_Source__c = 'Recommended by Friends/Relatives';
        l1.Referrer_Name__c = a.id;
        
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '8887775655';
        sp1.l.Email__c = 'customer1177@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('8887775655'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Recommended by Friends/Relatives'; 
        svf1.sv.Referrer_Name__c = a.id;
        SiteVisitFormController.getReferrerName(svf1.sv.Referrer_Name__c);
        svf1.submit();
        Test.stopTest();        
    }


    
    
    @isTest
    public static void walkInforLead22() {
        Test.startTest();
        
        Project__c p = createProject();
        //Lead__c l = createLead(p.Id);
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        p1.Site_Visit_QR_Assignment__c = UserInfo.getUserId();
        insert p1;
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '2121212121';
        a.Alternate_Email__c = 'Test2@gmail.com';
        a.PersonEmail = 'Test24@gmail.com';
        
        insert a;
        
        
       Id cpRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Marketing Partner Account').getRecordTypeId();
  
       
        
        Account a1 = new Account();
        a1.OwnerId = UserInfo.getUserId();
        system.debug('a.OwnerId:::'+a1.OwnerId);
        a1.RecordTypeId = cpRecordTypeId;
        a1.Name = 'Marketing Partner Account';
       // a.LastName = 'CPAccount';
        a1.Mobile__c = '1122334455';
        a1.Email__c = 'customer@test.in';
        a1.Firm_Name__c = 'Testttt';
       // a1.CP_Code__c = '2476vv';
        a1.MahaRERA_Registration_No__c = '4376bbsjfh';
        insert a1;
        
        
        Account a11 = new Account();
        a11.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Partner Account').getRecordTypeId();
        a11.Mobile__c = '2121212121';
        a11.Alternate_Email__c = 'Test2@gmail.com';
        a11.Email__c = 'Test24@gmail.com';
        a11.Name = 'Testtttt';
       // a11.CP_Code__c = '122312ER';
        a11.Firm_Name__c = 'jhdsfh';
        a11.MahaRERA_Registration_No__c = 'wyetg444';
        a11.OwnerId = userinfo.getUserId();
        
        insert a11;
        
        Lead__c l = new Lead__c();
        l.Salutation__c = 'Mr.';
        l.First_Name__c = 'Test';
        l.Last_Name__c = 'Customer';
        l.Mobile__c = '1122334455';
        l.Email__c = 'customer@test.in';
        l.Project__c = p1.id;
        l.Other_Occupation__c = 'Testtt';
        l.Gender__c = 'Male';
        l.Designation__c = 'Owner';
        l.Martial_Status__c = 'Married';
        l.Occupation__c = 'Shop owner';
        l.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        l.Current_Residence_Configuration__c = '1 BHK';
        // l.Current_Residence_Status__c = 'Rented';
        // l.Ethinicity__c = 'Marathi';
        // l.Household_Income_Annual__c = 'Rs. 16 Lakhs to 20 Lakhs';
        // l.Industry__c = 'Consulting';
        l.Configuration_Required__c = '2 BHK';
        l.Budget__c = 'Budget of 50 to 60 lakhs';
        l.Master_Source__c = 'Marketing Partner';
        l.Channel_Partner__c = a11.id;
        l.IsConverted__c = false;
        insert l;
        l.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l;
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project22';
        c2.Active__c = true;
        //c2.Type__c = 'Event'; 
        c2.Project__c = p.id;
        c2.Master_Source__c = 'Digital';
         system.debug('testt'+c2.Master_Source__c);

        //c2.Marketing_Brief__c = Mb.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
        //c2.Amount__c = 0;
        //c2.GST__c = 'GST 5%';
        //c2.Discount__c = 0;
        c2.Actual_Cost__c = 0;
        c2.Budgeted_Cost__c = 0;
        //c2.Actual_Bookings__c = 0;
        c2.Targeted_Leads__c = 20;
        // c2.Planned_Visits__c = 10;
        //c2.Planned_Cost__c = 100;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
        
        //Lead l1 = createLead(p1.Id);
        
        Lead__c l1 = new Lead__c();
        l1.Salutation__c = 'Mr.';
        l1.First_Name__c = 'Test';
        l1.Last_Name__c = 'Customer';
        l1.Mobile__c = '1122334455';
        l1.Email__c = 'customer@test.in';
        l1.Alternate_Email_Id__c = 'customer24@test.in';
        l1.Project__c = p1.id;
        l1.Master_Source__c = 'Digital';
                system.debug('testt'+l1.Master_Source__c);

        l1.Other_Occupation__c = 'Testtt';
        l1.Gender__c = 'Male';
        l1.Designation__c = 'Owner';
        l1.Martial_Status__c = 'Married';
        l1.Occupation__c = 'Shop owner';
        //l1.Family_Size__c = 'Joint Family';
        //l1.Highest_Education__c = 'Engineer';
        l1.Current_Residence_Configuration__c = '1 BHK';
        l1.Possession_Timeframe_Required__c = 'Ready to Move in (RTMI)';
        // l1.Buying_Purpose__c = 'Self';
        //l1.Household_Income_Annual__c = 'Rs. 16 Lakhs to 20 Lakhs';
        // l1.Industry__c = 'Consulting';
        l1.Configuration_Required__c = '2 BHK';
        l1.Budget__c = 'Budget of 50 to 60 lakhs';
        l1.IsConverted__c = false;
         l1.Stage__c = 'Visit Done';
        l1.Master_Source__c = 'Marketing Partner';
        l1.Channel_Partner__c = a11.id;
        insert l1;
        l1.OwnerId = p1.Site_Visit_QR_Assignment__c;
        update l1;
        
        
       
        
        PageReference pageRef = Page.SearchPage;
        Test.setCurrentPage(pageRef);        
        SearchPageController sp = new SearchPageController();
        sp.l.Mobile__c = '1122334455';
        sp.l.Email__c = 'customer@test.in';
        
        sp.search();
        sp.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1122334455'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf = new SiteVisitFormController();
        svf.sv.Master_Source__c = 'Recommended by Friends/Relatives';
        svf.sv.Referrer_Name__c = a.id;
        
        //svf.getCPAccount(a1.Name, a1.Mobile__c , a1.Firm_Name__c , a1.CP_Code__c , a1.MahaRERA_Registration_No__c , p.Default_Owner_For_CP__c);
        svf.submit();
        
        Opportunity__c op = [Select Id,Last_Source_Changed_By__c,Channel_Partner__c, Campaign_Custom__c,Account__c,Project__c,Stage__c from Opportunity__C ORDER BY CreatedDate ASC LIMIT 1];
        op.Campaign_Custom__c = c2.Id;
        op.Account__c = a.id;
        op.Project__c = p.id;
        op.Stage__c = 'In Follow-up';
        op.Channel_Partner__c = a1.id;
        update op;
       
        
        /*PageReference pageRef1 = Page.SearchPage;
Test.setCurrentPage(pageRef1);      */  
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '1122334455';
        sp1.l.Email__c = 'customer@test.in';
        sp1.l.OwnerId = UserInfo.getUserId();
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p1.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('1122334455'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('Test24@gmail.com'));
        SiteVisitFormController svf1 = new SiteVisitFormController();
        svf1.sv.Master_Source__c = 'Marketing Partner';
        svf1.sv.Channel_Partner__c = a11.id;
        svf1.submit();
        
        Test.stopTest();
    }
    
    
    
    
    
    
    @isTest
    public static void validationCheck() {
        Project__c p = createProject();
        
        Test.startTest();
        
        PageReference pageRef1 = Page.SearchPage;
        Test.setCurrentPage(pageRef1);        
        SearchPageController sp1 = new SearchPageController();
        sp1.l.Mobile__c = '112233445578';
        sp1.l.Email__c = 'customer@test.in';
        sp1.search();
        sp1.continueMethod();
        ApexPages.currentPage().getParameters().put('project', String.valueOf(p.id));
        ApexPages.currentPage().getParameters().put('mobile', String.valueOf('112233445578'));
        ApexPages.currentPage().getParameters().put('email', String.valueOf('customer@test.in'));
        SiteVisitFormController svf = new SiteVisitFormController();
        ApexPages.currentPage().getParameters().put('currentTab', '0');
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '1');
        svf.validateInput();
        svf.sv.Pincode__c = '454545';
        svf.sv.Last_Name__c = 'test';
        svf.sv.First_Name__c = 'test';
        svf.sv.Salutation__c = 'Mr.';
        svf.enterOtp = '3324';
        ApexPages.currentPage().getParameters().put('currentTab', '1');
        svf.sv.Locality__c = 'Test';
        svf.sv.City__c = 'Pune';
        svf.validateInput();
        svf.sv.Master_Source__c = 'Digital';
        svf.sv.Lead_Source__c = 'Native';
        system.debug('testt'+svf.sv.Master_Source__c);
        //svf.sv.Lead_Source__c = 'Channel Partner';
        ApexPages.currentPage().getParameters().put('currentTab', '2');
        svf.sv.Master_Source__c = 'Digital';
         system.debug('testt'+svf.sv.Master_Source__c);
                svf.sv.Lead_Source__c = 'Native';


        svf.validateInput();
        //svf.sv.Master_Source__c = 'Reference';
        //svf.sv.Lead_Source__c = 'Customers';
        ApexPages.currentPage().getParameters().put('currentTab', '2');
        svf.validateInput();
        //svf.sv.Master_Source__c = 'Reference';
        //svf.sv.Lead_Source__c = 'Employees';
        ApexPages.currentPage().getParameters().put('currentTab', '2');
        svf.validateInput();
        //svf.sv.Master_Source__c = 'Other';
        ApexPages.currentPage().getParameters().put('currentTab', '2');
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Budget__c = 'Budget of 30 to 40 lakhs';
        svf.validateInput();

        svf.sv.Configuration_Required__c = '1.5 BHK';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Master_Source__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Master_Source__c = 'Marketing Partner';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.RERA_Number__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.RERA_Number__c = 'Y653bb';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Master_Source__c = 'Recommended by Friends/Relatives';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.CP_Name__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Master_Source__c = 'Referral and Loyalty Programme';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Lead_Source__c = 'Existing Clients';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.sv.Mobile2__c = '9876543210';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '';
        svf.sv.Email2__c = 'test@hash.ck';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = '';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        svf.sv.Mobile2__c = '98765410';
        svf.validateInput();
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Lead_Source__c = 'Existing Tenants';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.sv.Mobile2__c = '9876543210';
        svf.validateInput();
        svf.sv.Mobile2__c = '';
        svf.sv.Name__c = 'asv';
        svf.sv.Email2__c = 'test@hash.ck';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = '';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '98765432';
        svf.sv.Email2__c = 'ad@sf.f';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.validateInput();
        svf.sv.Email2__c = ' ';
        svf.validateInput();
        svf.sv.Mobile2__c = ' ';
        svf.validateInput();
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Lead_Source__c = 'NonSales Staff';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.sv.Mobile2__c = '9876543210';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '';
        svf.sv.Departments__c = 'test';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Departments__c = '';
        svf.validateInput();
        svf.sv.Mobile2__c = '98765410';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.validateInput();
        svf.sv.Email2__c = '';
        svf.validateInput();
        svf.sv.Departments__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Lead_Source__c = 'Sales Staff';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.validateInput();
        svf.sv.Mobile2__c = '';
        svf.validateInput();
        svf.sv.Location__c = '';
        svf.validateInput();
        svf.sv.Comments__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '3');
        svf.sv.Lead_Source__c = 'Vendor Reference';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.sv.Mobile2__c = '9876543210';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '';
        svf.sv.Email2__c = 'test@hash.ck';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = '';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        svf.sv.Mobile2__c = '98765410';
        svf.validateInput();
        svf.sv.Current_Project_Name__c = '' ;
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = 'res' ;
        svf.sv.Vendor_Company__c = '';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = 'res' ;
        svf.sv.Vendor_Company__c = 'rf';
        svf.sv.Staff_Name__c = '';
        svf.validateInput();
        svf.sv.Name__c = 'asv';
        svf.sv.Mobile2__c = '9876543210';
        svf.sv.Email2__c = 'st@hash.n';
        svf.sv.Current_Project_Name__c = 'res' ;
        svf.sv.Vendor_Company__c = 'rf';
        svf.sv.Staff_Name__c = 'ff';
        svf.sv.Departments__c = '';
        svf.validateInput();
        svf.sv.Name__c = '';
        svf.validateInput();
        svf.sv.Mobile2__c = '';
        svf.validateInput();
        svf.sv.Email2__c = '';
        svf.validateInput();
        svf.sv.Comments__c = '';
        svf.validateInput();
        svf.sv.Vendor_Company__c = '';
        svf.validateInput();
        svf.sv.Staff_Name__c = '';
        svf.validateInput();
        svf.sv.Departments__c = '';
        svf.validateInput();
        ApexPages.currentPage().getParameters().put('currentTab', '4');
        svf.sv.Budget__c = '';
        svf.validateInput();
        svf.sv.Configuration_Required__c = '';
        svf.validateInput();

        Test.stopTest();
    }
    
    @isTest
    public static void testGenerateOTP() {
        SiteVisitFormController svf = new SiteVisitFormController();
        
        svf.mobile = '1234567890';
        
        Test.startTest();
        svf.generateOTP();
        Test.stopTest();
        

    }
    
    @isTest
    public static void testVerifyOTP() {
        SiteVisitFormController svf = new SiteVisitFormController();
        
        svf.enterOtp = '1234';
        svf.generatedOtp = '1234';
                        
        //svf.enterOtp = '5678';
        //svf.generatedOtp = '1234';
        
        Test.startTest();
        svf.verifyOTP();
        Test.stopTest();
    }
    
      @isTest
    public static void testVerifyOTP1() {
        SiteVisitFormController svf = new SiteVisitFormController();
        
        //svf.enterOtp = '1234';
        //svf.generatedOtp = '1234';
                        
        svf.enterOtp = '5678';
        svf.generatedOtp = '1234';
        
        Test.startTest();
        svf.verifyOTP();
        Test.stopTest();
    }
    
        @isTest
    public static void testVerifyOTP3() {
        SiteVisitFormController svf = new SiteVisitFormController();
        
        svf.enterOtp = '3011';
        svf.generatedOtp = '1234';
        
        Test.startTest();
        svf.verifyOTP();
        Test.stopTest();
    }

}