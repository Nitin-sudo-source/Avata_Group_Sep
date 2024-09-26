public class Ex_PrintQuotationController {
    public string qId{get;set;}
    public Quotation__c q{get;set;}
    public List<Quotation__c> qList {get;set;}
    public List<Car_Park__c> carList{get;set;}
    public List<Unit__c> uList{get;set;}
    public List<Charge_Details__c> cdList{get;set;}
    public Map<String, String> flatDetails {get;set;}
    public Map<String, String> considerationAmount {get;set;}
    public Map<String, String> societyCharges {get;set;}
    public Map<String, String> nonAccountableCharges {get;set;}
    public List<Map<String, String>> paymentSchedule {get;set;}
    public Map<String, String> paymentScheduleTotal {get;set;}
    public Map<String, String> flatCostBankingDetails {get;set;}
    public Map<String, String> gstCostBankingDetails {get;set;}
    public String createdDate {get;set;}
    public Decimal totalSDRCharges {get;set;}
    public String totalSDRChargesFormatted {get;set;}
    public Decimal totalOtherCharges {get;set;}
    public String totalOtherChargesFormatted {get;set;}
    public Decimal totalAgreementValue {get;set;}
    public String totalAgreementValueFormatted {get;set;}
    public Decimal grandTotal {get;set;}
    public String grandTotalFormatted {get;set;}
    public Quotation__c quotation {get; set;}
    
    public Ex_PrintQuotationController(){
        qId=ApexPages.currentPage().getParameters().get('qId');
        q=new Quotation__c();
        qList = new List<Quotation__c>();
        carList = new List<Car_Park__c>();
        uList = new List<Unit__c>();
        cdList = new List<Charge_Details__c>();
        flatDetails = new Map<String,String>();
        considerationAmount = new Map<String,String>();
        societyCharges = new Map<String,String>();
        nonAccountableCharges = new Map<String,String>();
        paymentSchedule = new List<Map<String,String>>();
        flatCostBankingDetails = new Map<String,String>();
        gstCostBankingDetails = new Map<String,String>();
        paymentScheduleTotal = new Map<String, String>();
        totalSDRCharges = 0;
        totalSDRChargesFormatted = '';
        totalOtherCharges = 0;
        totalOtherChargesFormatted = '';
        totalAgreementValue = 0;
        totalAgreementValueFormatted = '';
        grandTotal = 0;
        grandTotalFormatted = '';
        
        List<Quotation__c> quotationList = new List<Quotation__c>();
        quotation = new Quotation__c();
        List<Payment_Milestone__c> paymentMilestoneList = new List<Payment_Milestone__c>();
        
        if (qId != null) {
            quotationList = [SELECT Id, Name, CreatedDate, Car_Park_Required_Count__c, Project__r.Quotation_Terms_and_Conditions__c,
                             Unit__c, Unit__r.Floor__c, Unit__r.Configuration_Type__c, Unit__r.RERA_Carpet_Area_Sq_Ft__c, Unit__r.RERA_Carpet_Area_Sq_Mtr__c,
                             Project__c, Project__r.Project_Logo__c
                             FROM Quotation__c WHERE Id = :qId
                            ];
            if (quotationList != null && !quotationList.isEmpty()) {
                quotation = quotationList[0];
                createdDate = String.valueOf(quotation.CreatedDate.format('dd/MM/yyyy'));
                flatDetails.put('Car_Park_Required_Count__c', quotation.Car_Park_Required_Count__c != null ? String.valueOf(quotation.Car_Park_Required_Count__c) : ' ');
                flatDetails.put('Quotation_Terms_and_Conditions__c', quotation.Project__r.Quotation_Terms_and_Conditions__c != null ? String.valueOf(quotation.Project__r.Quotation_Terms_and_Conditions__c) : ' ');

                
                paymentMilestoneList = [SELECT Id, Name, Sequence_No__c, Quotation__c, Milestone_Name__c, Due_Date__c,
                                        Charge_Bucket_1__c, Charge_Bucket_1_Percentage__c, Charge_Bucket_1_Amount__c, Charge_Bucket_1_Total_Tax__c,
                                        Charge_Bucket_2__c, Charge_Bucket_2_Percentage__c, Charge_Bucket_2_Amount__c, Charge_Bucket_2_Total_Tax__c,
                                        Charge_Bucket_3__c, Charge_Bucket_3_Percentage__c, Charge_Bucket_3_Amount__c, Charge_Bucket_3_Total_Tax__c,
                                        Charge_Bucket_4__c, Charge_Bucket_4_Percentage__c, Charge_Bucket_4_Amount__c, Charge_Bucket_4_Total_Tax__c,
                                        Charge_Bucket_5__c, Charge_Bucket_5_Percentage__c, Charge_Bucket_5_Amount__c, Charge_Bucket_5_Total_Tax__c
                                        FROM Payment_Milestone__c WHERE Quotation__c = : qId 
                                        ORDER BY Sequence_No__c ASC ];
                
                
                Decimal totalChargeBucketPercentage = 0;
                Decimal totalChargeBucketAmount = 0;
                Decimal totalChargeBucketTotalTax = 0;
                Decimal totalChargeBucketTotal = 0;
                Decimal totalChargeBucketTDS = 0;
                
                for(Payment_Milestone__c paymentMilestone : paymentMilestoneList){
                    Map<String, String> currPaymentMilestone = new Map<String, String>();
                    
                    currPaymentMilestone.put('Sequence_No__c', paymentMilestone.Sequence_No__c != null ? String.valueOf(paymentMilestone.Sequence_No__c) : ' ');
                    currPaymentMilestone.put('Milestone_Name__c', paymentMilestone.Milestone_Name__c != null ? String.valueOf(paymentMilestone.Milestone_Name__c) : ' ');
                    //currPaymentMilestone.put('TDS_Amount__c',  paymentMilestone.TDS_Amount__c != null ? String.valueOf(currencyFormat(paymentMilestone.TDS_Amount__c)): ' ');
                    currPaymentMilestone.put('Due_Date__c',  paymentMilestone.Due_Date__c != null ? paymentMilestone.Due_Date__c.format(): ' ');
                    currPaymentMilestone.put('Total_Tax__c', ' ');
                    currPaymentMilestone.put('Percentage__c', ' ');
                    currPaymentMilestone.put('Amount__c', ' ');
                    currPaymentMilestone.put('Total', ' ');
                    
                    //totalChargeBucketTDS += (Decimal)paymentMilestone.TDS_Amount__c;
                    
                    for(Integer i=1; i<5; i++){
                        String chargeBucketName = 'Charge_Bucket_' + i + '__c';
                        String chargeBucketPercentage = 'Charge_Bucket_' + i + '_Percentage__c';
                        String chargeBucketAmount = 'Charge_Bucket_' + i + '_Amount__c';
                        String chargeBucketTotalTax = 'Charge_Bucket_' + i + '_Total_Tax__c';
                        
                        if(paymentMilestone.get(chargeBucketName) != null && paymentMilestone.get(chargeBucketName) == 'Agreement Value'){
                            Decimal chargeBucketPercentageValue =  (Decimal)paymentMilestone.get(chargeBucketPercentage);
                            Decimal chargeBucketAmountValue =  (Decimal)paymentMilestone.get(chargeBucketAmount);
                            Decimal chargeBucketTotalTaxValue =  (Decimal)paymentMilestone.get(chargeBucketTotalTax);
                            Decimal chargeBucketTotalValue =  (Decimal)paymentMilestone.get(chargeBucketAmount) + (Decimal)paymentMilestone.get(chargeBucketTotalTax);
                            
                            totalChargeBucketPercentage += chargeBucketPercentageValue;
                            totalChargeBucketAmount += chargeBucketAmountValue;
                            totalChargeBucketTotalTax += chargeBucketTotalTaxValue;
                            totalChargeBucketTotal  += chargeBucketTotalValue;
                            
                            currPaymentMilestone.put('Total_Tax__c', String.valueOf(currencyFormat(chargeBucketTotalTaxValue)));
                            currPaymentMilestone.put('Percentage__c', String.valueOf(currencyFormat(chargeBucketPercentageValue)));
                            currPaymentMilestone.put('Amount__c', String.valueOf(currencyFormat(chargeBucketAmountValue)));
                            currPaymentMilestone.put('Total', String.valueOf(currencyFormat(chargeBucketTotalValue)));
                            break;
                        }
                    }
                    System.debug('currPaymentMilestone : ' + currPaymentMilestone);
                    paymentSchedule.add(currPaymentMilestone);
                    
                }
                
                // A total of all Payment Milestone
                paymentScheduleTotal.put('Milestone_Name', 'Total');
                paymentScheduleTotal.put('Total_Percentage', String.valueOf(currencyFormat(totalChargeBucketPercentage)));
                paymentScheduleTotal.put('Total_TDS', String.valueOf(currencyFormat(totalChargeBucketTDS)));
                paymentScheduleTotal.put('Total_Amount', String.valueOf(currencyFormat(totalChargeBucketAmount)));
                paymentScheduleTotal.put('Total_Tax', String.valueOf(currencyFormat(totalChargeBucketTotalTax)));
                paymentScheduleTotal.put('Total_Total', String.valueOf(currencyFormat(totalChargeBucketTotal)));
            }
            else {
                System.debug('Quotatation list is either null or empty');
            }
        }
        else {
            System.debug('Unable to get Id for selected Quotation');
        }
        
       
        
        if(qId != null){
            qList = [Select Id,CreatedDate,Unit__c, Car_Park_Required_Count__c, Charge_Bucket_1_Amount__c,Charge_Bucket_1__c from Quotation__c where Id=:qId];
            system.debug('qList is::'+qList);
            for(Quotation__c q:qList){
                /*if(q.Charge_Bucket_1__c == 'Agreement Value'){
                    chargeBucket = String.valueOf(q.Charge_Bucket_1_Amount__c);
                }*/
            }
            
            uList = [Select Id,Floor__c, Name, Tower__c, Tower__r.Name, Inventory_Type__c, Configuration_Type__c, Total_carpet_Sq_Ft__c From Unit__c where Id=:qList[0].Unit__c];
            system.debug('uList is::'+uList);
            if (uList != null && !uList.isEmpty()){
                Unit__c unit = uList[0];
                flatDetails.put('Tower__c', unit.Tower__r.Name != null ? String.valueOf(unit.Tower__r.Name) : ' ');
                flatDetails.put('Flat_No__c', unit.Name != null ? String.valueOf(unit.Name) : ' ');
                flatDetails.put('Floor__c', unit.Floor__c != null ? String.valueOf(unit.Floor__c) : ' ');
                flatDetails.put('Type__c', unit.Inventory_Type__c != null ? String.valueOf(unit.Inventory_Type__c) : ' ');
                flatDetails.put('Configuration_Type__c',  unit.Configuration_Type__c != null ? String.valueOf(unit.Configuration_Type__c) : ' ');
                flatDetails.put('Total_carpet_Sq_Ft__c', unit.Total_carpet_Sq_Ft__c != null ? String.valueOf(unit.Total_carpet_Sq_Ft__c) : ' ');
            }
        }
    }
    
    public String currencyFormat(Decimal amt) {
        String formattedAmount = '';
        Decimal tempAmt = amt.setscale(2,RoundingMode.HALF_UP);
        String stringAmt = tempAmt.toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(stringAmt)) {
            tempStr = stringAmt.split('\\.');
            if(tempStr != null && tempStr.size() ==2) {
                decimalPart = tempStr[1];
            }
        }
        formattedAmount = (tempAmt.format().contains('.')?tempAmt.format():(tempAmt.format()+'.'+decimalPart));
        return formattedAmount;
    } 
    
}