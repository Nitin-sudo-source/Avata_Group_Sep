//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 21-11-2023
//-------------------------------------------//
public class Ex_PrintReceiptController {
    
    public Id rId {get;set;}
    public List<Receipt__c> rList {get;set;}
    public String amountInWords {get;set;}
    public decimal TotalAmount{get;set;}
    Public String Total {get;set;}
    public String showTotalAmount {get;set;}
    
    public Ex_PrintReceiptController(){
        rId=ApexPages.currentPage().getParameters().get('rId');
        rList = new List<Receipt__c>();
        
        if(rId != null) {
            rList = [Select Id, Name, Receipt_Number__c, Date__c,Payment_Mode__c,Amount__c,Receipt_Date__c,
                     Booking__r.Unit__c,Receipt_Type__c, Booking__r.Unit__r.Name, Booking__r.Unit__r.Floor__c, Booking__r.Unit__r.Tower__r.Name,
                     Booking__r.Unit__r.Project__r.Name, Booking__r.Unit__r.Tower__r.RERA_No__c,Booking__r.Applicant_Address__c,
                     Booking__r.Primary_Applicant_Name__c, Booking__r.Primary_Applicant_Mobile__c, Booking__r.Primary_Applicant_Email__c ,
                     Booking__r.Agreement_Value__c,Booking__r.Agreement_Value_Tax__c,Booking__r.Project__r.Name,Booking__r.Tower__r.Name,
                     Booking__r.Remarks__c,Transaction_ID__c,Bank_Name__c	
                     from Receipt__c where Id =: rId];
            system.debug('rList: '+rList);
            if(!rList.isEmpty() && rList != null){
                if(rList[0].Amount__c != 0) {
                    TotalAmount = Integer.valueOf((rList[0].Amount__c));
                    showTotalAmount = Ex_InventoryPriceManagementServices.currencyFormat(TotalAmount);
                    amountInWords=Ex_NumberToWord.convertNumbertoWords(Integer.valueOf(TotalAmount));
                    //Total = Ex_PrintReceiptController.currencyFormat(rlist[0].Booking__r.Agreement_Value__c + rList[0].Booking__r.Agreement_Value_Tax__c);
                }
            }
        }
    }

}