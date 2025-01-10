@isTest
public class TestEx_VisitPreRegistrationHanadler {

    @isTest
    public static void testGenerateOTP(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        p.Project_Logo__c = 'Test image';            
        insert p;
        
        Lead__c Lead = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CP Lead',
            Lead_Stage__c = 'Incoming',
            Mobile__c = '1234567890',
            Email__c = 'cpLead@test.com',
            Project__c = p.Id
        );
        insert Lead;
        
        CP_Lead__c cpLead = new CP_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CP Lead',
            Mobile__c = '1234567890',
            Email__c = 'cpLead@test.com',
            Project__c = p.Id
        );
        insert cpLead;
        
        Visit_Pre_Registration__c vpr1 = new Visit_Pre_Registration__c(
            Customer_Name__c = 'Customer 1',
            Mobile_Number__c = '1234567890',
            CP_Lead__c = cpLead.Id,
            Project__c = p.Id,
            Pre_Registration_Expiry__c = Date.today().addDays(1) // Future expiry
        );
        
        Visit_Pre_Registration__c vpr2 = new Visit_Pre_Registration__c(
            Customer_Name__c = 'Customer 2',
            Mobile_Number__c = '1234567890',
            CP_Lead__c = cpLead.Id,
            Project__c = p.Id,
            Pre_Registration_Expiry__c = Date.today().addDays(2) // Future expiry
        );
        
        insert new List<Visit_Pre_Registration__c>{vpr1, vpr2};
            
            Visit_Pre_Registration__c newVpr = new Visit_Pre_Registration__c(
            Customer_Name__c = 'New Customer',
            Mobile_Number__c = '1234567890',
            Project__c = p.Id,
            Pre_Registration_Expiry__c = Date.today().addDays(3)
        );

        
        List<Visit_Pre_Registration__c> vprList = new List<Visit_Pre_Registration__c>();
        vprList.add(vpr1);
        Map<Id,Visit_Pre_Registration__c> newVprMap = new Map<Id,Visit_Pre_Registration__c>();
        newVprMap.put(vpr1.id,vpr1);
        
        Test.startTest();
        List<Visit_Pre_Registration__c> vprList2 = new List<Visit_Pre_Registration__c>();
         Ex_VisitPreRegistrationHandler.beforeInsert(vprList);
         Ex_VisitPreRegistrationHandler.beforeUpdate(newVprMap, newVprMap);
         Ex_VisitPreRegistrationHandlerServices.createVPRLead(vprList);
         Ex_VisitPreRegistrationHandlerServices.updateVpr(vprList);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDuplicationCheckByLeadMobileWithProject() {
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;

        Lead__c lead = new Lead__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Lead_Stage__c = 'Incoming',
            Mobile__c = '1234567890',
            Email__c = 'john.doe@test.com',
            Project__c = project.Id
        );
        insert lead;

        Visit_Pre_Registration__c vpr1 = new Visit_Pre_Registration__c(
            Customer_Name__c = 'Customer A',
            Mobile_Number__c = '1234567890',
            Lead__c = lead.Id,
            Project__c = project.Id,
            Pre_Registration_Expiry__c = System.today().addDays(5)
        );
        insert vpr1;

        Visit_Pre_Registration__c vpr2 = new Visit_Pre_Registration__c(
            Customer_Name__c = 'Customer B',
            Mobile_Number__c = '1234567890',
            Lead__c = lead.Id,
            Project__c = project.Id,
            Pre_Registration_Expiry__c = System.today().addDays(5)
        );
        insert vpr2;

        List<Visit_Pre_Registration__c> vprList = new List<Visit_Pre_Registration__c>{vpr1};

        Test.startTest();
        Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> result =
            Ex_VisitPreRegDuplicationHandlerServices.vprDuplicationCheckByLeadMobileWithProject(vprList);
        Test.stopTest();

    }
}