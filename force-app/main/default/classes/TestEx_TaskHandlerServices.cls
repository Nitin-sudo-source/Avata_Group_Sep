@isTest
public class TestEx_TaskHandlerServices {
    
    @isTest
    public static void testCallHandlerServices() {
        // Create project
        Project__c p = createProject();

        // Create tasks for Presales Call
        Lead__c ld = new Lead__c();
        ld.Mobile__c = '9090888888';
        ld.Email__c = 'Testemail@gmail.com';
        ld.Lead_Source__c = 'Google';
        ld.Lead_Sub_Source__c = 'Google Search';
        ld.Lead_Stage__c = 'Incoming';
        ld.Project__c = p.Id;
        ld.Presales_Call_Count__c = 0;
        insert ld;

        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t1.Subject = 'Presales Call';
        t1.Call_Status__c = 'Not Answered';
        t1.Stage__c = 'Incoming';
        t1.Sub_Stage__c = 'Not Answering';
        t1.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t1.Next_Follow_Up_Date__c = System.today().addDays(1);
        t1.WhatId = ld.Id;
        t1.Status = 'Completed';
        insert t1;

        Task t2 = new Task();
        t2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t2.Subject = 'Presales Call';
        t2.Call_Status__c = 'Not Answered';
        t2.Stage__c = 'Incoming';
        t2.Sub_Stage__c = 'Not Answering';
        t2.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t2.Next_Follow_Up_Date__c = System.today().addDays(1);
        t2.WhatId = ld.Id;
        t2.Status = 'In Progress';
        insert t2;
        
        Task t3 = new Task();
        t3.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t3.Subject = 'Presales Call';
        t3.Call_Status__c = 'Not Answered';
        t3.Stage__c = 'Visit Confirmed';
        t3.Sub_Stage__c = 'Visit Confirmed';
        t3.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t3.Next_Follow_Up_Date__c = System.today().addDays(1);
        t3.WhatId = ld.Id;
        t3.Status = 'In Progress';
        insert t3;
       
        // Create a Set of Task IDs
        Set<Id> taskIdSet = new Set<Id>{t1.Id, t2.Id};
            
        Test.startTest();
        Ex_TaskHandlerServices.CallHandlerServices(taskIdSet, 'update', true);
        Test.stopTest();
    }
    
    @isTest
    public static Project__c createProject(){
        Project__c p = new Project__c();
        p.Name = 'test projec';
        p.Source_TAT__c = 45;
        p.Assignment_TAT__c = 60;
        insert p;
        return p;
    }
    
    @isTest 
    public static void createPresalesCall(){
        Project__c p = TestEx_TaskHandlerServices.createProject();
        
        Lead__c ld = new Lead__c();
        ld.Mobile__c = '9090888888';
        ld.Email__c = 'Testemail@gmail.com';
        ld.Lead_Source__c = 'Google';
        ld.Lead_Sub_Source__c = 'Google Search';
        ld.Lead_Stage__c = 'Incoming';
        ld.Project__c = p.id;
        ld.Presales_Call_Count__c = null;
        insert ld;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Presales Call';
        t.Call_Status__c = 'Not Answered';
        t.Stage__c = 'Incoming';
        t.Sub_Stage__c = 'Not Answering';
        t.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t.Next_Follow_Up_Date__c = System.today().addDays(1);
        t.WhatId = ld.Id;
        t.Status = 'Completed';
        
        insert t;
        
        t.Stage__c = 'SNP';
        t.Sub_Stage__c = 'SNP';
        update t;  
        
        Task t2 = new Task();
        t2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t2.Subject = 'Presales Call';
        t2.Call_Status__c = 'Not Answered';
        t2.Stage__c = 'Incoming';
        t2.Sub_Stage__c = 'Not Answering';
        t2.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t2.Next_Follow_Up_Date__c = System.today().addDays(1);
        t2.WhatId = ld.Id;
        t2.Status = 'In Progress';
        
        insert t2;
        
        t2.Stage__c = 'SNP';
        t2.Sub_Stage__c = 'SNP';
        t2.Status = 'Completed';
        update t;  
        
        Task t3 = new Task();
        t3.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t3.Subject = 'Presales Call';
        t3.Call_Status__c = 'Not Answered';
        t3.Stage__c = 'Visit Confirmed';
        t3.Sub_Stage__c = 'Visit Confirmed';
        t3.Proposed_Date_Of_Visit__c = System.today().addDays(3);
        t3.Next_Follow_Up_Date__c = System.today().addDays(1);
        t3.WhatId = ld.Id;
        t3.Status = 'In Progress';
        
        insert t3; 
    }
    
    @isTest 
    public static void createSalesCall(){
        Project__c p = TestEx_TaskHandlerServices.createProject();
        
        Id accountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account a = new Account();
        a.LastName = 'Test acc';
        a.Alternate_Mobile__c    = '9090777777';
        a.PersonEmail = 'Testemailseven@gmail.com';
        a.RecordTypeId = accountRecTypeId;
        insert a;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = a.Id;
        opp.Name = 'New opp';
        opp.Project__c = p.id;
        opp.Opportunity_Stage__c = 'In Follow-up';
        opp.Sales_Call_Count__c = null;
        opp.Last_Sales_Call_Comment__c = 'Test';
        insert opp;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t.Subject = 'Call';
        t.Stage__c = 'In Follow-up';
        t.Sub_Stage__c = 'Warm';
        t.Proposed_Date_Of_Visit__c = System.today().addDays(3) ;
        t.Next_Follow_Up_Date__c = System.today().addDays(1);
        t.WhatId = opp.Id;
        t.Status = 'Completed';
        insert t;
        
        t.Proposed_Date_Of_Visit__c = System.today().addDays(5) ;
        t.Sub_Stage__c = 'Hot';
        update t;
    }
    
    @isTest
    public static void createCPCall(){
        Project__c p = TestEx_TaskHandlerServices.createProject();
        
        CP_Project__c cpp = new CP_Project__c();
        cpp.Project__c = p.Id;
        insert cpp;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t.Subject = 'CP Call';
        t.WhatId = cpp.Id;
        t.Status = 'Completed';
        t.Call_Status__c = 'Answered';
        t.Next_Follow_Up_Date__c = System.today().addDays(1);
        insert t;
    }
    
    @isTest
    public static void createCPMeeting(){
        Project__c p = TestEx_TaskHandlerServices.createProject();
        
        CP_Project__c cpp = new CP_Project__c();
        cpp.Project__c = p.Id;
        insert cpp;
        
        Task t = new Task();    
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Meeting').getRecordTypeId();
        t.Status =  'Completed';
        t.Next_Follow_Up_Date__c = System.today().addDays(2);
        t.Subject = 'CP Meeting';
        t.WhatId = cpp.Id;
        insert t;
    }
    
    @isTest
    public static void testEnquiryTasks() {
        // Create Project
        Project__c project = createProject();
        
       
        
        Project__c p = createProject();
        
        CP_Project__c cpp = new CP_Project__c();
        cpp.Project__c = p.Id;
        insert cpp;
        
    }
    
    @isTest
    public static void testRollUpTaskLeadServices() {
    // Create a project for the lead
    Project__c project = createProject();

    // Create Lead
    Lead__c lead = new Lead__c();
    lead.Mobile__c = '9090888888';
    lead.Email__c = 'Testemail@gmail.com';
    lead.Lead_Source__c = 'Google';
    lead.Lead_Sub_Source__c = 'Google Search';
    lead.Lead_Stage__c = 'Incoming';
    lead.Project__c = project.Id;
    lead.Presales_Call_Count__c = 0;
    
    insert lead;

    // Create Task 1 - Completed Task
    Task task1 = new Task();
    task1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
    task1.Subject = 'Presales Call';
    task1.Call_Status__c = 'Not Answered';
    task1.Stage__c = 'Incoming';
    task1.Sub_Stage__c = 'Not Answering';
    task1.Proposed_Date_Of_Visit__c = System.today().addDays(2);
    task1.Next_Follow_Up_Date__c = System.today().addDays(1);
    task1.WhatId = lead.Id;
    task1.Status = 'Completed';
    task1.Description = 'First call attempt';
    insert task1;

    // Create Task 2 - Visit Confirmed Task
    Task task2 = new Task();
    task2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
    task2.Subject = 'Presales Call';
    task2.Call_Status__c = 'Answered';
    task2.Stage__c = 'Visit Confirmed';
    task2.Sub_Stage__c = 'Visit Confirmed';
    task2.Proposed_Date_Of_Visit__c = System.today().addDays(5);
    task2.Next_Follow_Up_Date__c = System.today().addDays(3);
    task2.WhatId = lead.Id;
    task2.Status = 'In Progress';
    task2.Description = 'Visit confirmed call';
    insert task2;

    // Prepare the map for roll-up
    Map<Id, List<Task>> mapRollUpLead = new Map<Id, List<Task>> {
        lead.Id => new List<Task> {task1, task2}
    };
    
    Test.startTest();
    // Call the RollUpTaskLeadServices method
    Ex_TaskHandlerServices.RollUpTaskLeadServices(mapRollUpLead, 'insert', true);
    Test.stopTest();
    
    // Fetch the updated Lead record
    Lead__c updatedLead = [SELECT Id, Presales_Call_Count__c, Last_Presales_Call_Date__c, Presales_Call_Comment__c, 
                           Presales_Comment_History__c, Lead_Stage__c, Lead_Sub_Stage__c, First_Visit_Confirmed_Date__c 
                           FROM Lead__c WHERE Id = :lead.Id];
}

    
    @isTest
    public static void testCPCallCommentHistory() {
        // Create a project
        Project__c project = createProject();

        // Create CP_Project__c record
        CP_Project__c cpProject = new CP_Project__c();
        cpProject.Project__c = project.Id;
        cpProject.Last_CP_Call_Remarks__c = 'Initial call remarks'; // Ensure this is not null
        cpProject.CP_Call_Comment_History__c = null;
        cpProject.CP_Meeting_Comment_History__c = '';
        insert cpProject;
        
        // Create Task for CP Call
        Task cpCallTask = new Task();
        cpCallTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        cpCallTask.Subject = 'CP Call';
        cpCallTask.WhatId = cpProject.Id;
        cpCallTask.Status = 'Completed';
        cpCallTask.Call_Status__c = 'Answered';
        insert cpCallTask;
        
        // Simulate the roll-up logic
        Map<Id, List<Task>> mapRollUpCP = new Map<Id, List<Task>> {
            cpProject.Id => new List<Task> {cpCallTask}
        };
        
        Test.startTest();
        Ex_TaskHandlerServices.RollUpTaskLeadServices(mapRollUpCP, 'update', true);
        Test.stopTest();
        
        // Fetch the updated CP_Project__c record
        CP_Project__c updatedCPProject = [SELECT Id, CP_Call_Comment_History__c FROM CP_Project__c WHERE Id = :cpProject.Id];
    }
}