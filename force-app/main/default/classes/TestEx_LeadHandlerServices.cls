@isTest
public class TestEx_LeadHandlerServices {

    @isTest
    public static void testHandlerServices(){

        Project__c p = new Project__c();
        p.Name = 'Test project 1';
        p.Assignment_TAT__c = 45;
        p.Source_TAT__c = 60;
        insert p;
        
        Team__c t = new Team__c();
        t.Name = 'Presales team 1';
        t.Project__c = p.Id;
        t.Team_Type__c = 'Presales Team';
        insert t;
                
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = [SELECT Id FROM User WHERE ProfileId = :sysAdminProfile.Id LIMIT 1];
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.Id;
        tm.Sequence_Number__c = 1;
        tm.Availability__c = true;
        tm.User__c = sysAdminUser.Id;
        insert tm;
        
        System.debug(':: Project ' + p);
        System.debug(':: Team ' + t);
        System.debug(':: Team Member ' + tm);
        
               
        List<Lead__c> leadList =  new List<Lead__c>();
        Lead__c l1 =  new Lead__c();
        l1.First_Name__c =  'Test';
        l1.Last_Name__c = 'Lead 1';
        l1.Mobile__c = '9074145963';
        l1.Email__c = 'nitin222@gmail.com';
        l1.Lead_Source__c = 'Google';
        l1.Lead_Sub_Source__c = 'Google Search';
        l1.Lead_Stage__c = 'Incoming';
        l1.Lead_Sub_Stage__c = 'Open';
        l1.Project__c = p.Id;
        //l1.Project__c = 'a01Hy00000ANpy3IAD';
        l1.Apply_Round_Robin__c = true;        
        leadList.add(l1);

        
        
        insert leadList;
        System.debug(':: Lead1 ' + l1);
        System.debug(':: Lead list ' + leadList);
        
        String applyRoundRobin = 'Yes';
        
        Lead__c l2 =  new Lead__c();
        l2.First_Name__c =  'Test';
        l2.Last_Name__c = 'Lead 1';
        l2.Mobile__c = '9074145963';
        l2.Email__c = 'nitin222@gmail.com';
        l2.Lead_Source__c = 'Google';
        l2.Lead_Sub_Source__c = 'Google Search';
        l2.Lead_Stage__c = 'Incoming';
        l2.Lead_Sub_Stage__c = 'Open';
        l2.Project__c = p.Id;
        l2.IsConverted__c = true;
        insert l2;
        
        Test.startTest();
        Ex_LeadConversionPopup.isChecked(l2.Id);
        Ex_ShowSimilarLeadController.getLeadData(l2.Id);
        Test.stopTest();
        
        l1.Presales_Call_Count__c = 1;
        update l1;
    }    
}