public class Ex_GenerateQuotation {
    
    @AuraEnabled(Cacheable = true)
    public static Opportunity__c getOppDetails(Id oppId) {
        Opportunity__c opp = Ex_InventoryPriceManagementServices.getOpportunityInfo(oppId);
        system.debug('opp: ' +opp);
        return opp;
    }
    
    @AuraEnabled
    public static Unit__c getUnitDetails(Id uId) {
        Unit__c u = Ex_InventoryPriceManagementServices.getUnitInfo(uId);
        system.debug('u: '+u);
        return u;
    }
    
    @AuraEnabled
    public static List<Payment_Scheme__c> getPaymentSchemeDetails(Id tId) {
        List<Payment_Scheme__c> schemeList = Ex_InventoryPriceManagementServices.getPaymentSchemeInfo(tId);
        system.debug('schemeList: '+schemeList);
        return schemeList;
    }
    
    @AuraEnabled(Cacheable = false )
    public static List<Ex_InventoryPriceManagementServices.CarParkWrapper> getCarParkDetails(Id pId, Id tId) {
        List<Ex_InventoryPriceManagementServices.CarParkWrapper> carParkList = new List<Ex_InventoryPriceManagementServices.CarParkWrapper>();
        carParkList = Ex_InventoryPriceManagementServices.getCarParkInfo(pId, tId);
        system.debug('carParkList: '+carParkList);
        return carParkList;
    }
    
    @AuraEnabled(Cacheable = false )
    public static Map<String, Pricing_List__c> getPriceListMapDetails(Id uId) {
        Map<String, Pricing_List__c> priceListMap = Ex_InventoryPriceManagementServices.getPriceListMap(uId);
        system.debug('priceListMap: '+priceListMap);
        return priceListMap;
    }
    
    @AuraEnabled(Cacheable = false )
    public static Map<String, List<String>> getPriceListGroupMapDetails(Id uId) {
        Map<String, List<String>> priceListGroupMap = Ex_InventoryPriceManagementServices.getPriceListGroupMap(uId);
        system.debug('priceListGroupMap: '+priceListGroupMap);
        return priceListGroupMap;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Project__c> getProjectList(Id pId) {
        try {
            List<Project__c> pList = [SELECT Id, Name, Discount_Maintain_At__c, Car_Park_Maintain_At__c FROM Project__c Where Id =: pId];
            System.debug('Project List .: ' + pList);
            if (!pList.isEmpty()) {
                return pList;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
    
    
    @AuraEnabled(Cacheable= false)
    public static  Map<String, List<Discount__c>>  getDiscountGroupMapDetails(Id pId, Id tId) {
        Map<String, List<Discount__c>> discountGroupMap = new Map<String, List<Discount__c>>();
        List<Discount__c> discountList = new List<Discount__c>();
        List<Project__c> plist = new List<Project__c>();
        plist = getProjectList(pId);
        if(plist != null && !plist.isEmpty()){
            if(plist[0].Discount_Maintain_At__c != null && plist[0].Discount_Maintain_At__c.equalsIgnoreCase('Tower')) {
                discountList = Ex_InventoryPriceManagementServices.getTowerLevelDiscountInfo(pId, tId);
            }else if(plist[0].Discount_Maintain_At__c != null && plist[0].Discount_Maintain_At__c.equalsIgnoreCase('Project')) {
                discountList = Ex_InventoryPriceManagementServices.getProjectLevelDiscountInfo(pId);
            }
        }
        
        System.debug('discountList: '+discountList);
        /*if(System.Label.Discount_Maintain_At.equalsIgnoreCase('Tower')) {
discountList = Ex_InventoryPriceManagementServices.getTowerLevelDiscountInfo(pId, tId);
} else if(System.Label.Discount_Maintain_At.equalsIgnoreCase('Project')) {
discountList = Ex_InventoryPriceManagementServices.getProjectLevelDiscountInfo(pId);
}*/
        
        if(discountList != null) {
            for(Discount__c d: discountList) {
                if(discountGroupMap.containsKey(d.Grouping__c)) {
                    discountGroupMap.get(d.grouping__c).add(d);
                } else {
                    List<Discount__c> dTempList = new List<Discount__c>();
                    dTempList.add(d);
                    discountGroupMap.put(d.Grouping__c, dTempList);
                }
            }
        }
        system.debug('discountGroupMap: '+discountGroupMap);
        return discountGroupMap;
    }
    
    @AuraEnabled
    public static Map<String, Decimal> getAllPriceMapDetails(Id uId, Map<String, List<String>> priceListGroupMap, Map<String, Pricing_List__c> priceListMap, Decimal carParkAmount, Decimal discountAmount, Decimal premiumPercentage) {
        Map<String, Decimal> allPriceInfoMap = Ex_InventoryPriceManagementServices.getAllPriceInfo(uId, priceListGroupMap, priceListMap, carParkAmount, discountAmount);
        system.debug('allPriceInfoMap: '+allPriceInfoMap);
        return allPriceInfoMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getAllPriceInfoFormattedMap(Map<String, Decimal> allPriceInfoMap) {
        Map<String, String> allPriceInfoFormattedMap = new Map<String, String>();
        if(allPriceInfoMap != null && !allPriceInfoMap.isEmpty()) {
            for(String ch: allPriceInfoMap.keySet()) {
                allPriceInfoFormattedMap.put(ch, Ex_InventoryPriceManagementServices.currencyFormat(allPriceInfoMap.get(ch)));
            }
        }
        return allPriceInfoFormattedMap;
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(String objectName, String picklistField) {
        List<String> values = new List<String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(picklistField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            values.add(pickListVal.getValue());
        }
        return values;
    }
    
    @AuraEnabled
    public static List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getPaymentScheduleDetails(Id uId, Id selectedScheme, Map<String, Decimal> allPriceInfoMap, Map<String, Pricing_List__c> priceListMap) {
        System.debug('priceListMap: '+priceListMap);
        System.debug('allPriceInfoMap: '+allPriceInfoMap);
        System.debug('uId: '+uId);
        System.debug('selectedScheme: '+selectedScheme);
        
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_InventoryPriceManagementServices.getPaymentSummaryInfo(uId, selectedScheme, allPriceInfoMap, priceListMap);
        return paymentMilestoneWrapperList;
    }
    
    @AuraEnabled
    public static List<String> validateUpdatedPaymentScheduleDetails(Integer agSeqNumber, Map<String, Decimal> allPriceInfoMap, List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<String> validationErrorList = Ex_InventoryPriceManagementServices.validateUpdatedPaymentSchedule(agSeqNumber, allPriceInfoMap, updatedPaymentMilestoneWrapperList);
        system.debug('validationErrorList: '+validationErrorList);
        return validationErrorList;
    }
    
    @AuraEnabled
    public static List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getUpdatedPaymentScheduleDetails(Unit__c u, Integer agSeqNumber, Map<String, Pricing_List__c> priceListMap, Map<String, Decimal> allPriceInfoMap, List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList = Ex_InventoryPriceManagementServices.getUpdatedPaymentSchedule(u, agSeqNumber, priceListMap, allPriceInfoMap, updatedPaymentMilestoneWrapperList);
        system.debug('paymentMilestoneWrapperList: '+paymentMilestoneWrapperList);
        return paymentMilestoneWrapperList;
    }
    
    @AuraEnabled
    public static List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> getModifiedPaymentScheduleDetails(String actionType, Integer rowIndex, List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList, Unit__c u, Integer agSeqNumber) {
        List<Construction_Stage__c> cStageList = Ex_InventoryPriceManagementServices.getConsturctionStageList(u.Project__c, u.Tower__c);
        
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
                
                Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper pmw = new Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper(psm, pm, cStageList, '', 0, 0, '', 0, '', 0, '', false, true, false);
                paymentMilestoneWrapperList.add(rowIndex+1, pmw);
            } else if(actionType.endsWithIgnoreCase('Remove')) {
                paymentMilestoneWrapperList.remove(rowIndex);
            }
        }
        system.debug('Size: '+paymentMilestoneWrapperList.size());
        return paymentMilestoneWrapperList;
    }
    
    @AuraEnabled
    public static Map<String, Decimal> getCalculatedNPVDetails(Boolean isPaymentScheduleUpdated, List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList, Unit__c u) {
        Map<String, Decimal> allNPVPriceMap = new Map<String, Decimal>();
        
        if(!paymentMilestoneWrapperList.isEmpty() && paymentMilestoneWrapperList != null) {
            paymentMilestoneWrapperList.remove(paymentMilestoneWrapperList.size() -1);
            if(!isPaymentScheduleUpdated) {
                allNPVPriceMap.put('Original NPV', Ex_InventoryPriceManagementServices.calculateNPV(paymentMilestoneWrapperList, u.Tower__r.Project__c));
                allNPVPriceMap.put('Original NPV PSF', (Ex_InventoryPriceManagementServices.calculateNPV(paymentMilestoneWrapperList, u.Tower__r.Project__c) / u.Saleable_Area__c));
            } else {
                allNPVPriceMap.put('Modified NPV', Ex_InventoryPriceManagementServices.calculateNPV(paymentMilestoneWrapperList, u.Tower__r.Project__c));
                allNPVPriceMap.put('Modified NPV PSF', (Ex_InventoryPriceManagementServices.calculateNPV(paymentMilestoneWrapperList, u.Tower__r.Project__c) / u.Saleable_Area__c));
            }
        }
        return allNPVPriceMap;
    }
    
   
    
    @AuraEnabled
    public static Id saveQuotationDetails(Unit__c u, Id oppId, Id selectedSchemeId, Map<String, List<String>> priceListGroupMap,Map<String, Pricing_List__c> priceListMap, Map<String, Decimal> allPriceOriginalInfoMap, Map<String, Decimal> allPriceInfoMap, List<Discount__c> appliedDiscountList, List<Ex_InventoryPriceManagementServices.CarParkWrapper> carParkList, List<Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper> paymentMilestoneWrapperList) {
        string level1Approver = '';
        string siteHeadApprover = '';
        string managementApprover = '';
        Decimal modifiedBaseRate = 0;
        Decimal modifiedstampduty = 0;
        List<Team__c> tList = new List<Team__c>();
        List<Team_Member__c> siteHeadTmList = new List<Team_Member__c>();
        List<Team_Member__c> managementTmList = new List<Team_Member__c>();
        try {
            
            
            Quotation__c q = new Quotation__c();
            q.Unit__c = u.Id;
            q.Project__c = u.Tower__r.Project__c;
            if(u.Tower__r.Project__r.CRM_Head__c != null){
                q.CRM_Head__c = u.Tower__r.Project__r.CRM_Head__c;
            }
            q.Tower__c = u.Tower__c;
            q.Opportunity__c = oppId;
            q.Payment_Scheme__c = selectedSchemeId;
            
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
                                if(priceListMap.get('Basic Charge').Charge_Type__c.equalsIgnoreCase('PSF')) {
                                    if(priceListMap.get('Basic Charge').Calculation_Area_Type__c.equalsIgnoreCase('Carpet Area')) {
                                        q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Total_carpet_Sq_Ft__c).setscale(2, RoundingMode.HALF_UP);
                                        system.debug('Basic Charge:'+allPriceOriginalInfoMap.get('Basic Charge'));
                                        q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Total_carpet_Sq_Ft__c).setscale(0, RoundingMode.HALF_UP);
                                        q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                                    } else {
                                        q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                        q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(0, RoundingMode.HALF_UP);
                                        q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                                    }
                                } else {
                                    q.Original_Base_Rate__c = (allPriceOriginalInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                    q.Modified_Base_Rate__c = (allPriceInfoMap.get('Basic Charge') / u.Saleable_Area__c).setscale(0, RoundingMode.HALF_UP);
                                    q.Basic_Charge_Amount__c = allPriceInfoMap.get('Basic Charge');
                                }
                            }
                        }
                    }
                }
            }
            
            if(allPriceInfoMap.containsKey('Total Discount Price')) {
                q.Total_Discount__c = allPriceInfoMap.get('Total Discount Price');
            }
            
            if(appliedDiscountList != null && !appliedDiscountList.isEmpty()) {
                for(Discount__c d : appliedDiscountList) {
                    if(d.Applied__c) {
                        if(d.Discount_Category__c.equalsIgnoreCase('Discount')) {
                            if(d.Category__c.equalsIgnoreCase('Approved')) {
                                if(q.Total_Approved_Discount__c == null)
                                    q.Total_Approved_Discount__c = 0;
                                q.Total_Approved_Discount__c += d.Total__c;
                            } else if(d.Category__c.equalsIgnoreCase('Unapproved')) {
                                if(q.Total_Unapproved_Discount__c == null)
                                    q.Total_Unapproved_Discount__c = 0;
                                q.Total_Unapproved_Discount__c += d.Total__c;
                            }
                        } else if(d.Discount_Category__c.equalsIgnoreCase('Credit Note')) {
                            if(q.Total_Credit_Note_Amount__c == null)
                                q.Total_Credit_Note_Amount__c = 0;
                            q.Total_Credit_Note_Amount__c += d.Total__c;
                        }
                    }
                }
            }
            
            if(carParkList != null && !carParkList.isEmpty()) {
                for(Ex_InventoryPriceManagementServices.CarParkWrapper cp: carParkList) {
                    if(cp.carParkRequiredCount > 0) {
                        if(q.Car_Park_Required_Count__c == null)
                            q.Car_Park_Required_Count__c = 0;
                        q.Car_Park_Required_Count__c += cp.carParkRequiredCount;
                        
                    }
                    if(cp.carParkAmount > 0){
                        if(q.Car_Park_Amount__c == null)
                            q.Car_Park_Amount__c = 0;
                        q.Car_Park_Amount__c += cp.carParkAmount * cp.carParkRequiredCount;
                    }
                }
            }
            
            Id qId = null;
            Database.saveResult sr = Database.insert(q);
            if(sr.isSuccess()) {
                qId = sr.getId();
                List<Charge_Details__c> chargeDetailsList = new List<Charge_Details__c>();
                List<Discount_Applied__c> discountAppliedList = new List<Discount_Applied__c>();
                List<Car_Park_Required__c> carParkReqList = new List<Car_Park_Required__c>();
                List<Payment_Milestone__c> paymentMilestoneList = new List<Payment_Milestone__c>();
                
                if(priceListGroupMap != null && !priceListGroupMap.isEmpty()) {
                    for(String bucket: priceListGroupMap.keySet()) {
                        for(String priceName: priceListGroupMap.get(bucket)) {
                            System.debug('priceName: '+priceName);
                            Decimal chargeAmount = allPriceInfoMap.get(priceName);
                            if(chargeAmount > 0) {
                                Charge_Details__c chDetail = new Charge_Details__c();
                                chDetail.Name = priceName;
                                chDetail.Charge_Bucket__c = bucket;
                                chDetail.Charge_Amount__c = allPriceInfoMap.get(priceName);
                                chDetail.Charge_SGST__c = allPriceInfoMap.get(priceName+' SGST');
                                chDetail.Charge_CGST__c = allPriceInfoMap.get(priceName+' CGST');
                                chDetail.Charge_Total_Tax__c = allPriceInfoMap.get(priceName+' TAX');
                                
                                
                                if(priceListMap != null && !priceListMap.isEmpty()) {
                                    if(priceListMap.containsKey(priceName)) {
                                        if(priceListMap.get(priceName).Charge_Type__c.equalsIgnoreCase('PSF')) {
                                            if(priceListMap.get(priceName).Calculation_Area_Type__c.equalsIgnoreCase('Carpet Area')) {
                                                chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Total_carpet_Sq_Ft__c).setscale(2, RoundingMode.HALF_UP);
                                                chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                                chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                                chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                                chDetail.GST__c = priceListMap.get(priceName).GST__c;
                                            } else {
                                                chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                                chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                                chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                                chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                                chDetail.GST__c = priceListMap.get(priceName).GST__c;
                                            }
                                        } else {
                                            chDetail.Charge_Rate__c = (allPriceInfoMap.get(priceName) / u.Saleable_Area__c).setscale(2, RoundingMode.HALF_UP);
                                            chDetail.Charge_Type__c = priceListMap.get(priceName).Charge_Type__c;
                                            chDetail.Charge_Percentage__c = priceListMap.get(priceName).Charge_Percentage__c;
                                            chDetail.Calculation_Area_Type__c = priceListMap.get(priceName).Calculation_Area_Type__c;
                                            chDetail.GST__c = priceListMap.get(priceName).GST__c;
                                            
                                        }
                                    }
                                }                            
                                chDetail.Quotation__c = qId;
                                chargeDetailsList.add(chDetail);
                            }
                        }
                    }
                }
                
                if(!chargeDetailsList.isEmpty() && chargeDetailsList != null){
                    for (Charge_Details__c chDetail : chargeDetailsList) {
                        if (chDetail.Charge_Bucket__c != null && chDetail.Charge_Bucket__c.equalsIgnoreCase('Agreement Value')) {
                            system.debug('Inside chDetail:: ');
                            modifiedBaseRate += chDetail.Charge_Rate__c != null ? chDetail.Charge_Rate__c : 0;
                        }
                    }
                }
                
                Quotation__c quo = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId FROM Quotation__c WHERE Id = :qId];
                System.debug('Quotation quo : '+ quo);
                
                Id oppOwnerId = quo.Opportunity__r.OwnerId;
                system.debug('oppOwnerId is::'+oppOwnerId);
                
                if(string.isNotBlank(oppOwnerId) && oppOwnerId != null){
                    List<User> uList = [Select Id,ManagerId from User Where Id=:oppOwnerId];
                    system.debug('uList is::'+uList);
                    level1Approver = uList[0].ManagerId;
                    System.debug(':: Manager Id ->' + uList[0].ManagerId);
                }
                
                
                
                tList = [Select Id,Name,Team_Type__c from Team__c Where Team_Type__c=:'Quotation Approval Team'];
                System.debug('tList is::'+tList);
                
                if(!tList.isEmpty() && tList != null){
                    siteHeadTmList = [Select Id,Team__c, User__c, Position__c,User_Active_Status__c From Team_Member__c 
                                      WHERE Team__c=:tList[0].Id AND Position__c=:'Site Head Approver' AND User_Active_Status__c = True];
                    system.debug('siteHeadTmList is::'+siteHeadTmList);
                    
                    managementTmList = [Select Id,Team__c,User__c,Position__c,User_Active_Status__c From Team_Member__c 
                                        WHERE Team__c=:tList[0].Id AND Position__c=:'Management Approver' AND User_Active_Status__c = True];
                    system.debug('managementTmList is::'+managementTmList);
                }
                if(!siteHeadTmList.isEmpty() && siteHeadTmList != null){
                    siteHeadApprover = siteHeadTmList[0].User__c;
                }
                if(!managementTmList.isEmpty() && managementTmList != null){
                    managementApprover = managementTmList[0].User__c;
                }
                System.debug('Modified_Base_Rate__c: '+q.Modified_Base_Rate__c);
                System.debug('level1Approver: '+level1Approver);
                if(u.SM_Threshold__c != null && q.Modified_Base_Rate__c != null && u.TL_Threshold__c != null){
                    //if(u.SM_Threshold__c < q.Modified_Base_Rate__c && q.Modified_Base_Rate__c < u.TL_Threshold__c) {
                    if (q.Modified_Base_Rate__c >= u.TL_Threshold__c && q.Modified_Base_Rate__c < u.SM_Threshold__c) {
                        if(String.isNotBlank(level1Approver) && level1Approver != null){
                            q.Level_1_Approver__c = level1Approver; 
                            q.Level_1_Approval_Status__c = 'Pending for Approval';
                            q.Quotation_Status__c = 'Pending For Approval';
                            
                        }   
                    }
                    if(u.TL_Threshold__c != null && q.Modified_Base_Rate__c != null && u.Site_Head_Threshold__c != null){
                        //if(u.TL_Threshold__c < q.Modified_Base_Rate__c && q.Modified_Base_Rate__c < u.Site_Head_Threshold__c) {
                        if (q.Modified_Base_Rate__c >= u.Site_Head_Threshold__c && q.Modified_Base_Rate__c < u.TL_Threshold__c) {
                            if(String.isNotBlank(level1Approver) && level1Approver != null){
                                q.Level_1_Approver__c = level1Approver; 
                                q.Level_1_Approval_Status__c = 'Pending for Approval';
                            }
                            if(String.isNotBlank(siteHeadApprover) && siteHeadApprover != null){
                                q.Level_2_Approver__c = siteHeadApprover;   
                                q.Level_2_Approval_Status__c = 'Pending for Approval';
                                q.Quotation_Status__c = 'Pending For Approval';
                            }
                        }
                    }
                    if(u.Site_Head_Threshold__c != null && q.Modified_Base_Rate__c != null && u.Management_Threshold__c != null){
                        if (q.Modified_Base_Rate__c >= u.Management_Threshold__c && q.Modified_Base_Rate__c < u.Site_Head_Threshold__c) {
                            if(String.isNotBlank(level1Approver) && level1Approver != null){
                                q.Level_1_Approver__c = level1Approver; 
                                q.Level_1_Approval_Status__c = 'Pending for Approval';
                            }
                            if(String.isNotBlank(siteHeadApprover) && siteHeadApprover != null){
                                q.Level_2_Approver__c = siteHeadApprover;   
                                q.Level_2_Approval_Status__c = 'Pending for Approval';
                            }
                            if(String.isNotBlank(managementApprover) && managementApprover != null){
                                q.Level_3_Approver__c = managementApprover;   
                                q.Level_3_Approval_Status__c = 'Pending for Approval';
                                q.Quotation_Status__c = 'Pending For Approval';
                            }     
                        }
                    }
                    
                    if(q.Level_1_Approver__c == null && q.Level_2_Approver__c == null && q.Level_3_Approver__c == null){
                        q.Quotation_Status__c = 'Approved';
                    } 
                    
                    if(q.Modified_Base_Rate__c != null && u.Management_Threshold__c != null){
                        if (q.Modified_Base_Rate__c < u.Management_Threshold__c) {
                            q.Quotation_Status__c = 'Invalid';
                        }   
                    }
                }
                
                update q;
                system.debug('Modified_Base_Rate__c ' +q.Modified_Base_Rate__c);
                system.debug('Approver quotation approval:'+q);
                system.debug('Approval status : ' + q.Quotation_Status__c);
                system.debug('L1 Approval status : ' + q.Level_1_Approval_Status__c);
                system.debug('L2 Approval status : ' + q.Level_2_Approval_Status__c);
                system.debug('L3 Approval status : ' + q.Level_3_Approval_Status__c);
                
                
                
                if(appliedDiscountList != null && !appliedDiscountList.isEmpty()) {
                    for(Discount__c d : appliedDiscountList) {
                        if(d.Applied__c) {
                            Discount_Applied__c da = new Discount_Applied__c();
                            da.Quotation__c = qId;
                            da.Amount__c = d.Amount__c;
                            da.Percentage_of_AV__c = d.Percentage_of_AV__c;
                            da.PSF_Amount__c = d.PSF_Amount__c;
                            da.Discount_Type__c = d.Discount_Type__c;
                            da.Category__c = d.Category__c;
                            da.Discount_Category__c = d.Discount_Category__c;
                            da.Description__c = d.Description__c;
                            da.Discount_Reason__c = d.Discount_Reason__c;
                            da.Total__c = d.Total__c;
                            da.Discount__c = d.Id;
                            discountAppliedList.add(da);
                        }
                    }
                }
                
                if(carParkList != null && !carParkList.isEmpty()) {
                    for(Ex_InventoryPriceManagementServices.CarParkWrapper cp: carParkList) {
                        if(cp.carParkRequiredCount > 0) {
                            Car_Park_Required__c cpr = new Car_Park_Required__c();
                            cpr.Quotation__c = qId;
                            cpr.Car_Park_Type__c = cp.carParkType;
                            cpr.Car_Park_Count__c = cp.carParkRequiredCount;
                            cpr.Car_Park_Amount__c = cp.carParkAmount * cp.carParkRequiredCount;
                            carParkReqList.add(cpr);
                        }
                    }
                }
                
                if(paymentMilestoneWrapperList != null && !paymentMilestoneWrapperList.isEmpty()) {
                    Integer i = 1;
                    for(Ex_InventoryPriceManagementServices.PaymentMilestoneWrapper pmw: paymentMilestoneWrapperList) {
                        if(pmw.pm != null) {
                            pmw.pm.Sequence_No__c = i;
                            pmw.pm.Quotation__c = qId;
                            paymentMilestoneList.add(pmw.pm);
                            i++;
                        }
                    }
                }
                
                if(!chargeDetailsList.isEmpty() && chargeDetailsList != null) {
                    insert chargeDetailsList;
                }
                if(!discountAppliedList.isEmpty() && discountAppliedList != null) {
                    insert discountAppliedList;
                }
                if(!carParkReqList.isEmpty() && carParkReqList != null) {
                    insert carParkReqList;
                }
                if(!paymentMilestoneList.isEmpty() && paymentMilestoneList != null) {
                    insert paymentMilestoneList;
                }
                
                return qId;
            } else {
                for(Database.Error err : sr.getErrors()) {
                    system.debug('Error: '+err);
                }
                return null;
            }
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            return null;
        }
    }
    
}