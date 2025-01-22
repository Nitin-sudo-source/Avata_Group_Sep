public class Ex_ReceiptHandlerServices {
    public static void receiptApporation(Set<Id> rIdSet) {
        system.debug('rIdSet: '+rIdSet);
        Set<Id> bookingIdSet = new Set<Id>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        List<Receipt__c> updateReceiptList = new List<Receipt__c>();
        List<Ledger__c> ledgerList = new List<Ledger__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        Map<String, List<Demand__c>> demandMap = new Map<String, List<Demand__c>>();
        
        receiptList = [Select Id, Name, Receipt_Date__c, Instrument_Date__c, Booking__c, Booking__r.Quotation__c, GST_Amount__c, Token_Amount_Tax__c,
                       Amount__c, Total_Money_Apportioned__c, Receipt_Type__c, On_Account_Money__c, Token_Amount__c, Token_Amount_Flat_Cost__c
                       from Receipt__c where Id IN: rIdSet /*AND Payment_Status__c = 'Payment Successful'*/];
        //Added by Aniket
        system.debug('receiptList: '+receiptList);
        
        if(!receiptList.isEmpty() && receiptList != null) {
            for(Receipt__c r: receiptList) {
                if(r.Booking__c != null) {
                    bookingIdSet.add(r.Booking__c);
                }
            }
            if(bookingIdSet != null) {
                demandMap = getPendingDemandMap(bookingIdSet);
            }
            //system.debug('demandMap: '+demandMap);       
            
            for(Receipt__c r: receiptList) {                
                if(r.On_Account_Money__c > 0) {   
                    if(r.Total_Money_Apportioned__c == null)
                        r.Total_Money_Apportioned__c = 0;
                    if(!demandMap.isEmpty() && demandMap != null) {
                        if(demandMap.containsKey(r.Booking__c)) {
                            Boolean isApportionReceipt = false;
                            system.debug('Size: '+demandMap.get(r.Booking__c).size());
                            
                            for(Demand__c d: demandMap.get(r.Booking__c)) {
                                Boolean isApportion = false;
                                
                                if(r.Receipt_Type__c.equalsIgnoreCase('Interest')) {
                                    //Interest Apportion
                                    if(d.Total_Interest_Amount_Remaining__c != null && d.Total_Interest_Amount_Remaining__c > 0 && (r.Amount__c - r.Total_Money_Apportioned__c) > 0) {
                                        Decimal paidInterest = 0;
                                        if(d.Total_Interest_Amount_Remaining__c <= (r.Amount__c - r.Total_Money_Apportioned__c)) {
                                            paidInterest = d.Total_Interest_Amount_Remaining__c;
                                            if(d.Total_Interest_Amount_Paid__c == null)
                                                d.Total_Interest_Amount_Paid__c = 0;
                                            d.Total_Interest_Amount_Paid__c = d.Total_Interest_Amount_Paid__c + paidInterest;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidInterest;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            //system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        } else {
                                            paidInterest = (r.Amount__c - r.Total_Money_Apportioned__c);
                                            if(d.Total_Interest_Amount_Paid__c == null)
                                                d.Total_Interest_Amount_Paid__c = 0;
                                            d.Total_Interest_Amount_Paid__c = d.Total_Interest_Amount_Paid__c + paidInterest;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidInterest;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            //system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        }
                                        
                                        //Ledger Creation
                                        Ledger__c ld = new Ledger__c();
                                        ld.Transaction_Date__c = r.Receipt_Date__c;
                                        ld.Charge_Name__c = 'Interest';
                                        ld.Type__c = 'Debit';
                                        ld.Amount__c = paidInterest;
                                        ld.Demand__c = d.Id;
                                        ld.Booking__c = r.Booking__c;
                                        ledgerList.add(ld);
                                        
                                        Ledger__c lc = new Ledger__c();
                                        lc.Transaction_Date__c = r.Receipt_Date__c;
                                        lc.Charge_Name__c = 'Interest';
                                        lc.Type__c = 'Credit';
                                        lc.Amount__c = paidInterest;
                                        lc.Demand__c = d.Id;
                                        lc.Booking__c = r.Booking__c;
                                        lc.Receipt__c = r.Id;
                                        ledgerList.add(lc);
                                    }
                                }
                                
                                if(r.Receipt_Type__c.equalsIgnoreCase('Interest GST')) {
                                    //Interest GST Apportion
                                    if(d.Total_GST_On_Interest_Amount_Remaining__c != null && d.Total_GST_On_Interest_Amount_Remaining__c > 0 && (r.Amount__c - r.Total_Money_Apportioned__c) > 0) {
                                        Decimal paidInterest = 0;
                                        if(d.Total_GST_On_Interest_Amount_Remaining__c <= (r.Amount__c - r.Total_Money_Apportioned__c)) {
                                            paidInterest = d.Total_GST_On_Interest_Amount_Remaining__c;
                                            if(d.Total_Tax_On_Interest_Amount__c == null)
                                                d.Total_Tax_On_Interest_Amount__c = 0;
                                            d.Total_Tax_On_Interest_Amount_Paid__c = d.Total_Tax_On_Interest_Amount_Paid__c + paidInterest;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidInterest;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            //system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        } else {
                                            paidInterest = (r.Amount__c - r.Total_Money_Apportioned__c);
                                            if(d.Total_Tax_On_Interest_Amount__c == null)
                                                d.Total_Tax_On_Interest_Amount__c = 0;
                                            d.Total_Tax_On_Interest_Amount_Paid__c = d.Total_Tax_On_Interest_Amount_Paid__c + paidInterest;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidInterest;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            //system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        }
                                        
                                        //Ledger Creation
                                        Ledger__c ld = new Ledger__c();
                                        ld.Transaction_Date__c = r.Receipt_Date__c;
                                        ld.Charge_Name__c = 'Interest GST';
                                        ld.Type__c = 'Debit';
                                        ld.Amount__c = paidInterest;
                                        ld.Demand__c = d.Id;
                                        ld.Booking__c = r.Booking__c;
                                        ledgerList.add(ld);
                                        
                                        Ledger__c lc = new Ledger__c();
                                        lc.Transaction_Date__c = r.Receipt_Date__c;
                                        lc.Charge_Name__c = 'Interest GST';
                                        lc.Type__c = 'Credit';
                                        lc.Amount__c = paidInterest;
                                        lc.Demand__c = d.Id;
                                        lc.Booking__c = r.Booking__c;
                                        lc.Receipt__c = r.Id;
                                        ledgerList.add(lc);
                                    }
                                }                                  
                                
                                if(r.Receipt_Type__c.equalsIgnoreCase('GST')) {
                                    if(d.Agreement_Value_Tax_Remaining__c != null && d.Agreement_Value_Tax_Remaining__c > 0 && (r.Amount__c - r.Total_Money_Apportioned__c) > 0) {
                                        Decimal paidTax = 0;
                                        if(d.Agreement_Value_Tax_Remaining__c <= (r.Amount__c - r.Total_Money_Apportioned__c)) {
                                            paidTax = d.Agreement_Value_Tax_Remaining__c;
                                            if(d.Agreement_Value_Tax_Paid__c == null)
                                                d.Agreement_Value_Tax_Paid__c = 0;
                                            d.Agreement_Value_Tax_Paid__c = d.Agreement_Value_Tax_Paid__c + paidTax;
                                            d.Total_Tax_Paid__c = d.Total_Tax_Paid__c + paidTax;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidTax;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                        }
                                        else {
                                            paidTax = (r.Amount__c - r.Total_Money_Apportioned__c);
                                            if(d.Agreement_Value_Tax_Paid__c == null)
                                                d.Agreement_Value_Tax_Paid__c = 0;
                                            d.Agreement_Value_Tax_Paid__c = d.Agreement_Value_Tax_Paid__c + paidTax;
                                            d.Total_Tax_Paid__c = d.Total_Tax_Paid__c + paidTax;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidTax;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                        }
                                        //Ledger Creation
                                        Ledger__c l = new Ledger__c();
                                        l.Transaction_Date__c = r.Receipt_Date__c;
                                        l.Charge_Name__c = 'Tax';
                                        l.Type__c = 'Credit';
                                        l.Amount__c = paidTax;
                                        l.Demand__c = d.Id;
                                        l.Booking__c = r.Booking__c;
                                        l.Receipt__c = r.Id;
                                        l.Tax_Ledger__c = true;
                                        ledgerList.add(l);
                                    }
                                }
                                if(r.Receipt_Type__c.equalsIgnoreCase('Flat Cost')) {
                                    if(d.Agreement_Value_Remaining__c != null && d.Agreement_Value_Remaining__c > 0 && (r.Amount__c - r.Total_Money_Apportioned__c) > 0) {
                                        Decimal paidAmount = 0;
                                        if(d.Agreement_Value_Remaining__c <= (r.Amount__c - r.Total_Money_Apportioned__c)) {
                                            paidAmount = d.Agreement_Value_Remaining__c;
                                            if(d.Agreement_Value_Paid__c == null)
                                                d.Agreement_Value_Paid__c = 0;
                                            d.Agreement_Value_Paid__c = d.Agreement_Value_Paid__c + paidAmount;
                                            d.Total_Amount_Paid__c = d.Total_Amount_Paid__c + paidAmount;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidAmount;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                        } else {
                                            paidAmount = (r.Amount__c - r.Total_Money_Apportioned__c);
                                            if(d.Agreement_Value_Paid__c == null)
                                                d.Agreement_Value_Paid__c = 0;
                                            d.Agreement_Value_Paid__c = d.Agreement_Value_Paid__c + paidAmount;
                                            d.Total_Amount_Paid__c = d.Total_Amount_Paid__c + paidAmount;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidAmount;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                        }
                                        
                                        //Ledger Creation
                                        Ledger__c l = new Ledger__c();
                                        l.Transaction_Date__c = r.Receipt_Date__c;
                                        l.Type__c = 'Credit';
                                        l.Charge_Name__c = 'Flat Cost';
                                        l.Amount__c = paidAmount;
                                        l.Demand__c = d.Id;
                                        l.Booking__c = r.Booking__c;
                                        l.Receipt__c = r.Id;
                                        ledgerList.add(l);
                                    }
                                }
                                
                                if(r.Receipt_Type__c.equalsIgnoreCase('TDS Challan')) {
                                    if(d.TDS_Value_Remaining__c != null && d.TDS_Value_Remaining__c > 0 && (r.Amount__c - r.Total_Money_Apportioned__c) > 0) {
                                        Decimal paidTDSAmount = 0;
                                        if(d.TDS_Value_Remaining__c <= (r.Amount__c - r.Total_Money_Apportioned__c)) {
                                            paidTDSAmount = d.TDS_Value_Remaining__c;
                                            if(d.TDS_Value_Paid__c == null)
                                                d.TDS_Value_Paid__c = 0;
                                            d.TDS_Value_Paid__c = d.TDS_Value_Paid__c + paidTDSAmount;
                                            d.Total_Amount_Paid__c = d.Total_Amount_Paid__c + paidTDSAmount;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidTDSAmount;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        } else {
                                            paidTDSAmount = (r.Amount__c - r.Total_Money_Apportioned__c); 
                                            if(d.TDS_Value_Paid__c == null)
                                                d.TDS_Value_Paid__c = 0;
                                            d.TDS_Value_Paid__c = d.TDS_Value_Paid__c + paidTDSAmount;
                                            d.Total_Amount_Paid__c = d.Total_Amount_Paid__c + paidTDSAmount;
                                            r.Total_Money_Apportioned__c = r.Total_Money_Apportioned__c + paidTDSAmount;
                                            isApportion = true;
                                            isApportionReceipt = true;
                                            system.debug('r.On_Account_Money__c: '+r.On_Account_Money__c);
                                        }
                                        
                                        //Ledger Creation
                                        Ledger__c l = new Ledger__c();
                                        l.Transaction_Date__c = r.Receipt_Date__c;
                                        l.Charge_Name__c = 'TDS';
                                        l.Type__c = 'Credit';
                                        l.Amount__c = paidTDSAmount;
                                        l.Demand__c = d.Id;
                                        l.Booking__c = r.Booking__c;
                                        l.Receipt__c = r.Id;
                                        ledgerList.add(l);
                                    }
                                }
                                if(isApportion) {
                                    update d;
                                    demandMap = getPendingDemandMap(bookingIdSet);
                                }
                            }
                            if(isApportionReceipt)
                                updateReceiptList.add(r);
                        }
                    }
                }
            }
            if(!ledgerList.isEmpty() && ledgerList != null)
                insert ledgerList;
            if(!updateReceiptList.isEmpty() && updateReceiptList != null)
                update updateReceiptList;
        }
    }
    
    public static void reverseReceiptCalculation(Set<Id> reverseReceiptIdSet) {
        List<Ledger__c> creditLedgerList = new List<Ledger__c>();
        List<Ledger__c> updateCreditLedgerList = new List<Ledger__c>();
        List<Ledger__c> insertDebitLedgerList = new List<Ledger__c>();
        Map<Id, List<Ledger__c>> demandIdLedgerMap = new Map<Id, List<Ledger__c>>();
        List<Demand__c> demandList = new List<Demand__c>();
        Map<Id, Demand__c> demandMap = new Map<Id, Demand__c>();
        List<Demand__c> updateDemandList = new List<Demand__c>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        List<Receipt__c> updateReceiptList = new List<Receipt__c>();
        Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>();
        Map<Id, List<Ledger__c>> receiptCreditLedgerMap = new Map<Id, List<Ledger__c>>();
        
        creditLedgerList = getLedgerInfo(reverseReceiptIdSet);
        //system.debug('creditLedgerList: '+creditLedgerList);
        
        if(creditLedgerList != null) {
            for(Ledger__c l: creditLedgerList) {
                if(!l.Cancelled__c) {
                    if(demandIdLedgerMap.containsKey(l.Demand__c)) {
                        demandIdLedgerMap.get(l.Demand__c).add(l); 
                    } else {
                        List<Ledger__c> newList = new List<Ledger__c>();
                        newList.add(l);
                        demandIdLedgerMap.put(l.Demand__c, newList);
                    }
                    if(receiptCreditLedgerMap.containsKey(l.Receipt__c)) {
                        receiptCreditLedgerMap.get(l.Receipt__c).add(l);
                    } else {
                        List<Ledger__c> newList = new List<Ledger__c>();
                        newList.add(l);
                        receiptCreditLedgerMap.put(l.Receipt__c, newList);
                    }
                }
            }
            
            if(!demandIdLedgerMap.isEmpty() && demandIdLedgerMap != null) {
                demandList = getDemandInfo(demandIdLedgerMap.keySet());
                //system.debug('demandList: '+demandList);
                
                if(!demandList.isEmpty() && demandList != null) {
                    for(Demand__c d: demandList) {
                        demandMap.put(d.Id, d);
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
            
            for(Id dId: demandIdLedgerMap.keySet()) {
                if(demandMap.containsKey(dId)) {
                    Demand__c d = demandMap.get(dId);
                    for(Ledger__c l: demandIdLedgerMap.get(d.Id)) {
                        if(l.Charge_Name__c.equalsIgnoreCase('Interest')) {
                            d.Total_Interest_Amount_Paid__c = d.Total_Interest_Amount_Paid__c - l.Amount__c;
                        } else if(l.Charge_Name__c.equalsIgnoreCase('Flat Cost')) {
                            if(d.Demand_Type__c.equalsIgnoreCase('Flat Cost')) {
                                d.Agreement_Value_Paid__c = d.Agreement_Value_Paid__c - l.Amount__c;
                            }
                            d.Total_Amount_Paid__c = d.Total_Amount_Paid__c - l.Amount__c;
                        } else if(l.Charge_Name__c.equalsIgnoreCase('Tax')) {
                            if(l.Tax_Ledger__c) {
                                if(d.Demand_Type__c.equalsIgnoreCase('Flat Cost')) {
                                    d.Agreement_Value_Tax_Paid__c = d.Agreement_Value_Tax_Paid__c - l.Amount__c;
                                }
                                d.Total_Tax_Paid__c = d.Total_Tax_Paid__c - l.Amount__c;
                            } 
                        }
                        
                        l.Cancelled__c = true;
                        l.Remarks__c = 'Apportion Reverse';
                        updateCreditLedgerList.add(l);
                        
                        //Credit Debit Ledger
                        Ledger__c ld = new Ledger__c();
                        ld.Demand__c = l.Demand__c;
                        ld.Type__c = 'Debit';
                        ld.Charge_Name__c = l.Charge_Name__c;
                        ld.Booking__c = l.Booking__c;
                        ld.Account__c = l.Account__c;
                        ld.Amount__c = l.Amount__c;
                        ld.Transaction_Date__c = system.today();
                        ld.Tax_Ledger__c = l.Tax_Ledger__c;
                        ld.Cancelled__c = true;
                        ld.Remarks__c = 'Receipt No : ' + l.Receipt__r.Name + ' Reverse on  ' + system.now().format('dd/MM/yyyy');
                        insertDebitLedgerList.add(ld);
                    }
                    updateDemandList.add(d);
                }
            }
        }
        if(!updateCreditLedgerList.isEmpty() && updateCreditLedgerList != null)
            update updateCreditLedgerList;
        if(!insertDebitLedgerList.isEmpty() && insertDebitLedgerList != null)
            insert insertDebitLedgerList;
        if(!updateDemandList.isEmpty() && updateDemandList != null)
            update updateDemandList;
        if(!updateReceiptList.isEmpty() && updateReceiptList != null)
            update updateReceiptList;
    }
    
    public static void deleteReceiptApportionCalculation(Set<Id> rIdSet) {
        List<Ledger__c> creditLedgerList = new List<Ledger__c>();
        
        creditLedgerList = getLedgerInfo(rIdSet);
        //system.debug('creditLedgerList: '+creditLedgerList);
        
        if(creditLedgerList != null)
            delete creditLedgerList;
    }
    
    public static Map<String, List<Demand__c>> getPendingDemandMap(Set<Id> bookingIdSet) {
        Map<String, List<Demand__c>> pendingDemandMap = new Map<String, List<Demand__c>>();
        List<Demand__c> demandList = [Select Id, Booking__c, Quotation__c, Payment_Milestone__c, Milestone_Name__c, Due_Date__c, Invoice_Date__c, Demand_Type__c,
                                      Total_Interest_Amount__c, Total_Interest_Amount_Paid__c, Total_Interest_Amount_Waived__c, Total_Interest_Amount_Remaining__c,
                                      Total_Amount_Demanded__c, Total_Amount_Paid__c, Total_Amount_Remaining__c, Total_Tax_Demanded__c, Total_Tax_Paid__c, Total_Tax_Remaining__c,
                                      Agreement_Value_Demanded__c, Agreement_Value_Paid__c, Agreement_Value_Remaining__c, Agreement_Value_Tax_Demanded__c, Agreement_Value_Tax_Paid__c, Agreement_Value_Tax_Remaining__c,
                                      Other_Charges_Demanded__c, Other_Charges_Paid__c, Other_Charges_Remaining__c, Other_Charges_Tax_Demanded__c, Other_Charges_Tax_Paid__c, Other_Charges_Tax_Remaining__c,
                                      TDS_Value_Demanded__c,TDS_Value_Paid__c,TDS_Value_Remaining__c,Total_GST_On_Interest_Amount_Remaining__c,
                                      /*Interest_Waive_Off_status__c,
                                      Pre_Interest_GST_Waive_off_Amount__c,
                                      Pre_Interest_Waive_off_Amount__c,*/
                                      Total_Tax_On_Interest_Amount__c,Total_Tax_On_Interest_Amount_Paid__c,Total_Tax_On_Interest_Amount_Waived__c
                                      from Demand__c where Booking__c IN: bookingIdSet AND 
                                      (Total_Amount_Remaining__c > 0 OR Total_Tax_Remaining__c > 0 OR Total_Interest_Amount_Remaining__c > 0)
                                      ORDER BY Due_Date__c ASC];
        //system.debug('demandList: '+demandList);
        
        if(demandList != null) {
            for(Demand__c d: demandList) {
                if(pendingDemandMap.containsKey(d.Booking__c)) {
                    pendingDemandMap.get(d.Booking__c).add(d);
                } else {
                    List<Demand__c> newList = new List<Demand__c>();
                    newList.add(d);
                    pendingDemandMap.put(d.Booking__c, newList);
                }
            }
        }
        return pendingDemandMap;
    }
    
    public static List<Ledger__c> getLedgerInfo(Set<Id> receiptIdSet) {
        List<Ledger__c> ledgerList = new List<Ledger__c>();
        String[] types = new String[]{'Ledger__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ', Receipt__r.Receipt_Number__c,Receipt__r.Name from Ledger__c Where Receipt__c IN :receiptIdSet'; 
        //system.debug('soqlQuery: '+soqlQuery);
        ledgerList = Database.query(soqlQuery);
        if(ledgerList.size() > 0) {
            return ledgerList;
        } else {
            return null;
        }
    }
    
    public static List<Demand__c> getDemandInfo(Set<Id> invoiceIdSet) {
        List<Demand__c> invoiceList = new List<Demand__c>();
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
        String soqlQuery = 'Select ' + queryFields  + ' from Demand__c Where Id IN :invoiceIdSet'; 
        //system.debug('soqlQuery: '+soqlQuery);
        invoiceList = Database.query(soqlQuery);
        if(invoiceList.size() > 0) {
            return invoiceList;
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