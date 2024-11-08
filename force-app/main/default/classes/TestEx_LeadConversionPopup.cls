@isTest
public class TestEx_LeadConversionPopup {
    @isTest
    public static void ConvertLeadTest(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Campaign__c c2 = new Campaign__c();
        c2.Name = 'Test Project';
        c2.Start_Date__c = system.today();
        //   c2.End_Date__c = system.today().addDays(4);
        //     c2.Status__c = 'Approved';
        c2.Actual_Leads__c = 0;
        c2.Actual_Enquiries__c= 0;
        c2.Actual_Visits__c = 2;
        c2.Actual_Bookings__c = 0;
        c2.Planned_Leads__c = 20;
        c2.Planned_Visits__c = 10;
        c2.Planned_Cost__c = 100;
        
        insert c2;
        c2.Campaign_Code__c = c2.Id;
        update c2;
        Lead__c l11 = new Lead__c( 
            Salutation__c ='Mr.',
            First_Name__c = 'Test',
            Last_Name__c = 'test2',
            ownerId = userInfo.getUserId(),
            Campaign__c = c2.id ,
            Apply_Round_Robin__c = true, 
            Lead_Stage__c = 'Incoming',
            Mobile__c = '1122334455',
            Project__c = p.Id, 
            Lead_Source__c='Google',
            Lead_Sub_Source__c = 'Google Search');
        insert l11;
        
        
        String RecTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a1 = new Account( Salutation = 'Mr.' ,FirstName = 'Test', LastName = 'Lead 1', PersonMobilePhone = '1122334455' ,RecordTypeId  = RecTypeId);
        insert a1;
        
        List<Lead__c>leadList = [ Select Id , name, Salutation__c, First_Name__c,Last_Name__c , Email__c,Current_Resident_Status__c,
                                 ownerId,Campaign__c , Apply_Round_Robin__c , Lead_Stage__c, Mobile__c ,Alternate_Mobile__c, Project__c,Alternate_Email__c,Current_Residence_Configuration__c,
                                 Designation__c,Ethnicity__c,Gender__c,Marital_Status__c,Occupation__c,Company_Name__c,Possession_Timeframe__c,
                                 Lead_Source__c,Source_Description__c,Budget_Range__c,Buying_Purpose__c,Configuration_Required__c,
                                 Presales_Next_Follow_up_Date__c,Presales_Call_Count__c,Presales_Last_Call_Date__c,Presales_Proposed_Visit_Date__c,
                                 Presales_Last_Call_Comment__c,Presales_Call_Comment_History__c,Is_Serviced__c,Campaign_Code__c,Lead_Sub_Source__c
                                 
                                 
                                 From Lead__C where Id =:l11.id];
        
        
        Test.startTest();
        Ex_LeadConversionPopup.isChecked(l11.Id);
        Test.stopTest();
    }
    
}