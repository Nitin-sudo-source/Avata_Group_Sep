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
    
    @AuraEnabled
    public static Booking__c getBookingInfo(Id recordId) {
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
        String soqlQuery = 'Select ' + queryFields  + ', Tower__r.Project__c, Tower__r.Project__r.Name, Tower__r.Name,Tower__r.Project__r.Threshold_Amount__c, Tower__r.Project__r.Threshold_Percentage__c, Quotation__r.Payment_Scheme__c from Booking__c Where Id = \''+recordId+'\''; 
        system.debug(soqlQuery);
        unitList = Database.query(soqlQuery);
        if (unitList.size() > 0) {
            return unitList[0];
        } else {
            return null;
        }
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
                
                getwrapperList.add(new getAVWrapper(String.valueof(bkList[0].Updated_Agreement_Value__c),
                                                    String.valueof(bkList[0].Stamp_Duty__c),
                                                    String.valueof(bkList[0].GST__c),
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
    
    @AuraEnabled(Cacheable=false)
    public static Map<String, Charge_Details__c> getPriceListMapDetails(Id uId) {
        system.debug('uId: '+uId);
        Map<String, Charge_Details__c> priceListMap = Ex_AfterBookingPriceManagementServices.getPriceListMap(uId);
        system.debug('priceListMap: '+priceListMap);
        return priceListMap;
    }
    
    @AuraEnabled(Cacheable=false)
    public static Map<String, List<String>> getPriceListGroupMapDetails(Id uId) {
        Map<String, List<String>> priceListGroupMap = Ex_AfterBookingPriceManagementServices.getPriceListGroupMap(uId);
        system.debug('priceListGroupMap: '+priceListGroupMap);
        return priceListGroupMap;
    }
    
    @AuraEnabled
    public static Map<String, Decimal> getAllPriceMapDetails(Id uId, Decimal updatedAV, Decimal updatedSDR, Decimal updatedGST, Map<String, List<String>> priceListGroupMap, Map<String, Charge_Details__c> priceListMap, Decimal carParkAmount, Decimal discountAmount) {
        System.debug('priceListGroupMap: '+priceListGroupMap);
        System.debug('priceListMap: '+priceListMap);
        
        Map<String, Decimal> allPriceInfoMap = Ex_AfterBookingPriceManagementServices.getAllPriceInfo(uId, updatedAV, updatedSDR, updatedGST, priceListGroupMap, priceListMap, carParkAmount, discountAmount);
        system.debug('allPriceInfoMap: '+allPriceInfoMap);
        return allPriceInfoMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getAllPriceInfoFormattedMap(Map<String, Decimal> allPriceInfoMap) {
        Map<String, String> allPriceInfoFormattedMap = new Map<String, String>();
        if(allPriceInfoMap != null && !allPriceInfoMap.isEmpty()) {
            for(String ch: allPriceInfoMap.keySet()) {
                allPriceInfoFormattedMap.put(ch, Ex_AfterBookingPriceManagementServices.currencyFormat(allPriceInfoMap.get(ch)));
            }
        }
        return allPriceInfoFormattedMap;
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
    
    @AuraEnabled
    public static List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> getPaymentScheduleDetails(Id uId, Id qId, Map<String, Decimal> allPriceInfoMap, Map<String, Charge_Details__c> priceListMap) {
        System.debug('priceListMap: '+priceListMap);
        System.debug('allPriceInfoMap: '+allPriceInfoMap);
        System.debug('uId: '+uId);
        //System.debug('selectedScheme: '+selectedScheme);
        
        List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_AfterBookingPriceManagementServices.getPaymentSummaryInfo(uId, qId, allPriceInfoMap, priceListMap);
        return paymentMilestoneWrapperList;
    }

     @AuraEnabled
    public static List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> updatedgetPaymentScheduleDetails(Integer agSeqNumber,Id uId, Id qId, Map<String, Decimal> allPriceInfoMap, Map<String, Charge_Details__c> priceListMap,List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        System.debug('priceListMap: '+priceListMap);
        System.debug('allPriceInfoMap: '+allPriceInfoMap);
        System.debug('uId: '+uId);
        System.debug('updatedPaymentMilestoneWrapperList: '+updatedPaymentMilestoneWrapperList);
        
        List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_AfterBookingPriceManagementServices.updatedGetPaymentSummaryInfo(agSeqNumber,uId, qId, allPriceInfoMap, priceListMap,updatedPaymentMilestoneWrapperList);
        return paymentMilestoneWrapperList;
    }
    
    
    @AuraEnabled
    public static List<String> validateUpdatedPaymentScheduleDetails(Integer agSeqNumber, Map<String, Decimal> allPriceInfoMap, List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<String> validationErrorList = Ex_AfterBookingPriceManagementServices.validateUpdatedPaymentSchedule(agSeqNumber, allPriceInfoMap, updatedPaymentMilestoneWrapperList);
        system.debug('validationErrorList: '+validationErrorList);
        return validationErrorList;
    }
    
    @AuraEnabled
    public static List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> getUpdatedPaymentScheduleDetails(Booking__c u, Integer agSeqNumber, Map<String, Charge_Details__c> priceListMap, Map<String, Decimal> allPriceInfoMap, List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_AfterBookingPriceManagementServices.getUpdatedPaymentSchedule(u, agSeqNumber, priceListMap, allPriceInfoMap, updatedPaymentMilestoneWrapperList);
        system.debug('paymentMilestoneWrapperList: '+paymentMilestoneWrapperList);
        return paymentMilestoneWrapperList;
    }
    
    @AuraEnabled
    public static List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> getModifiedPaymentScheduleDetails(String actionType, Integer rowIndex, List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList, Booking__c u, Integer agSeqNumber) {
        List<Construction_Stage__c> cStageList = Ex_AfterBookingPriceManagementServices.getConsturctionStageList(u.Project__c, u.Tower__c);
        
        if(!paymentMilestoneWrapperList.isEmpty() && paymentMilestoneWrapperList != null) {
            if(actionType.endsWithIgnoreCase('Add')) {
                Payment_Scheme_Milestone__c psm = new Payment_Scheme_Milestone__c();
                psm.put('Charge_Bucket_'+agSeqNumber+'_Type__c', '');
                
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.put('Charge_Bucket_'+agSeqNumber+'__c', 'Agreement Value');
                pm.put('Number_of_Days__c', 0);
                pm.put('Milestone_Type__c', '');
                pm.put('Construction_Stage__c', null);
                pm.put('Charge_Bucket_'+agSeqNumber+'_Percentage__c', 0);
                pm.put('Charge_Bucket_'+agSeqNumber+'_Amount__c', 0);
                
                Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper pmw = new Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper(pm, cStageList, '', 0, 0, '', 0, '', 0, '', false, true, false);
                paymentMilestoneWrapperList.add(rowIndex+1, pmw);
            } else if(actionType.endsWithIgnoreCase('Remove')) {
                paymentMilestoneWrapperList.remove(rowIndex);
            }
        }
        system.debug('Size: '+paymentMilestoneWrapperList.size());
        return paymentMilestoneWrapperList;
    }
    
    /*****Saving Updated AV Details on Booking ******/
    @AuraEnabled
    public static Boolean saveAV(String recordId, String updatedAVvalue, Decimal gstValue, Decimal stampValue, String remarks, Map<String, List<String>> priceListGroupMap,Map<String, Charge_Details__c> priceListMap, Map<String, Decimal> allPriceOriginalInfoMap, Map<String, Decimal> allPriceInfoMap, List<Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList){
        System.debug('priceListGroupMap: '+priceListGroupMap);
        System.debug('priceListMap: '+priceListMap);
        System.debug('allPriceOriginalInfoMap: '+allPriceOriginalInfoMap);
        System.debug('allPriceInfoMap: '+allPriceInfoMap);
        
        List<Quotation__c> qList = new List<Quotation__c>();
        List<Booking__c> bkList = new  List<Booking__c>();
        List<Payment_Milestone__c> paymentMilestoneList = new List<Payment_Milestone__c>();
        
        bkList = [SELECT Id, Updated_Agreement_Value__c, Quotation__c, SDR_Tax__c, SDR_Value__c, Agreement_Value__c, Agreement_Value_Tax__c, Stamp_Duty__c, GST__c, Remarks__c  FROM Booking__c WHERE Id = :recordId];
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
        
        Quotation__c q = Ex_AfterBookingPriceManagementServices.getQuotationInfo(bkList[0].Quotation__c);
        Unit__c u = Ex_AfterBookingPriceManagementServices.getUnitInfo(q.Booking__r.Unit__c);
        System.debug('u:'+u);
        
        if(priceListGroupMap != null && !priceListGroupMap.isEmpty()) {
            Integer i = 1;
            for(String bucket: priceListGroupMap.keySet()) {
                q.put('Charge_Bucket_'+i+'__c', bucket);
                q.put('Charge_Bucket_'+i+'_Amount__c', allPriceInfoMap.get(bucket));
                q.put('Charge_Bucket_'+i+'_SGST__c', allPriceInfoMap.get(bucket+' SGST'));
                q.put('Charge_Bucket_'+i+'_CGST__c', allPriceInfoMap.get(bucket+' CGST'));
                q.put('Charge_Bucket_'+i+'_Total_Tax__c', allPriceInfoMap.get(bucket+' TAX'));
                i++;
                if(bucket.equalsIgnoreCase('Agreement Value') && priceListGroupMap.get(bucket).contains('Basic Charge')) {
                    if(priceListMap != null && !priceListMap.isEmpty()) {
                        if(priceListMap.containsKey('Basic Charge')) {
                            if(priceListMap.get('Basic Charge').Charge_Type__c != null && priceListMap.get('Basic Charge').Charge_Type__c.equalsIgnoreCase('PSF')) {
                                if(priceListMap.get('Basic Charge').Calculation_Area_Type__c != null && priceListMap.get('Basic Charge').Calculation_Area_Type__c.equalsIgnoreCase('Carpet Area')) {
                                    q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Total_carpet_Sq_Ft__c).setscale(2, RoundingMode.HALF_UP);
                                    system.debug('Basic Charge:'+allPriceOriginalInfoMap.get('Basic Charge'));
                                    q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Total_carpet_Sq_Ft__c).setscale(2, RoundingMode.HALF_UP);
                                    q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                                } else {
                                    q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                    q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                    q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                                }
                            } else {
                                q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                            }
                        }
                    }
                }
            }
        }
        qList.add(q);
        for(Integer i = 1; i <= 3; i++) {
            if(String.isNotBlank((String)q.get('Charge_Bucket_'+i+'__c')) && ((String)q.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                bkList[0].Agreement_Value__c = (Decimal)q.get('Charge_Bucket_'+i+'_Amount__c');
                bkList[0].Agreement_Value_Tax__c = (Decimal)q.get('Charge_Bucket_'+i+'_Total_Tax__c');
            }
            if(String.isNotBlank((String)q.get('Charge_Bucket_'+i+'__c')) && ((String)q.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Statutory Charges')) {
                bkList[0].SDR_Value__c = (Decimal)q.get('Charge_Bucket_'+i+'_Amount__c');
                bkList[0].SDR_Tax__c = (Decimal)q.get('Charge_Bucket_'+i+'_Total_Tax__c');
            }
        }
        if(bkList[0].Agreement_Value__c != null){
            bkList[0].Updated_Agreement_Value__c = bkList[0].Agreement_Value__c;
        }
        
        List<Charge_Details__c> chargeDetailsList = new List<Charge_Details__c>();
    
        if(priceListGroupMap != null && !priceListGroupMap.isEmpty()) {
            for(String bucket: priceListGroupMap.keySet()) {
                for(String priceName: priceListGroupMap.get(bucket)) {
                    System.debug('priceName: '+priceName);
                    Decimal chargeAmount = allPriceInfoMap.get(priceName);
                     System.debug('chargeAmount: '+chargeAmount);
                    if(chargeAmount > 0) {
                        Charge_Details__c chDetail = new Charge_Details__c();
                        if(String.isNotBlank(priceName) &&  priceName != null && bucket != null){
                            chDetail.Name = priceName;
                            chDetail.Charge_Bucket__c = bucket;
                            chDetail.Charge_Amount__c = allPriceInfoMap.get(priceName);
                            chDetail.Charge_SGST__c = allPriceInfoMap.get(priceName+' SGST');
                            chDetail.Charge_CGST__c = allPriceInfoMap.get(priceName+' CGST');
                            chDetail.Charge_Total_Tax__c = allPriceInfoMap.get(priceName+' TAX');
                            chDetail.Id = priceListMap.get(priceName).Id;
                        }
                        
                        
                        if(priceListMap != null && !priceListMap.isEmpty()) {
                            if(priceListMap.containsKey(priceName)) {
                                if(priceListMap.get(priceName).Charge_Type__c != null && priceListMap.get(priceName).Charge_Type__c.equalsIgnoreCase('PSF')) {
                                    if(priceListMap.get(priceName).Calculation_Area_Type__c != null && priceListMap.get(priceName).Calculation_Area_Type__c.equalsIgnoreCase('Carpet Area')) {
                                        chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Total_carpet_Sq_Ft__c).setscale(2, RoundingMode.HALF_UP);
                                        chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                        chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                        chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                    } else {
                                        chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                        chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                        chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                        chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                    }
                                } else {
                                    chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                    chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                    chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                    chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                    
                                }
                            }
                        }                            
                        //chDetail.Quotation__c = qId;
                        chargeDetailsList.add(chDetail);
                    }
                }
            }
        }
        
        System.debug('paymentMilestoneWrapperList: '+paymentMilestoneWrapperList);
        if(paymentMilestoneWrapperList != null && !paymentMilestoneWrapperList.isEmpty()) {
            Integer i = 1;
            for(Ex_AfterBookingPriceManagementServices.PaymentMilestoneWrapper pmw: paymentMilestoneWrapperList) {
                if(pmw.pm != null) {
                    pmw.pm.Sequence_No__c = i;
                    pmw.pm.Quotation__c =  bkList[0].Quotation__c;
                    paymentMilestoneList.add(pmw.pm);
                    i++;
                }
            }
        }
        System.debug('chargeDetailsList: '+chargeDetailsList);
        if(chargeDetailsList != null){
           update chargeDetailsList;
        }
        System.debug('qList: '+qList);
        if(qList != null){
            update qList;
        }
        System.debug('paymentMilestoneList: '+paymentMilestoneList);
        if(paymentMilestoneList != null){
            update paymentMilestoneList;
        }
       
      
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