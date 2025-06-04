public class Ex_PrintDemandLetter {
    // Public properties for VF page binding
    public Id dId {get; set;}
    public String ProjectAddress {get; set;} 
    public String ProjectName {get; set;}
    public String MahaRERANumber {get; set;}
    public String DateOfInvoice {get; set;}
    public String CustomerName {get; set;}
    public String Address {get; set;}
    public String ContactNumber {get; set;}
    public String EmailAddress {get; set;}
    public String InvoiceNumber {get; set;}
    public String CustomerNameTitle {get; set;}
    public String Tower {get; set;}
    public String FlatNo {get; set;}
     
    public String Milestone {get; set;}
    
    public String GSTACNo {get; set;}
    public String GSTIN {get; set;}
       
    public String BankName {get;set;}
    public String BranchName {get;set;}
    public String Accountnumber {get;set;}
    public String IFSCCode {get;set;}
    
    public String amountDemandStr {get;set;}
    public String amountPaidDemandStr {get;set;}
    public String amountRemainingDemandStr {get;set;}
    public String amountDemandTaxStr {get;set;}
    public String amountPaidDemandTaxStr {get;set;}
    public String amountRemainingDemandTaxStr {get;set;}
    public String totalInterestamountDemandStr {get;set;}
    public String totalInterestamountPaidDemandStr {get;set;}
    public String totalInterestamountRemainingDemandStr {get;set;}
    public Decimal totalInterestamountDemand {get;set;}
    public Decimal totalInterestamountPaidDemand {get;set;}
    public Decimal totalInterestamountRemainingDemand {get;set;}
    public String totalInterestAmountRemainingDemandInWords {get; set;}
    
    public String totalamountDemandStr {get;set;}
    public String totalamountPaidDemandStr {get;set;}
    public String totalamountRemainingDemandStr {get;set;}
    public Decimal totalamountDemand {get;set;}
    public Decimal totalamountPaidDemand {get;set;}
    public Decimal totalamountRemainingDemand {get;set;}
    public String totalAmountRemainingDemandInWords {get; set;}
  
    public Decimal InterestamountDemand {get;set;}
    public Decimal InterestamountPaidDemand {get;set;}
    public Decimal InterestamountRemainingDemand {get;set;}
    public Decimal InterestamountDemandTax {get;set;}
    public Decimal InterestamountPaidDemandTax {get;set;}
    public Decimal InterestamountRemainingDemandTax {get;set;}
    public String InterestamountDemandStr {get;set;}
    public String InterestamountPaidDemandStr {get;set;}
    public String InterestamountRemainingDemandStr {get;set;}
    public String InterestamountDemandTaxStr {get;set;}
    public String InterestamountPaidDemandTaxStr {get;set;}
    public String InterestamountRemainingDemandTaxStr {get;set;}
    
    public String closedemandStr {get;set;}
    public String closedemandPaidStr {get;set;}
    public String closedemandRemainingStr {get;set;}
    public String closedAmountRemainingDemandInWords {get; set;}
    
    List<Demand__c> deList {get; set;}
    
    public Ex_PrintDemandLetter() {
        
        ProjectAddress = '';
        ProjectName = '';
        MahaRERANumber = '';
        DateOfInvoice = '';
        CustomerName = '';
        Address = '';
        ContactNumber = '';
        EmailAddress = '';
        InvoiceNumber = '';
        CustomerNameTitle = '';
        Tower = '';
        FlatNo = '';
       
        Milestone = '';
       
        GSTACNo = '';
        GSTIN = '';
       
       
        
        BankName = '';
        BranchName = '';
        AccountNumber = '';
        IFSCCode = '';
        
        Decimal amountDemand = 0;
        Decimal amountPaidDemand = 0;
        Decimal amountRemainingDemand = 0;
        Decimal amountDemandTax = 0;
        Decimal amountPaidDemandTax = 0;
        Decimal amountRemainingDemandTax = 0;
        
        amountDemandStr = '';
        amountPaidDemandStr = '';
        amountRemainingDemandStr = '';
        amountDemandTaxStr = '';
        amountPaidDemandTaxStr = '';
        amountRemainingDemandTaxStr = '';
        
        totalamountDemand = 0;
        totalamountPaidDemand = 0;
        totalamountRemainingDemand = 0;
        totalamountDemandStr = '';
        totalamountPaidDemandStr = '';
        totalamountRemainingDemandStr = '';
        totalAmountRemainingDemandInWords = '';
        
        InterestamountDemand = 0;
        InterestamountPaidDemand = 0;
        InterestamountRemainingDemand = 0;
        InterestamountDemandTax = 0;
        InterestamountPaidDemandTax = 0;
        InterestamountRemainingDemandTax = 0;
        
        InterestamountDemandStr = '';
        InterestamountPaidDemandStr = '';
        InterestamountRemainingDemandStr = '';
        InterestamountDemandTaxStr = '';
        InterestamountPaidDemandTaxStr = '';
        InterestamountRemainingDemandTaxStr = '';
        
        totalInterestamountDemand = 0;
        totalInterestamountPaidDemand = 0;
        totalInterestamountRemainingDemand = 0;
        totalInterestamountDemandStr = '';
        totalInterestamountPaidDemandStr = '';
        totalInterestamountRemainingDemandStr = '';
        totalInterestAmountRemainingDemandInWords = '';

        Decimal closedemand = 0 ;
        Decimal closedemandPaid = 0 ;
        Decimal closedemandRemaining = 0;
        closedemandStr = '';
        closedemandPaidStr = '';
        closedemandRemainingStr = '';
        closedAmountRemainingDemandInWords = '';
        
        dId = (Id)ApexPages.currentPage().getParameters().get('dId');
        
        if(dId != null) {
            try {
                
                deList = [SELECT Id, 
                         Booking__r.Project__r.Project_Address__c,
                         Booking__r.Project__r.Name,
                         Booking__r.Project__r.Project_RERA_Number__c,
                         Booking__r.Unit__r.Tower__r.Name,
                         Booking__r.Primary_Applicant_Title__c,
                         Booking__r.Unit__r.Name,
                        
                         
                         Booking__r.Tower__r.Legal_Entity__r.Account_Number_Tax__c,
                         Booking__r.Tower__r.Legal_Entity__r.GSTIN__c,
                         
                         Customer_Email__c,
                         Invoice_Date__c,
                         Customer_Name__c,
                         Customer_Mobile__c,
                         Invoice_Number__c,
                         Booking__r.Primary_Applicant_Address__c,
                         Milestone_Name__c,
                         
                         
                         Booking__r.Tower__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,
                         Booking__r.Tower__r.Legal_Entity__r.Branch_Name_Flat_Cost__c,
                         Booking__r.Tower__r.Legal_Entity__r.Account_Number_Flat_Cost__c,
                         Booking__r.Tower__r.Legal_Entity__r.IFSC_Code_Flat_Cost__c,
                         Booking__r.Total_Amount_Demanded__c,
                         Booking__r.Total_Amount_Paid__c,
                         Booking__r.Total_Amount_Remaining__c,
                         Booking__r.Total_Tax_Demanded__c,
                         Booking__r.Total_Tax_Paid__c,
                         Booking__r.Total_Tax_Remaining__c,
                         Booking__r.Total_Interest_Amount__c,
                         Booking__r.Total_Interest_Amount_Paid__c,
                         Booking__r.Total_Interest_Amount_Remaining__c,
                         Booking__r.Total_Tax_On_Interest_Amount__c,
                         Booking__r.Total_Tax_On_Interest_Amount_Paid__c,
                         Booking__r.Total_Tax_On_Interest_Amount_Remaining__c
                          
                         FROM Demand__c 
                         WHERE Id = :dId
                         LIMIT 1];
                
                if(!deList.isEmpty()) {
                    Demand__c demand = deList[0];
                    
                    // Map all fields with null checks
                    DateOfInvoice = demand.Invoice_Date__c != null ? 
                        demand.Invoice_Date__c.format() : ' ';
                    
                    CustomerName = demand.Customer_Name__c != null ? 
                        demand.Customer_Name__c : ' ';
                    
                    Address = demand.Booking__r.Primary_Applicant_Address__c != null ? 
                        demand.Booking__r.Primary_Applicant_Address__c : ' ';
                    
                    ContactNumber = demand.Customer_Mobile__c != null ? 
                        demand.Customer_Mobile__c : ' ';
                    
                    EmailAddress = demand.Customer_Email__c != null ? 
                        demand.Customer_Email__c : ' ';
                    
                    InvoiceNumber = demand.Invoice_Number__c != null ? 
                        demand.Invoice_Number__c : ' ';
                     
                    CustomerNameTitle = demand.Booking__r.Project__r.Project_RERA_Number__c != null ?
                        demand.Booking__r.Project__r.Project_RERA_Number__c : '';
                    
                    amountDemand = demand.Booking__r.Total_Amount_Demanded__c != null ?
                        demand.Booking__r.Total_Amount_Demanded__c : 0;
                    amountDemandStr = currencyFormat(amountDemand);
                    
                    amountPaidDemand = demand.Booking__r.Total_Amount_Paid__c != null ?
                        demand.Booking__r.Total_Amount_Paid__c : 0;
                    amountPaidDemandStr = currencyFormat(amountPaidDemand);

                    
                    amountRemainingDemand = demand.Booking__r.Total_Amount_Remaining__c != null ?
                        demand.Booking__r.Total_Amount_Remaining__c : 0;
                    amountRemainingDemandStr = currencyFormat(amountRemainingDemand);
                    
                    amountDemandTax = demand.Booking__r.Total_Tax_Demanded__c != null ?
                        demand.Booking__r.Total_Tax_Demanded__c : 0;
                    amountDemandTaxStr = currencyFormat(amountDemandTax);
                    
                    amountPaidDemandTax = demand.Booking__r.Total_Tax_Paid__c != null ?
                        demand.Booking__r.Total_Tax_Paid__c : 0;
                    amountPaidDemandTaxStr = currencyFormat(amountPaidDemandTax);
                  
                    amountRemainingDemandTax = demand.Booking__r.Total_Tax_Remaining__c != null ?
                        demand.Booking__r.Total_Tax_Remaining__c : 0;
                    amountRemainingDemandTaxStr = currencyFormat(amountRemainingDemandTax);
                    
                    totalAmountDemand = amountDemand + amountDemandTax;
                    totalAmountPaidDemand = amountPaidDemand + amountPaidDemandTax;
                    totalAmountRemainingDemand = amountRemainingDemand + amountRemainingDemandTax;
                    totalAmountDemandStr = currencyFormat(totalAmountDemand);
                    totalAmountPaidDemandStr = currencyFormat(totalAmountPaidDemand);
                    totalAmountRemainingDemandStr = currencyFormat(totalAmountRemainingDemand);
                    
                 
                    
                    Integer totalRemainingInt = Integer.valueOf(totalAmountRemainingDemand.round(System.RoundingMode.HALF_UP));
                    totalAmountRemainingDemandInWords = Ex_NumberToWord.convertNumbertoWords(totalRemainingInt);
                    
                    InterestamountDemand = demand.Booking__r.Total_Interest_Amount__c != null ?
                        demand.Booking__r.Total_Interest_Amount__c : 0;
                    InterestamountDemandStr = currencyFormat(InterestamountDemand);
                    
                    InterestamountPaidDemand = demand.Booking__r.Total_Interest_Amount_Paid__c != null ?
                        demand.Booking__r.Total_Interest_Amount_Paid__c : 0;
                    InterestamountPaidDemandStr = currencyFormat(InterestamountPaidDemand);

                    
                    InterestamountRemainingDemand = demand.Booking__r.Total_Interest_Amount_Remaining__c != null ?
                        demand.Booking__r.Total_Interest_Amount_Remaining__c : 0;
                    InterestamountRemainingDemandStr = currencyFormat(InterestamountRemainingDemand);
                    
                    InterestamountDemandTax = demand.Booking__r.Total_Tax_On_Interest_Amount__c != null ?
                        demand.Booking__r.Total_Tax_On_Interest_Amount__c : 0;
                    InterestamountDemandTaxStr = currencyFormat(InterestamountDemandTax);
                    
                    InterestamountPaidDemandTax = demand.Booking__r.Total_Tax_On_Interest_Amount_Paid__c != null ?
                        demand.Booking__r.Total_Tax_On_Interest_Amount_Paid__c : 0;
                    InterestamountPaidDemandTaxStr = currencyFormat(InterestamountPaidDemandTax);

                    
                    InterestamountRemainingDemandTax = demand.Booking__r.Total_Tax_On_Interest_Amount_Remaining__c != null ?
                        demand.Booking__r.Total_Tax_On_Interest_Amount_Remaining__c : 0;
                    InterestamountRemainingDemandTaxStr = currencyFormat(InterestamountRemainingDemandTax);
                    
                    
                    totalInterestAmountDemand = InterestamountDemand + InterestamountDemandTax;
                    totalInterestAmountPaidDemand = InterestamountPaidDemand + InterestamountPaidDemandTax;
                    totalInterestAmountRemainingDemand = InterestamountRemainingDemand + InterestamountRemainingDemandTax;
                    totalInterestAmountDemandStr = currencyFormat(totalInterestAmountDemand);
                    totalInterestAmountPaidDemandStr = currencyFormat(totalInterestAmountPaidDemand);
                    totalInterestAmountRemainingDemandStr = currencyFormat(totalInterestAmountRemainingDemand);
                    
                    Integer InteresttotalRemainingInt = Integer.valueOf(totalInterestAmountRemainingDemand.round(System.RoundingMode.HALF_UP));
                    totalInterestAmountRemainingDemandInWords = Ex_NumberToWord.convertNumbertoWords(InteresttotalRemainingInt);
                    
                    
                 closedemand = (totalAmountDemand + totalInterestAmountDemand).round();
                closedemandStr = currencyFormat(closedemand);
                closedemandPaid = (totalAmountPaidDemand + totalInterestAmountPaidDemand).round();
                closedemandPaidStr = currencyFormat(closedemandPaid);
                closedemandRemaining = (totalAmountRemainingDemand + totalInterestAmountRemainingDemand).round();
                closedemandRemainingStr = currencyFormat(closedemandRemaining);
                    
                    Integer closedDemandRemainingInt = Integer.valueOf(closedemandRemaining.round(System.RoundingMode.HALF_UP));
                    closedAmountRemainingDemandInWords = Ex_NumberToWord.convertNumbertoWords(closedDemandRemainingInt);
                    
                    
                    ProjectAddress = demand.Booking__r.Project__r.Project_Address__c != null ? 
                        demand.Booking__r.Project__r.Project_Address__c : ' ';
                    
                    ProjectName = demand.Booking__r.Project__r.Name != null ? 
                        demand.Booking__r.Project__r.Name : ' ';
                    
                    
                    Tower = demand.Booking__r.Unit__r.Tower__r.Name != null ? 
                        demand.Booking__r.Unit__r.Tower__r.Name : ' ';
                    
                    FlatNo = demand.Booking__r.Unit__r.Name != null ? 
                        demand.Booking__r.Unit__r.Name : ' ';
                    
                    
                    MahaRERANumber = demand.Booking__r.Project__r.Project_RERA_Number__c != null ? 
                        demand.Booking__r.Project__r.Project_RERA_Number__c : ' ';
                    
                   
                    Milestone = demand.Milestone_Name__c != null ? 
                        demand.Milestone_Name__c : '';
                    
                    
                    
                    BankName = demand.Booking__r.Tower__r.Legal_Entity__r.Bank_Name_Flat_Cost__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.Bank_Name_Flat_Cost__c : '';
                    
                    BranchName = demand.Booking__r.Tower__r.Legal_Entity__r.Branch_Name_Flat_Cost__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.Branch_Name_Flat_Cost__c : '';
                    
                    AccountNumber = demand.Booking__r.Tower__r.Legal_Entity__r.Account_Number_Flat_Cost__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.Account_Number_Flat_Cost__c : '';
                    
                    IFSCCode = demand.Booking__r.Tower__r.Legal_Entity__r.IFSC_Code_Flat_Cost__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.IFSC_Code_Flat_Cost__c : '';
                    
                    GSTACNo = demand.Booking__r.Tower__r.Legal_Entity__r.Account_Number_Tax__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.Account_Number_Tax__c : '';
                   
                    GSTIN = demand.Booking__r.Tower__r.Legal_Entity__r.GSTIN__c != null ?
                        demand.Booking__r.Tower__r.Legal_Entity__r.GSTIN__c : '';
                    
                }
            } catch(Exception e) {
                System.debug('Error in controller: ' + e.getMessage());
                // Add error handling as needed
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while loading demand information.'));
            }
        }
    }
    
    public static String currencyFormat(Decimal amt) {
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
        if(decimalPart=='00' || decimalPart==null)
            formattedAmount = (tempAmt.format().contains('.')?tempAmt.format():(tempAmt.format()));
        else
            formattedAmount = (tempAmt.format().contains('.')?tempAmt.format():(tempAmt.format()+'.'+decimalPart));
        return formattedAmount+ '/-';
    }
}