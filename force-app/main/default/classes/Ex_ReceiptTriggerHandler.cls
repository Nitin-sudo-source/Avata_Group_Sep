//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_ReceiptTriggerHandler {
    public static void beforeInsert(List<Receipt__c> receiptList) {
        Map<Id, Date> boookingInterestDateMap = new Map<Id, Date>();
        for(Receipt__c r: receiptList) {
            if(r.Booking__c != null && r.Date__c != null) {
                if(r.Date__c < system.today()) {
                    boookingInterestDateMap.put(r.Booking__c, r.Date__c);
                }
            } 
        }   
        if(!boookingInterestDateMap.isEmpty() && boookingInterestDateMap != null)
            Ex_InterestCalculateManagementServices.interestCalculate(boookingInterestDateMap);
    }
    
    public static void afterInsert(List<Receipt__c> receiptList) {
        Set<Id> rIdSet = new Set<Id>();
        Map<Id, Decimal> bookingReceiptMap = new Map<Id, Decimal>();
        
        for(Receipt__c r: receiptList) {
            rIdSet.add(r.Id);
            if(r.Receipt_Type__c != null && r.Receipt_Type__c.equalsIgnoreCase('Flat Cost') && r.Payment_Status__c != null && r.Payment_Status__c.equalsIgnoreCase('Payment Successful') && r.Booking__c != null){
                bookingReceiptMap.put(r.Booking__c,r.Amount__c);
            }
        }
        System.debug('bookingReceiptMap: '+bookingReceiptMap);
        if(!bookingReceiptMap.isEmpty() && bookingReceiptMap != null)
            Ex_ReceiptHandlerServices.updateAVReceipts(bookingReceiptMap);
        if(!rIdSet.isEmpty() && rIdSet != null)
            Ex_ReceiptHandlerServices.receiptApporation(rIdSet);
    }
    
    public static void afterUpdate(Map<Id, Receipt__c> oldMap, Map<Id, Receipt__c> newMap) {
        Set<Id> reverseReceiptIdSet = new Set<Id>();
        Set<Id> PaymentSuccessIdSet = new Set<Id>();
        Map<Id, Decimal> PaymentSuccessAVSetMap = new Map<Id, Decimal>();
        
        for(Receipt__c oldReceipt: oldMap.values()) {
            Receipt__c newReceipt = newMap.get(oldReceipt.Id);
            
            if(oldReceipt.Receipt_Status__c != newReceipt.Receipt_Status__c && newReceipt.Receipt_Status__c.equalsIgnoreCase('Reverse'))
                reverseReceiptIdSet.add(newReceipt.Id);
            if(oldReceipt.Payment_Status__c != newReceipt.Payment_Status__c && newReceipt.Payment_Status__c.equalsIgnoreCase('Payment Successful')){
                PaymentSuccessIdSet.add(newReceipt.Id);
                PaymentSuccessAVSetMap.put(newReceipt.Booking__c,newReceipt.Amount__c);
            }
        }
        if(!reverseReceiptIdSet.isEmpty() && reverseReceiptIdSet != null && Ex_CheckRecursive.runOnce())
            Ex_ReceiptHandlerServices.reverseReceiptCalculation(reverseReceiptIdSet);
        if(!PaymentSuccessIdSet.isEmpty() && PaymentSuccessIdSet != null && Ex_CheckRecursive.runOnce())
            Ex_ReceiptHandlerServices.receiptApporation(PaymentSuccessIdSet);
        if(!PaymentSuccessAVSetMap.isEmpty() && PaymentSuccessAVSetMap != null)
              Ex_ReceiptHandlerServices.updateAVReceipts(PaymentSuccessAVSetMap);
    }
    
    public static void beforeDelete(Map<Id, Receipt__c> oldMap, Map<Id, Receipt__c> newMap) {
        Set<Id> rIdSet = new Set<Id>();
        
        for(Receipt__c oldReceipt: oldMap.values()) {
            rIdSet.add(oldReceipt.Id);
        }
        if(!rIdSet.isEmpty() && rIdSet != null)
            Ex_ReceiptHandlerServices.deleteReceiptApportionCalculation(rIdSet);
        if(!rIdSet.isEmpty() && rIdSet != null)
            Ex_ReceiptHandlerServices.updateAVReceiptAmountCalculationonBooking(rIdSet);
    }
    
}