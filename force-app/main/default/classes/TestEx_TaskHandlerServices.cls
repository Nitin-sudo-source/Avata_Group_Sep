@isTest
public class TestEx_TaskHandlerServices {
     @isTest
    public static Project__c createProject() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        return p;
    }
    
    @isTest
    public static void createPresaleCall() {
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Lead_Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id);
        insert l1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = l1.Id;

        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Busy';
        t.Stage__c = 'Prospects';
        t.Sub_Stage__c = 'Hot';
        t.Status = 'Open';
        t.Next_Follow_Up_Date__c = system.today().addDays(1);
        insert t;
        
        t.Stage__c = 'Incoming';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
    }
    
    @isTest
    public static void sendBrochuretoCustomer(){
        Project__c p = createProject();
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('Data');
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        try {
            insert cv;
        } catch(DMLException e) {
            System.debug(e);
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id =: cv.id
        ].ContentDocumentId;
        cdl.LinkedEntityId = p.id;
        cdl.ShareType = 'V';
        
        insert cdl;
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Lead_Stage__c = 'Incoming', Mobile__c = '1122334433', Email__c='nitinc893@gmail.com' ,Project__c = p.Id);
        insert l1;
        
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = l1.Id;

        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Busy';
        t.Stage__c = 'Prospects';
        t.Sub_Stage__c = 'Hot';
        t.Status = 'Completed';
        t.Next_Follow_Up_Date__c = system.today().addDays(1);
        insert t;
    }
    
	@isTest
    public static void coldCall(){
        
        Project__c p = createProject();
        
        
        
    }  
    
    @isTest
    public static void createSalesCall() {
        Project__c p = createProject();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '1122334455',RecordtypeId = rtId);
        insert a;
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp',Account__c = a.Id,Stage__c = 'In Follow-up',Project__c = p.Id);
        insert op;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = op.Id;
        t.Type = 'Sales Call';
        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Busy';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        insert t;
    }
    @isTest
    public static void createCPCall() {
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t.Subject = 'CP Call';
        t.WhatId = cp1.Id;
        
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        insert t;
    }
    @isTest
    public static void createCPMeetingCall() {
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Meeting').getRecordTypeId();
        t.Subject = 'CP Meeting';
        t.WhatId = cp1.Id;
       // t.Call_Status__c = 'Call Completed';
        t.Priority = 'Normal';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Meeting_Type__c = 'None';
        t.Status = 'Completed';
        t.Description = 'Test Call';
        insert t;
    }
    @isTest
    public static void testCPLeadCall(){
        Project__c p = createProject();
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        List<Cp_Lead__c> cpLeadList = new List<Cp_Lead__c>();
        Cp_Lead__c cpLead = new Cp_Lead__c();
        cpLead.CP_Project__c = cp1.Id;
        cpLead.First_Name__c = 'Test';
        cpLead.Last_Name__c = 'Call';
        cpLead.Email__c = 'testcplead123@gmail.com';
        cpLead.Phone__c = '6357428767';
        cpLead.Mobile__c = '6666371789';
        insert cpLead;
        
        cpLead.Email__c = 'testcp123@gmail.com';
        update cpLead;
        cpLeadList.add(cpLead);
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Lead Call').getRecordTypeId();
        t.Subject = 'CP Lead Call';
        t.WhatId = cpLead.Id;
       // t.Call_Status__c = 'Call Completed';
        t.Priority = 'Normal';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Meeting_Type__c = 'None';
        t.Status = 'Completed';
        t.Description = 'Test Call';
        insert t;
        
        Test.startTest();
        // Ex_CPLeadHandlerServices.duplicationCheck('No', cpLeadList);
        Test.stopTest();
        
    }
     @isTest
    public static void createPresaleCallforAccount() {
        Project__c p = createProject();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a1 = new Account(FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455',RecordtypeId = rtId);
        insert a1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = a1.Id;
        t.Type = 'Presales Call';
        t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
       // t.Call_Status__c = 'Answered';
        t.Status = 'Open';
         t.Next_Follow_Up_Date__c = system.today().addDays(1);
        insert t;
        
        CP_Project__c cp1 = new CP_Project__c( Project_Name__c = p.Id);
        insert cp1;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t1.Subject = 'Call';
        t1.WhatId = cp1.Id;
        t1.Type = 'CP Call';
        t1.CallType = 'Inbound';
        t1.Status = 'Completed';
        t1.Priority = 'Normal';
       // t.Call_Status__c = 'Answered';
        t1.Status = 'Open';
        insert t1;
        
        t.Stage__c = 'Incoming';
        t.Sub_Stage__c = '';
        t.Sub_Stage_Reason__c = ' ';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
    }
    
    @isTest
    public static void createCPLeadCall() {
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
        
      
        
       
        
        CP_Lead__c cpl=new CP_Lead__c();
        cpl.Channel_Partner_Name__c = cpacc.Id;
        cpl.Project__c = p.Id;
        cpl.Mobile__c = '8889898988';
        // cpl.CP_Project__c = cpp.id;
        insert cpl;
        
          Opportunity__c opp = new Opportunity__c();
        opp.CP_Lead__c = cpl.Id;
        opp.Account__c = acc2.Id;
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
        
        
        CP_Lead__c cpl1=new CP_Lead__c();
        cpl1.Channel_Partner_Name__c = cpacc.Id;
        cpl1.Project__c = p.Id;
        cpl1.Mobile__c = '8889898900';
        // cpl.CP_Project__c = cpp.id;
        insert cpl1;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Lead Call').getRecordTypeId();
        t1.Subject = 'CP Lead Call';
        t1.WhatId = cpl1.Id;
        t1.CallType = 'Inbound';
        t1.Status = 'Completed';
        t1.Priority = 'Normal';
        // t.Call_Status__c = 'Answered';
        t1.Status = 'Open';
        insert t1;
        
        opp.CP_Lead__c = cpl1.Id;
        update opp;
          List<Opportunity__c> newOPPTaskUpdateList = new List<Opportunity__c>();
        newOPPTaskUpdateList.add(opp);
        Ex_OpportunityHandlerServices.updateTaskOnOpp(newOPPTaskUpdateList);
    }
    
    

}