//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_LedgerHandlerServices {
    public static void reverseCalculationOnDemandAndReceipt(Set<Id> lIdSet) {
        List<Demand__c> updateDemandList = new List<Demand__c>();
        List<Receipt__c> updateReceiptList = new List<Receipt__c>();
        List<Ledger__c> creditLedgerList = new List<Ledger__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        Map<Id, Demand__c> demandMap = new Map<Id, Demand__c>();
        Map<Id, List<Ledger__c>> demandCreditLedgerMap = new Map<Id, List<Ledger__c>>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>();
        Map<Id, List<Ledger__c>> receiptCreditLedgerMap = new Map<Id, List<Ledger__c>>();
        
        creditLedgerList = [Select Id, Name, Charge_Name__c, Amount__c, Demand__c, Tax_Ledger__c, Receipt__c from Ledger__c where Id IN: lIdSet AND Type__c = 'Credit'];
        system.debug('creditLedgerList: '+creditLedgerList);
        
        if(!creditLedgerList.isEmpty() && creditLedgerList != null) {
            for(Ledger__c l: creditLedgerList) {
                if(demandCreditLedgerMap.containsKey(l.Demand__c)) {
                    demandCreditLedgerMap.get(l.Demand__c).add(l);
                } else {
                    List<Ledger__c> newList = new List<Ledger__c>();
                    newList.add(l);
                    demandCreditLedgerMap.put(l.Demand__c, newList);
                }
                if(receiptCreditLedgerMap.containsKey(l.Receipt__c)) {
                    receiptCreditLedgerMap.get(l.Receipt__c).add(l);
                } else {
                    List<Ledger__c> newList = new List<Ledger__c>();
                    newList.add(l);
                    receiptCreditLedgerMap.put(l.Receipt__c, newList);
                }
            }
            if(!demandCreditLedgerMap.isEmpty() && demandCreditLedgerMap != null) {
                demandList = getDemandInfo(demandCreditLedgerMap.keySet());
                system.debug('demandList: '+demandList);
                
                if(demandList != null) {
                    for(Demand__c d: demandList) {
                        demandMap.put(d.Id, d);
                    }
                    for(Id dId: demandMap.keySet()) {
                        Demand__c d = demandMap.get(dId);
                        for(Ledger__c l: demandCreditLedgerMap.get(d.Id)) {
                            if(l.Charge_Name__c.equalsIgnoreCase('Interest')) {
                                d.Total_Interest_Amount_Paid__c = d.Total_Interest_Amount_Paid__c - l.Amount__c;
                            } else if(l.Charge_Name__c.equalsIgnoreCase('Flat Cost')) {
                                if(l.Tax_Ledger__c) {
                                    if(d.Demand_Type__c.equalsIgnoreCase('Flat Cost')) {
                                        d.Agreement_Value_Tax_Paid__c = d.Agreement_Value_Tax_Paid__c - l.Amount__c;
                                    }
                                    d.Total_Tax_Paid__c = d.Total_Tax_Paid__c - l.Amount__c;
                                } else {
                                    if(d.Demand_Type__c.equalsIgnoreCase('Flat Cost')) {
                                        d.Agreement_Value_Paid__c = d.Agreement_Value_Paid__c - l.Amount__c;
                                    }
                                    d.Total_Amount_Paid__c = d.Total_Amount_Paid__c - l.Amount__c;
                                }
                            }
                        }
                        updateDemandList.add(d);
                    }
                }
            }
            if(!receiptCreditLedgerMap.isEmpty() && receiptCreditLedgerMap != null) {
                receiptList = getReceiptInfo(receiptCreditLedgerMap.keySet());
                system.debug('receiptList: '+receiptList);
                
                if(receiptList != null) {
                    for(Receipt__c r: receiptList) {
                        receiptMap.put(r.Id, r);
                    }
                    for(Id receiptId: receiptMap.keySet()) {
                        Receipt__c r = receiptMap.get(receiptId);
                        for(Ledger__c l: receiptCreditLedgerMap.get(r.Id)) {
                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c - l.Amount__c;
                        }
                        updateReceiptList.add(r);
                    }
                }
            }
            if(!updateDemandList.isEmpty() && updateDemandList != null)
                update updateDemandList;
            if(!updateReceiptList.isEmpty() && updateReceiptList != null)
                update updateReceiptList;
        }
    }
    
    public static List<Demand__c> getDemandInfo(Set<Id> demandIdSet) {
        List<Demand__c> demandList = new List<Demand__c>();
        String[] types = new String[]{'Demand__c'};
            string queryFields = '';
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Schema.DescribeSobjectResult res : results) {
            string sObjectname = res.getName();
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values()) { 
                schema.describefieldresult dfield = sfield.getDescribe();
                String fieldLabel = dfield.getLabel();
                
                if(queryFields == null || queryFields == '') {
                    queryFields = dField.getName();
                } else {
                    queryFields = queryFields + ', ' + dField.getName();
                }
            }
        }
        String soqlQuery = 'Select ' + queryFields  + ' from Demand__c Where Id IN :demandIdSet'; 
        system.debug('soqlQuery: '+soqlQuery);
        demandList = Database.query(soqlQuery);
        if(demandList.size() > 0) {
            return demandList;
        } else {
            return null;
        }
    }
    
    public static List<Receipt__c> getReceiptInfo(Set<Id> receiptIdSet) {
        List<Receipt__c> receiptList = new List<Receipt__c>();
        String[] types = new String[]{'Receipt__c'};
            string queryFields = '';
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Schema.DescribeSobjectResult res : results) {
            string sObjectname = res.getName();
            Map <String, Schema.SObjectField> fieldMap = res.fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values()) { 
                schema.describefieldresult dfield = sfield.getDescribe();
                String fieldLabel = dfield.getLabel();
                
                if(queryFields == null || queryFields == '') {
                    queryFields = dField.getName();
                } else {
                    queryFields = queryFields + ', ' + dField.getName();
                }
            }
        }
        String soqlQuery = 'Select ' + queryFields  + ' from Receipt__c Where Id IN :receiptIdSet'; 
        system.debug('soqlQuery: '+soqlQuery);
        receiptList = Database.query(soqlQuery);
        if(receiptList.size() > 0) {
            return receiptList;
        } else {
            return null;
        }
    }
    
}