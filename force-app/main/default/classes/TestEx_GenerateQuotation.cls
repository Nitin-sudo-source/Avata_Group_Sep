@isTest
public class TestEx_GenerateQuotation {
    public static Map<String, Id> createMasterData(String projectName) {
        Map<String, Id> returnMap = new Map<String, Id>();
        
        Project__c pro = new Project__c();
        pro.Name = projectName;
        pro.NPV__c = 9;
        pro.Car_Park_Maintain_At__c = 'Tower';
        insert pro;
        returnMap.put('Project', pro.Id);
        
        Tower__c tower = new Tower__c();
        tower.Name = 'Test Tower';
        tower.Project__c = pro.Id;
        insert tower;
        returnMap.put('Tower', tower.Id);
        
        Car_Park__c cp1 = new Car_Park__c();
        cp1.Project__c = pro.Id;
        cp1.Tower__c = tower.Id ;
        cp1.Status__c = 'Available';
        cp1.Car_Park_Type__c  = 'Open Parking';
        cp1.Amount__c = 500000;
        insert cp1;
        
        Car_Park__c cp2 = new Car_Park__c();
        cp2.Project__c = pro.Id;
        cp2.Tower__c = tower.Id ;
        cp2.Status__c = 'Available';
        cp2.Car_Park_Type__c  = 'Open Parking';
        cp2.Amount__c = 500000;
        insert cp2;
        
        Car_Park__c cp3 = new Car_Park__c();
        cp3.Project__c = pro.Id;
        cp3.Tower__c = tower.Id ;
        cp3.Status__c = 'Available';
        cp3.Car_Park_Type__c  = 'Podium Parking';
        cp3.Amount__c = 600000;
        insert cp3; 
        
        Team__c te1=new Team__c();
        te1.Team_Type__c = 'Quotation Approval Team';
        te1.Project__c=pro.id;
        insert te1;
       // User u11=new User();
       // u11.IsActive=true;
        //insert u11;
        
        Team_Member__c t1=new Team_Member__c();
        t1.Team__c=te1.id;
        t1.Position__c='Site Head Approver';
       // t1.User__c=u11.id;
        insert t1;
        
        Car_Park__c cp4 = new Car_Park__c();
        cp4.Project__c = pro.Id;
        cp4.Tower__c = tower.Id ;
        cp4.Status__c = 'Available';
        cp4.Car_Park_Type__c  = 'Podium Parking';
        cp4.Amount__c = 600000;
        insert cp4;
        
        Construction_Stage__c cs1 = new Construction_Stage__c();
        cs1.Name = 'Construction Stage 1';
        cs1.Tower__c = tower.Id;
        cs1.Expected_Completion_Date__c = system.today().addDays(-30);
        cs1.Actual_Completion_Date__c = system.today().addDays(-20);
        insert cs1;
        
        Construction_Stage__c cs2 = new Construction_Stage__c();
        cs2.Name = 'Construction Stage 2';
        cs2.Tower__c = tower.Id;
        cs2.Expected_Completion_Date__c = system.today().addDays(30);
        insert cs2;
        
        Construction_Stage__c cs3 = new Construction_Stage__c();
        cs3.Name = 'Construction Stage 3';
        cs3.Tower__c = tower.Id;
        cs3.Expected_Completion_Date__c = system.today().addDays(60);
        insert cs3;
        
        Construction_Stage__c cs4 = new Construction_Stage__c();
        cs4.Name = 'Construction Stage 4';
        cs4.Tower__c = tower.Id;
        cs4.Expected_Completion_Date__c = system.today().addDays(90);
        insert cs4;
        
        Payment_Scheme__c ps = new Payment_Scheme__c();
        ps.Name = 'Test Payment Scheme';
        ps.Tower__c = tower.Id;
        ps.Is_Editable__c = true;
        ps.Active__c = true;
        ps.Number_of_Milestone__c = 20;
        insert ps;
        returnMap.put('Payment Scheme', ps.Id);
        
        List<Payment_Scheme_Milestone__c> psmList = new List<Payment_Scheme_Milestone__c>();
        
        Payment_Scheme_Milestone__c psm1 = new Payment_Scheme_Milestone__c();
        psm1.Milestone_Name__c = 'On Booking';
        psm1.Payment_Scheme__c = ps.Id;
        psm1.Number_of_Days__c = 0;
        psm1.Milestone_Type__c = 'Date Linked';
        psm1.Sequence_No__c = 1;
        psm1.Charge_Bucket_1__c = 'Agreement Value';
        psm1.Charge_Bucket_1_Type__c = 'Amount';
        psm1.Charge_Bucket_1_Amount__c = 50000;
        psm1.Charge_Bucket_1_Percentage__c = 0;
        psmList.add(psm1);
        
        Payment_Scheme_Milestone__c psm2 = new Payment_Scheme_Milestone__c();
        psm2.Milestone_Name__c = 'After 10 Days of Booking';
        psm2.Payment_Scheme__c = ps.Id;
        psm2.Number_of_Days__c = 10;
        psm2.Milestone_Type__c = 'Date Linked';
        psm2.Sequence_No__c = 2;
        psm2.Deduct_Token__c = true;
        psm2.Token_Amount__c = 50000;
        psm2.Charge_Bucket_1__c = 'Agreement Value';
        psm2.Charge_Bucket_1_Type__c = 'Percentage';
        psm2.Charge_Bucket_1_Amount__c = 0;
        psm2.Charge_Bucket_1_Percentage__c = 20;
        psmList.add(psm2);
        
        Payment_Scheme_Milestone__c psm3 = new Payment_Scheme_Milestone__c();
        psm3.Milestone_Name__c = 'On Completetion Construction Stage 1';
        psm3.Payment_Scheme__c = ps.Id;
        psm3.Number_of_Days__c = 0;
        psm3.Milestone_Type__c = 'Construction Linked';
        psm3.Construction_Stage__c = cs1.Id;
        psm3.Sequence_No__c = 3;
        psm3.Charge_Bucket_1__c = 'Agreement Value';
        psm3.Charge_Bucket_1_Type__c = 'Percentage';
        psm3.Charge_Bucket_1_Amount__c = 0;
        psm3.Charge_Bucket_1_Percentage__c = 20;
        psmList.add(psm3);
        
        Payment_Scheme_Milestone__c psm4 = new Payment_Scheme_Milestone__c();
        psm4.Milestone_Name__c = 'On Completetion Construction Stage 2';
        psm4.Payment_Scheme__c = ps.Id;
        psm4.Number_of_Days__c = 0;
        psm4.Milestone_Type__c = 'Construction Linked';
        psm4.Construction_Stage__c = cs2.Id;
        psm4.Sequence_No__c = 4;
        psm4.Charge_Bucket_1__c = 'Agreement Value';
        psm4.Charge_Bucket_1_Type__c = 'Percentage';
        psm4.Charge_Bucket_1_Amount__c = 0;
        psm4.Charge_Bucket_1_Percentage__c = 20;
        psmList.add(psm4);
        
        Payment_Scheme_Milestone__c psm5 = new Payment_Scheme_Milestone__c();
        psm5.Milestone_Name__c = 'On Completetion Construction Stage 3';
        psm5.Payment_Scheme__c = ps.Id;
        psm5.Number_of_Days__c = 0;
        psm5.Milestone_Type__c = 'Construction Linked';
        psm5.Construction_Stage__c = cs3.Id;
        psm5.Sequence_No__c = 5;
        psm5.Charge_Bucket_1__c = 'Agreement Value';
        psm5.Charge_Bucket_1_Type__c = 'Percentage';
        psm5.Charge_Bucket_1_Amount__c = 0;
        psm5.Charge_Bucket_1_Percentage__c = 20;
        psmList.add(psm5);
        
        Payment_Scheme_Milestone__c psm6 = new Payment_Scheme_Milestone__c();
        psm6.Milestone_Name__c = 'On Completetion Construction Stage 4';
        psm6.Payment_Scheme__c = ps.Id;
        psm6.Number_of_Days__c = 0;
        psm6.Milestone_Type__c = 'Construction Linked';
        psm6.Construction_Stage__c = cs4.Id;
        psm6.Sequence_No__c = 6;
        psm6.Charge_Bucket_1__c = 'Agreement Value';
        psm6.Charge_Bucket_1_Type__c = 'Percentage';
        psm6.Charge_Bucket_1_Amount__c = 0;
        psm6.Charge_Bucket_1_Percentage__c = 20;
        psmList.add(psm6);
        insert psmList;
        
        Unit__c unit1 = new Unit__c();
        unit1.Name = 'Unit 1';
        unit1.Tower__c = tower.Id;
        unit1.Project__c = pro.Id;
        unit1.Total_carpet_Sq_Ft__c = 1000;
        unit1.Saleable_Area__c = 1200;
        unit1.Configuration_Type__c = '4 BHK';
        unit1.Sales_Status__c = 'Vacant';
        insert unit1;
        returnMap.put('Unit', unit1.Id);
        
        Pricing_List__c pl1 = new Pricing_List__c();
        pl1.Unit__c = unit1.id;
        pl1.Charge_Type__c = 'PSF';
        pl1.Calculation_Area_Type__c = 'Saleable Area';
        pl1.Charge_Rate__c = 1000;
        pl1.GST__c = 5;
        pl1.Charge_Bucket__c = 'Agreement Value';
        pl1.Charge_Name__c = 'Basic Charge';
        insert pl1;
        
        Pricing_List__c pl2 = new Pricing_List__c();
        pl2.Unit__c = unit1.id;
        pl2.Charge_Type__c = 'PSF';
        pl2.Calculation_Area_Type__c = 'Saleable Area';
        pl2.Charge_Rate__c = 84;
        pl2.GST__c = 18;
        pl2.Charge_Bucket__c = 'Other Charges';
        pl2.Charge_Name__c = 'MSEB & Water Charge';
        insert pl2;
        
        Pricing_List__c pl3 = new Pricing_List__c();
        pl3.Unit__c = unit1.id;
        pl3.Charge_Type__c = 'Lumpsum';
        pl3.Charge_Amount__c = 50000;
        pl3.GST__c = 18;
        pl3.Charge_Bucket__c = 'Other Charges';
        pl3.Charge_Name__c = 'Development Charge';
        insert pl3;
        
        Pricing_List__c pl4 = new Pricing_List__c();
        pl4.Unit__c = unit1.id;
        pl4.Charge_Type__c = 'Percentage';
        pl4.Charge_Percentage__c = 6;
        pl4.GST__c = 0;
        pl4.Charge_Bucket__c = 'Statutory Charges';
        pl4.Charge_Name__c = 'Stamp Duty';
        insert pl4;
        
        Pricing_List__c pl5 = new Pricing_List__c();
        pl5.Unit__c = unit1.id;
        pl5.Charge_Type__c = 'Percentage';
        pl5.Charge_Percentage__c = 1;
        pl5.GST__c = 0;
        pl5.Charge_Bucket__c = 'Statutory Charges';
        pl5.Charge_Name__c = 'Registration Charges';
        insert pl5;
        
        Discount__c d1 = new Discount__c();
        d1.Project__c = pro.Id;
        d1.Tower__c = tower.Id;
        d1.Grouping__c = 'Group 1';
        d1.Category__c = 'Approved';
        d1.Discount_Category__c = 'Discount';
        d1.Discount_Reason__c = 'Test PSF Discount 1';
        d1.Discount_Type__c = 'PSF';
        d1.PSF_Amount__c = 100;
        d1.Start_Date__c = system.today() - 10;
        insert d1;
		returnMap.put('Discount 1', d1.Id);
        
        Discount__c d2 = new Discount__c();
        d2.Project__c = pro.Id;
        d2.Tower__c = tower.Id;
        d2.Grouping__c = 'Group 2';
        d2.Category__c = 'Approved';
        d2.Discount_Category__c = 'Discount';
        d2.Discount_Reason__c = 'Test Discount 2';
        d2.Discount_Type__c = 'Lumpsum';
        d2.Amount__c = 10000;
        d2.Start_Date__c = system.today() - 10;
        insert d2;
        returnMap.put('Discount 2', d2.Id);
        
        Discount__c d3 = new Discount__c();
        d3.Project__c = pro.Id;
        d3.Tower__c = tower.Id;
        d3.Grouping__c = 'Group 3';
        d3.Category__c = 'Approved';
        d3.Discount_Category__c = 'Discount';
        d3.Discount_Reason__c = 'Test Discount 3';
        d3.Discount_Type__c = 'Percentage';
        d3.Percentage_of_AV__c = 1;
        d3.Start_Date__c = system.today() - 10;
        insert d3;
        returnMap.put('Discount 3', d3.Id);
        
         Discount__c d4 = new Discount__c();
        d4.Project__c = pro.Id;
        d4.Tower__c = tower.Id;
        d4.Grouping__c = 'Group 3';
        d4.Category__c = 'Unapproved';
        d4.Discount_Category__c = 'Discount';
        d4.Discount_Reason__c = 'Test Discount 3';
        d4.Discount_Type__c = 'Percentage';
        d4.Percentage_of_AV__c = 1;
        d4.Start_Date__c = system.today() - 10;
        insert d4;
        returnMap.put('Discount 4', d4.Id);
        
         Discount__c d5 = new Discount__c();
        d5.Project__c = pro.Id;
        d5.Tower__c = tower.Id;
        d5.Grouping__c = 'Group 3';
        d5.Category__c = 'Unapproved';
        d5.Discount_Category__c = 'Credit Note';
        d5.Discount_Reason__c = 'Test Discount 3';
        d5.Discount_Type__c = 'Percentage';
        d5.Percentage_of_AV__c = 1;
        d5.Start_Date__c = system.today() - 10;
        insert d5;
        returnMap.put('Discount 4', d5.Id);
        return returnMap;
    }
    
    @isTest
    public static void testQuotation() {
        Map<String, Id> returnMap = createMasterData('Test Project');
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.LastName = 'acc1';
        acc.Phone = '99854857584';
        acc.PersonMobilePhone = '9958455544';
        acc.Alternate_Email__c = 'acc1@gmail.com';
        acc.PersonEmail = 'acc11@gmail.com';
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Test op';
        opp.Account__c = acc.Id;
        opp.Stage__c = 'In Follow-up';
        opp.Close_Date__c = system.today().addDays(1);
        opp.Project__c = returnMap.get('Project');
        insert opp;
        
        Quotation__c quote = new Quotation__c();
        quote.Opportunity__c = opp.Id;
        insert quote;
        Quotation__c q = Ex_InventoryPriceManagementServices.getQuotationInfo(quote.Id);
        Opportunity__c op = Ex_GenerateQuotation.getOppDetails(opp.Id);
        Unit__c u = Ex_GenerateQuotation.getUnitDetails(returnMap.get('Unit'));
        Map<String, Team_Member__c> approvalTeam =  Ex_InventoryPriceManagementServices.getApprovalTeamMemberDetails(u.project__c, 'Quotation Approval Team');

        List<Payment_Scheme__c> psList = Ex_GenerateQuotation.getPaymentSchemeDetails(u.Tower__c);
        List<Ex_InventoryPriceManagementServices.CarParkWrapper> carParkList = Ex_GenerateQuotation.getCarParkDetails(u.Project__c, u.Tower__c);
        Map<String, List<String>> priceListGroupMap = Ex_GenerateQuotation.getPriceListGroupMapDetails(u.Id);
        Map<String, Pricing_List__c> priceListMap = Ex_GenerateQuotation.getPriceListMapDetails(u.Id);
        Map<String, List<Discount__c>> discountGroupMap = Ex_GenerateQuotation.getDiscountGroupMapDetails(u.Project__c, u.Tower__c);
        Ex_GenerateQuotation.getDiscountGroupMapDetails(u.Project__c, u.Tower__c);
        List<String> values = Ex_GenerateQuotation.getPicklistValues('Payment_Milestone__c', 'Milestone_Type__c');
        Map<String, Decimal> allPriceOriginalInfoMap = Ex_GenerateQuotation.getAllPriceMapDetails(u.Id, priceListGroupMap, priceListMap, 0, 0,0);
        Map<String, String> allPriceInfoFormattedMap = Ex_GenerateQuotation.getAllPriceInfoFormattedMap(allPriceOriginalInfoMap);
        List<Discount__c> appliedDiscountList = new List<Discount__c>();
        Discount__c d = [Select Id, Name, Applied__c, Discount_Category__c, Category__c, Total__c, Percentage_of_AV__c, Amount__c, PSF_Amount__c, Discount_Type__c,
                         Description__c, Discount_Reason__c from Discount__c where Id =: returnMap.get('Discount 2')];
        d.Total__c = 10000;
        d.Applied__c = true;
        appliedDiscountList.add(d);
        Map<String, Decimal> allPriceInfoMap = Ex_GenerateQuotation.getAllPriceMapDetails(u.Id, priceListGroupMap, priceListMap, 0, 10000,0);
        allPriceInfoFormattedMap = Ex_GenerateQuotation.getAllPriceInfoFormattedMap(allPriceInfoMap);
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_GenerateQuotation.getPaymentScheduleDetails(u.Id, psList[0].Id, allPriceInfoMap, priceListMap);
        Map<String, Decimal> allOriginalNPVPriceMap = Ex_GenerateQuotation.getCalculatedNPVDetails(false, paymentMilestoneWrapperList, u);
        List<String> validationErrorList = Ex_GenerateQuotation.validateUpdatedPaymentScheduleDetails(1, allPriceInfoMap, paymentMilestoneWrapperList);
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList = Ex_GenerateQuotation.getUpdatedPaymentScheduleDetails(u, 1, priceListMap, allPriceInfoMap, paymentMilestoneWrapperList);
        Map<String, Decimal> allUpdatedNPVPriceMap = Ex_GenerateQuotation.getCalculatedNPVDetails(true, updatedPaymentMilestoneWrapperList, u);
        Ex_GenerateQuotation.getModifiedPaymentScheduleDetails('hello', 1, paymentMilestoneWrapperList, u, 1000);
        Id qId = Ex_GenerateQuotation.saveQuotationDetails(u, op.Id, psList[0].Id, priceListGroupMap, priceListMap, allPriceOriginalInfoMap, allPriceInfoMap, appliedDiscountList, carParkList, updatedPaymentMilestoneWrapperList);
    }
}