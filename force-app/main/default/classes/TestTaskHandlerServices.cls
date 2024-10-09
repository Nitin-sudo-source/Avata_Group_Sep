@isTest
public class TestTaskHandlerServices {
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
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Stage__c = 'Incoming', Mobile__c = '1122334455', Project__c = p.Id);
        insert l1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = l1.Id;
        //t.Type = 'Presales Call';
        //t.CallType = 'Inbound';
        t.Status = 'Open';
        t.Priority = 'Normal';
       // t.Call_Status__c = 'Call Complete'; 
       // t.Next_Follow_up_Date__c = system.today().addDays(2);
        t.Next_Action_Date__c = system.today().addDays(2);


        insert t;
        
        t.Stage__c	 = 'Incoming';
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t1.Subject = 'Call';
        t1.WhatId = l1.Id;
       // t1.Type = 'Presales Call';
       // t1.CallType = 'Inbound';
        t1.Priority = 'Normal';
       // t1.Call_Status__c = 'Call Complete';
        t1.Stage__c = 'Incoming';
        t1.Next_Action_Date__c = system.today().addDays(6);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
    }
    
     @isTest
    public static void createSalesCall() {
        Project__c p = createProject();
		        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '1122334455');
        insert a;
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Stage__c = 'In Follow-up',Project__c = p.Id);
        insert op;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.WhatId = op.Id;
       // t.Type = 'Sales Call';
       // t.CallType = 'Inbound';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.Other_Reason__c = 'Testttt';
        insert t;
        
        t.Stage__c = 'In Follow-up';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        update t;
        
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t1.Subject = 'Call';
        t1.WhatId = op.Id;
        //t1.Type = 'Sales Call';
       // t1.CallType = 'Inbound';
        t1.Priority = 'Normal';
        t1.Other_Reason__c = 'testts';
        t1.Stage__c = 'In Follow-up';
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
    }
    
    
    @isTest
    public static void createChannelPartner() {  
        Test.startTest();
        Id cpRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Marketing Partner Account').getRecordTypeId();
        Account a = new Account();
        a.OwnerId = UserInfo.getUserId();
        system.debug('a.OwnerId:::'+a.OwnerId);
        a.RecordTypeId = cpRecordTypeId;
        a.Name = 'CPAccount';
        a.Mobile__c = '1122334455';
        a.Email__c = 'customer@test.in';
        a.Firm_Name__c = 'Testttt';
       // a.CP_Code__c = '2476vv';
        a.MahaRERA_Registration_No__c = '4376bbsjfh';
        insert a;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Partner Call / Meeting').getRecordTypeId();
        t.Subject = 'Call';
        t.Description = 'Test Description';
        t.CP_Stage__c = 'Prospect';
        t.CP_Sub_Stage__c = 'High Potential';
        t.Next_Action_Date__c = Date.today().addDays(1);
        insert t;
        
        Map<Id, List<Task>> mapRollUpCp = new Map<Id, List<Task>>();
        mapRollUpCp.put(a.Id, new List<Task>{ t });
        
      
        TaskHandlerServices.RollUpTaskChannelPartnerServices(mapRollUpCp, 'insert', false);
        
        
        Test.stopTest();
       
    }
}