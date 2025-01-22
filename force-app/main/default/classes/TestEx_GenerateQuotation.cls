@isTest
public class TestEx_GenerateQuotation {
    @isTest
    public static void testdata(){
        Project__c pro = new Project__c(Name = 'Test',NPV__c =100);
        insert pro ;
        
        Tower__c tower = new Tower__c(Name = 'Test' ,Project__c =Pro.Id);
        insert tower ;
        
        Unit__c unit = new Unit__c(Name = 'Test' ,Saleable_Area__c = 54 ,Tower__c = tower.Id ,Project__c =Pro.Id ,Total_Carpet_Area_Sq_Ft__c =10,Configuration__c = '4 BHK' ,Floor__c=1,Sale_Status__c = 'Vacant');
        insert unit ;
        List<Unit__c> unitList = new List<Unit__c>();
        
        Unit__c unit3 = new Unit__c(
            Name = 'Test Unit 1',
            Tower__c = tower.Id,
            Project__c = Pro.Id,
            Total_Carpet_Area_Sq_Ft__c = 10,
            Floor__c = 1,
            Sale_Status__c = 'Vacant',
            Configuration__c = '3 BHK',
            Saleable_Area__c = 54
        );
        unitList.add(unit3);
        
        Unit__c unit2 = new Unit__c(
            Name = 'Test Unit 2',
            Tower__c = tower.Id,
            Project__c = Pro.Id,
            Total_Carpet_Area_Sq_Ft__c = 106,
            Floor__c = 2,
            Sale_Status__c = 'Booking Confirmed',
            Configuration__c = '2 BHK',
            Saleable_Area__c = 54
        );
        Unit__c unit4 = new Unit__c(
            Name = 'Test Unit 3',
            Tower__c = tower.Id,
            Project__c = Pro.Id,
            Total_Carpet_Area_Sq_Ft__c = 106,
            Floor__c = 3,
            Sale_Status__c = 'Blocked',
            Saleable_Area__c = 54
        );
        unitList.add(unit4);
        
        Unit__c unit5 = new Unit__c(
            Name = 'Test Unit 3',
            Tower__c = tower.Id,
            Project__c = Pro.Id,
            Total_Carpet_Area_Sq_Ft__c = 106,
            Floor__c = 4,
            Sale_Status__c = '	Reserved',
            Configuration__c = '1 BHK',
            Saleable_Area__c = 54
        );
        unitList.add(unit5);
        
        insert unitList;
        
        
        Opportunity__c opp = new Opportunity__c(Name = 'Test Opp', Opportunity_Stage__c = 'Booking Confirmed' , Project__c = pro.Id);
        insert opp;
        
        Construction_Stage__c cos = new Construction_Stage__c(Name = 'Test' ,Tower__c =tower.Id);
        insert cos;
        
        Payment_Scheme__c paymentScheme = new Payment_Scheme__c(Name = 'Test' ,Tower__c =tower.Id);
        insert paymentScheme ;
        
        List<Payment_Scheme_Milestone__c> psmList = new List<Payment_Scheme_Milestone__c>();
        
        Payment_Scheme_Milestone__c psm1 = new Payment_Scheme_Milestone__c(
            No_of_Days__c = 1,
            Milestone_Type__c = 'Date Linked',
            Payment_Scheme__c = paymentScheme.Id,
            Milestone_Name__c = 'test',
            Sequence_No__c = 1,
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Type__c = 'Percentage' ,
            Charge_Bucket_1_Percentage__c = 100 
        );
        psmList.add(psm1);
        
        Payment_Scheme_Milestone__c psm2 = new Payment_Scheme_Milestone__c(
            No_of_Days__c = 1,
            Milestone_Type__c = 'Construction Linked',
            Construction_Stage__c = cos.Id,
            Payment_Scheme__c = paymentScheme.Id,
            Charge_Bucket_1__c = 'Agreement Value',
            Charge_Bucket_1_Type__c = 'Percentage' ,
            Charge_Bucket_1_Percentage__c = 100 
        );
        psmList.add(psm2);
        insert psmList;
        
        Ex_InventoryPriceManagementServices.CarParkWrapper carPark = new Ex_InventoryPriceManagementServices.CarParkWrapper(
            'Compact',
            10.0,
            500.0,
            5.0,
            '500.00'
        );
        Decimal positiveAmount = 1234.56;
        String formattedAmount = Ex_InventoryPriceManagementServices.currencyFormat(positiveAmount);
        Decimal negativeAmount = -789.12;
        formattedAmount = Ex_InventoryPriceManagementServices.currencyFormat(negativeAmount);
        Decimal zeroAmount = 0.00;
        formattedAmount = Ex_InventoryPriceManagementServices.currencyFormat(zeroAmount);
        List<Discount__c> discounts = new List<Discount__c>();
        discounts.add(new Discount__c(
            Project__c = pro.Id,
            Grouping__c = 'Group 1	',
            Tower__c = tower.Id,
            Discount_Type__c = 'PSF',
            PSF_Amount__c = 100.00,
            Category__c = 'Approved',
            Discount_Category__c = 'Discount',
            Amount__c = 777 ,
            End_Date__c = System.today().addDays(+2),
            Applied__c = true 
        ));
        discounts.add(new Discount__c(
            Project__c = pro.Id,
            Grouping__c = 'Group 1',
            Discount_Type__c = 'Percentage',
            Tower__c = tower.Id,
            Percentage_of_AV__c = 10.0,
            Category__c = 'Unapproved',
            Discount_Category__c = 'Discount',
            Amount__c = 777 ,
            End_Date__c = System.today().addDays(+2),
            Applied__c = true 
        ));
        discounts.add(new Discount__c(
            Project__c = pro.Id,
            Grouping__c = 'Group 1',
            Discount_Type__c = 'Percentage',
            Tower__c = tower.Id,
            Percentage_of_AV__c = 10.0,
            Discount_Category__c = 'Credit Note',
            Amount__c = 777 ,
            End_Date__c = System.today().addDays(+2),
            Applied__c = true 
        ));
        insert discounts;
        
        system.debug('discounts  ::'+discounts);
        
        Car_Park__c cp = new Car_Park__c();
        cp.Project__c = pro.Id;
        cp.Tower__c = tower.Id ;
        cp.Status__c='Available';
        // cp.Car_Park_Type__c = 'Open Parking';
        cp.Type__c  = 'Open Parking';
        cp.Amount__c = 76766 ;
        insert cp ;
        
        Team__c t = new Team__c();
        t.Name = 'Test';
        t.Team_Type__c = 'Sales Team';
        t.Project__c = pro.id;
        insert t ;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Team__c = t.id;
        tm.User__c = UserInfo.getUserId();
        tm.Availability__c = true;
        insert tm;
        
        Pricing_List__c testPriceList = new Pricing_List__c(
            Unit__c = unit.Id,
            Charge_Bucket__c = 'Agreement Value',
            Charge_Name__c = 'Basic Charge',
            Charge_Type__c = 'Percentage',
            Charge_Percentage__c = 10,
            GST__c = 5
        );
        insert testPriceList ;
        Pricing_List__c testPriceList2 = new Pricing_List__c(
            Unit__c = unit.Id,
            Charge_Bucket__c = 'Statutory Charges',
            Charge_Name__c = 'Stamp Duty',
            Charge_Type__c = 'Percentage',
            Charge_Percentage__c = 10,
            GST__c = 5
        );
        insert testPriceList2 ;
        
        Car_Park_Required__c cpr = new Car_Park_Required__c();
        cpr.Car_Park_Type__c = 'Podium Parking';
        cpr.Car_Park_Count__c = 2;
        cpr.Car_Park_Amount__c = 100 * 2;
        insert cpr ;
        
        Blocking_Details__c bd = new Blocking_Details__c();
        bd.Status__c = 'Blocked' ;
        bd.Unit__c = unit4.id;
        insert bd ;
        
        Unit__c getUnitDetails = Ex_CreateQuotationController.getUnitDetails(unit.Id);
        Opportunity__c getOppDetails = Ex_CreateQuotationController.getOppDetails(opp.Id);
        List<Payment_Scheme__c> getPaymentSchemeDetails = Ex_CreateQuotationController.getPaymentSchemeDetails(tower.Id);
        List<Ex_InventoryPriceManagementServices.CarParkWrapper> getCarParkDetails = Ex_CreateQuotationController.getCarParkDetails(Pro.Id, tower.Id ,unit);
        Map<String, Pricing_List__c> getPriceListMapDetails = Ex_CreateQuotationController.getPriceListMapDetails(unit.Id);
        Map<String, List<String>> getPriceListGroupMapDetails = Ex_CreateQuotationController.getPriceListGroupMapDetails(unit.Id);
        Map<String, List<Discount__c>>  getDiscountGroupMapDetails = Ex_CreateQuotationController.getDiscountGroupMapDetails(Pro.Id, tower.Id ,unit);
        Map<String, Decimal> getAllPriceMapDetails = Ex_CreateQuotationController.getAllPriceMapDetails(unit.Id ,getPriceListGroupMapDetails,getPriceListMapDetails,100, 200);
        Map<String, String> getAllPriceInfoFormattedMap = Ex_CreateQuotationController.getAllPriceInfoFormattedMap(getAllPriceMapDetails);
        Ex_CreateQuotationController.getPicklistValues('Opportunity__c','Configuration_Required__c');
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getPaymentScheduleDetails = Ex_CreateQuotationController.getPaymentScheduleDetails(unit.Id , paymentScheme.Id, getAllPriceMapDetails ,getPriceListMapDetails);
        List<String> validateUpdatedPaymentScheduleDetails = Ex_CreateQuotationController.validateUpdatedPaymentScheduleDetails(1,getAllPriceMapDetails,getPaymentScheduleDetails);
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getUpdatedPaymentScheduleDetails = Ex_CreateQuotationController.getUpdatedPaymentScheduleDetails(unit,1,getPriceListMapDetails,getAllPriceMapDetails ,getPaymentScheduleDetails);
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getModifiedPaymentScheduleDetails = Ex_CreateQuotationController.getModifiedPaymentScheduleDetails('Remove',1, getPaymentScheduleDetails, unit , 0);
        Map<String, Decimal> getCalculatedNPVDetails = Ex_CreateQuotationController.getCalculatedNPVDetails(true, getPaymentScheduleDetails, unit);
        Id saveQuotationDetails = Ex_CreateQuotationController.saveQuotationDetails(
            unit,
            opp.Id,
            paymentScheme.Id,
            getPriceListGroupMapDetails,
            getAllPriceMapDetails,
            Ex_InventoryPriceManagementServices.getTowerLevelDiscountInfo(pro.Id, tower.Id, unit),
            getCarParkDetails,
            getPaymentScheduleDetails,
            getCalculatedNPVDetails
        );
        Ex_InventoryPriceManagementServices.getOpportunityInfo(opp.Id);
        Ex_InventoryPriceManagementServices.getTowerLevelDiscountInfo(Pro.Id, tower.Id ,unit);
        Ex_InventoryPriceManagementServices.calculateNPV(getPaymentScheduleDetails,Pro.Id);
        Ex_InventoryPriceManagementServices.getPaymentSchemeInfo(tower.Id);
        Ex_InventoryPriceManagementServices.getQuotationInfo(Pro.Id);
        Ex_InventoryPriceManagementServices.getLegalEntityDetails(unit.Id ,tower.Id , Pro.Id);
        Ex_InventoryPriceManagementServices.getProjectLevelDiscountInfo(Pro.Id);
        Ex_InventoryPriceManagementServices.getApprovalTeamMemberDetails(Pro.Id , 'Sales Team');
        Ex_InventoryPriceManagementServices.INFormatR(455);
        EX_BlockingDetailsController.getBlockDetails(unit4.id);
        EX_BlockingDetailsController.fetchUnits(unit.id);
        EX_BlockingDetailsController.getOppName(opp.id);
        EX_BlockingDetailsController.getModeOfFundingPicklist();
        EX_BlockingDetailsController.createBlockingRecord(true , 200,'test' ,'test',unit.Id ,opp.Id,'Credit');
        EX_BlockingDetailsController.unblockLogic(bd.id ,'unblockComment');
    }
}