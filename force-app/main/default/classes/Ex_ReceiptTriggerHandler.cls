public class Ex_ReceiptTriggerHandler { 
    public static void beforeInsert(List<Receipt__c> receiptList) {
        Map<Id, Date> boookingInterestDateMap = new Map<Id, Date>();
        
        for(Receipt__c r: receiptList) {
            if(r.Booking__c != null && r.Receipt_Date__c != null) {
                if(r.Receipt_Date__c < system.today()) {
                    boookingInterestDateMap.put(r.Booking__c, r.Receipt_Date__c);
                    //system.debug('boookingInterestDateMap'+boookingInterestDateMap);
                }
            } 
        }
        if(!boookingInterestDateMap.isEmpty() && boookingInterestDateMap != null)
           Ex_InterestCalculateManagementServices.interestCalculate(boookingInterestDateMap);
            //system.debug('boookingInterestDateMap'+boookingInterestDateMap);
    }
    
    public static void afterInsert(List<Receipt__c> receiptList) {
        Set<Id> rIdSet = new Set<Id>();
        
        for(Receipt__c r: receiptList) {
            rIdSet.add(r.Id);
        }
        if(!rIdSet.isEmpty() && rIdSet != null)
            Ex_ReceiptHandlerServices.receiptApporation(rIdSet);
    }
        
    public static void afterUpdate(Map<Id, Receipt__c> oldMap, Map<Id, Receipt__c> newMap) {
        Set<Id> reverseReceiptIdSet = new Set<Id>();
        //Set<Id> PaymentSuccessIdSet = new Set<Id>();

        for(Receipt__c oldReceipt: oldMap.values()) {
            Receipt__c newReceipt = newMap.get(oldReceipt.Id);

            if(oldReceipt.Receipt_Status__c != newReceipt.Receipt_Status__c && newReceipt.Receipt_Status__c.equalsIgnoreCase('Reverse'))
            	reverseReceiptIdSet.add(newReceipt.Id);
            //if(oldReceipt.Payment_Status__c != newReceipt.Payment_Status__c && newReceipt.Payment_Status__c.equalsIgnoreCase('Payment Successful'))
            	//PaymentSuccessIdSet.add(newReceipt.Id);
            	//if(oldReceipt.Approval_Status__c != newReceipt.Approval_Status__c && newReceipt.Approval_Status__c == 'Rejected') 
                //reverseReceiptIdSet.add(newReceipt.Id);
            
        }
        if(!reverseReceiptIdSet.isEmpty() && reverseReceiptIdSet != null && Ex_CheckRecursive.runOnce())
            Ex_ReceiptHandlerServices.reverseReceiptCalculation(reverseReceiptIdSet);
        //if(!PaymentSuccessIdSet.isEmpty() && PaymentSuccessIdSet != null && Ex_CheckRecursive.runOnce())
            //Ex_ReceiptHandlerServices.receiptApporation(PaymentSuccessIdSet);
    }
    
    public static void beforeDelete(Map<Id, Receipt__c> oldMap, Map<Id, Receipt__c> newMap) {
        Set<Id> rIdSet = new Set<Id>();
        
        for(Receipt__c oldReceipt: oldMap.values()) {
            rIdSet.add(oldReceipt.Id);
        }
        if(!rIdSet.isEmpty() && rIdSet != null)
            Ex_ReceiptHandlerServices.deleteReceiptApportionCalculation(rIdSet);
    }
}