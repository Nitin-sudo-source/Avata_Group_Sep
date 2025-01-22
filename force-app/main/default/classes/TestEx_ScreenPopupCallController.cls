@isTest
public class TestEx_ScreenPopupCallController {
   @isTest
    public static void leadAccountPagePop() {
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Lead__c l = new Lead__c(First_Name__c = 'Test', Last_Name__c = 'Lead', Mobile__c = '1234567890',IsConverted__c = false, Project__c = p.Id);
        insert l;
        
        Opportunity__c op = new Opportunity__c (Name = 'Test Opp', Phone__c = '1234567890', Project__c = p.Id);
        insert op;
        
        CP_Project__c cp = new CP_Project__c(Mobile__c = '8989898988');
        insert cp;
                
        Test.startTest();
        PageReference pRef = Page.Ex_ScreenPopupVF;
        Test.setCurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('did', '1234');
        Apexpages.currentPage().getParameters().put('phone', '1234567890');
        Apexpages.currentPage().getParameters().put('uui', '1234567890');
        Ex_ScreenPopupCallController sc = new Ex_ScreenPopupCallController();
        sc.screenPop();
        
        Apexpages.currentPage().getParameters().put('did', '1234');
        Apexpages.currentPage().getParameters().put('phone', '01234567891');
        Apexpages.currentPage().getParameters().put('uui', '');
        Ex_ScreenPopupCallController sc1 = new Ex_ScreenPopupCallController();
        sc1.screenPop();
        Test.stopTest();
    }
    
}