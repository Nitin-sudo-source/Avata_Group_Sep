@isTest
public class TestEx_SiteVisitFormController {
    
        @isTest()
    Public Static  void insertSitevisit(){
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        p1.TAT_Days_for_Walkin__c = 30;
        insert p1;
        
        Team__c t = new Team__c();
        t.Name = 'Sales Team';
        t.Project__c = p1.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        Team_Member__c tmb1 = new Team_Member__c();
        tmb1.Team__c = t.Id;
        tmb1.User__c = UserInfo.getUserId();
        tmb1.Availability__c = true;
        tmb1.DayOff__c = false;
        tmb1.Last_Assignment_DateTime__c =System.now();
        tmb1.Last_Assignment_Milliseconds__c = 1;
        insert tmb1;
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc1';
        acc.Phone = '99854857584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc1@gmail.com';
        acc.PersonEmail = 'acc11@gmail.com';
        insert acc;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Account__c = acc.id;
        op.Stage__c = '';
        op.Close_Date__c = system.today().addDays(30);
        op.SV_Count__c =1 ;
        insert op ;
        
        Site_visit__c sv = new Site_visit__c();
        sv.Salutation__c = 'Mr.';
        sv.First_Name__c = 'SV';
        sv.Last_Name__c = 'Test';
        sv.Project__c = p1.id;
        sv.Mobile__c= '1212141214';
        sv.Email__c = 'Test@gmail.com';
        sv.Lead_Source__c = 'Google';
        sv.Lead_Sub_Source__c = 'Google Search';
        sv.Current_Resident_Status__c = 'Rented';
        sv.Configuration_Required__c = '1 BHK';
        sv.Budget_Range__c = 'Budget of 20 to 30 lakhs';
        sv.Buying_Purpose__c = 'Self-Use';
        sv.Site_Visit_Count__c = 1;
        sv.Possession_Timeframe_Required__c = 'Under Construction (UC – 1 to 2 years)';
        sv.Is_Sales_Manager_Assigned__c = false;
        sv.Opportunity__c=  op.id;
        insert sv;
        
        List <Site_visit__C> svList =  [Select Id , Name , Sales_Manager__c,OwnerId,opportunity__c , Is_Sales_Manager_Assigned__c , Project__C 
                                       From Site_visit__c Where Id=:sv.Id];
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, List<Site_Visit__c>> svMap = new Map<Id, List<Site_Visit__c>>();
        for(Site_Visit__c sv1: svList) {
        
            List<Site_Visit__c> newList = new List<Site_Visit__c>();
                    newList.add(sv1);
                    svMap.put(sv1.Project__c, newList);
                     oppIdSet.add(sv1.Opportunity__c);
          }
        Test.startTest();
        System.debug('Project Id'+sv.Project__c);
        Ex_SiteVisitHandlerServices.applyRoundRobin(svMap,oppIdSet);
        Test.stopTest();
        
    }
    
     @isTest()
    Public Static void makeAvailable(){
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        p1.TAT_Days_for_Walkin__c = 30;
        insert p1;
        
        Team__c t1 = new Team__c();
        t1.Name = 'Sales Team';
        t1.Project__c = p1.Id;
        t1.Team_Type__c = 'Sales Team';
        insert t1;
        
        Team_Member__c tmb1 = new Team_Member__c();
        tmb1.Team__c = t1.Id;
        tmb1.User__c = UserInfo.getUserId();
        tmb1.Availability__c = true;
        tmb1.DayOff__c = false;
        tmb1.Last_Assignment_DateTime__c =System.now();
        tmb1.Last_Assignment_Milliseconds__c = 1;
        insert tmb1;
        
         Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc111';
        acc.Phone = '99854887584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc111@gmail.com';
        acc.PersonEmail = 'acc1122@gmail.com';
        insert acc;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Account__c = acc.id;
        op.Stage__c = '';
        op.Close_Date__c = system.today().addDays(30);
        op.SV_Count__c =1 ;
        insert op ;
        
        Site_visit__c sv = new Site_visit__c();
        sv.Salutation__c = 'Mr.';
        sv.First_Name__c = 'SV12';
        sv.Last_Name__c = 'Test';
        sv.Project__c = p1.id;
        sv.Mobile__c= '1212149914';
        sv.Email__c = 'Test9666@gmail.com';
        sv.Lead_Source__c = 'Google';
        sv.Lead_Sub_source__c ='Google Search';
        sv.Current_Resident_Status__c = 'Self-owned';
        sv.Configuration_Required__c = '1 BHK';
        sv.Budget_Range__c = 'Budget of 20 to 30 lakhs';
        sv.Buying_Purpose__c = 'Self-Use';
        sv.Site_Visit_Count__c = 1;
        sv.Possession_Timeframe_Required__c = 'Under Construction (UC – 1 to 2 years)';
        sv.Is_Sales_Manager_Assigned__c = true;
        sv.Sales_Manager__c = tmb1.User__c;
        sv.Opportunity__c=  op.id;
        sv.Comments__c ='';
        
       
        Test.startTest();
        insert sv;
        sv.Comments__c = 'Test Commenttttttttttttttt';
        update sv;
        
        Map<Id, Set<Id>> projectUserIdMap = new Map<Id, Set<Id>>();
         Set<Id> newIdSet = new Set<Id>();
                    newIdSet.add(sv.Sales_Manager__c);
                    projectUserIdMap.put(sv.Project__c, newIdSet);
        Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(projectUserIdMap);
        
        Test.stopTest();
    }
    
     @isTest
    Public Static  void insertSitevisitForDayOff(){
        
        Project__c p2 = new Project__c();
        p2.Name = 'New Project2';
        p2.TAT_Days_for_Walkin__c = 30;
        insert p2;
        
        Team__c t3 = new Team__c();
        t3.Name = 'Sales Team';
        t3.Project__c = p2.Id;
        t3.Team_Type__c = 'Sales Team';
        insert t3;
        
        Team_Member__c tmb1 = new Team_Member__c();
        tmb1.Team__c = t3.Id;
        tmb1.User__c = UserInfo.getUserId();
        tmb1.Availability__c = false;
        tmb1.DayOff__c = true;
        tmb1.Last_Assignment_DateTime__c =System.now();
        tmb1.Last_Assignment_Milliseconds__c = 1;
        insert tmb1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; // Get a standard profile
      integer i = 10;
        i++; 

        User newUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testtt'+i+'@example.com',
            Username = 'testtt'+i+'@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        insert newUser;
        
        Team_Member__c tmb2 = new Team_Member__c();
        tmb2.Team__c = t3.Id;
        tmb2.User__c = newUser.Id;
        tmb2.Availability__c = true;
        tmb2.DayOff__c = false;
        tmb2.Last_Assignment_DateTime__c =System.now();
        tmb2.Last_Assignment_Milliseconds__c = 1;
        insert tmb2;
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc111';
        acc.Phone = '99854887584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc111@gmail.com';
        acc.PersonEmail = 'acc1122@gmail.com';
        insert acc;
        
        Opportunity__c op = new Opportunity__c();
        op.Name = 'Test';
        op.Account__c = acc.id;
        op.Stage__c = '';
        op.Close_Date__c = system.today().addDays(30);
        op.SV_Count__c =1 ;
        op.Sales_Manager__c = tmb1.User__c;
        insert op ;
        
        Site_visit__c sv = new Site_visit__c();
        sv.Salutation__c = 'Mr.';
        sv.First_Name__c = 'SV12';
        sv.Last_Name__c = 'Test';
        sv.Project__c = p2.id;
        sv.Mobile__c= '1212149914';
        sv.Email__c = 'Test9666@gmail.com';
        sv.Lead_Source__c = 'Google';
        sv.Lead_Sub_Source__c = 'Google Search';
        sv.Current_Resident_Status__c = 'Self-owned';
        sv.Configuration_Required__c = '1 BHK';
        sv.Budget_Range__c = 'Budget of 20 to 30 lakhs';
        sv.Buying_Purpose__c = 'Self-Use';
        sv.Site_Visit_Count__c = 1;
        sv.Possession_Timeframe_Required__c = 'Under Construction (UC – 1 to 2 years)';
        sv.Is_Sales_Manager_Assigned__c = false;
        sv.Site_Visit_Count__c=2;
        
        sv.Opportunity__c=  op.id;
        insert sv;
        
        Test.startTest();
        System.debug('Project Id2nd'+sv.Project__c);
        
        
         List <Site_visit__C> svList =  [Select Id , Name , Sales_Manager__c,OwnerId,opportunity__c , Is_Sales_Manager_Assigned__c , Project__C 
                                       From Site_visit__c Where Id=:sv.Id];
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, List<Site_Visit__c>> svMap = new Map<Id, List<Site_Visit__c>>();
        for(Site_Visit__c sv1: svList) {
        
            List<Site_Visit__c> newList = new List<Site_Visit__c>();
                    newList.add(sv1);
                    svMap.put(sv1.Project__c, newList);
                     oppIdSet.add(sv1.Opportunity__c);
          }
        
        
        
        Test.stopTest();
        
    }
    
    
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
        l1.Mobile__c = '9637576100';
        l1.Age_Group__c = '25 to 30 Years';
        l1.Configuration_Required__c = '1 BHK';
        l1.OwnerId = userInfo.getuserId();
        l1.Budget_Range__c = 'Budget of 30 to 40 lakhs';
        l1.Current_Resident_Status__c = 'Self-owned';
        l1.Buying_Purpose__c = 'Self-Use';
        l1.Industry__c = 'Agriculture';
        l1.Current_Residence_Configuration__c = '1 RK';
        l1.Ethnicity__c = 'Marathi';
        l1.Source_Description__c = 'NA';
        l1.Possession_Timeframe__c = 'RTMI (Ready to Move in)';
        //l1.Channel_Partner__c = acc1.Id;
        l1.Family_Size__c = '3';
        l1.Company_Name__c = 'Test Comapny';
        //l1.CP_Project__c = cpp.Id;
        
        return l1;
    }
    
    @isTest
    public static void testLeadFound(){
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Occupation__c = 'Employed in Pvt. company ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        // acc2.Current_Residence_Status__c = 'Self-owned';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        //acc2.Residence__c = 'Indian';
        //acc2.Country__c = 'India';
        insert acc2;
        
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
        
        /*Channel_Partner__c cp1 = new Channel_Partner__c();
cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
cp1.RERA_Available__c = 'No';
cp1.Mobile__c = '9876543210';
cp1.PAN_No__c = 'ABCDE1234A';
Id cpRecordTypeId = SObjectType.Channel_Partner__c.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
cp1.RecordTypeId =cpRecordTypeId;
insert cp1;*/
        
        Account cpacc = new Account();
        cpacc.OwnerId = userInfo.getUserId();
        cpacc.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc.Phone = '9011722426';
        cpacc.Email__c = 'prasad.alamwar@test.com';
        cpacc.PAN_No__c = '676747';
        cpacc.RERA_Available__c = 'No';
        insert cpacc;
        
        CP_Project__c cpp = new CP_Project__c();
        //  cpp.Account__c = cp1.Id;
        cpp.Project_Name__c = p.Id;
        insert cpp;
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = cpacc.Id;
        l1.CP_Project__c =  cpp.Id;
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
        
        Opportunity__c opp = new Opportunity__c();
        opp.Project__c =p.Id;
        opp.Sourcing_Manager__c = UserInfo.getUserId();
        insert opp;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Opportunity__c = opp.Id;
        sv.Comments__c = 'Test Fresh Sv';
        sv.Stage__c = 'In Follow-up';
        insert sv;
        sv.Sourcing_Manager__c = UserInfo.getUserId();
        sv.Comments__c = 'Test Revisit';
        //sv.Stage__c = 'Approved';
        sv.Sales_Manager__c = UserInfo.getUserId();
        // sv.Re_Assign_Sales_Manager__c = UserInfo.getUserId();
        update sv;
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.Channel_Partner_Name__c = cpacc.Id;
        cpl.Project__c = p.Id;
        cpl.Mobile__c = '8889898988';
        // cpl.CP_Project__c = cpp.id;
        insert cpl;
        
         CP_Lead__c cpl1=new CP_Lead__c();
        cpl1.Channel_Partner_Name__c = cpacc.Id;
        cpl1.Project__c = p.Id;
        cpl1.Mobile__c = '8889898988';
        // cpl.CP_Project__c = cpp.id;
        insert cpl1;
         cpl1.Mobile__c = '8889898986';
        update cpl1;
        
        List<CP_Lead__c> leadList = new List<CP_Lead__c>();
        leadList.add(cpl);
        leadList.add(cpl1);
        
        
        
        
        String projid=p.id;
        String cpleadid=cpl.id;
        
        test.startTest();
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        //  Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(projid, l1.Id ,opp.id ,acc2.id,cpleadid);
        
        
        //List<String> resultsubmit1 = Ex_SiteVisitForm.submit(l1.Project__c, l1.Id, null, null, svwrapperResult , true, '', true,  '',  '');
        //List<String> resultsubmit2 = Ex_SiteVisitForm.submit(null, null, null, null, svwrapperResult , false, '', false, '' ,'' );
        Ex_SiteVisitForm.getLeadSource();
        Ex_SiteVisitForm.getLeadSubSource();
        Ex_SiteVisitForm.getSalutation();
        Ex_SiteVisitForm.selectProject();
        Ex_CPLeadHandlerServices.duplicationCheck('Yes', leadList);
        Ex_CPLeadHandlerServices.duplicationCheck('No', leadList);
        Ex_CPLeadHandlerServices.AssignCPProject(leadList);
        
        
        
        
        test.stopTest();
    }
    
    @isTest
    public static void testAccountFound(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
        /*Channel_Partner__c cp1 = new Channel_Partner__c();
        cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp1.RERA_Available__c = 'No';
        cp1.Mobile__c = '9876543210';
        cp1.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId = SObjectType.Channel_Partner__c.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
        cp1.RecordTypeId =cpRecordTypeId;
        insert cp1;*/
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Occupation__c = 'Employed in Pvt. company ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
       // acc2.Current_Residence_Status__c = 'Self-owned';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        //acc2.Residence__c = 'Indian';
        //acc2.Country__c = 'India';
        insert acc2;
        
        CP_Project__c cp = new CP_Project__c();
        //cp.Account__c = cp1.Id;
        cp.Project_Name__c = p.Id;
        insert cp;
        
        CP_Project__c cp2 = new CP_Project__c();
        cp2.OwnerId = userInfo.getUserId();
       // cp2.Account__c = cp1.Id;
        cp2.Project_Name__c = p.Id;
        insert cp2;
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
       // l1.Channel_Partner__c = cp1.Id;
        l1.CP_Project__c = cp2.Id;
        insert l1;
        
        
        Visit_Pre_Registration__c testVPR = new Visit_Pre_Registration__c();
           
            testVPR.Site_Visit_Date__c = System.today();
            testVPR.Status__c = 'Valid';
        
        insert testVPR;
        
        // Test parameters
        String projectId = p.Id;
        Boolean isQRUser = true;
        Boolean changeStatus = true;
        String vpId = testVPR.Id;
        
        test.startTest();
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
       //   Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id ,opp.id ,acc2.id,l1.id);       
        Ex_SiteVisitForm.submit(svwrapperResult1,projectId,true,true,vpId);
        
       // Ex_SiteVisitForm.ge(cp1.Id, p.Id);
       // List<sObject> channelParter =  Ex_SiteVisitForm.fetchLookupData('VG001', 'Channel_Partner__c', p.id);
       // List<sObject> User = Ex_SiteVisitForm.fetchLookupData('Test User', 'User', p.id);
       // Ex_SiteVisitForm.fetchDefaultRecord('Test User', 'User', p.Id);
        
        test.stopTest();
        
    }
    
    @isTest
    public static void testLeadAndOpportunityFound(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
         CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
         CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
       /*Channel_Partner__c cp1 = new Channel_Partner__c();
        cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp1.RERA_Available__c = 'No';
        cp1.Mobile__c = '9876543210';
        cp1.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId = SObjectType.Channel_Partner__c.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
        cp1.RecordTypeId =cpRecordTypeId;
        insert cp1;*/
        
        CP_Project__c cp = new CP_Project__c();
       // cp.Account__c = cp1.Id;
        cp.Project_Name__c = p.Id;
        insert cp;
        
                
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
       // acc2.Current_Residence_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        acc2.BillingCity='pune';
        acc2.BillingState='mp';
        acc2.BillingPostalCode='413304';
        acc2.Current_Resident_Status__c='Rented';
        acc2.Residential_Address__c='delhi';
        acc2.Salutation='Ms.';
        acc2.FirstName='test';
        acc2.Industry__c='Shipping';
        acc2.Office_Location__c='pune';
        acc2.Office_Pincode__c='66777';
        acc2.Family_Size__c='3';
        acc2.Employment_Type__c='Business';
       // acc2.Residence__c = 'Indian';
       // acc2.Country__c = 'India';
        insert acc2;
        
         Account cpacc = new Account();
        cpacc.OwnerId = userInfo.getUserId();
        cpacc.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc.Phone = '9011722426';
        cpacc.Email__c = 'prasad.alamwar@test.com';
        cpacc.PAN_No__c = '676747';
        cpacc.RERA_Available__c = 'No';
        insert cpacc;
        
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = cpacc.Id;
        l1.CP_Project__c = cp.Id;
        insert l1;

        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = acc2.Id;
        opp.CP_Project__c = cp.Id;
        opp.Project__c = p.Id;
        
        //opp.Project_Type__c = 'Residential';
        opp.Buying_Purpose__c = 'Second Home';
        opp.Possession_Timeframe__c = 'RTMI (Ready to Move in)';
        opp.Source__c = 'Channel Partner';
        opp.Sub_Source__c = 'Channel Partner';
        opp.Source_Description__c = 'Test Discription';
        opp.Budget_Range__c = 'Budget of 30 to 40 lakhs';
        opp.Presales_Manager__c = UserInfo.getUserId();
        opp.Sourcing_Manager__c = Userinfo.getUserId();
        opp.Configuration_Required__c = '1 BHK';
        opp.Fist_SV_Date__c = system.today();
        //opp.Channel_Partner__c = cpacc.Id;
        opp.Area_Sq_ft__c='451-650';
        opp.Location__c='new';
        opp.Actual_Budget__c=Decimal.valueOf('6000000');
        opp.Source_of_Funding__c='Loan';
        opp.Any_Pre_existing_Loans__c='No';
        opp.Current_Outstanding_Amount__c=Decimal.valueOf('6776757');
        insert opp;
        
        Opportunity__c opp1 = new Opportunity__c();
        opp1.Account__c = acc2.Id;
        opp1.CP_Project__c = cp.Id;
        opp1.Project__c = p.Id;
        opp1.Source__c = 'Reference';
        opp1.Sub_Source__c = 'Reference';
        opp1.Referrer_Name__c='arati';
        opp1.Fist_SV_Date__c = system.today();
        //opp.Channel_Partner__c = cpacc.Id;
        insert opp1;
        
        
        Opportunity__c newopp =[select id, Account__c, Project__c from Opportunity__c where Id =: opp.Id];
        
        CP_Project__c cp2 = new CP_Project__c();
        cp2.OwnerId = userInfo.getUserId();
       // cp2. = cpacc.Id;
        cp2.Project_Name__c = p.Id;
        insert cp2;
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.CP_Project__c=cp2.id;
        insert cpl;
        
         Visit_Pre_Registration__c testVPR = new Visit_Pre_Registration__c();
           testVPR.Visit_Pre_Registration_Code__c = 'CODE123';
            testVPR.Project__c = p.Id;
            testVPR.Site_Visit_Date__c = System.today();
            testVPR.Status__c = 'Valid';
        
        insert testVPR;
        
        String projid=p.id;
        String cpleadid=cpl.id;
        Boolean isQRUser = true;
        Boolean changeStatus = true;
        String vpId = testVPR.Id;
        
        
        Test.startTest();
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id ,opp.id ,acc2.Id,cpl.id);
         Ex_SiteVisitForm.SVWrapper svwrapperResultt = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id ,opp1.id ,acc2.Id,cpl.id);

        Ex_SiteVisitForm.checkCPData('CODE123',projid);
              
       Ex_SiteVisitForm.submit(svwrapperResult1, projid, isQRUser, changeStatus, vpId);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestAccountandOpportunityFound(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
        Account acc = new Account();
        acc.Name = 'test account';
        acc.City__c = 'Pune';
        //acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('PersonAccount').getRecordTypeId();
        //insert acc;
        
        /*Channel_Partner__c cp1 = new Channel_Partner__c();
        cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp1.RERA_Available__c = 'No';
        cp1.Mobile__c = '9876543210';
        cp1.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId = SObjectType.Channel_Partner__c.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
        cp1.RecordTypeId =cpRecordTypeId;
        insert cp1;*/
        
        CP_Project__c cp = new CP_Project__c();
       // cp.Account__c = cp1.Id;
        cp.Project_Name__c = p.Id;
        insert cp;
        
        CP_Document__c cpd3 = new CP_Document__c();
        cpd3.Name = 'Yes';
        cpd3.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd3;
        
         CP_Document__c cpd4 = new CP_Document__c();
        cpd4.Name = 'No';
        cpd4.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd4;

        CP_Project__c cpproj = new CP_Project__c();
        cpproj.OwnerId = userInfo.getUserId();
       // cpproj. = cp1.Id;
        cpproj.Project_Name__c = p.Id;
        insert cpproj;
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.PersonEmail = 'prasad@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
       // acc2.Current_Residence_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
        //acc2.Residence__c = 'Indian';
        //acc2.Country__c = 'India';
        insert acc2;
        
        Account cpacc = new Account();
        cpacc.OwnerId = userInfo.getUserId();
        cpacc.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc.Phone = '9011722426';
        cpacc.Email__c = 'prasad.alamwar@test.com';
        cpacc.PAN_No__c = '676747';
        cpacc.RERA_Available__c = 'No';
        insert cpacc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Close_Date__c = system.today().addDays(2);
        opp.Account__c = acc2.Id;
        opp.CP_Project__c = cpproj.Id;
        opp.Project__c = p.Id;
        //opp.Project_Type__c = 'Residential';
        opp.Buying_Purpose__c = 'Second Home';
        opp.Possession_Timeframe__c = 'RTMI (Ready to Move in)';
        opp.Source__c = 'Channel Partner';
        opp.Sub_Source__c = 'Channel Partner';
        opp.Source_Description__c = 'Test Discription';
        opp.Budget_Range__c = 'Budget of 30 to 40 lakhs';
        opp.Presales_Manager__c = UserInfo.getUserId();
        opp.Sourcing_Manager__c = Userinfo.getUserId();
        opp.Configuration_Required__c = '1 BHK';
        opp.Fist_SV_Date__c = system.today();
        //opp.Channel_Partner__c = cpacc.Id;
        insert opp;
        
        Opportunity__c newopp =[select id, Account__c, Project__c from Opportunity__c where Id =: opp.Id];
        
        CP_Project__c cp11 = new CP_Project__c();
        cp11.Project_Name__c = p.id;
        //cp11.Account__c = cp1.Id;
        insert cp11;
        
        Lead__c ld = new Lead__c();
        ld.Last_Name__c = 'Test';
        ld.Lead_Source__c = 'Channel Partner';
        ld.Channel_Partner__c = cpacc.Id;
        ld.CP_Project__c = cp11.Id;
        ld.Project__c = p.Id;
        ld.IsConverted__c = true;
        ld.Mobile__c = '9637576210';
        insert ld;
        
        Lead__c ld1 = new Lead__c();
        ld1.Last_Name__c = 'Test';
        ld1.Lead_Source__c = 'Channel Partner';
        ld1.Channel_Partner__c = cpacc.Id;
        ld1.CP_Project__c = cp11.Id;
        ld1.Project__c = p.Id;
        ld1.IsConverted__c = false;
        ld1.Mobile__c = '9637576100';
        insert ld1;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Salutation__c = 'Mr.';
        sv.Mobile__c = '9637576100';
        insert sv;
        
        List<Lead__c> leadList = new List<Lead__c>();
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c =  cpacc.Id;
        l1.CP_Project__c = cp.Id;
        insert l1;
        leadList.add(l1);
        
        
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Account';
        a.PersonMobilePhone = '1122334005';
        a.Phone = 'Test2@gmail.com';
        a.PersonEmail = 'customer12321@test.in';
        a.Company_Name__c = 'test';
        a.City__c = 'Pune';
       // a.Residence__c = 'Indian';
       // a.Country__c = 'India';
        a.Pincode__c = '422610';
        a.Locality__c = 'Mundwa Road';
       // a.Current_Residence_Status__c = 'Self-owned';
        a.Current_Residence_Configuration__c = '3 BHK';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert a;
        a.Salutation = 'Mr.';
        update a;
        
        Visit_Pre_Registration__c testVPR = new Visit_Pre_Registration__c();
           testVPR.Visit_Pre_Registration_Code__c = 'CODE123';
            testVPR.Project__c = p.Id;
            testVPR.Site_Visit_Date__c = System.today();
            testVPR.Status__c = 'Valid';
        
        insert testVPR;
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.CP_Project__c=cp11.id;
        insert cpl;
        String projid=p.id;
        String cpleadid=cpl.id;
        Boolean isQRUser = true;
        Boolean changeStatus = true;
        String vpId = testVPR.Id;
        
        test.startTest();
        Map<string,string> selectProject = Ex_SiteVisitForm.selectProject();
         Ex_SiteVisitForm.projectImage(p.id);
      //  Ex_SiteVisitForm.getSVWrapper(projectId, leadId, oppId, accId, cpLeadId)
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id , opp.Id ,acc2.Id,'test');
       Ex_SiteVisitForm.search('hgfh','hur','ujk');
       // Map<String, List<SObject>> result2 = Ex_SiteVisitForm.search(l1.Mobile__c,l1.Email__c,l1.Project__c);
       // Map<String, List<SObject>> result3 = Ex_SiteVisitForm.searchForData(ld.Mobile__c,l1.Email__c,l1.Project__c);
      //  Ex_SiteVisitForm.submit(svwrapperResult1,p.id,true,true,'demo');
          Ex_SiteVisitForm.submit(svwrapperResult1, projid, isQRUser, changeStatus, vpId);
      //  Ex_SiteVisitForm.saveFile('base64Data', 'fileName', sv);
        Map<Id, Account> result = Ex_LeadConversionServices.getLeadIdAccountMap(leadList);  
        Ex_LeadConversionServices.convertLead(leadList);
        test.stopTest();
    }  
    
    @isTest
    public static void TestLeadandAccountFound(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
         CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
         CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        
        /*Channel_Partner__c cp1 = new Channel_Partner__c();
        cp1.Name_as_per_MahaRERA__c = 'Prop Tiger';
        cp1.RERA_Available__c = 'No';
        cp1.Mobile__c = '9876543210';
        cp1.PAN_No__c = 'ABCDE1234A';
        Id cpRecordTypeId = SObjectType.Channel_Partner__c.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
        cp1.RecordTypeId =cpRecordTypeId;
        insert cp1;*/
        
        Account acc2 = new Account();
        acc2.OwnerId = userInfo.getUserId();
        acc2.LastName = 'Last Name';
        acc2.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc2.PersonMobilePhone = '9637576210';
        //acc2.PersonEmail = 'prasad.alamwar@test.com';
        acc2.PersonEmail = 'prasad@test.com';
        acc2.Ethnicity__c = 'Christian';
        acc2.Age_Group__c = '25 to 30 Years ';
        acc2.Gender__c = 'Male';
        acc2.Occupation__c = 'Employed in Pvt. company ';
        acc2.Marital_Status__c = 'Married';
        acc2.Current_Residence_Configuration__c = '1 BHK';
        acc2.Designation__c = 'Accountant';
       // acc2.Current_Residence_Status__c = 'Self-owned';
        acc2.Current_Residence_Configuration__c = '1 RK';
        acc2.Ethnicity__c = 'Marathi';
        acc2.Designation__c = 'Air Force';
        acc2.Gender__c = 'Male';
        acc2.Company_Name__c = 'Test Comapny';
        acc2.Locality__c = 'Pune';
        acc2.Pincode__c = '422610';
        acc2.City__c = 'Pune';
      //  acc2.Residence__c = 'Indian';
       // acc2.Country__c = 'India';
        insert acc2;
        
         Account cpacc = new Account();
        cpacc.OwnerId = userInfo.getUserId();
        cpacc.Name = 'Last Name';
        cpacc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        cpacc.Phone = '9011722426';
        cpacc.Email__c = 'prasad.alamwar@test.com';
        cpacc.PAN_No__c = '676747';
        cpacc.RERA_Available__c = 'No';
        insert cpacc;
        
        CP_Project__c cp = new CP_Project__c();
     //   cp.Account__c = cp1.Id;
        cp.Project_Name__c = p.Id;
        insert cp;
        
        CP_Project__c cp2 = new CP_Project__c();
        cp2.OwnerId = userInfo.getUserId();
       // cp2.Account__c = cp1.Id;
        cp2.Project_Name__c = p.Id;
        insert cp2;
        
        Lead__c l1 = TestEx_SiteVisitFormController.getLead();
        l1.Project__c = p.Id;
        l1.Channel_Partner__c = cpacc.Id;
        l1.CP_Project__c = cp2.Id;
        insert l1;
        
        Opportunity__c opp=new Opportunity__c();
        opp.Account__c=acc2.id;
        insert opp;
        
        Visit_Pre_Registration__c testVPR = new Visit_Pre_Registration__c();
           testVPR.Visit_Pre_Registration_Code__c = 'CODE123';
            testVPR.Project__c = p.Id;
            testVPR.Site_Visit_Date__c = System.today();
            testVPR.Status__c = 'Valid';
        
        insert testVPR;
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.CP_Project__c=cp.id;
        insert cpl;
        String projid=p.id;
        String cpleadid=cpl.id;
        Boolean isQRUser = true;
        Boolean changeStatus = true;
        String vpId = testVPR.Id;
        
        test.startTest();
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        //  Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id , opp.Id ,acc2.Id,'test');
        //Ex_SiteVisitForm.SVWrapper svwrapperResult = Ex_SiteVisitForm.getSVWrapper(p.Id , l1.Id , null ,acc2.Id, svwrapperResult1, 'Yes', false);
        //List<String> resultsubmit2 = Ex_SiteVisitForm.submit(l1.Project__c, l1.Id, null, acc2.Id, svwrapperResult , false, '', false,'','');
         // Ex_SiteVisitForm.submit(svwrapperResult1,p.id,true,true,'demo');
  Ex_SiteVisitForm.submit(svwrapperResult1, projid, isQRUser, changeStatus, vpId);
        test.stopTest();
    }
    
    @isTest
    static void testSubmitMethod() {
        // Create test data for the Account and Project
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'User',
            PersonMobilePhone = '9999999999',
            PersonEmail = 'testuser@example.com'
        );
        insert testAccount;

        Project__c testProject = new Project__c(Name = 'Test Project');
        insert testProject;

        // Simulate Site Visit creation without existing Opportunity or Lead
        Site_Visit__c testSiteVisit = new Site_Visit__c(
            Mobile__c = '9999999999',
            Email__c = 'testuser@example.com',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Budget_Range__c = '30-40 Lakhs',
            Buying_Purpose__c = 'Investment',
            Configuration_Required__c = '2 BHK',
            Possession_Timeframe_Required__c = '6-12 Months'
        );

        // Simulate the scenario with no Opportunity or Lead found
        //SVWrapper wrapper = new SVWrapper();
        Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        svwrapperResult1.sv = testSiteVisit;

        Test.startTest();
        Map<Id, String> resultMap = Ex_SiteVisitForm.submit(
            svwrapperResult1,
            testProject.Id,
            true,  // isQRUser
            false, // changeStatus
            null   // vpId
        );
        Test.stopTest();

       
          }

    @isTest
    static void testLeadConversionScenario() {
        // Create test Lead
        Lead__c testLead = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Lead',
            Mobile__c = '8888888888',
            Email__c = 'testlead@example.com',
            Lead_Stage__c = 'Incoming',
            Project__c = null
        );
        insert testLead;

        // Simulate Site Visit creation for a Lead
        Site_Visit__c testSiteVisit = new Site_Visit__c(
            Mobile__c = '8888888888',
            Email__c = 'testlead@example.com',
            First_Name__c = 'Test',
            Last_Name__c = 'Lead'
        );

        
         Ex_SiteVisitForm.SVWrapper svwrapperResult1 = new Ex_SiteVisitForm.SVWrapper();
        svwrapperResult1.sv = testSiteVisit;


        Test.startTest();
        Map<Id, String> resultMap = Ex_SiteVisitForm.submit(
            svwrapperResult1,
            null, // No project ID
            true, // isQRUser
            false, // changeStatus
            null  // vpId
        );
        Test.stopTest();

        // Assertions for Lead conversion
        Lead__c convertedLead = [SELECT Converted_Opportunity__c FROM Lead__c WHERE Id = :testLead.Id];
        System.assertNotEquals(null, convertedLead.Converted_Opportunity__c, 'Lead should be converted to an Opportunity.');

        Opportunity__c convertedOpp = [SELECT Id, SV_Count__c FROM Opportunity__c WHERE Id = :convertedLead.Converted_Opportunity__c];
        System.assertEquals(1, convertedOpp.SV_Count__c, 'SV Count should be updated in converted Opportunity.');

        // Assertions for Site Visit linking
        Site_Visit__c createdSV = [SELECT Opportunity__c FROM Site_Visit__c WHERE Opportunity__c = :convertedOpp.Id];
        System.assertNotEquals(null, createdSV, 'Site Visit should be linked to the converted Opportunity.');
    }

}