@isTest
public class TestEx_UpdateAVDetails {
    @isTest
    static void testAVDetails(){
        Project__c pro = new Project__c();
        pro.Name = 'Test Project';
        pro.NPV__c = 9;
        pro.Car_Park_Maintain_At__c = 'Tower';
        insert pro;
        
        Tower__c tower = new Tower__c();
        tower.Name = 'Test Tower';
        tower.Project__c = pro.Id;
        insert tower;
        
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
        
       /* Pricing_List__c pl4 = new Pricing_List__c();
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
        insert pl5;*/
        
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
        
        Quotation__c q = new Quotation__c();
        insert q;
        
      
        
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Quotation__c = q.Id;
        pm.Milestone_Name__c = 'On Booking';
        pm.Number_of_Days__c = 0;
        pm.Milestone_Type__c = 'Date Linked';
        pm.Sequence_No__c = 1;
        pm.Charge_Bucket_1__c = 'Agreement Value';
        pm.Charge_Bucket_1_Type__c = 'Amount';
        pm.Charge_Bucket_1_Amount__c = 50000;
        pm.Charge_Bucket_1_Percentage__c = 0;
        insert pm;
        
        Payment_Scheme_Milestone__c pm2 = new Payment_Scheme_Milestone__c();
        pm2.Milestone_Name__c = 'After 10 Days of Booking';
        pm2.Payment_Scheme__c = ps.Id;
        pm2.Number_of_Days__c = 10;
        pm2.Milestone_Type__c = 'Date Linked';
        pm2.Sequence_No__c = 2;
        pm2.Deduct_Token__c = true;
        pm2.Token_Amount__c = 50000;
        pm2.Charge_Bucket_1__c = 'Agreement Value';
        pm2.Charge_Bucket_1_Type__c = 'Percentage';
        pm2.Charge_Bucket_1_Amount__c = 0;
        pm2.Charge_Bucket_1_Percentage__c = 20;
        insert pm2;
        
        Charge_Details__c cd = new Charge_Details__c();
        cd.Name = 'Basic Charge';
        cd.Charge_Bucket__c = 'Agreement Value';
        cd.Quotation__c = q.Id;
        insert cd;
        
        Booking__c bk = new Booking__c();
        bk.Unit__c = unit1.Id;
        insert bk;
        
        q.Booking__c = bk.Id;
        update q;
        
        
        Booking__c testBooking = Ex_UpdateAVDetails.getBookingInfo(bk.Id);
        Ex_UpdateAVDetails.getAVDetails(bk.Id); 
        Map<String, Charge_Details__c>  testgetPriceListMapDetails = Ex_UpdateAVDetails.getPriceListMapDetails(unit1.Id);
        Map<String, List<String>> testgetPriceListGroupMapDetails = Ex_UpdateAVDetails.getPriceListGroupMapDetails(unit1.Id);
        Map<String, Charge_Details__c> priceListMap = Ex_UpdateAVDetails.getPriceListMapDetails(q.Id);
        Map<String, List<String>> priceListGroupMap = Ex_UpdateAVDetails.getPriceListGroupMapDetails(q.Id);
        
        Map<String, Decimal> allPriceOriginalInfoMap = Ex_UpdateAVDetails.getAllPriceMapDetails(q.Id, 1000000, 50000 , 20000, priceListGroupMap, priceListMap, 10000, 50000);
        Map<String, String> testgetAllPriceInfoFormattedMap = Ex_UpdateAVDetails.getAllPriceInfoFormattedMap(allPriceOriginalInfoMap);
        
        Ex_UpdateAVDetails.updateAVChangeDetails(bk.Id, 1000000, 500000, 30000);
        List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> testgetPaymentScheduleDetails = Ex_UpdateAVDetails.getPaymentScheduleDetails(unit1.Id, q.Id, allPriceOriginalInfoMap, priceListMap);
        List<String> testvalidateUpdatedPaymentSchedule = Ex_UpdateAVDetails.validateUpdatedPaymentScheduleDetails(1, allPriceOriginalInfoMap, testgetPaymentScheduleDetails);

        
        
    }
    
}