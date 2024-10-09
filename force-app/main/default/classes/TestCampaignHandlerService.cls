@isTest
public class TestCampaignHandlerService {
  
    	@isTest
       public static void CreateCampaign() {
       
       Account a = new Account ();
       a.LastName = 'acc 2';
       a.Phone = '9822341223';
       a.PersonMobilePhone = '9922341223';
       a.Alternate_Email__c = 'acc12@gmail.com';
       a.PersonEmail = 'acc32@gmail.com';
       
        insert a;
           
       Project__c p = new Project__c();
       p.Name = 'Test Project';
       insert p;
       
       Project__c p1 = new Project__c();
       p1.Name = 'Test Project1';
       insert p1;
        
       
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
       // c2.Type__c = 'Event'; 
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
       
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
      
        c2.Campaign_Code__c = 'ANCUYTEE';
        update c2;
       
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
      //  c4.Type__c = 'Email'; 
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Weekly';
        c4.Status__c = 'Completed';
       
        insert c4;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
       // c3.Type__c = 'Social Media'; 
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';      
        c3.Status__c = 'Completed';
        c3.Targeted_Leads__c = 5;
        insert c3;
           
        c3.Targeted_Leads__c = 100;
        update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
        
       
       Opportunity__c Opp = new Opportunity__c();
       opp.Name = 'Test Opp';
       opp.Account__c = a.id;
       opp.Stage__c = 'In Follow-up';
       opp.Project__c = p.Id;
       opp.Sales_Next_Follow_up_Date__c = system.now();
       opp.Site_Visit_Count__c = 0;
       opp.Campaign_Custom__c = c2.id;
        insert opp;
        
        opp.Site_Visit_Count__c = 10;
        update opp;
           
           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       
           
    // CampaignHandlerServices cs = new CampaignHandlerServices();
		
    }
    @isTest
       public static void CreateCampaign5() {
       
       Account a = new Account ();
       a.LastName = 'acc 2';
       a.Phone = '9822341223';
       a.PersonMobilePhone = '9922341223';
       a.Alternate_Email__c = 'acc12@gmail.com';
       a.PersonEmail = 'acc32@gmail.com';
       
        insert a;
           
       Project__c p = new Project__c();
       p.Name = 'Test Project';
       insert p;
       
       Project__c p1 = new Project__c();
       p1.Name = 'Test Project1';
       insert p1;
        
       
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
        c2.Budgeted_Cost__c = 234;
        c2.Lead_Count__c = 2;
        c2.Targeted_Leads__c = 200;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
        c2.Budgeted_Cost__c = 294;
        c2.Lead_Count__c = 5;
        c2.Targeted_Leads__c = 240;
        c2.Campaign_Code__c = 'AVTTJH7';
        update c2;
       
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
       // c4.Type__c = 'Email'; 
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Weekly';
        c4.Status__c = 'Completed';
        c4.Budgeted_Cost__c = 0;
       
        insert c4;
        c4.Budgeted_Cost__c = 100;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';      
        c3.Status__c = 'Completed';
        c3.Budgeted_Cost__c = 0;
        insert c3;
           
        c3.Budgeted_Cost__c = 100;
        update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
        
       
       Opportunity__c Opp = new Opportunity__c();
       opp.Name = 'Test Opp';
       opp.Account__c = a.id;
       opp.Stage__c = 'In Follow-up';
       opp.Project__c = p.Id;
       opp.Sales_Next_Follow_up_Date__c = system.now();
       opp.Site_Visit_Count__c = 0;
       opp.Campaign_Custom__c = c2.id;
       insert opp;
        
       opp.project__c = p1.Id;
       update opp;
           

           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       
           
    // CampaignHandlerServices cs = new CampaignHandlerServices();
		
    }
    @isTest
       public static void CreateCampaign6() {
       
       Account a = new Account ();
       a.LastName = 'acc 2';
       a.Phone = '9822341223';
       a.PersonMobilePhone = '9922341223';
       a.Alternate_Email__c = 'acc12@gmail.com';
       a.PersonEmail = 'acc32@gmail.com';
       
        insert a;
           
       Project__c p = new Project__c();
       p.Name = 'Test Project';
       insert p;
       
       Project__c p1 = new Project__c();
       p1.Name = 'Test Project1';
       insert p1;
        
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
      c2.Budgeted_Cost__c = 234;
        c2.Lead_Count__c = 2;
        c2.Targeted_Leads__c = 200;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
        c2.Budgeted_Cost__c = 294;
        c2.Lead_Count__c = 5;
        c2.Targeted_Leads__c = 240;
        c2.Campaign_Code__c = 'AVTTJH7';
        update c2; 
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Weekly';
        c4.Status__c = 'Completed';
        c4.Budgeted_Cost__c = 0;
       
        insert c4;
        c4.Budgeted_Cost__c = 100;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';      
        c3.Status__c = 'Completed';
        c3.Budgeted_Cost__c = 0;
        insert c3;
           
        c3.Budgeted_Cost__c = 100;
        update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
        
       
       Opportunity__c Opp = new Opportunity__c();
       opp.Name = 'Test Opp';
       opp.Account__c = a.id;
       opp.Stage__c = 'In Follow-up';
       opp.Project__c = p.Id;
       opp.Sales_Next_Follow_up_Date__c = system.now();
       opp.Site_Visit_Count__c = 0;
       opp.Campaign_Custom__c = c2.id;
       insert opp;
        
       opp.Campaign_Custom__c = c3.id;
       update opp;
           
      
           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       
           
    // CampaignHandlerServices cs = new CampaignHandlerServices();
		
    }
    @isTest
       public static void CreateCampaign2() {
       Project__c p = new Project__c();
      
           
       
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Daily';
        c2.Status__c = 'Completed';
         c2.Budgeted_Cost__c = 234;
        c2.Lead_Count__c = 2;
        c2.Targeted_Leads__c = 200;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
        c2.Budgeted_Cost__c = 294;
        c2.Lead_Count__c = 5;
        c2.Targeted_Leads__c = 240;
        c2.Campaign_Code__c = 'AVTTJH7';
        update c2; 
     
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Weekly';
        c4.Status__c = 'Completed';
        c4.Budgeted_Cost__c = 0;
       
        insert c4;
        c4.Budgeted_Cost__c = 100;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';      
        c3.Status__c = 'Completed';
      //  c3.Amount__c = 0;
        insert c3;
           
       // c3.Amount__c = 100;
       // update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
           
           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       
           
    // CampaignHandlerServices cs = new CampaignHandlerServices();
		
    }
    
    
    @isTest
       public static void CreateCampaign3() {
       Project__c p = new Project__c();
      
           
     
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Weekly'; 
        c2.Status__c = 'Completed';
         c2.Budgeted_Cost__c = 234;
        c2.Lead_Count__c = 2;
        c2.Targeted_Leads__c = 200;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
        c2.Budgeted_Cost__c = 294;
        c2.Lead_Count__c = 5;
        c2.Targeted_Leads__c = 240;
        c2.Campaign_Code__c = 'AVTTJH7';
        update c2; 
     
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Daily';
        c4.Status__c = 'Completed';
        c4.Budgeted_Cost__c = 0;
       
        insert c4;
        c4.Budgeted_Cost__c = 100;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Monthly';      
        c3.Status__c = 'Completed';
        c3.Budgeted_Cost__c = 0;
        insert c3;
           
        c3.Budgeted_Cost__c = 100;
        update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
           
           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       
           
    // CampaignHandlerServices cs = new CampaignHandlerServices();
		
    }
    
    @isTest
       public static void CreateCampaign4() {
       Project__c p = new Project__c();
           
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Active__c = true;
        c2.Project__c = p.id;
        c2.Start_Date__c = system.today();
        c2.End_Date__c = system.today().addDays(1);
        c2.Performance_Measure_On__c = 'Monthly'; 
        c2.Status__c = 'Completed';
          c2.Budgeted_Cost__c = 234;
        c2.Lead_Count__c = 2;
        c2.Targeted_Leads__c = 200;
        c2.Campaign_Code__c = 'AVJH7';
        insert c2;
           
        c2.Budgeted_Cost__c = 294;
        c2.Lead_Count__c = 5;
        c2.Targeted_Leads__c = 240;
        c2.Campaign_Code__c = 'AVTTJH7';
        update c2; 
     
        
        
        Campaign__c c4 = new Campaign__c();
        c4.Name = 'Test Project';
        c4.Active__c = true;
        c4.Project__c = p.id;
        c4.Start_Date__c = system.today();
        c4.End_Date__c = system.today().addDays(60);
        c4.Performance_Measure_On__c = 'Daily';
        c4.Status__c = 'Completed';
        c4.Budgeted_Cost__c = 0;
       
        insert c4;
        c4.Budgeted_Cost__c = 100;
        update c4;
		
        
        
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Weekly';      
        c3.Status__c = 'Completed';
        c3.Budgeted_Cost__c = 0;
        insert c3;
           
        c3.Budgeted_Cost__c = 100;
        update c3;
        
           
        Lead__c Ld = new Lead__c();
        Ld.Last_Name__c = 'test';   
        Ld.Campaign_Custom__c = c2.id;
        Ld.Budget__c = 'Budget of 80 to 90 lakhs';
        Ld.Configuration_Required__c = '1 BHK';
        Ld.Project__c = p.id;
        insert Ld;
           
           
        
        Campaign_Performance__c cpl = new Campaign_Performance__c();
        cpl.Lead_Count__c = 0;
        cpl.Start_Date__c = system.today();
        cpl.End_Date__c = system.today();
        cpl.Campaign__c = c2.id;
        
        insert cpl;
       		
    }
       @IsTest
        static void testCreateCampaignMember() {
         Project__c p = new Project__c();
 
            
        Campaign__c c3 = new Campaign__c();
        c3.Name = 'Test Project';
        c3.Active__c = true;
        c3.Project__c = p.id;
        c3.Start_Date__c = system.today();
        c3.End_Date__c = system.today().addDays(60);
        c3.Performance_Measure_On__c = 'Weekly';      
        c3.Status__c = 'Completed';
        c3.Budgeted_Cost__c = 0;
        insert c3;
         

        List<Lead__c> testLeads = new List<Lead__c>();
        testLeads.add(new Lead__c(Campaign_Code__c = 'TEST'));
        testLeads.add(new Lead__c(Campaign_Code__c = 'TEST'));
        
        Test.startTest();
        CampaignHandlerServices.createCampaignMember(testLeads);
        Test.stopTest();

       
    }

 }