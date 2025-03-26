@isTest
public class TestEx_AfterBookingPriceMgmtService {
    @isTest
    static void setupTestData() {
        // Create Project
        Project__c project = new Project__c(
            Name = 'Test Project',
            Threshold_Amount__c = 500000,
            Threshold_Percentage__c = 10
        );
        insert project;

        // Create Tower
        Tower__c tower = new Tower__c(
            Name = 'Test Tower',
            Project__c = project.Id
        );
        insert tower;

        // Create Unit
        Unit__c unit = new Unit__c(
            Name = 'Unit 101',
            Tower__c = tower.Id,
            Project__c = project.Id,
            Saleable_Area__c = 1000,
            RERA_Carpet_Area_Sq_Ft__c = 800
        );
        insert unit;

        // Create Booking
        Booking__c booking = new Booking__c(
           
            Unit__c = unit.Id,
            Project__c = project.Id,
            Agreement_Value__c = 1200000
        );
        insert booking;

        // Create Quotation
        Quotation__c quotation = new Quotation__c(
           
            Booking__c = booking.Id
        );
        insert quotation;

        // Create Charge Details
        Charge_Details__c charge1 = new Charge_Details__c(
            Name = 'Basic Charge',
            Charge_Bucket__c = 'Agreement Value',
            Charge_Type__c = 'PSF',
            Charge_Amount__c = 1000000,
            GST__c = 18,
            Quotation__c = quotation.Id
        );
        insert charge1;

        Charge_Details__c charge2 = new Charge_Details__c(
            Name = 'Parking Charges',
            Charge_Bucket__c = 'Statutory Charges',
            Charge_Type__c = 'Lumpsum',
            Charge_Amount__c = 50000,
            GST__c = 0,
            Quotation__c = quotation.Id
        );
        insert charge2;
    

    
        Unit__c testUnit = [SELECT Id FROM Unit__c LIMIT 1];

        // Call getUnitInfo
        Test.startTest();
        Unit__c result = Ex_AfterBookingPriceManagementServices.getUnitInfo(testUnit.Id);
        Quotation__c testQuotation = [SELECT Id FROM Quotation__c LIMIT 1];
        Quotation__c result1 = Ex_AfterBookingPriceManagementServices.getQuotationInfo(testQuotation.Id);
        Map<String, Charge_Details__c> priceListMap = Ex_AfterBookingPriceManagementServices.getPriceListMap(booking.Id);
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        Map<String, List<String>> priceListGroupMap = Ex_AfterBookingPriceManagementServices.getPriceListGroupMap(testBooking.Id);
        Ex_AfterBookingPriceManagementServices.getConstructionStagesMap(project.id, tower.id);
        Ex_AfterBookingPriceManagementServices.getConsturctionStageList(project.id, tower.id);
        Ex_AfterBookingPriceManagementServices.getPaymentMilestoneInfo(quotation.id);
       // Ex_AfterBookingPriceManagementServices.getPaymentSummaryInfo(testUnit.id, quotation.id, allPriceInfoMap, priceListMap)
       Ex_AfterBookingPriceManagementServices.getPriceListGroupMap(unit.id);
        Quotation__c testQuotation1 = [SELECT Id FROM Quotation__c LIMIT 1];
        Map<String, List<String>> priceListGroupMap1 = new Map<String, List<String>>();
        Map<String, Charge_Details__c> priceListMap1 = new Map<String, Charge_Details__c>();
        List<String> agreementValueGroup = new List<String>{'Basic Charge'};
        priceListGroupMap.put('Agreement Value', agreementValueGroup);
        Charge_Details__c basicCharge = [SELECT Id, Name, Charge_Amount__c, GST__c FROM Charge_Details__c WHERE Name = 'Basic Charge' LIMIT 1];
        priceListMap1.put('Basic Charge', basicCharge);

     
        Map<String, Decimal> allPriceInfo = Ex_AfterBookingPriceManagementServices.getAllPriceInfo(
            testQuotation1.Id, 1200000, 0, 18, priceListGroupMap1, priceListMap1, 50000, 10000
        );
        Test.stopTest();
 }

}