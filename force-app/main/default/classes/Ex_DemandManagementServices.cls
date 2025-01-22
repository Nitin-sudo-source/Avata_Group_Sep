public class Ex_DemandManagementServices {
    public static void raiseDemand(Payment_Milestone__c pm) {
        if (pm != null) {
            
            // Update Payment Milestone
            pm.Is_Raised__c = true;
            pm.Demand_Raised_Date__c = system.today();
            Decimal onAccountBalance = 0;
            
            onAccountBalance = getOnAccountBalance(pm.Quotation__r.Booking__c);
            system.debug('onAccountBalance: '+onAccountBalance);
            
            // Raise Demand
            Demand__c d = new Demand__c();
            d.Demand_Type__c = 'Flat Cost';
            d.Booking__c = pm.Quotation__r.Booking__c;
            d.Quotation__c = pm.Quotation__c;
            d.Payment_Milestone__c = pm.Id;
            d.Milestone_Name__c = pm.Milestone_Name__c;
            d.Invoice_Date__c = pm.Due_Date__c;
            d.Due_Date__c = pm.Due_Date__c.addDays(7); 
            d.Demand_Status__c = 'Raised';
            d.Customer_Name__c = pm.Quotation__r.Booking__r.Primary_Applicant_Title__c + ' ' + pm.Quotation__r.Booking__r.Primary_Applicant_Name__c;
            d.Customer_Mobile__c = pm.Quotation__r.Booking__r.Primary_Applicant_Mobile__c;
            d.Customer_Email__c = pm.Quotation__r.Booking__r.Primary_Applicant_Email__c;
            system.debug('DemandList: '+d);
            
            if (pm.Quotation__r.Booking__r.Project__r.Last_Demand_No__c != null) {
                d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-' + (pm.Quotation__r.Booking__r.Project__r.Last_Demand_No__c + 1);
            } else {
                if (pm.Quotation__r.Booking__r.Project__r.Starting_Demand_No__c != null) {
                    d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-' + (pm.Quotation__r.Booking__r.Project__r.Starting_Demand_No__c + 1);
                } else {
                    d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-1';
                }
            }
           /* system.debug('pm.TDS_Amount__c--->'+pm.TDS_Amount__c);
            if(pm.TDS_Amount__c != null) {
                d.TDS_Value_Demanded__c = pm.TDS_Amount__c;
            }*/
            
            for (Integer i = 1; i <= 5; i++) {
                if ((String) pm.get('Charge_Bucket_' + i + '__c') != null && String.isNotBlank((String) pm.get('Charge_Bucket_' + i + '__c'))) {
                    if (((String) pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
                        d.Agreement_Value_Demanded__c = ((Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c'));
                        d.Agreement_Value_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                        d.Total_Amount_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        d.Total_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                    } else if (((String) pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Other Charges')) {
                        d.Other_Charges_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        d.Other_Charges_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                    }
                }
            }
            try {
                insert d;
                
                update pm;
                
                               
                if(onAccountBalance > 0) {
                    Set<Id> rIdSet = getOnAccountBalanceReceipts(pm.Quotation__r.Booking__c);
                    
                    if(rIdSet != null && !rIdSet.isEmpty()) {
                        Ex_ReceiptHandlerServices.receiptApporation(rIdSet);
                    }
                }
                
            } catch (Exception ex) {
                system.debug('Error: ' + ex.getMessage());
            }
        }
    }
    
    public static Decimal getOnAccountBalance(Id bId) {
        Decimal onAccountBalance = 0;
        List<Receipt__c> rList = [Select Id, Name, On_Account_Money__c from Receipt__c where /*Receipt_Status__c = 'UnProcessed' AND*/ On_Account_Money__c > 0
                                  AND Booking__c =: bId ORDER BY Receipt_Date__c ASC];
        
        if(rList != null) {
            for(Receipt__c r: rList) {
                onAccountBalance += r.On_Account_Money__c;
            }
        }
        return onAccountBalance;
    }
    
    public static Set<Id> getOnAccountBalanceReceipts(Id bId) {
        Set<Id> rIdSet = new Set<Id>();
        List<Receipt__c> rList = [Select Id, Name, On_Account_Money__c from Receipt__c where /*Receipt_Status__c = 'UnProcessed' AND*/ On_Account_Money__c > 0
                                  AND Booking__c =: bId ORDER BY Receipt_Date__c ASC];
        system.debug('getOnAccountBalanceReceipts--->'+rList);
        if(rList != null) {
            for(Receipt__c r: rList) {
                rIdSet.add(r.Id);
            }
        }
        return rIdSet;
    } 
    
}