//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 1-12-2023
//-------------------------------------------//
@isTest
public class TestEx_ConstructionStageUpdate {
      @isTest
    public static void Test_Ex_ConstructionStageUpdate1(){
       
        Project__c pro = new Project__c();
        pro.Name = 'Test Project';
        insert pro;
       
        Tower__c twr = new Tower__c();
        twr.Name = 'TowerA';
        twr.Project__c = pro.Id;
        insert twr;
       
      
        Unit__c un = new Unit__c();
        un.Name = '1BHK501';
        //un.For_Sale__c = 'Yes';
        un.Sale_Status__c = 'Vacant';
        un.Configuration__c = '1 BHK';
        un.Inventory_Type__c = 'Residential';
        un.Floor__c = 5;
        un.Project__c = pro.Id;
        un.Tower__c = twr.Id;
        un.Saleable_Area__c = 1000;
        un.RERA_Carpet_Area_Sq_Ft__c = 800;
        insert un;
       
        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 1';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = twr.id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Unit_Wise_Milestone__c = true;
        cs1.Actual_Completion_Date__c = system.today() - 10;
        cs1.Expected_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
       
        Construction_Stage_History__c csh = new Construction_Stage_History__c();
        csh.Construction_Stage__c = cs1.id;
        csh.Tower_Name__c = twr.id;
        csh.Actual_Completion_Date__c = system.today() - 10;
        csh.Expected_Completion_Date__c = system.today();
        csh.Floor__c = '5';
        insert csh;
       
        Test.startTest();
        List<Construction_Stage__c> resultList = Ex_ConstructionStageUpdate.Cosnstructionupdate(cs1.id, cs1.Actual_Completion_Date__c, cs1.Expected_Completion_Date__c);
        List<Construction_Stage__c> resultList2 =Ex_ConstructionStageUpdate.getCosnstructionStage(cs1.id);
        Test.stopTest();
       
    }
   
    @isTest
    static void testGetcons() {
        Tower__c twr = new Tower__c(Name = 'Test Tower');
        insert twr;
       
        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 2';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = twr.id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Unit_Wise_Milestone__c = true;
        cs1.Actual_Completion_Date__c = system.today();
        cs1.Expected_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
       
        Construction_Stage__c cs2 = new Construction_Stage__c();
        cs2.Name = 'Slab 2';
        cs2.Stage_Description__c = 'Slab 2';
        cs2.Tower__c = twr.id;
        cs2.Milestone_Status__c = 'Completed';
        cs2.Unit_Wise_Milestone__c = true;
        cs2.Actual_Completion_Date__c = system.today();
        cs2.Expected_Completion_Date__c = system.today();
        cs2.Sequence_Number__c = 2;
        insert cs2;
       
        Test.startTest();
        List<Construction_Stage__c> result = Ex_ConstructionStageUpdate.getcons(twr.Id, Date.today(), Date.today().addDays(10));
        Test.stopTest();
    }
   
   
    @isTest
    static void testGetFloor() {
       
        Project__c pro = new Project__c();
        pro.Name = 'Test Project';
        insert pro;
       
        Tower__c tower = new Tower__c(Name = 'Test Tower');
        insert tower;
       
       
        Unit__c un = new Unit__c();
        un.Name = '1BHK501';
        un.Sale_Status__c = 'Vacant';
        un.Configuration__c = '1 BHK';
        un.Inventory_Type__c = 'Residential';
        un.Floor__c = 5;
        un.Project__c = pro.Id;
        un.Tower__c = tower.Id;
        un.Saleable_Area__c = 1000;
        un.RERA_Carpet_Area_Sq_Ft__c = 800;      
        insert un;
       
        Test.startTest();
        Map<Decimal, List<Unit__c>> floorUnitsMap = Ex_ConstructionStageUpdate.getFloor(tower.Id);
        Test.stopTest();
    }

   
    @isTest
    static void testSaveMethod() {
        Project__c pro = new Project__c();
        pro.Name = 'Test Project';
        insert pro;
       
        Tower__c twr = new Tower__c(Name = 'Test Tower', Project__c = pro.Id);
        insert twr;
       
        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Slab 1';
        cs1.Stage_Description__c = 'Slab 1';
        cs1.Tower__c = twr.Id;
        cs1.Milestone_Status__c = 'Completed';
        cs1.Unit_Wise_Milestone__c = false;
        cs1.Actual_Completion_Date__c = system.today();
        cs1.Sequence_Number__c = 1;
        insert cs1;
       
        Construction_Stage__c cs2 = new Construction_Stage__c();
        cs2.Name = 'Slab 1';
        cs2.Stage_Description__c = 'Slab 1';
        cs2.Tower__c = twr.Id;
        cs2.Milestone_Status__c = 'Completed';
        cs2.Unit_Wise_Milestone__c = false;
        cs2.Expected_Completion_Date__c = system.today();
        cs2.Sequence_Number__c = 1;
        insert cs2;
       
        
        Unit__c un = new Unit__c();
        un.Name = '1BHK501';
        un.Sale_Status__c = 'Booked';
        un.Configuration__c = '1 BHK';
        un.Inventory_Type__c = 'Residential';
        un.Floor__c = 5;
        un.Project__c = pro.Id;
        un.Tower__c = twr.Id;
        un.Saleable_Area__c = 1000;
        un.RERA_Carpet_Area_Sq_Ft__c = 800;
        insert un;
       
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'acc1';
        insert opp;
       
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = opp.id;
        q.Tower__c = twr.id;
        q.Project__c = pro.Id;
        q.Unit__c = un.id;
        insert q;
       
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Milestone_Name__c = '1ST Slab';
        pm.Quotation__c = q.id;
        pm.Milestone_Type__c = 'Construction Linked';
        pm.Construction_Stage__c = cs1.id;
        pm.Due_Date__c = system.today();
        pm.Is_Due__c = true;
        pm.Is_Raised__c = false;
        pm.Milestone_Complete_At_Booking__c = false;
        insert pm;
       
        Payment_Milestone__c pm1 = new Payment_Milestone__c();
        pm1.Milestone_Name__c = '1ST Slab';
        pm1.Quotation__c = q.id;
        pm1.Milestone_Type__c = 'Construction Linked';
        pm1.Construction_Stage__c = cs2.id;
        pm1.Due_Date__c = system.today();
        pm1.Is_Due__c = false;
        pm1.Is_Raised__c = false;
        pm1.Milestone_Complete_At_Booking__c = false;
        insert pm1;
       
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Mode_Of_Funding__c = 'Self Funding';
        b.Tower__c = twr.id;
        b.Project__c = pro.Id;
        b.Quotation__c = q.id;
        b.Opportunity__c = opp.id;
        b.Unit__c = un.id;
        insert b;
       
        un.Booking__c=b.id;
        update un;

        Ex_ConstructionStageUpdate.saveMethod('Expected Completion Date', Date.today(), cs1.Id, null, 'Test', 'Test');
        Ex_ConstructionStageUpdate.saveMethod('Actual Completion Date', Date.today(), cs1.Id, new List<String>{'1', '2'} , 'Test', 'Test');
       
    }
}