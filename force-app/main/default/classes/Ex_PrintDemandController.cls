/**
* @description       :
* @author            : nitinSFDC@exceller.SFDoc
* @group             :
* @last modified on  : 28-05-2025
* @last modified by  : nitinSFDC@exceller.SFDoc
**/

public class Ex_PrintDemandController {
    
    public Id dId {get;set;}
    public Booking__c bk {get;set;}
    public String unitName {get; set;}
    public String towerName {get;set;}
    public String projectName {get;set;}
    public String projectAddress {get;set;}
    public Date invoiceDate { get; set; }
    public String AmountDemand {get;set;}
    public String AmountDemandTax {get;set;}
    public String avValueStr {get;set;}
    public String avValueTaxStr {get;set;}
    public String paidedDemandAmountTillDate {get;set;}
    public String paidedDemandAmountTaxTillDate {get;set;}
    public String remainingDemandAmountTillDate {get;set;}
    public String remainingDemandAmountTaxTillDate {get;set;}
    
    
    public Ex_PrintDemandController() {
        unitName = '';
        towerName = '';
        projectName= '';
        projectAddress = '';
        AmountDemand = '';
        AmountDemandTax = '';
        bk = null;
        invoiceDate = null;
        avValueStr = '';
        avValueTaxStr = '';
        paidedDemandAmountTaxTillDate = '';
        paidedDemandAmountTillDate = '';
        remainingDemandAmountTillDate = '';
        remainingDemandAmountTaxTillDate = '';
        
        dId = ApexPages.currentPage().getParameters().get('dId');
        system.debug('dId: '+dId);
        
        Demand__c d = getDemandInfo(dId);
        if(d != null){
            invoiceDate = d.Invoice_Date__c;
        }
        if(d.Booking__c != null){
            bk = getBookingInfo(d.Booking__c);
            unitName = bk.Unit__r.Name;
            towerName = bk.Tower__r.Name;
            projectAddress = bk.Project__r.Project_Address__c;
            avValueStr = Ex_InventoryPriceManagementServices.currencyFormat(bk.Agreement_Value__c);
            avValueTaxStr = Ex_InventoryPriceManagementServices.currencyFormat(bk.Agreement_Value_Tax__c);
            AmountDemand = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Amount_Demanded__c);
            AmountDemandTax = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Tax_Demanded__c);
            paidedDemandAmountTillDate = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Amount_Paid__c);
            paidedDemandAmountTaxTillDate = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Tax_Paid__c);
            remainingDemandAmountTillDate = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Amount_Remaining__c);
            remainingDemandAmountTaxTillDate = Ex_InventoryPriceManagementServices.currencyFormat(d.Total_Tax_Remaining__c);
        }
    }
    
    public static Booking__c getBookingInfo(Id dId) {
        List<Booking__c> unitList = new List<Booking__c>();
        String[] types = new String[]{'Booking__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' , Unit__r.Name, Project__r.Name, Tower__r.Name, Project__r.Project_Address__c  from Booking__c Where Id = \''+dId+'\''; 
        system.debug(soqlQuery);
        unitList = Database.query(soqlQuery);
        if (unitList.size() > 0) {
            return unitList[0];
        } else {
            return null;
        }
    }
    
    public static Demand__c getDemandInfo(Id dId) {
        List<Demand__c> unitList = new List<Demand__c>();
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
        String soqlQuery = 'Select ' + queryFields  + '  from Demand__c Where Id = \''+dId+'\''; 
        system.debug(soqlQuery);
        unitList = Database.query(soqlQuery);
        if (unitList.size() > 0) {
            return unitList[0];
        } else {
            return null;
        }
    }
}