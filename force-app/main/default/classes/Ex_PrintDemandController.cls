/**
 * @description       :
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             :
 * @last modified on  : 28-05-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
 **/
//-------------------------------------------//
//  Project: Aga Hall
//  Created By: Exceller Consultancy
//  Created Date: 25-08-2023
//-------------------------------------------//
public class Ex_PrintDemandController {
    
    public Id bId {get;set;}
    public List<Booking__c> BookingList {get;set;}
    public String CustomerAddress {get; set;}
    public String CustomerPrimaryName {get; set;}
    public String CustomerMobile {get; set;}
    public String unitName {get; set;}
    public String CustomerBank {get; set;}
    public String CustomerAccountNoFlat {get; set;}
    public String CustomerAccountNoTax {get; set;}
    public String CustomerIfsc {get; set;}
    public String CustomerBranch {get; set;}
    public String CustomerPan {get; set;}
    public String AccountName {get;set;}
    public String RegistrationNumber {get;set;}
    public String RegistrationDate {get;set;}
    public String Unit {get;set;}
    public String milestoneName { get; set; }
    public Date dueDate { get; set; }
    public Date invoiceDate { get; set; }
    public String invoiceNumber { get; set; }
    public Decimal TotalAmountoutstanding {get;set;}
    public Decimal TotalGSToutstanding {get;set;}
    public Decimal AmountDemand {get;set;}
    public Decimal AmountDemandTax {get;set;}
    public String ReceiptSigned {get;set;}
    public String principleAmount{get;set;}
    public String tdsAmount{get;set;}
    public String cgstAmount{get;set;}
    public String sgstAmount{get;set;}
    public String totalAmount{get;set;}
    public String overallAmountWordString {get;set;}
    public String overallAmountString {get;set;}
    
    public Ex_PrintDemandController() {
        BookingList = new List<Booking__c>();
        invoiceDate = null;
        invoiceNumber = null;
        dueDate = null;
        milestoneName = null;
        AmountDemand = null;
        ReceiptSigned = null;
        AmountDemandTax = null;
        tdsAmount = null;
        principleAmount = null;
        cgstAmount = null;
        sgstAmount = null;
        totalAmount = null;
        overallAmountString = '';
        overallAmountWordString = '';
        
        bId = ApexPages.currentPage().getParameters().get('bId');
        system.debug('bId: '+bId);
    }
        
        // invoiceDate = Date.valueOf(ApexPages.currentPage().getParameters().get('invoiceDate'));
        // System.debug('invoiceDate: ' + invoiceDate);
        
        // invoiceNumber = ApexPages.currentPage().getParameters().get('invoiceNumber');
        
        // dueDate = Date.valueOf(ApexPages.currentPage().getParameters().get('dueDate'));
        // System.debug('dueDate: ' + dueDate);
        
        // milestoneName = ApexPages.currentPage().getParameters().get('milestoneName');
        // system.debug('milestoneName: '+milestoneName);
        
        // AmountDemand = Decimal.valueOf(ApexPages.currentPage().getParameters().get('AmountDemand'));
        // System.debug('AmountDemand: ' + AmountDemand);
        
        // AmountDemandTax = Decimal.valueOf(ApexPages.currentPage().getParameters().get('AmountDemandTax'));
        // System.debug('AmountDemandTax: ' + AmountDemandTax);
        
        // principleAmount = ApexPages.currentPage().getParameters().get('principleAmount');
        
        // tdsAmount = ApexPages.currentPage().getParameters().get('tdsAmount');
        
        // cgstAmount = ApexPages.currentPage().getParameters().get('cgstAmount');
        
        // sgstAmount = ApexPages.currentPage().getParameters().get('sgstAmount');
        
        // totalAmount = ApexPages.currentPage().getParameters().get('totalAmount');
        
        // overallAmountString = ApexPages.currentPage().getParameters().get('overallAmountString');
        
        // overallAmountWordString = ApexPages.currentPage().getParameters().get('overallAmountWordString');
        
        // String receiptSignedParam = ApexPages.currentPage().getParameters().get('ReceiptSigned');
        // if (String.isBlank(receiptSignedParam)) {
        //     ReceiptSigned = 'Director';
        // } else {
        //     ReceiptSigned = receiptSignedParam.replace('+', ' '); // Replacing '+' with a space
        //     system.debug('ReceiptSigned: ' + ReceiptSigned);
        // }
        
        /*if (ApexPages.currentPage().getParameters().get('ReceiptSigned') == '') {
            ReceiptSigned = 'Director';
        } else {
            ReceiptSigned = ApexPages.currentPage().getParameters().get('ReceiptSigned');
            ReceiptSigned = ReceiptSigned.replace('+', ' '); // Replacing '+' with a space
            system.debug('ReceiptSigned: ' + ReceiptSigned);
        }*/
        
        
    //     if(bId != null) {
    //         BookingList = [Select Id, Name,Primary_Applicant_Address__c,Primary_Applicant_Name__c ,Primary_Applicant_Mobile__c,Agreement_Value__c,
    //                        Tower__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,Tower__r.Legal_Entity__r.Account_Number_Flat_Cost__c,Unit__r.Tower__r.RERA_No__c,
    //                        Tower__r.Legal_Entity__r.Account_Number_Tax__c,Tower__r.Legal_Entity__r.IFSC_Code_Flat_Cost__c,
    //                        Tower__r.Legal_Entity__r.Branch_Name_Flat_Cost__c,
    //                    Unit__r.Name,Total_Amount_Demanded__c,Total_Tax_Demanded__c,Total_Amount_Remaining__c,
    //                        Total_Tax_Remaining__c,Tower__r.Legal_Entity__r.Account_Name_Flat_Cost__c                        
    //                        from Booking__c where Id =: bId];
    //         system.debug('BookingList: '+BookingList);
            
    //         if(BookingList != null && !BookingList.isEmpty()) {
    //             CustomerPrimaryName = BookingList[0].Primary_Applicant_Name__c;
    //             CustomerMobile = BookingList[0].Primary_Applicant_Mobile__c;
    //             CustomerAddress = BookingList[0].Primary_Applicant_Address__c;
    //             unitName = BookingList[0].Unit__r.Name;
    //             CustomerBank = BookingList[0].Tower__r.Legal_Entity__r.Bank_Name_Flat_Cost__c;
    //             CustomerAccountNoFlat = BookingList[0].Tower__r.Legal_Entity__r.Account_Number_Flat_Cost__c;
    //             CustomerAccountNoTax = BookingList[0].Tower__r.Legal_Entity__r.Account_Number_Tax__c;
    //             CustomerIfsc = BookingList[0].Tower__r.Legal_Entity__r.IFSC_Code_Flat_Cost__c;
    //             CustomerBranch = BookingList[0].Tower__r.Legal_Entity__r.Branch_Name_Flat_Cost__c;
    //             AccountName = BookingList[0].Tower__r.Legal_Entity__r.Account_Name_Flat_Cost__c;
                
    //             Date RegistrationDate = null;
    //             String formattedDate;
    //             if (registrationDate != null) {
    //                 formattedDate = registrationDate.format();
    //             } else {
    //                 formattedDate = 'N/A';
    //             }
    //             Unit = BookingList[0].Unit__r.Name;
                
    //             if (!BookingList[0].Demands__r.isEmpty()) {
                    
    //                 AmountDemand = BookingList[0].Demands__r[0].Total_Amount_Demanded__c;
    //                 AmountDemandTax = BookingList[0].Demands__r[0].Total_Tax_Demanded__c;
    //                 milestoneName = BookingList[0].Demands__r[0].Milestone_Name__c;
    //                 dueDate = BookingList[0].Demands__r[0].Due_Date__c;
    //                 invoiceDate = BookingList[0].Demands__r[0].Invoice_Date__c;
                    
    //             }
    //         }
            
    //     }
    // }
    
    // public Decimal TotalAmountoutstanding1 {
    //     get {
    //         if (BookingList != null && BookingList.size() > 0 && AmountDemand != null && BookingList[0].Total_Amount_Remaining__c != null) {
    //             return AmountDemand + BookingList[0].Total_Amount_Remaining__c;
    //         }
    //         return 0;
    //     }
    // }
    
    // public Decimal TotalGSToutstanding1 {
    //     get {
    //         if (BookingList != null && BookingList.size() > 0 && AmountDemandTax != null && BookingList[0].Total_Tax_Remaining__c != null) {
    //             return AmountDemandTax + BookingList[0].Total_Tax_Remaining__c;
    //         }
    //         return 0;
    //     }
        
    // }
}