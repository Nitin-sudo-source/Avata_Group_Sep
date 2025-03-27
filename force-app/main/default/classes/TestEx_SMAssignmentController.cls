@istest
public class TestEx_SMAssignmentController {
    
    @isTest
    public static void testSM(){
        Test.startTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'Test';
        u.Username = 'testtesttetst@test.com';
        u.Email = 'test323232@test.com';
        u.Alias = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = profileId.id ;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        project__c pr = createProject();
        
        Team__c t = new Team__c();
        t.Name = 'Sales Team'; 
        t.Project__c = pr.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        
        
        Team_Member__c tm = new Team_Member__c();
        tm.Availability__c = true;
        tm.Team__c = t.Id;
        tm.User__c = u.id;
        tm.DayOff__c = false;
        insert tm;
        
        Team_Member__c tm1 = new Team_Member__c();
        tm1.Availability__c = false;
        tm1.Team__c = t.Id;
        tm1.User__c = u.Id;
        insert tm1;
        
        List<Team_Member__c> userList = new  List<Team_Member__c>();
        userList = [Select Id, User__r.Name, User__r.Id, Availability__c, Assignment_Counter__c ,Last_Assignment_DateTime__c, Last_Assignment_Milliseconds__c, DayOff__c, User__c from Team_Member__c
                                        where User__c =: tm.User__c AND Id =: tm.Id];
        System.debug('userList: '+userList);
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
        CP_Document__c cpd1 = new CP_Document__c();
        cpd1.Name = 'No';
        cpd1.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd1;
        
        /*Id cpRtId = Schema.SObjectType.Channel_Partner.getRecordTypeInfosByName().get('CP Mira Road').getRecordTypeId();
        Channel_Partner__c cpAccount = new Channel_Partner__c(
            Channel_Partner_Name__c = 'Test CP1',
            Mobile__c = '1122334455',
            RERA_Available__c = 'No',
            Name_as_per_MahaRERA__c = 'GujRERA',
            MahaRERA_Registration_No__c = '1234',
            RecordTypeId = cpRtId
        );
        insert cpAccount;*/
        
        /*CP_Project__c cp=new CP_Project__c();
        cp.Account__c = cpAccount.Id;
        cp.Project__c = pr.Id;
        insert cp;
        Set<Id> cpProjId = new Set<Id>();
        cpProjId.add(cp.Id);*/
        
        Site_Visit__c  sv = new Site_Visit__c  ();
        sv.City__c = 'Mumbai';
        //sv.Country__c = 'India';
        sv.Occupation__c = 'Retired';
        sv.Project__c = t.Project__c;
        insert sv;
        sv.OwnerId = userList[0].User__r.Id;
        sv.Comments__c = 'testtt';
        sv.Site_Visit_Count__c = 2;
        update sv;
        
        Set<Id> svIdSet = new Set<Id>();
        svIdSet.add(sv.Id);
                
        
        
        Ex_SMAssignmentController.getSVRecord(sv.Id);
        Ex_SMAssignmentController.getAllSalesManager(sv);
        Ex_SMAssignmentController.checkUserAvailability(tm.Id);
        Ex_SMAssignmentController.assignSalesManager(sv, userList[0]);
        Ex_SMAssignmentController.getPreferredSalesManager(sv);
        //Ex_SMAssignmentController.reAssignSalesManager(sv, userList[0], true);
        //Ex_SMAssignmentController.
        //Ex_SiteVisitHandlerServices.apexSharingWithSourcingManager(svIdSet);
        //Ex_SiteVisitHandlerServices.removeSharingWithSourcingManagerOnSV(svIdSet);
        Test.stopTest(); 
        
        
    }
    
    public static project__c createProject()
    {
        Project__c pr = new Project__c();
        pr.Name = 'test project';
        insert pr;
        return pr;
    }
    
    public static void updateTeam(){
        Test.startTest();
        
        Team__c salesTeam = new Team__c(Team_Type__c = 'Sales Team');
        insert salesTeam;
        
        Team_Member__c tm2 = new Team_Member__c();
        tm2.Team__c = salesTeam.Id;
        tm2.User__c = UserInfo.getUserId();
        tm2.Availability__c = true;
        insert tm2;
        
        Set<Id> uIdSet = new Set<Id>();
        uIdSet.add(tm2.User__c);

        //Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);

        
        Test.stopTest();
    }

    @isTest
   public static void testUpdateSalesManagerAvailability() {
       User u = new User(
           ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
           LastName = 'last',
           Email = 'puser000@amamama.com',
           Username = 'puser000@amamama.com' + System.currentTimeMillis(),
           CompanyName = 'TEST',
           Title = 'title',
           Alias = 'alias',
           TimeZoneSidKey = 'America/Los_Angeles',
           EmailEncodingKey = 'UTF-8',
           LanguageLocaleKey = 'en_US',
           LocaleSidKey = 'en_US'
       );
       
        project__c pr = createProject();


        // Create a Sales Team record related to the test User
        Team__c testTeam = new Team__c(
            Name = 'Test Team',
            Team_Type__c = 'Sales Team',
            Project__c = pr.Id
        );
        insert testTeam;

        Team_Member__c testTeamMember = new Team_Member__c(
            User__c = u.Id,
            Team__c = testTeam.Id,
            Availability__c = false
        );
        insert testTeamMember;

        Set<Id> uIdSet = new Set<Id>();
        uIdSet.add(u.Id);

       /* Test.startTest();
        Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);
        Test.stopTest();*/
    }
    

}