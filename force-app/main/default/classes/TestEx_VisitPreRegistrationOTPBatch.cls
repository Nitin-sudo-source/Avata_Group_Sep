@isTest
public class TestEx_VisitPreRegistrationOTPBatch {
    @isTest
    public static void testValidateOpp(){
        
        List<Visit_Pre_Registration__c> vps = new List<Visit_Pre_Registration__c>();
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        project.Project_Logo__c = 'Test image';
        insert project;
        
        Visit_Pre_Registration__c preReg = new Visit_Pre_Registration__c(
            Customer_Name__c = 'Test Customer',
            Mobile_Number__c = '1234567890',
            Project__c = project.Id,
            Status__c= 'Valid',
            Pre_Registration_Expiry__c = System.now().addDays(-2) // Set expiry to 30 days ago 
        );
        vps.add(preReg);
        insert vps;
        
        Test.setCreatedDate(preReg.Id, DateTime.now().addDays(-2)); 
        Test.startTest();
        Ex_VisitPreRegistrationOTPValidityBatch vprOtpBatch = new Ex_VisitPreRegistrationOTPValidityBatch();
        Database.QueryLocator queryLocator = vprOtpBatch.start(null);
        vprOtpBatch.execute(null, vps);
        vprOtpBatch.execute(null);
        Test.stopTest();
        
    }  
    
    
}