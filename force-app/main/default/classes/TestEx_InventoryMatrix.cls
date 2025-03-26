@isTest
public class TestEx_InventoryMatrix {
    
    @isTest
    public static void testmethod1(){
        Project__c p = new Project__c();
        p.Name = 'Test Project';
        insert p;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test Bhavesh';
        opp.Project__c = p.Id;
        insert opp;
        
        Tower__c tower = new Tower__c();
        tower.Name = 'Test' ;
        tower.Project__c = p.Id;
        insert tower ;
        
        Unit__c unit = new Unit__c();
        unit.Name = 'Test' ;
        unit.Tower__c = tower.Id ;
        unit.Project__c =p.Id ;
        unit.Total_carpet_Sq_Ft__c =10;
        unit.Configuration_Type__c = '4 BHK' ;
        unit.Floor__c=1;
        unit.Sales_Status__c = 'Vacant';
        insert unit ;
       
       
        
        test.StartTest();
        Ex_InventoryMatrix.getOppDetails(opp.Id);
        Ex_InventoryMatrix.getOppDetails('opp');
        Ex_InventoryMatrix.getProjectList();
        Ex_InventoryMatrix.getTower(p.Id);
        Ex_InventoryMatrix.getTower('p');
        Ex_InventoryMatrix.getUnit(tower.Id);
        Ex_InventoryMatrix.getUnit('tower');
        Ex_InventoryMatrix.getUnitConfigurationMapDetails(tower.Id);
        Ex_InventoryMatrix.getUnitFloorMapDetails(tower.Id);
        Test.stopTest();
    }

}