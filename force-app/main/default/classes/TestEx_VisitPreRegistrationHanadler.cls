@isTest
public class TestEx_VisitPreRegistrationHanadler {

    @isTest
    public static void testGenerateOTP(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Project_Logo__c = 'Test image';
        insert p;
        
        Lead__c l2 = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead 2', Lead_Stage__c = 'Incoming', Mobile__c = '1122334499', Email__c = 'lead9@test.in', Alternate_Email__c = 'lead0@test.in', Project__c = p.Id);
         insert l2;
        
        Visit_Pre_Registration__c vpr = new Visit_Pre_Registration__c();
        vpr.Customer_Name__c = 'Test Customer';
        vpr.Mobile_Number__c = '1234567890';
        vpr.Lead__c = l2.Id;
        vpr.Project__c = p.Id;
        //vpr.Pre_Registration_OTP__c = '123456';
        vpr.Extend_Validity_In_Hours__c = 48;
        vpr.Pre_Registration_Expiry__c = System.now(); 
        insert vpr;
        List<Visit_Pre_Registration__c> vprList = new List<Visit_Pre_Registration__c>();
        vprList.add(vpr);
        Map<Id,Visit_Pre_Registration__c> newVprMap = new Map<Id,Visit_Pre_Registration__c>();
        newVprMap.put(vpr.id,vpr);
        
      /*  Test.startTest();
         Ex_VisitPreRegistrationHandler.beforeInsert(vprList);
         Ex_VisitPreRegistrationHandler.beforeUpdate(newVprMap, newVprMap);
         Ex_VisitPreRegistrationHandlerServices.createVPRLead(vprList);
         Ex_VisitPreRegistrationHandlerServices.updateVpr(vprList);
        Test.stopTest();*/
        
    }
}