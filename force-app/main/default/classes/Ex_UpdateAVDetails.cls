/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Ex_UpdateAVDetails {
    public Ex_UpdateAVDetails() {

    }
    @AuraEnabled(cacheable = true)
    public static getAVWrapper getAVDetails(Id recordId) {
        List<getAVWrapper> getwrapperList = new List<getAVWrapper>();
        List<Booking__c> bkList = new  List<Booking__c>();
        String getOrginalValueTotal;
        String getOrginalStampValue;
        String getOrginalGstValue;
        bkList = [SELECT Id, Name, Updated_Agreement_Value__c, Stamp_Duty__c, GST__c  FROM Booking__c WHERE Id = :recordId];
        System.debug('bkList: '+bkList);
        try{       
            if (!bkList.isEmpty() && bklist != null)  {
                getOrginalStampValue = Ex_InventoryPriceManagementServices.currencyFormat((bkList[0].Updated_Agreement_Value__c * (bkList[0].Stamp_Duty__c/ 100)).setscale(0,RoundingMode.HALF_UP));
                getOrginalGstValue = Ex_InventoryPriceManagementServices.currencyFormat((bkList[0].Updated_Agreement_Value__c * (bkList[0].GST__c / 100)).setscale(0,RoundingMode.HALF_UP));
                getOrginalValueTotal = Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Updated_Agreement_Value__c + (bkList[0].Updated_Agreement_Value__c *( bkList[0].Stamp_Duty__c / 100) ) +
                                                                                           (bkList[0].Updated_Agreement_Value__c *( bkList[0].GST__c / 100)).setscale(0,RoundingMode.HALF_UP));
                
                getwrapperList.add(new getAVWrapper(Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Updated_Agreement_Value__c),
                                                    Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].Stamp_Duty__c),
                                                    Ex_InventoryPriceManagementServices.currencyFormat(bkList[0].GST__c),
                                                    getOrginalValueTotal,
                                                    getOrginalStampValue,
                                                    getOrginalGstValue,
                                                    bkList[0].Name , ''));
                return getwrapperList[0];
            }else{
                return null;
            }
        }
        catch (Exception ex) {
            String errorMessage = 'An error occurred: ' + ex.getMessage();
            return new getAVWrapper('', '', '','','', '','',errorMessage);
        }
    }
    
    /********* Method for update Agreement value on Booking ******/
    @AuraEnabled
    public static getAVWrapper updateAVChangeDetails(String recordId, Decimal updatedAVvalue, Decimal getUpdatedStampValue, Decimal getUpdatedGST){
        try {
            System.debug('recordId: ' + recordId);
            System.debug('updatedAVvalue: ' + updatedAVvalue);
            System.debug('getUpdatedStampValue: ' + getUpdatedStampValue);
            System.debug('getUpdatedGST: ' + getUpdatedGST);
            List<getAVWrapper> getwrapperList = new List<getAVWrapper>();
            
            
            List<Booking__c> bkList = [SELECT Id, Updated_Agreement_Value__c, Stamp_Duty__c, GST__c, Remarks__c FROM Booking__c WHERE Id = :recordId];
            System.debug('bkList: ' + bkList);
            
            if (!bkList.isEmpty() && bkList != null) {
                if(getUpdatedStampValue == null || getUpdatedStampValue == 0){
                    getUpdatedStampValue = bkList[0].Stamp_Duty__c;
                }
                if(getUpdatedGST == null || getUpdatedGST == 0){
                    getUpdatedGST = bkList[0].GST__c;
                }
                if(updatedAVvalue == null || updatedAVvalue == 0){
                    updatedAVvalue = bklist[0].Updated_Agreement_Value__c;
                }
               
                //  Decimal stampDuty = bkList[0].Stamp_Duty__c;
                //  Decimal gst = bkList[0].GST__c;
                String getModifiedValueTotal = Ex_InventoryPriceManagementServices.currencyFormat((updatedAVvalue + (getUpdatedStampValue * updatedAVvalue / 100) + (getUpdatedGST * updatedAVvalue / 100)).setscale(0,RoundingMode.HALF_UP));
                getwrapperList.add(new getAVWrapper(
                    Ex_InventoryPriceManagementServices.currencyFormat((updatedAVvalue).setscale(0,RoundingMode.HALF_UP)),
                    Ex_InventoryPriceManagementServices.currencyFormat(((getUpdatedStampValue * updatedAVvalue) / 100).setscale(0,RoundingMode.HALF_UP)),
                    Ex_InventoryPriceManagementServices.currencyFormat(((getUpdatedGST * updatedAVvalue) / 100).setscale(0,RoundingMode.HALF_UP)),
                    getModifiedValueTotal, '','','',''
                ));
                System.debug('getwrapperListModified: ' + getwrapperList);
                return getwrapperList[0];
            } else {
                return null;
            }
        } catch (Exception ex) {
            String errorMessage = 'An error occurred: ' + ex.getMessage();
            return new getAVWrapper('', '', '', '','','','',errorMessage);
        }
    }
    
    /*****Saving Updated AV Details on Booking ******/
    @AuraEnabled
    public static Boolean saveAV(String recordId, String updatedAVvalue, Decimal gstValue, Decimal stampValue, String remarks){
        List<Booking__c> bkList = new  List<Booking__c>();
        bkList = [SELECT Id, Updated_Agreement_Value__c, Stamp_Duty__c, GST__c, Remarks__c  FROM Booking__c WHERE Id = :recordId];
        System.debug('bkList: '+bkList);
        if(updatedAVvalue != null){
            updatedAVvalue = updatedAVvalue.replaceAll('[^0-9.]', '');
            bkList[0].Updated_Agreement_Value__c = Decimal.ValueOf(updatedAVvalue);
        }
        if(gstValue != null)
            bkList[0].GST__c = gstValue;
        if(stampValue != null)
            bkList[0].Stamp_Duty__c = stampValue;
        if(remarks != null)
            bkList[0].Remarks__c = remarks;
        
        if(!bkList.isEmpty() && bkList != null){
            update bkList[0];
            return true;
        }else{
            return false;
        }
    }
    
    public class getAVWrapper{
        @Auraenabled
        public String getAvvalue {get;set;}
        @Auraenabled
        public String getStampvalue {get;set;}
        @Auraenabled
        public String getTaxalue {get;set;}
        @Auraenabled
        public String getValueTotal {get;set;}
        @Auraenabled
        public String getOrginalGstValue {get;set;}
        
        @Auraenabled
        public String getOrginalStampValue {get;set;}
        
        @Auraenabled
        public String errorMsg {get;set;}
        @Auraenabled
        public String bookingName {get;set;}
        
        public getAVWrapper(String getAvvalue, String getStampvalue, String getTaxalue, String getValueTotal, String getOrginalStampValue, String getOrginalGstValue,  String bookingName, String errorMsg){
            this.getAvvalue = getAvvalue;
            this.getStampvalue = getStampvalue;
            this.getTaxalue = getTaxalue;
            this.getValueTotal = getValueTotal;
            this.getOrginalStampValue = getOrginalStampValue;
            this.getOrginalGstValue = getOrginalGstValue;
            this.bookingName = bookingName;
            this.errorMsg = errorMsg;
        }
    }
}