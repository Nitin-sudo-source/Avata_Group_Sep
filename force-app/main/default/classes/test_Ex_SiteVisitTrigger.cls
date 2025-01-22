@isTest
public class test_Ex_SiteVisitTrigger {
    @isTest
    public static void test_beforeInsert(){
        Test.startTest();
        
        CP_Document__c cp = new CP_Document__c();
        cp.Name = 'Yes';
        cp.Document_Required__c = 'Pan Card';
        insert cp;
        system.debug('cp doc is::'+cp);
        
        Account acc = new Account();
        acc.Name = '360 realtors';
       // acc.Salutation = 'Ms.';
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('CP Account').getRecordTypeId();
        insert acc;
        system.debug('Account is::'+acc);
        
        Account acc1 = new Account();
        acc1.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc1.LastName = '360 realtors';
        acc1.Salutation = 'Ms.';
        insert acc1;
        system.debug('Account is::'+acc1);
        
        Document__c d = new Document__c();
        d.CP_Account__c = acc.Id;
        d.Document_Type__c = cp.Document_Required__c;
        insert d;
        
        Project__c p = new Project__c();
        p.name = 'Test Project';
        p.Sales_Head__c = userInfo.getUserId();
        insert p;
        system.debug('Project is::'+p);
        
        CP_Project__c cpp = new CP_Project__c();
        cpp.CP_Account__c = acc.Id;
        cpp.Project__c = p.Id;
        insert cpp;
        system.debug('cpp is::'+cpp);
        
        Opportunity__c opp = new Opportunity__c();
        opp.Account__c = acc1.Id;
        opp.Project__c = p.Id;
        insert opp;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Salutation__c = 'Mr.';
        sv.OwnerId = userInfo.getUserId();
        sv.Project_Name__c = p.Id;
        sv.CP_Project__c = cpp.Id;
        sv.Opportunity__c = opp.Id;
        sv.Sales_Manager__c = userInfo.getUserId();
        sv.Channel_Partner__c = acc.Id;
        sv.Site_Visit_Count__c = 1;
        
        
        Site_Visit__c sv1 = new Site_Visit__c();
        sv1.OwnerId = userInfo.getUserId();
        sv1.Project_Name__c = p.Id;
        sv1.CP_Project__c = cpp.Id;
        sv1.Opportunity__c = opp.Id;
        sv1.Sales_Manager__c = userInfo.getUserId();
        sv1.Site_Visit_Date__c = system.today();
        sv1.Comment__c = 'Test comment';
        sv1.Configuration_Required__c = '2 BHK';
        sv1.Project_Type__c = 'Residential';
        sv1.Budget__c = 'Budget less than 20 lakhs';
        sv1.Buying_Purpose__c = 'Self-Use';
        sv1.Possession_Timeframe_Required__c = 'RTMI (Ready to Move in)';
        sv1.Opportunity_Stage__c = 'In Follow-up';
        sv1.Opportunity_Sub_Stage__c = 'Hot';
        sv1.Opportunity_Sub_Stage_Reason__c = 'All Good Expected Closure';
        sv1.Locality__c = 'Central';
        sv1.Locality_details__c = 'Bhandup';
        sv1.Country__c = 'India';
        sv1.City_Name__c = 'Raigad';
        sv1.City_Type__c = 'Mumbai';
        
        insert sv1;
        
       // sv1.Comment__c = 'test comment 1';
      //  sv1.Salutation__c = 'Mr.';
       // update sv1;
        
        Set<Id> uIdSet = new Set<Id>();
        uIdSet.add(sv1.Sales_Manager__c);
        
        Site_Visit__c sv2 = new Site_Visit__c();
        sv2.OwnerId = userInfo.getUserId();
        sv2.Project_Name__c = p.Id;
        sv2.CP_Project__c = cpp.Id;
        sv2.Opportunity__c = opp.Id;
        
        insert sv2;
        
        sv2.Sales_Manager__c = userInfo.getUserId();
        update sv2;
        
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        svList.add(sv);

        Team__c t = new Team__c();
        t.Team_Type__c = 'Sales Team';
        t.Project__c = p.Id;
        insert t;
        
        Team_Member__c tm = new Team_Member__c();
        tm.User__c = sv2.Sales_Manager__c;
        tm.Availability__c = true;
        tm.Team__c = t.Id;
        insert tm;
        tm.Availability__c = false;
        update tm;
        
        Ex_SiteVisitHandlerServices.appCPProjectOnSV(svList);
        Ex_SiteVisitHandlerServices.rollupOnOpportunity(sv);
        Ex_SiteVisitHandlerServices.updateSalesManagerAvailability(uIdSet);
        Ex_SiteVisitTriggerHandler.updateCPOnOppo(svList);
        Test.stopTest();
    }
}