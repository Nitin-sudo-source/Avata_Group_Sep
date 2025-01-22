//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_DemandHandlerServices {
    public static void createDebitLedgerAndUpdateLastDemandNo(Set<Id> demandIdSet) {
        Map<Id, Demand__c> projectDemandMap = new Map<Id, Demand__c>();
        List<Project__c> pList = new List<Project__c>();
        List<Project__c> updateProjectList = new List<Project__c>();
        List<Demand__c> dList = new List<Demand__c>();
        List<Ledger__c> debitLedgerList = new List<Ledger__c>();
        
        dList = [Select Id, Name, Invoice_Date__c, Invoice_Number__c, Agreement_Value_Demanded__c, Agreement_Value_Tax_Demanded__c, 
                 Booking__c, Booking__r.Project__c, Booking__r.Opportunity__c
                 from Demand__c where Id IN: demandIdSet ORDER BY CreatedDate ASC];
        system.debug('dList: '+dList);
        
        if(!dList.isEmpty() && dList != null) {
            for(Demand__c d: dList) {
                if(d.Booking__r.Project__c != null) {
                    projectDemandMap.put(d.Booking__r.Project__c, d);
                }
                if(d.Agreement_Value_Demanded__c != null && d.Agreement_Value_Demanded__c > 0) {
                    Ledger__c amtLedger = new Ledger__c();
                    amtLedger.Transaction_Date__c = d.Invoice_Date__c;
                    amtLedger.Charge_Name__c = 'Flat Cost';
                    amtLedger.Type__c = 'Debit';
                    amtLedger.Amount__c = d.Agreement_Value_Demanded__c;
                    amtLedger.Demand__c = d.Id;
                    amtLedger.Booking__c = d.Booking__c;
                    amtLedger.Opportunity__c = d.Booking__r.Opportunity__c;
                    debitLedgerList.add(amtLedger);
                }
                if(d.Agreement_Value_Tax_Demanded__c != null && d.Agreement_Value_Tax_Demanded__c > 0) {
                    Ledger__c taxLedger = new Ledger__c();
                    taxLedger.Transaction_Date__c = d.Invoice_Date__c;
                    taxLedger.Charge_Name__c = 'Tax';
                    taxLedger.Type__c = 'Debit';
                    taxLedger.Amount__c = d.Agreement_Value_Tax_Demanded__c;
                    taxLedger.Demand__c = d.Id;
                    taxLedger.Booking__c = d.Booking__c;
                    taxLedger.Opportunity__c = d.Booking__r.Opportunity__c;
                    taxLedger.Tax_Ledger__c = true;
                    debitLedgerList.add(taxLedger);
                }
            }
            
            if(!projectDemandMap.isEmpty() && projectDemandMap != null) {
                pList = [Select Id, Name, Starting_Demand_No__c, Last_Demand_No__c from Project__c where Id IN: projectDemandMap.keySet()];
                system.debug('pList: '+pList);
                
                if(!pList.isEmpty() && pList != null) {
                    for(Project__c p: pList) {
                        if(projectDemandMap.containsKey(p.Id)) {
                            if(projectDemandMap.get(p.Id).Invoice_Number__c!=null)
                            {    
                                p.Last_Demand_No__c = Decimal.valueOf(projectDemandMap.get(p.Id).Invoice_Number__c.remove(p.Name+'-'));
                            }
                            updateProjectList.add(p);
                        }
                    }
                }
            }
        }
        if(!debitLedgerList.isEmpty() && debitLedgerList != null)
            insert debitLedgerList;
        if(!updateProjectList.isEmpty() && updateProjectList != null)
            update updateProjectList;
    }
    
    public static void reverseDemandCalculation(Set<Id> reverseDemandIdSet) {
        List<Ledger__c> creditLedgerList = new List<Ledger__c>();
        List<Ledger__c> debitLedgerList = new List<Ledger__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        List<Ledger__c> insertCreditLedgerList = new List<Ledger__c>();
        List<Ledger__c> updateDebitLedgerList = new List<Ledger__c>();
        List<Demand__c> updateDemandList = new List<Demand__c>();
        
        creditLedgerList = getLedgerInfo(reverseDemandIdSet, 'Credit');
        //system.debug('creditLedgerList: '+creditLedgerList.size());
        
        debitLedgerList = getLedgerInfo(reverseDemandIdSet, 'Debit');
        //system.debug('debitLedgerList: '+debitLedgerList.size());
        
        demandList = getDemandInfo(reverseDemandIdSet);
        //system.debug('demandList: '+demandList);
        
        if(creditLedgerList != null)
            delete creditLedgerList;
        
        if(debitLedgerList != null) {
            for(Ledger__c l: debitLedgerList) {
                Ledger__c cl = new Ledger__c();
                cl = l.clone(false, false, false, false);
                cl.Type__c = 'Credit';
                cl.Remarks__c = l.Demand__r.Invoice_Number__c + ' - Invoice Cancellation Credit';
                cl.Cancelled__c = true;
                l.Remarks__c = l.Demand__r.Invoice_Number__c + ' - Invoice Cancellation Credit';
                l.Cancelled__c = true;
                insertCreditLedgerList.add(cl);
                updateDebitLedgerList.add(l);
            }
        }
        if(!insertCreditLedgerList.isEmpty() && insertCreditLedgerList != null)
            insert insertCreditLedgerList;
        if(!updateDebitLedgerList.isEmpty() && updateDebitLedgerList != null)
            update updateDebitLedgerList;
        
        for(Demand__c d: demandList) {
            d.Agreement_Value_Demanded__c = 0;
            d.Agreement_Value_Paid__c = 0;
            d.Agreement_Value_Tax_Demanded__c = 0;
            d.Agreement_Value_Tax_Paid__c = 0;
            d.Other_Charges_Demanded__c = 0;
            d.Other_Charges_Paid__c = 0;
            d.Other_Charges_Tax_Demanded__c = 0;
            d.Other_Charges_Tax_Paid__c = 0;
            d.Statutory_Charges_Demanded__c = 0;
            d.Statutory_Charges_Paid__c = 0;
            d.Statutory_Charges_Tax_Demanded__c = 0;
            d.Statutory_Charges_Tax_Paid__c = 0;
            d.Total_Amount_Demanded__c = 0;
            d.Total_Amount_Paid__c = 0;
            d.Total_Tax_Demanded__c = 0;
            d.Total_Tax_Paid__c = 0;
            d.Total_Interest_Amount__c = 0;
            d.Total_Interest_Amount_Paid__c = 0;
            d.Total_Interest_Amount_Waived__c = 0;
            d.Total_Tax_On_Interest_Amount__c = 0;
            d.Total_Tax_On_Interest_Amount_Paid__c = 0;
            d.Total_Tax_On_Interest_Amount_Waived__c = 0;
            updateDemandList.add(d);
        }
        if(!updateDemandList.isEmpty() && updateDemandList != null)
            update updateDemandList;
    }
    
    public static void deletedDemandCalculation(Set<Id> deletedDemandIdSet) {
        List<Ledger__c> ledgerList = getLedgerInfo(deletedDemandIdSet, '');
        //system.debug('ledgerList: '+ledgerList);
        
        if(ledgerList != null)
            delete ledgerList;
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
    
    public static List<Ledger__c> getLedgerInfo(Set<Id> demandIdSet, String ledgerType) {
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
        String soqlQuery;
        if(!String.isBlank(ledgerType) && ledgerType != '') {
            soqlQuery = 'Select ' + queryFields  + ', Demand__r.Invoice_Number__c from Ledger__c Where Demand__c IN :demandIdSet AND Type__c = ' + '\'' + ledgerType + '\''; 
        } else {
            soqlQuery = 'Select ' + queryFields  + ', Demand__r.Invoice_Number__c from Ledger__c Where Demand__c IN :demandIdSet'; 
        }
        system.debug('soqlQuery: '+soqlQuery);
        ledgerList = Database.query(soqlQuery);
        if(ledgerList.size() > 0) {
            return ledgerList;
        } else {
            return null;
        }
    }
    
}