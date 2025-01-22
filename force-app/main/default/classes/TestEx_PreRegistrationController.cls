//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 30-11-2023
//-------------------------------------------//
@isTest
public class TestEx_PreRegistrationController {
    @isTest
    public static void testGetCPProject() {
        Project__c p = new Project__c();
        p.Name = 'test';
        insert p;
        
        CP_Project__c testCPProject1 = new CP_Project__c(Project__c = p.Id);
        CP_Project__c testCPProject2 = new CP_Project__c(Project__c = p.Id);
        insert new List<CP_Project__c>{testCPProject1, testCPProject2};
            
            Visit_Pre_Registration__c vp = new Visit_Pre_Registration__c();
        vp.Ola_Pickup_Facility__c = 'Yes';
        vp.Mobile__c = '8989898989';
        vp.Pre_registration_OTP__c = '1234';
        insert vp;
        
        if(vp != null && vp.Ola_Pickup_Facility__c == 'Yes'){
            Ola_Pickup__c op = new Ola_Pickup__c();
            op.Pickup_Location__c = 'Test ';
            op.Pickup_Datetime__c = system.now();
            op.Visit_Pre_Registration__c = vp.Id;
            insert op;
        }
        
        Test.startTest();
        List<Ex_PreRegistrationController.CPProjectWrapper> result = Ex_PreRegistrationController.getCPProject();
       // Ex_PreRegistrationController.sendOTP(vp.Mobile__c, testCPProject1.Id);
       // Ex_PreRegistrationController.validateOTP('1234', vp.Mobile__c);
        Ex_PreRegistrationController.saveData(testCPProject1.Id, 'customerName', vp.Mobile__c, '', '1 BHK', 'Yes', System.now(), 'Location', System.now());
        Ex_NumberToWord.convertNumbertoWords(100);
        Test.stopTest();        
    }
    
    
}