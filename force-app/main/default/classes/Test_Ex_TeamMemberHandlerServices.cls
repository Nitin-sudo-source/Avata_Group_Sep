@isTest
public class Test_Ex_TeamMemberHandlerServices {
    @isTest
    Public static Void SmAssignment(){
        Set<Id> smId = new Set<Id>();
        
        Project__c p1 = new Project__c();
        p1.Name = 'New Project';
        p1.TAT_Days_for_Walkin__c = 30;
        insert p1;
        
        Team__c t = new Team__c();
        t.Name = 'Sales Team';
        t.Project__c = p1.Id;
        t.Team_Type__c = 'Sales Team';
        insert t;
        
        
        
                
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
        
        insert op ;
        
        //Insert Sv
        Site_Visit__c sv = new Site_Visit__c();
        sv.Site_Visit_Count__c = 1;
        sv.Project__c = p1.Id;
        sv.Opportunity__c = op.Id;
        sv.Age_Group__c = '25 to 30 Years';
        sv.Gender__c = 'Male';
        sv.Designation__c = 'Owner';
        sv.Marital_Status__c = 'Married';
        sv.Occupation__c = 'Shop owner';
        sv.Family_Size__c = '2';
        sv.Current_Residence_Configuration__c = '1 BHK';
        sv.Industry__c = 'Consulting';
        sv.Company_Name__c = 'Test Company';
        sv.Residential_Address__c = 'Test Street';
        sv.City__c = 'Ahmednagar';
        sv.State__c = 'Maharashtra';
        sv.PinCode__c = '477522';
        sv.Is_Sales_Manager_Assigned__c = false;
        
        
        
            Test.startTest();
             insert sv;
        System.debug('sv::'+sv);
        Team_Member__c tmb1 = new Team_Member__c();
        tmb1.Team__c = t.Id;
        tmb1.User__c = UserInfo.getUserId();
        tmb1.Availability__c = true;
        tmb1.DayOff__c = false;
        insert tmb1;
        smId.add(tmb1.Id);
            Ex_TeamMemberHandlerServices.checkVisitForAssignment(smId);
            
            Test.stopTest();
           
    }
    
}