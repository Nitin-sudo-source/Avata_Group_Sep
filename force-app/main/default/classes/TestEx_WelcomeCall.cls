//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 1-12-2023
//-------------------------------------------//
@isTest
public class TestEx_WelcomeCall {
    
     @isTest
    public static void testWelcomeCall() {
         Test.startTest();
        Booking__c b = new Booking__c();
        b.Agreement_Value__c = 100;
        b.Generate_Welcome_Call_Checklist_Master__c = False;
        insert b;
        
        Tower__c t = new Tower__c ();
        t.CRM_Manager__c =UserInfo.getUserId() ;
        insert t ;
        
        Project__c p = new Project__c ();
        p.CRM_Head__c = UserInfo.getUserId() ;
        insert p ;
        
        Booking__c b1 = new Booking__c();
        b1.Agreement_Value__c = 100;
        b1.Generate_Welcome_Call_Checklist_Master__c = False;
        b1.Tower__c = t.Id ;
        b1.Project__c = p.id ;
        b1.Welcome_Call_Done__c = true ;
        insert b1;
        b1.Generate_Welcome_Call_Checklist_Master__c = true;
        update b1;
        
        Welcome_Call_Checklist__c wc = new Welcome_Call_Checklist__c();
        wc.Decision__c = 'Rejected';
        wc.Booking__c = b1.Id;
        wc.Accepted__c = true;
        List<Welcome_Call_Checklist__c> WelcomeCallCheckList = new List<Welcome_Call_Checklist__c>();
        WelcomeCallCheckList.add(wc);
        insert WelcomeCallCheckList;
        

        
       // Test.startTest();
        Ex_WelcomeCall.getWelcomCallDetails(b.Id);
        Ex_WelcomeCall.changeGenarateCheckBoxValue(b1.Id);
        Ex_WelcomeCall.getWelcomCallDetails(b1.Id);
        Ex_WelcomeCall.checkGenerateWelcomeCallChecklist(b.Id);
        Ex_WelcomeCall.updateRecords(WelcomeCallCheckList, WelcomeCallCheckList, b1.Id, 'Test');
        Test.stoptest();

    }
    
    @isTest
    public static void testProjectLWC() {
        Project__c p = new Project__c();
        p.Name = 'Test';
        insert p;
        Test.startTest();  
        List<ContentDocumentLink> result = ProjectLwc.notes(p.Id);
        List<Project__c> pList = ProjectLwc.searchpro();
        Test.stoptest();
        
    }
  


    

    @isTest
    public static void testGetFieldDynamicValue() {
        Booking__c b1 = new Booking__c();
        b1.Agreement_Value__c = 100;
        b1.Generate_Welcome_Call_Checklist_Master__c = true;
        insert b1;
        
      //  String result = Ex_BookingHanldlerServices.getFieldDynamicValue(b1, 'Token Amount', null, null);
       // System.assertEquals(null, result);
    }

    @isTest
    public static void testGetBookingReceiptMap() {
        Booking__c b1 = new Booking__c();
        b1.Agreement_Value__c = 100;
        b1.Generate_Welcome_Call_Checklist_Master__c = true;
        insert b1;
        Set<Id> bId = new set<Id>();
        bId.add(b1.Id);

        
        Welcome_Call_Checklist__c wc = new Welcome_Call_Checklist__c();
        wc.Decision__c = 'Rejected';
        wc.Booking__c = b1.Id;
        wc.Accepted__c = true;
        List<Welcome_Call_Checklist__c> WelcomeCallCheckList = new List<Welcome_Call_Checklist__c>();
        WelcomeCallCheckList.add(wc);
        insert WelcomeCallCheckList;

        Test.startTest();
        Map<Id, List<Receipt__c>> receiptMap = Ex_BookingHanldlerServices.getBookingReceiptMap(bId);
      

        Test.stopTest();
        // Assert that the map is populated correctly

       
    }

    @isTest
    public static void testGetBookingUnitMap() {
        Test.startTest();
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
        
        Booking__c b1 = new Booking__c();
        b1.Agreement_Value__c = 100;
        b1.Generate_Welcome_Call_Checklist_Master__c = true;
        b1.Unit__c = un.id;
        b1.Project__c = pro.id;
        b1.Tower__c = twr.Id;
        insert b1;
        Set<Id> bId = new set<Id>();
        bId.add(b1.Id);

        
        Welcome_Call_Checklist__c wc = new Welcome_Call_Checklist__c();
        wc.Decision__c = 'Rejected';
        wc.Booking__c = b1.Id;
        wc.Accepted__c = true;
        List<Welcome_Call_Checklist__c> WelcomeCallCheckList = new List<Welcome_Call_Checklist__c>();
        WelcomeCallCheckList.add(wc);
        insert WelcomeCallCheckList;
        
        List<Unit__c> unitList = new List<Unit__c> ();
        unitList = [Select Id, Name,Booking__c,Booking__r.unit__c from Unit__c where Id =: b1.Unit__c];
            
        Ex_BookingHanldlerServices.getBookingUnitMap(bId);        
        
        Map<Id, Unit__c> bookingUnitMap = new Map<Id, Unit__c>();
        for (Unit__c unit : unitList) {
            bookingUnitMap.put(unit.Booking__c, unit);
        }
        
        
       // String result = Ex_BookingHanldlerServices.getFieldDynamicValue(b1, 'Unit Floor', bookingUnitMap , null);
        List<Welcome_Call_Checklist_Master__c> welcomeCallMasterList = Welcome_Call_Checklist_Master__c.getall().values();
        Welcome_Call_Checklist__c checklist = new Welcome_Call_Checklist__c();
        checklist.Category__c = ''	;
        checklist.Description__c = 'checklistMaster.Description__c';
        checklist.Booking__c = b1.Id;
        String result = Ex_BookingHanldlerServices.getFieldDynamicValue(b1, 'Unit Floor', bookingUnitMap , null);
        checklist.Values__c = result; 
        welcomeCallCheckList.add(checklist);
       // insert checklist;
    

        Test.stopTest();
      
    }



    
    
    
}