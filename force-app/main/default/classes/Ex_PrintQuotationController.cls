//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 21-11-2023
//-------------------------------------------//
public class Ex_PrintQuotationController {
    public Id qId {get;set;}
    public Quotation__c q {get;set;}
    public List<Quotation__c> qlist {get;set;}
    public List<Payment_Milestone__c> pmList {get;set;}
    public String tdsPer {get;set;}
    public String chargeAmount {get;set;} 
    public String chargeTaxA {get;set;} 
    public String discountAmount {get;set;}
    public String sumofDiscount {get;set;}
    public String otherchargeAmount {get;set;} 
    public String gstotherchargeAmount {get;set;}
    public String gstchargeAmountFivePer {get;set;} 
    public String stamp_registrationchargeAmount {get;set;}
    public String TotalsumofAmount {get;set;} 
    public String Total_c {get;set;}
    public String TotalCalculate {get;set;} 
    public String pmName {get;set;}
    public String InstallmentAmountPer {get;set;}
    public String gstInstallmentAmount {get;set;}
    public String finalTotal {get;set;}
    public List<paymentScheduleWrapper>  pswList {get;set;}
    public String gstotherchargeTotalOthercharges {get;set;}
    public String finalTotalOtherchargesAgreementValue {get;set;}
    public Decimal TotalTax {get;set;}
    public Decimal TotalAmount {get;set;}
    public Decimal TotalPercentage {get;set;}
    public Decimal grandTotal {get;set;}
    public  List<Charge_Detail__c> chargeList {get;set;}
    public Decimal getRegistrationAmount {get;set;}
    public Decimal BasicChargeAmount {get;set;}
    public Decimal getStampDutyAmount {get;set;}
    public Decimal getFloorRise {get;set;}//netTotal
    public Decimal netTotal {get;set;}
    public String showValueTotalper {get;set;}
    public String bookingName {get;set;}
    public String showValueTotalavgst {get;set;}
    public String showValueTotalgst {get;set;}
    public String showValueTotalIn {get;set;}
    public String showRegistrationAmount {get;set;}
    public String showBasicChargeAmount {get;set;}
    public String showgetFloorRiseAmount {get;set;}
    public String showStampAmount {get;set;}
    public String shownetTotalAmount {get;set;}

    
    public Ex_PrintQuotationController(){
        q = new Quotation__c(); 
        pmList = new List<Payment_Milestone__c>();
        qlist = new List<Quotation__c> ();
        tdsPer = null;
        chargeAmount = null;
        chargeTaxA = null;
        discountAmount = null;
        showValueTotalper = '';
        showValueTotalgst = '';
        showValueTotalavgst = '';
        showValueTotalIn = '';
      //  InstallmentAmountPerTotal = '';
        InstallmentAmountPer = '';
        TotalPercentage = 0;
        TotalTax = 0;
        TotalAmount = 0;
        grandTotal = 0;
        getStampDutyAmount = 0;
        getRegistrationAmount = 0;
        BasicChargeAmount = 0;
        getFloorRise = 0;
        netTotal = 0;
        bookingName = '';
        pswList = new List<paymentScheduleWrapper>();
        chargeList = new List<Charge_Detail__c>();
        if(ApexPages.currentPage().getParameters().containsKey('qId')) {
            qId = (Id)ApexPages.currentPage().getParameters().get('qId');
            
        }
        
        if(qId != null) {
            
            qlist =  [select id, Car_Park_Required_Count__c,Unit__r.Deck_Area__c, Unit__r.Service_Slab__c, Car_Park_Amount__c, Name,Unit__r.CreatedDate,Project__r.Name,Tower__r.Name, Unit__r.Tower__r.Terms_Condition__c, Unit__c,Unit__r.RERA_Carpet_Area_Sq_Ft__c,Unit__r.Name /*,Project__r.TDS__c */,
                      Unit__r.Inventory_Type__c,Unit__r.Total_Carpet_Area_Sq_Ft__c, Unit__r.RERA_Carpet_Area_Sq_Mtr__c, Charge_Bucket_1_Amount__c, Total_Discount__c,Charge_Bucket_3_Amount__c,Charge_Bucket_3_Total_Tax__c,Charge_Bucket_1_Total_Tax__c,Charge_Bucket_2_Amount__c,
                      CreatedDate ,Opportunity__r.Name , Unit__r.Configuration__c ,Booking__r.Name
                      from Quotation__c 
                      where id =: qId];
            if(qList[0].Booking__r.Name != null){
                bookingName = qList[0].Booking__r.Name ;
                
            }
            
            
            if(qList[0].Charge_Bucket_1_Amount__c != null){
                chargeAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Amount__c);
            }
            if(qList[0].Charge_Bucket_1_Total_Tax__c != null){
                chargeTaxA = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Total_Tax__c);
            }
            
            if(qList[0].Total_Discount__c != null){
                discountAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Total_Discount__c);
            }
            if(qList[0].Charge_Bucket_3_Amount__c != null){
                otherchargeAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_3_Amount__c);
            }
            if(qList[0].Charge_Bucket_3_Total_Tax__c != null){
                gstotherchargeAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_3_Total_Tax__c);
            }
            if(qList[0].Charge_Bucket_3_Total_Tax__c != null){
                gstotherchargeTotalOthercharges  = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_3_Amount__c + qList[0].Charge_Bucket_3_Total_Tax__c);
            }
            if(qList[0].Charge_Bucket_3_Total_Tax__c != null && qList[0].Charge_Bucket_1_Amount__c != null ){
                finalTotalOtherchargesAgreementValue  = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Amount__c + qList[0].Charge_Bucket_3_Amount__c + qList[0].Charge_Bucket_3_Total_Tax__c);
            }
            
            
            
            if(qList[0].Charge_Bucket_1_Total_Tax__c != null){
                gstchargeAmountFivePer = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Total_Tax__c);
            }
            if(qList[0].Charge_Bucket_2_Amount__c != null){
                stamp_registrationchargeAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_2_Amount__c);
            }
            sumofDiscount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Amount__c + qList[0].Total_Discount__c);
            TotalsumofAmount = Ex_InventoryPriceManagementServices.currencyFormat(qList[0].Charge_Bucket_1_Amount__c + qList[0].Charge_Bucket_3_Amount__c + qList[0].Charge_Bucket_1_Total_Tax__c +  qList[0].Charge_Bucket_3_Total_Tax__c + qList[0].Charge_Bucket_2_Amount__c  );
        }
        if(qId != null){
            chargeList = [Select Id ,Name, Charge_Amount__c from Charge_Detail__c where Quotation__c =: qId ];
            for(Charge_Detail__c cd : chargeList){
                if(cd.Name == 'Registration Charges' && cd.Charge_Amount__c != null){
                    getRegistrationAmount =  cd.Charge_Amount__c;
                    showRegistrationAmount = Ex_InventoryPriceManagementServices.currencyFormat(getRegistrationAmount);
                }
                if(cd.Name == 'Stamp Duty' && cd.Charge_Amount__c != null){
                    getStampDutyAmount =  cd.Charge_Amount__c;
                    showStampAmount = Ex_InventoryPriceManagementServices.currencyFormat(getStampDutyAmount);
                }
                if(cd.Name == 'Floor Rise' && cd.Charge_Amount__c != null){
                    getFloorRise =  cd.Charge_Amount__c;
                    showgetFloorRiseAmount = Ex_InventoryPriceManagementServices.currencyFormat(getFloorRise);
                }
                if(cd.Name == 'Basic Charge' && cd.Charge_Amount__c != null){
                    BasicChargeAmount =  (cd.Charge_Amount__c + qList[0].Car_Park_Amount__c);
                    showBasicChargeAmount = Ex_InventoryPriceManagementServices.currencyFormat(BasicChargeAmount);
                }
                
                
            }
        }
        if(qId != null){
            pmList = [Select Id, Name, Milestone_Name__c,Charge_Bucket_1_SGST__c, Charge_Bucket_1_CGST__c,Charge_Bucket_1_Total_Tax__c,  Charge_Bucket_1_Percentage__c, Charge_Bucket_1_Amount__c, Sequence_No__c /*,Quotation__r.Project__r.TDS__c*/ from Payment_Milestone__c where Quotation__c =: qId And Milestone_Name__c != null  Order By Sequence_No__c ASC ];
            System.debug('pmList: '+pmList.size());            
            for(Payment_Milestone__c pm : pmList){
                pmName = pm.Milestone_Name__c ;
                InstallmentAmountPer = Ex_InventoryPriceManagementServices.currencyFormat(pm.Charge_Bucket_1_Percentage__c); //InstallmentAmountPerTotal
                gstInstallmentAmount = Ex_InventoryPriceManagementServices.currencyFormat(pm.Charge_Bucket_1_Amount__c);
                Total_c =  Ex_InventoryPriceManagementServices.currencyFormat(pm.Charge_Bucket_1_CGST__c + pm.Charge_Bucket_1_SGST__c);
                finalTotal = Ex_InventoryPriceManagementServices.currencyFormat(pm.Charge_Bucket_1_Amount__c + pm.Charge_Bucket_1_CGST__c + pm.Charge_Bucket_1_SGST__c);
                if(pm.Charge_Bucket_1_Total_Tax__c != null)
                TotalTax += pm.Charge_Bucket_1_Total_Tax__c;
                showValueTotalgst = Ex_InventoryPriceManagementServices.currencyFormat(TotalTax);
                if(pm.Charge_Bucket_1_Amount__c != null)
                TotalAmount += pm.Charge_Bucket_1_Amount__c;
                showValueTotalavgst = Ex_InventoryPriceManagementServices.currencyFormat(TotalAmount);
                if(pm.Charge_Bucket_1_Percentage__c != null)
                TotalPercentage += pm.Charge_Bucket_1_Percentage__c;
                showValueTotalper = Ex_InventoryPriceManagementServices.currencyFormat(TotalPercentage);
                grandTotal = TotalTax + TotalAmount;
                showValueTotalIn = Ex_InventoryPriceManagementServices.currencyFormat(grandTotal);
                pswList.add(new paymentScheduleWrapper(pmName,InstallmentAmountPer,gstInstallmentAmount,Total_c,tdsPer,finalTotal,TotalPercentage,TotalAmount,TotalTax,grandTotal));
            }
            netTotal = grandTotal + getRegistrationAmount + getStampDutyAmount;
            shownetTotalAmount = Ex_InventoryPriceManagementServices.currencyFormat(netTotal);
            system.debug('grandTotal: '+grandTotal);
            System.debug('pswList: '+pswList);

        }
    }
    
    public class paymentScheduleWrapper {
        public String milestoneName {get;set;}
        public String percentDue {get;set;}
        public String milestoneAmount {get;set;}
        public String milestoneGST {get;set;}
        public String milestonegstPercentange {get;set;}
        public String totalCalculate {get;set;} 
        public Decimal TotalPercentage {get;set;}
        public Decimal TotalAmount {get;set;}
        public Decimal TotalTax {get;set;}
        public Decimal grandTotal {get;set;}

        
        public paymentScheduleWrapper(String milestoneName, String percentDue, String milestoneAmount, String milestoneGST, String milestonegstPercentange, String totalCalculate, Decimal TotalPercentage, Decimal TotalAmount,Decimal TotalTax, Decimal grandTotal) {
            this.milestoneName = milestoneName;
            this.percentDue = percentDue;
            this.milestoneAmount = milestoneAmount;
            this.milestoneGST = milestoneGST;
            this.milestonegstPercentange = milestonegstPercentange;
            this.totalCalculate = totalCalculate; 
            this.TotalPercentage = TotalPercentage;
            this.TotalAmount = TotalAmount;
            this.TotalTax = TotalTax;
            this.grandTotal = grandTotal;
        }
    }
}