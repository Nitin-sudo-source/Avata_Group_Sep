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
    public static void createCPCall() {
        Project__c p = createProject();
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
         Account a = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        
        insert a ;
        
        CP_Sub_Account__c cp = new CP_Sub_Account__c();
        cp.Account__c = a.id;
        cp.Name = 'test';
        insert cp;
       
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Opportunity_Stage__c = 'In Follow-up', Opportunity_Sub_Stage__c = 'Hot', Opportunity_Sub_Stage_Reason__c = 'All Good Expected Closure' , Project__c = p.Id);
        insert op;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t.Subject = 'CP Call';
        t.WhatId = cp.Id;
        //t.Stage__c = 'Active';
       // //t.Sub_Stage__c = 'Open';
       // t.Sub_Stage_Reason__c = 'All Good Expected Closure';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed'; 
        insert t;
        
       
        t.Next_Follow_up_Date__c = system.today().addDays(5);
        t.Description = 'Test Call';
        update t;
        
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t1.Subject = 'CP Call';
        t1.WhatId = cp.Id;
        
        t1.Status = 'Open';
        t1.Priority = 'Normal';
        t1.Call_Status__c = 'Call Completed';
        //t1.Stage__c = 'Active';
       
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
        
       
       
    }
    
    
    @isTest
    static void testRollUpTaskCPProjectServices() {
        // Step 1: Set up test data
        // Create a sample CP_Project__c record
        CP_Project__c cpProject = new CP_Project__c(
            // Initialize required fields as necessary
        );
        insert cpProject;
        
        // Create some sample Task records
        List<Task> taskList = new List<Task>();
        
        Task cpCallTask = new Task(
            Subject = 'CP Call',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CP Call' AND SObjectType = 'Task' LIMIT 1].Id,
            Description = 'Call to discuss project updates',
            Next_Call_Action_Date__c = DateTime.now().addDays(7)
        );
        
        Task cpMeetingTask = new Task(
            Subject = 'CP Meeting',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'CP Meeting' AND SObjectType = 'Task' LIMIT 1].Id,
            Description = 'Meeting to finalize project details',
            Next_Meeting_Date__c = DateTime.now().addDays(7)
        );
        
        taskList.add(cpCallTask);
        taskList.add(cpMeetingTask);
        
        // Insert tasks
        insert taskList;
        
        // Step 2: Prepare the Map for roll-up
        Map<Id, List<Task>> mapRollUpCp = new Map<Id, List<Task>>();
        mapRollUpCp.put(cpProject.Id, taskList);
        
        // Step 3: Invoke the method to test
        Test.startTest();
        Ex_TaskHandlerServices.RollUpTaskCPProjectServices(mapRollUpCp, 'someOperation', true);
        Test.stopTest();
        
        // Step 4: Assert the expected results
        // Re-query the CP_Project__c record to check for updates
        CP_Project__c updatedProject = [SELECT Last_CP_Call_Date__c, Last_CP_Call_Next_Action_Date__c, Last_CP_Call_Remarks__c, 
                                        Last_CP_Meeting_Date__c, Last_CP_Meeting_Action_Date__c, Last_CP_Meeting_Remarks__c 
                                        FROM CP_Project__c WHERE Id = :cpProject.Id];
        
        // Assert that the call task fields were updated correctly
        
    }

    
	@isTest
    public static void createPresaleCall() {
        Project__c p = createProject();
        
        Lead__c l1 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 1', Mobile__c = '1122334455', Project__c = p.Id);
        insert l1;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t.Subject = 'Presales Call';
        t.WhatId = l1.Id;
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed';
        t.Stage__c='Incoming';
        t.Sub_Stage__c='Not Answering';
        t.Next_Follow_up_Date__c=system.today().addDays(2);
        insert t;
        
        t.Stage__c='Visit Confirmed';
        t.Sub_Stage__c='Visit Confirmed';
        t.Date_of_Visit__c=system.today().addDays(5);
        update t;
        
        
        Task t5 = new Task();
        t5.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t5.Subject = 'Call';
        t5.WhatId = l1.Id;
        t5.Type = 'Sales Call';
        t5.CallType = 'Inbound';
        t5.Status = 'Open';
        t5.Priority = 'Normal';
        t5.Call_Status__c = 'Call Completed'; 
        insert t5;
      
       Task t3 = new Task();
        t3.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Meeting').getRecordTypeId();
        t3.Subject = 'Call';
        t3.WhatId = l1.Id;
        t3.Type = 'CP Meeting';
        t3.CallType = 'Inbound';
        t3.Status = 'Open';
        t3.Priority = 'Normal';
        t3.Call_Status__c = 'Meeting Completed'; 
        insert t3;
        
        
        Task t4 = new Task();
        t4.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Call').getRecordTypeId();
        t4.Subject = 'Call';
        t4.WhatId = l1.Id;
        t4.Type = 'CP Call';
        t4.CallType = 'Inbound';
        t4.Status = 'Open';
        t4.Priority = 'Normal';
       // t4.Call_Status__c = 'Meeting Completed'; 
        insert t4;
        
        
     
        
        //t.Stage__c	 = 'SNP';
        //t.Sub_Stage__c = 'SNP';
       // t.Sub_Stage_Reason__c = 'Switched off';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Description = 'Test Call';
        t.Status = 'Completed';
        update t;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t1.Subject = 'Presales Call';
        t1.WhatId = l1.Id;
        
        t1.Priority = 'Normal';
        t1.Call_Status__c = 'Call Completed';
        //t1.Stage__c	 = 'SNP';
       // t1.Sub_Stage__c = 'SNP';
        //t1.Sub_Stage_Reason__c = 'Switched off';
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
    }
    
     @isTest
    public static void createSalesCall() {
        Project__c p = createProject();
		        
        Account a = new Account(FirstName = 'Test', LastName = 'Account', PersonMobilePhone = '1122334455', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId());
        insert a;
        Opportunity__c op = new Opportunity__c(Name = 'Test Opp', Account__c = a.Id, Opportunity_Stage__c = 'In Follow-up', Opportunity_Sub_Stage__c = 'Hot', Opportunity_Sub_Stage_Reason__c = 'All Good Expected Closure' , Project__c = p.Id);
        insert op;
        
        Task t = new Task();
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t.Subject = 'Sales Call';
        t.WhatId = op.Id;
        t.Stage__c='In Follow-up';
        t.Sub_Stage__c='Cold';
        t.Sub_Stage_Reason__c='General Enquiry';
        t.Next_Follow_up_Date__c = system.today().addDays(1);
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed'; 
        insert t;
        
        t.Stage__c = 'In Follow-up';
        t.Sub_Stage__c = 'Hot';
        t.Sub_Stage_Reason__c = 'All Good Expected Closure';
        t.Next_Follow_up_Date__c = system.today().addDays(5);
        t.Description = 'Test Call';
        update t;
        
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Call').getRecordTypeId();
        t1.Subject = 'Sales Call';
        t1.WhatId = op.Id;
        
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.Call_Status__c = 'Call Completed';
        t.Stage__c = 'In Follow-up';
        t.Sub_Stage__c = 'Hot';
        t.Sub_Stage_Reason__c = 'All Good Expected Closure';
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        t1.Status = 'Completed';
        insert t1;
        
    }
    
   
  
   @isTest
    public static void CreateAcc(){
        Project__c pr = new Project__c();
        pr.Name = 'Test Project';
        insert pr;
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name='Yes';
        cpd.Document_Required__c='Pan Card, GST Registration Certificate, RERA Certificate, Passport';
        insert cpd;
        
         Account a = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId(),
            RERA_Available__c = 'Yes',
            MahaRERA_Registration_No__c = 'mah123',
            CP_Type__c = 'ICP',
            Owner_Name__c = 'Test',
            Owner_Mobile_No__c = '8989898989',
            Name_as_per_MahaRERA__c = 'testt'
        );
        
        insert a ;
        
        Task t1 = new Task();
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
        t1.Subject = 'Call';
        t1.WhatId = a.Id;
        t1.Type = 'Presale Call';
        t1.CallType = 'Inbound';
        t1.Priority = 'Normal';
        t1.Status = 'Completed';
        //t1.Stage__c	 = 'SNP';
        //t1.Sub_Stage__c = 'SNP';
        t1.Call_Status__c = 'Call Completed';
        //t1.Sub_Stage_Reason__c = 'Switched off';
        t1.Next_Follow_up_Date__c = system.today().addDays(1);
        t1.Description = 'Test Call';
        insert t1;
       
    }
    
}