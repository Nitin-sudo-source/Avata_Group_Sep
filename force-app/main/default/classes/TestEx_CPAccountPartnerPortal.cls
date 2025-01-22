@isTest
public class TestEx_CPAccountPartnerPortal {
@isTest
    public static void testCreateUser(){
         Account testAccount = new Account(
            Name = 'Test Account',
            Owner_Name__c = 'Test Owner',
            Owner_Email__c = 'test@example.com'
        );
        insert testAccount;

        Test.startTest();
        List<User> createdUsers = Ex_CPAccountPartnerPortal.createPartnerUser(testAccount.Id);
        Test.stopTest(); 
        
    }
}