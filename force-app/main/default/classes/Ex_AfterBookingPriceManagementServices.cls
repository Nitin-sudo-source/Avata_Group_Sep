public class Ex_AfterBookingPriceManagementServices {
    
    public static Unit__c getUnitInfo(Id uId) {
        List<Unit__c> unitList = new List<Unit__c>();
        String[] types = new String[]{'Unit__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ', Tower__r.Project__c, Tower__r.Project__r.Name, Tower__r.Name,Tower__r.Project__r.Threshold_Amount__c, Tower__r.Project__r.Threshold_Percentage__c, Booking__r.Quotation__c from Unit__c Where Id = \''+uId+'\''; 
        system.debug(soqlQuery);
        unitList = Database.query(soqlQuery);
        if (unitList.size() > 0) {
            return unitList[0];
        } else {
            return null;
        }
    }
    
    public static Quotation__c getQuotationInfo(Id uId) {
        List<Quotation__c> qList = new List<Quotation__c>();
        String[] types = new String[]{'Quotation__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ', Tower__r.Project__c, Tower__r.Project__r.Name, Tower__r.Name,Tower__r.Project__r.Threshold_Amount__c, Tower__r.Project__r.Threshold_Percentage__c, Booking__r.Quotation__c, Booking__r.Unit__c, Booking__r.Tower__c from Quotation__c Where Id = \''+uId+'\''; 
        system.debug(soqlQuery);
        qList = Database.query(soqlQuery);
        if (qList.size() > 0) {
            return qList[0];
        } else {
            return null;
        }
    }
    
    public static Map<String, Charge_Details__c> getPriceListMap(Id uId) {
        System.debug('u.Booking__r.Quotation__c: '+ uId);
        if(uId != null) {
            Map<String, Charge_Details__c> priceListMap = new Map<String, Charge_Details__c>();
            List<Charge_Details__c> priceList = getPriceListInfo(uId);
            System.debug('priceList: '+priceList);
            
            if(priceList != null) {
                for(Charge_Details__c pl: priceList) {
                    System.debug('pl: '+pl);
                    priceListMap.put(pl.Name, pl);
                }
            }
            return priceListMap;
        } else {
            return null;
        }
    }
    
    public static Map<String, List<String>> getPriceListGroupMap(Id uId) {
        if(uId != null) {
            Map<String, List<String>> priceListGroupMap = new Map<String, List<String>>();
            List<Charge_Details__c> priceList = getPriceListInfo(uId);
            
            if(priceList != null) {
                for(Charge_Details__c pl: priceList) {
                    if(priceListGroupMap.containsKey(pl.Charge_Bucket__c)) {
                        priceListGroupMap.get(pl.Charge_Bucket__c).add(pl.Name);
                    } else {
                        List<String> newList = new List<String>();
                        newList.add(pl.Name);
                        priceListGroupMap.put(pl.Charge_Bucket__c, newList);
                    }
                }
                /* if(priceListGroupMap.containsKey('Agreement Value') ){
priceListGroupMap.get('Agreement Value').add('Parking Charges');
}*/
            }
            System.debug('priceListGroupMapApex: '+priceListGroupMap);
            return priceListGroupMap;
        } else {
            return null;
        }
    }
    
    public static Map<String, Decimal> getAllPriceInfo(Id uId, Decimal updatedAV, Decimal updatedSDR, Decimal updatedGST, Map<String, List<String>> priceListGroupMap, Map<String, Charge_Details__c> priceListMap, Decimal carParkPrice, Decimal discountPrice) {
        Decimal avAmount = 0;
        Decimal avWithoutCarPark = 0;
        Quotation__c q = [Select Id, Unit__c, Tower__r.Project__r.Threshold_Amount__c, Booking__r.Unit__c, Booking__r.Agreement_Value__c from Quotation__c where Id =: uId];
        System.debug('q: '+q);
        Unit__c u = getUnitInfo(q.Booking__r.Unit__c);
        System.debug('u:'+u);
        if(q.Booking__r.Agreement_Value__c != null && updatedAV != null && updatedAV > 0){
            discountPrice = updatedAV - q.Booking__r.Agreement_Value__c;
        }else{
            discountPrice = 0;
        }
        
        
        System.debug('discountPrice: '+discountPrice);
        System.debug('priceListMap: '+priceListMap);
        System.debug('priceListGroupMap: '+priceListGroupMap);
        
        if(uId != null) {
            Map<String, Decimal> allPriceInfoMap = new Map<String, Decimal>();
            if(priceListGroupMap != null){
                for(String priceGroup: priceListGroupMap.keySet()) {
                    if(!priceGroup.equalsIgnoreCase('Statutory Charges')) {
                        for(String priceList: priceListGroupMap.get(priceGroup)) {
                           /* if(updatedGST != 0 && updatedGST != null){
                                priceListMap.get('Basic Charge').GST__c = updatedGST;
                            }*/
                            Decimal amount = 0;
                            Decimal sgst = 0;
                            Decimal cgst = 0;
                            
                            if(priceListMap.containsKey(priceList)) {
                                if(priceListMap.get(priceList).Name.equalsIgnoreCase('Parking Charges')) {
                                    avAmount += carParkPrice;
                                    amount = carParkPrice;
                                    sgst = (((carParkPrice / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                    cgst = (((carParkPrice / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                } else {
                                    if(priceListMap.get(priceList).Charge_Type__c != null && priceListMap.get(priceList).Charge_Type__c.equalsIgnoreCase('Percentage')) {
                                        if(allPriceInfoMap.containsKey('Agreement Value')) {
                                            amount = ((allPriceInfoMap.get('Agreement Value') * priceListMap.get(priceList).Charge_Percentage__c) / 100).setscale(0,RoundingMode.HALF_UP);
                                            sgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                            cgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                        }   
                                    }else{
                                        amount = (priceListMap.get(priceList).Charge_Amount__c).setscale(0,RoundingMode.HALF_UP);
                                        sgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                        cgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                        
                                    }
                                }
                                allPriceInfoMap.put(priceList, amount);
                                allPriceInfoMap.put(priceList+' SGST', sgst);
                                allPriceInfoMap.put(priceList+' CGST', cgst);
                                allPriceInfoMap.put(priceList+' TAX', (sgst + cgst));
                                
                                //Grouping Pricing Information
                                if(allPriceInfoMap.containsKey(priceListMap.get(priceList).Charge_Bucket__c)) {
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c) + amount);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SGST') + sgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' CGST') + cgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' TAX') + sgst + cgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SIZE') + 1);
                                } else {
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, amount);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', sgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', cgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', sgst + cgst);
                                    allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', 1);
                                }
                            }
                        }
                    }
                }
            }
            
            
            if(allPriceInfoMap.containsKey('Agreement Value')) {
               /* if(updatedGST != 0 && updatedGST != null){
                    priceListMap.get('Basic Charge').GST__c = updatedGST;
                }*/
                // if(discountPrice != 0 && discountPrice != null ) {
                //Discount Price will be deducted from Basic Charge also recalculate taxes
                allPriceInfoMap.put('Basic Charge', allPriceInfoMap.get('Basic Charge') + discountPrice);
                Decimal sgstBasic =  (((allPriceInfoMap.get('Basic Charge') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                Decimal cgstBasic =  (((allPriceInfoMap.get('Basic Charge') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                allPriceInfoMap.put('Basic Charge SGST', sgstBasic);
                allPriceInfoMap.put('Basic Charge CGST', cgstBasic);
                allPriceInfoMap.put('Basic Charge TAX', sgstBasic + cgstBasic);
                system.debug('allPriceInfoMap'+allPriceInfoMap);
                
                //Discount Price will be deducted from Agreement Value Group also recalculate taxes
                allPriceInfoMap.put('Agreement Value', allPriceInfoMap.get('Agreement Value') + discountPrice);
                Decimal sgstBasicDiff = (((allPriceInfoMap.get('Agreement Value') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                Decimal cgstBasicDiff = (((allPriceInfoMap.get('Agreement Value') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                //Decimal sgstBasicDiff = ((priceListMap.get('Basic Charge').GST_Amount__c / 2) - sgstBasic).setscale(0,RoundingMode.HALF_UP);
                //Decimal cgstBasicDiff = ((priceListMap.get('Basic Charge').GST_Amount__c / 2) - cgstBasic).setscale(0,RoundingMode.HALF_UP);
                allPriceInfoMap.put('Agreement Value SGST', sgstBasicDiff);
                allPriceInfoMap.put('Agreement Value CGST', cgstBasicDiff);
                allPriceInfoMap.put('Agreement Value TAX', sgstBasicDiff + cgstBasicDiff);
                //}
                allPriceInfoMap.put('Total Discount Price', discountPrice);
                
                if(allPriceInfoMap.get('Agreement Value') <= u.Tower__r.Project__r.Threshold_Amount__c) {
                    //Remove this value for update latest data
                    allPriceInfoMap.remove('Agreement Value');
                    Decimal amount = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;
                    
                    for(String priceList: priceListGroupMap.get('Agreement Value')) {
                        amount = allPriceInfoMap.get(priceList);
                        sgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                        cgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                        
                        allPriceInfoMap.put(priceList, amount);
                        allPriceInfoMap.put(priceList+' SGST', sgst);
                        allPriceInfoMap.put(priceList+' CGST', cgst);
                        allPriceInfoMap.put(priceList+' TAX', (sgst + cgst));
                        
                        //Grouping Pricing Information
                        if(allPriceInfoMap.containsKey(priceListMap.get(priceList).Charge_Bucket__c)) {
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c) + amount);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SGST') + sgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' CGST') + cgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' TAX') + sgst + cgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SIZE') + 1);
                        } else {
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, amount);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', sgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', cgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', sgst + cgst);
                            allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', 1);
                        }
                    }
                }
            }
            
            if(priceListGroupMap.containsKey('Statutory Charges')) {
                
                
                Decimal roundednum = 0;
                Decimal amount = 0;
                Decimal sgst = 0;
                Decimal cgst = 0;
                
                for(String priceList: priceListGroupMap.get('Statutory Charges')) {
                   /* if(updatedGST != 0 && updatedGST != null){
                        priceListMap.get(priceList).GST__c = updatedGST;
                    }*/
                    if(priceListMap.get(priceList).Charge_Type__c != null && priceListMap.get(priceList).Charge_Type__c.equalsIgnoreCase('Percentage')) {
                        if(allPriceInfoMap.containsKey('Agreement Value')) {
                            amount = ((allPriceInfoMap.get('Agreement Value') * priceListMap.get(priceList).Charge_Percentage__c) / 100).setscale(0,RoundingMode.HALF_UP);
                            sgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                            cgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                        }   
                    } else {
                        amount = (priceListMap.get(priceList).Charge_Amount__c).setscale(0,RoundingMode.HALF_UP);
                        sgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                        cgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                    }
                    
                    allPriceInfoMap.put(priceList, amount);
                    allPriceInfoMap.put(priceList+' SGST', sgst);
                    allPriceInfoMap.put(priceList+' CGST', cgst);
                    allPriceInfoMap.put(priceList+' TAX', (sgst + cgst));
                    
                    //Grouping Pricing Information
                    if(allPriceInfoMap.containsKey(priceListMap.get(priceList).Charge_Bucket__c)) {
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c) + amount);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SGST') + sgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' CGST') + cgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' TAX') + sgst + cgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', allPriceInfoMap.get(priceListMap.get(priceList).Charge_Bucket__c+' SIZE') + 1);
                    } else {
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c, amount);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SGST', sgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' CGST', cgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' TAX', sgst + cgst);
                        allPriceInfoMap.put(priceListMap.get(priceList).Charge_Bucket__c+' SIZE', 1);
                    }
                }
            }
            
            
            
            allPriceInfoMap.put('Agreement Value Without Car Park',avWithoutCarPark);
            system.debug('allPriceInfoMap:'+allPriceInfoMap);
            return allPriceInfoMap;
        } else {
            return null;
        }
    }
    
    public static List<Charge_Details__c> getPriceListInfo(Id uId) {
        //Unit__c u = getUnitInfo(uId);
        
        List<Charge_Details__c> priceList = new List<Charge_Details__c>();
        String[] types = new String[]{'Charge_Details__c'};
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
        System.debug('uId: '+uId);
        String soqlQuery = 'Select ' + queryFields  + ' from Charge_Details__c Where Quotation__c = \''+uId +'\' ORDER BY Charge_Bucket__c, Name ASC'; 
        system.debug('chargeDetails:' +soqlQuery);
        priceList = Database.query(soqlQuery);
        if (priceList.size() > 0) {
            return priceList;
        } else {
            return null;
        }
    }
    
    public static List<Payment_Milestone__c> getPaymentMilestoneInfo(Id qId) {
        List<Payment_Milestone__c> psMilestoneList = new List<Payment_Milestone__c>();
        String[] types = new String[]{'Payment_Milestone__c'};
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
        String soqlQuery = 'Select Construction_Stage__r.Name, ' + queryFields  + '  from Payment_Milestone__c Where Quotation__c = \''+qId+'\' ORDER BY Sequence_No__c ASC'; 
        system.debug(soqlQuery);
        psMilestoneList = Database.query(soqlQuery);
        if (psMilestoneList.size() > 0) {
            return psMilestoneList;
        } else {
            return null;
        }
    }
    
    public static List<PaymentMilestoneWrapper> getPaymentSummaryInfo(Id uId, Id QId, Map<String, Decimal> allPriceInfoMap, Map<String, Charge_Details__c> priceListMap) {
        List<PaymentMilestoneWrapper> paymentMilestoneWrapperList = new List<PaymentMilestoneWrapper>();
        List<Payment_Milestone__c> psMilestoneList = getPaymentMilestoneInfo(QId);
        Unit__c u = getUnitInfo(uId);
        System.debug('priceListMap: '+priceListMap);
        System.debug('allPriceInfoMap: '+allPriceInfoMap);
        
        
        if(u != null) {
            List<Construction_Stage__c> cStageList = getConsturctionStageList(u.Project__c, u.Tower__c);
            List<SelectOption> cStageOptionList = new List<SelectOption>();
            if(cStageList != null && !cStageList.isEmpty()) {
                cStageOptionList.add(new SelectOption('', '--None--'));
                for(Construction_Stage__c cs : cStageList) {
                    cStageOptionList.add(new SelectOption(cs.Id, cs.Name));
                }
            }
            Map<Id, Construction_Stage__c> cStageMap = getConstructionStagesMap(u.Project__c, u.Tower__c);
            
            if(psMilestoneList != null) {
                Decimal tokenAmount = 0;
                Decimal grandAmount = 0;
                Decimal grandPercentage = 0;
                Decimal grandSGST = 0;
                Decimal grandCGST = 0;
                Decimal grandTotalTax = 0;
                Decimal grandTotal = 0;
                
                for(Payment_Milestone__c psm: psMilestoneList) {
                    Decimal amount = 0;
                    Decimal percentage = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;
                    Decimal totalTax = 0;
                    Decimal total = 0;
                    Boolean agMilestone = false;
                    
                    Payment_Milestone__c pm = new Payment_Milestone__c();
                    pm.Milestone_Name__c = psm.Milestone_Name__c;
                    pm.Milestone_Type__c = psm.Milestone_Type__c;
                    pm.Number_of_Days__c = psm.Number_of_Days__c;
                    if(psm.Construction_Stage__c !=null)
                        pm.Construction_Stage__c = psm.Construction_Stage__c;
                    pm.Deduct_Token__c = psm.Deduct_Token__c;
                    pm.Sequence_No__c = psm.Sequence_No__c;
                    pm.Id = psm.id;
                   
                    
                    if(String.isNotBlank(psm.Milestone_Type__c) && psm.Milestone_Type__c.equals('Date Linked')) {
                        if(psm.Number_of_Days__c != null) {
                            pm.Due_Date__c = System.today().addDays(Integer.valueOf(psm.Number_of_Days__c));
                        }
                        
                    } else if(String.isNotBlank(psm.Milestone_Type__c) && psm.Milestone_Type__c.equals('Construction Linked')) {
                        Date completionDate = null;
                        Boolean IsMilestoneAchieved = false;
                        Construction_Stage__c cStage = cStageMap.get(psm.Construction_Stage__c);
                        
                        if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c > System.today()) {
                            completionDate = cStage.Actual_Completion_Date__c;
                        } else if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c <= System.today()) {
                            completionDate = system.today().addDays(60);
                            IsMilestoneAchieved = True;
                        } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c > System.today()) {
                            completionDate = cStage.Expected_Completion_Date__c;
                        } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c <= System.today()) {
                            completionDate = system.today();
                        }   
                        if(completionDate == null) {
                            completionDate = system.today().addDays(365);
                        }
                        pm.Due_Date__c = completionDate.addDays(Integer.valueOf(psm.Number_of_Days__c));
                        
                        if(IsMilestoneAchieved) {
                            pm.Milestone_Complete_At_Booking__c = true;
                        } else {
                            pm.Milestone_Complete_At_Booking__c = false;
                        }
                    } else if(String.isNotBlank(psm.Milestone_Type__c) && psm.Milestone_Type__c.equals('Registration Linked')) {
                        //10% of Agreement Value is collected within 30 days.
                        //Hence setting the dates for registration demand as 60th day
                        pm.Due_Date__c = system.today().addDays(60);
                    }
                    
                    for(Integer i = 1; i <= 3; i++) {
                        if(String.isNotBlank((String)psm.get('Charge_Bucket_'+i+'__c'))) { 
                            pm.put('Charge_Bucket_'+i+'__c', psm.get('Charge_Bucket_'+i+'__c'));
                            
                            if(((String)psm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                                //Calculation for agreement value bucket
                                if(pm.get('Charge_Bucket_'+i+'_Percentage__c') != null && psm.get('Charge_Bucket_'+i+'_Percentage__c') != 0) {
                                    amount = (((Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c') * allPriceInfoMap.get('Agreement Value')) / 100).setscale(0,RoundingMode.HALF_UP);
                                    percentage = (Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c');
                                } else {
                                    amount = ((Decimal)psm.get('Charge_Bucket_'+i+'_Amount__c')).setscale(0,RoundingMode.HALF_UP);
                                    percentage = (((Decimal)psm.get('Charge_Bucket_'+i+'_Amount__c') / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                                }
                               /* if(psm.Token_Amount__c != null && psm.Token_Amount__c != 0) {
                                    tokenAmount = psm.Token_Amount__c;
                                }*/
                               /* if(psm.Deduct_Token__c && tokenAmount != 0) {
                                    amount = amount - tokenAmount;
                                    percentage = ((amount / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                                    psm.put('Charge_Bucket_'+i+'__c', 'Amount');
                                }*/
                                if(allPriceInfoMap.get('Agreement Value') < u.Tower__r.Project__r.Threshold_Amount__c) {
                                    sgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                    cgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                } else {
                                    if(priceListMap != null && priceListMap.containsKey('Basic Charge')) {
                                        sgst = (((amount / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                        cgst = (((amount / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                    }
                                }                                
                                agMilestone = true;
                                totalTax = sgst + cgst;
                                total = amount + totalTax;
                                grandAmount += amount;
                                grandPercentage += percentage;
                                grandSGST += sgst;
                                grandCGST += cgst;
                                grandTotalTax += totalTax;
                                grandTotal += total;
                                
                                pm.put('Charge_Bucket_'+i+'_Amount__c', amount);
                                pm.put('Charge_Bucket_'+i+'_Percentage__c', percentage);
                                pm.put('Charge_Bucket_'+i+'_SGST__c', sgst);
                                pm.put('Charge_Bucket_'+i+'_CGST__c', cgst);
                                pm.put('Charge_Bucket_'+i+'_Total_Tax__c', totalTax);
                            }
                            
                            if(((String)psm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Other Charges')) {
                                
                                //Calculation for other than agreement value bucket
                                Decimal amountOther = 0;
                                Decimal sgstOther = 0;
                                Decimal cgstOther = 0;
                                Decimal totalTaxOther = 0;
                                
                                if(allPriceInfoMap != null){
                                    pm.put('Charge_Bucket_'+i+'_Percentage__c', (Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c'));
                                    amountOther = (((Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c') * allPriceInfoMap.get((String)psm.get('Charge_Bucket_'+i+'__c'))) / 100);
                                    pm.put('Charge_Bucket_'+i+'_Amount__c', amountOther);
                                    
                                    if(allPriceInfoMap.get((String)psm.get('Charge_Bucket_'+i+'__c')+' TAX') != null && allPriceInfoMap.get((String)psm.get('Charge_Bucket_'+i+'__c')+' TAX') != 0) {
                                        sgstOther = ((allPriceInfoMap.get((String)psm.get('Charge_Bucket_'+i+'__c')+' TAX') / 100) * (Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c')).setscale(0,RoundingMode.HALF_UP);
                                        cgstOther = ((allPriceInfoMap.get((String)psm.get('Charge_Bucket_'+i+'__c')+' TAX') / 100) * (Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c')).setscale(0,RoundingMode.HALF_UP);
                                    }
                                    totalTaxOther = sgstOther + cgstOther;
                                    pm.put('Charge_Bucket_'+i+'_SGST__c', sgstOther);
                                    pm.put('Charge_Bucket_'+i+'_CGST__c', cgstOther);
                                    pm.put('Charge_Bucket_'+i+'_Total_Tax__c', totalTaxOther);
                                    
                                }
                            }
                        }
                    }
                    if(pm.Milestone_Complete_At_Booking__c) {
                        if(paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.Milestone_Complete_At_Booking__c) {
                            for(Integer i = 1; i <= 5; i++) {
                                if(String.isNotBlank((String)pm.get('Charge_Bucket_'+i+'__c'))) {
                                    
                                    if(((String)pm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                                        pm.put('Charge_Bucket_'+i+'_Amount__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Amount__c') + amount));
                                        pm.put('Charge_Bucket_'+i+'_Percentage__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Percentage__c') + percentage));
                                        pm.put('Charge_Bucket_'+i+'_SGST__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_SGST__c') + sgst));
                                        pm.put('Charge_Bucket_'+i+'_CGST__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_CGST__c') + cgst));
                                        pm.put('Charge_Bucket_'+i+'_Total_Tax__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Total_Tax__c') + totalTax));
                                    } else {
                                        pm.put('Charge_Bucket_'+i+'_Amount__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Amount__c') + (Decimal)pm.get('Charge_Bucket_'+i+'_Amount__c')));
                                        pm.put('Charge_Bucket_'+i+'_Percentage__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Percentage__c') + (Decimal)pm.get('Charge_Bucket_'+i+'_Percentage__c')));
                                        pm.put('Charge_Bucket_'+i+'_SGST__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_SGST__c') + (Decimal)pm.get('Charge_Bucket_'+i+'_SGST__c')));
                                        pm.put('Charge_Bucket_'+i+'_CGST__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_CGST__c') + (Decimal)pm.get('Charge_Bucket_'+i+'_CGST__c')));
                                        pm.put('Charge_Bucket_'+i+'_Total_Tax__c', ((Decimal)paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].pm.get('Charge_Bucket_'+i+'_Total_Tax__c') + (Decimal)pm.get('Charge_Bucket_'+i+'_Total_Tax__c')));
                                    }
                                }
                            }
                            Decimal totalMergePercentage = (paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].percentage + percentage);
                            Decimal totalMergeAmount = (paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].amount + amount);
                            Decimal totalMergeTax = (paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].tax + totalTax);
                            Decimal totalMergeTotal = (paymentMilestoneWrapperList[paymentMilestoneWrapperList.size()-1].total + total); 
                            
                            paymentMilestoneWrapperList.remove(paymentMilestoneWrapperList.size()-1);
                            paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(pm, cStageList, pm.Milestone_Name__c, totalMergePercentage, totalMergeAmount, currencyFormat(totalMergeAmount), totalMergeTax, currencyFormat(totalMergeTax), totalMergeTotal, currencyFormat(totalMergeTotal), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                        } else {
                            paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(pm, cStageList, pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                        }
                    } else {
                        paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(pm, cStageList, pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                    }
                }
                paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(null, null, 'Total', grandPercentage, grandAmount, currencyFormat(grandAmount), grandTotalTax, currencyFormat(grandTotalTax), grandTotal, currencyFormat(grandTotal), true, true, false));
            }
        }
        
        // Update the last and second-to-last row elements in the list
        if (allPriceInfoMap != null & paymentMilestoneWrapperList != null && !paymentMilestoneWrapperList.isEmpty()) {
            // Retrieve the last element in the list
            PaymentMilestoneWrapper lastRowElement = paymentMilestoneWrapperList[paymentMilestoneWrapperList.size() - 1];
            // Retrieve the second-to-last element in the list
            PaymentMilestoneWrapper secondToLastElement = paymentMilestoneWrapperList[paymentMilestoneWrapperList.size() - 2];
            
            // Calculate differences for the last row
            Decimal percentageDiff = 100 - lastRowElement.percentage;
            System.debug('percentage: '+percentageDiff);
            Decimal amountDiffLatest = allPriceInfoMap.get('Agreement Value') - lastRowElement.amount;
            Decimal taxDiffLatest = allPriceInfoMap.get('Agreement Value TAX') - lastRowElement.tax;
            
            // Adjust percentage values dynamically to stay within the range of 0% to 100%
            if (percentageDiff != 0) {
                Decimal newLastRowPercentage = lastRowElement.percentage + percentageDiff;
                System.debug('newLastRowPercentage: '+newLastRowPercentage);
                // Ensure the last row percentage is within the range 0% to 100%
                newLastRowPercentage = Math.min(Math.max(newLastRowPercentage, 0), 100);
                lastRowElement.percentage = newLastRowPercentage;
                lastRowElement.percentageString = String.valueOf(lastRowElement.percentage) + '%';
                
                Decimal newSecondToLastPercentage = secondToLastElement.percentage + percentageDiff;
                // Ensure the second-to-last percentage is within the range 0% to 100%
                newSecondToLastPercentage = Math.min(Math.max(newSecondToLastPercentage, 0), 100);
                secondToLastElement.percentage = newSecondToLastPercentage;
                secondToLastElement.percentageString = String.valueOf(secondToLastElement.percentage) + '%';
                
                for (Integer i = 1; i <= 5; i++) {
                    if (String.isNotBlank((String) secondToLastElement.pm.get('Charge_Bucket_' + i + '__c'))) {
                        if (((String) secondToLastElement.pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
                            secondToLastElement.pm.put('Charge_Bucket_' + i + '_Percentage__c',
                                                       ((Decimal) secondToLastElement.pm.get('Charge_Bucket_' + i + '_Percentage__c') + percentageDiff));
                        }
                    }
                }
                
                System.debug('secondToLastElement.percentage: ' + secondToLastElement.percentage);
            }

            
            // Update the last row element
            if (amountDiffLatest != 0) {
                lastRowElement.amount = lastRowElement.amount + amountDiffLatest;
                lastRowElement.amountString = currencyFormat(lastRowElement.amount);
                system.debug('Grand Total Updated Amount: ' + lastRowElement.amountString);
                
                
                secondToLastElement.amount = secondToLastElement.amount + amountDiffLatest;
                secondToLastElement.amountString = currencyFormat(secondToLastElement.amount);
                system.debug('Last Milestone Updated Amount: ' + secondToLastElement.amountString);
                
                for(Integer i = 1; i <= 5; i++) {
                    if(String.isNotBlank((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c'))) {
                        if(((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                            secondToLastElement.pm.put('Charge_Bucket_'+i+'_Amount__c', ((Decimal)secondToLastElement.pm.get('Charge_Bucket_'+i+'_Amount__c') + amountDiffLatest));
                        }
                    }
                }
            }
            
            if (taxDiffLatest != 0) {
                lastRowElement.tax = lastRowElement.tax + taxDiffLatest;
                lastRowElement.taxString = currencyFormat(lastRowElement.tax);
                system.debug('Grand Total Updated Tax: ' + lastRowElement.taxString);
                
                secondToLastElement.tax = secondToLastElement.tax + taxDiffLatest;
                secondToLastElement.taxString = currencyFormat(secondToLastElement.tax);
                system.debug('Last Milestone Updated Tax: ' + secondToLastElement.taxString);
                
                for(Integer i = 1; i <= 5; i++) {
                    if(String.isNotBlank((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c'))) {
                        if(((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                            secondToLastElement.pm.put('Charge_Bucket_'+i+'_Total_Tax__c', ((Decimal)secondToLastElement.pm.get('Charge_Bucket_'+i+'_Total_Tax__c') + taxDiffLatest));
                        }
                    }
                }
            }
            
            if (lastRowElement.amount != null && lastRowElement.tax != null) {
                lastRowElement.Total = lastRowElement.amount + lastRowElement.tax;
                lastRowElement.totalString = currencyFormat(lastRowElement.Total);
                
                secondToLastElement.Total = secondToLastElement.amount + secondToLastElement.tax;
                secondToLastElement.totalString = currencyFormat(secondToLastElement.Total);
            }
            
            
        }
        system.debug('paymentMilestoneWrapperList: '+paymentMilestoneWrapperList);
        return paymentMilestoneWrapperList;
    }
    
    public static List<String> validateUpdatedPaymentSchedule(Integer agSeqNumber, Map<String, Decimal> allPriceInfoMap, List<PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<String> validationErrorList = new List<String>();
        
        if(!updatedPaymentMilestoneWrapperList.isEmpty() && updatedPaymentMilestoneWrapperList != null) {
            Decimal totalAmount = 0;
            Decimal totalPercentage = 0;
            Integer errorCount = 0;
            
            for(PaymentMilestoneWrapper pmw: updatedPaymentMilestoneWrapperList) {
                if(pmw.agMilestone && pmw.pm != null) {
                    if(((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')).equalsIgnoreCase('Percentage')) {
                        totalAmount += ((((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Percentage__c') * allPriceInfoMap.get('Agreement Value')) / 100)); //.setscale(0,RoundingMode.HALF_UP);
                        totalPercentage += ((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Percentage__c')).setscale(0,RoundingMode.HALF_UP);
                    } else if(((String)pmw.psm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')).equalsIgnoreCase('Amount')) {
                        totalAmount += ((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Amount__c'));
                        totalPercentage +=  ((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Amount__c') / allPriceInfoMap.get('Agreement Value') * 100).setscale(0,RoundingMode.HALF_UP); //.setscale(2,RoundingMode.HALF_UP);
                    }
                    system.debug('totalAmount: '+totalAmount);
                    system.debug('totalPercentage: '+totalPercentage);
                }
            }
            system.debug('Milestone Total Amount: '+totalAmount);
            system.debug('Agreement Value: '+allPriceInfoMap.get('Agreement Value').setscale(0,RoundingMode.HALF_UP));
            
            if(validationErrorList.isEmpty()) {
                if(Math.abs(totalAmount.setscale(0,RoundingMode.HALF_UP) - allPriceInfoMap.get('Agreement Value')).setscale(0,RoundingMode.HALF_UP) > 1) {
                    if(totalAmount > allPriceInfoMap.get('Agreement Value').setscale(0,RoundingMode.HALF_UP)) {
                        errorCount++;
                        validationErrorList.add('Error '+errorCount+': There is an excess of ₹ '+currencyFormat(Math.abs(totalAmount - allPriceInfoMap.get('Agreement Value').setscale(0,RoundingMode.HALF_UP))));
                        errorCount++;
                        validationErrorList.add('Error '+errorCount+': Percentages add up to: '+totalPercentage);
                    } else {
                        errorCount++;
                        validationErrorList.add('Error '+errorCount+': There is an shortfall of ₹ '+currencyFormat(Math.abs(totalAmount - allPriceInfoMap.get('Agreement Value').setscale(0,RoundingMode.HALF_UP))));
                        errorCount++;
                        validationErrorList.add('Error '+errorCount+': Percentages add up to: '+totalPercentage);
                    }
                }
            }
        }
        if(validationErrorList != null){
            return validationErrorList;
        }else if(validationErrorList.isEmpty()){
            return null;
        }else{
            return null;
        }
        
    }
    
    public static List<PaymentMilestoneWrapper> getUpdatedPaymentSchedule(Booking__c u, Integer agSeqNumber, Map<String, Charge_Details__c> priceListMap, Map<String, Decimal> allPriceInfoMap, List<PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<PaymentMilestoneWrapper> paymentMilestoneWrapperList = new List<PaymentMilestoneWrapper>();
        
        if(u != null) {
            Map<Id, Construction_Stage__c> cStageMap = getConstructionStagesMap(u.Project__c, u.Tower__c);
            if(!updatedPaymentMilestoneWrapperList.isEmpty() && updatedPaymentMilestoneWrapperList != null) {
                Integer count = 0;
                Decimal tokenAmount = 0;
                Decimal grandAmount = 0;
                Decimal grandPercentage = 0;
                Decimal grandSGST = 0;
                Decimal grandCGST = 0;
                Decimal grandTotalTax = 0;
                Decimal grandTotal = 0;
                updatedPaymentMilestoneWrapperList.remove(updatedPaymentMilestoneWrapperList.size()-1);
                System.debug('updatedPaymentMilestoneWrapperList: '+updatedPaymentMilestoneWrapperList);
                for(PaymentMilestoneWrapper pmw: updatedPaymentMilestoneWrapperList) {
                    Decimal amount = 0;
                    Decimal percentage = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;
                    Decimal totalTax = 0;
                    Decimal total = 0;
                    Boolean agMilestone = false;
                    System.debug('av:'+allPriceInfoMap.get('Agreement Value'));
                    System.debug('pmw.pm: '+pmw.pm);
                    if(pmw.agMilestone && pmw.pm != null) {
                        if(((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'__c')) != null && ((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'__c')).equalsIgnoreCase('Agreement Value')) {
                            if(((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')) != null && ((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')).equalsIgnoreCase('Percentage') ) {
                                amount = (((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Percentage__c') * allPriceInfoMap.get('Agreement Value')) / 100).setscale(0,RoundingMode.HALF_UP);
                                percentage = ((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Percentage__c')).setscale(2,RoundingMode.HALF_UP);
                            } else {
                                amount = ((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Amount__c')).setscale(0,RoundingMode.HALF_UP);
                                percentage = (((Decimal)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'_Amount__c') / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                            }
                            if(count == 0) {
                                tokenAmount = 0;
                            }
                            if(pmw.psm.Deduct_Token__c && tokenAmount > 0) {
                                amount = amount - tokenAmount;
                                percentage = ((amount / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                            }
                            if(allPriceInfoMap.get('Agreement Value') < u.Tower__r.Project__r.Threshold_Amount__c) {
                                sgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                cgst =  (((amount / 100) * u.Tower__r.Project__r.Threshold_Percentage__c) / 2).setscale(0,RoundingMode.HALF_UP);
                            } else {
                                if(priceListMap != null && priceListMap.containsKey('Basic Charge')) {
                                    sgst = (((amount / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                    cgst = (((amount / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                                }
                            }
                            
                            System.debug('percentage: '+percentage);
                            agMilestone = true;
                            totalTax = sgst + cgst;
                            total = amount + totalTax;
                            grandAmount += amount;
                            grandPercentage += percentage;
                            grandSGST += sgst;
                            grandCGST += cgst;
                            grandTotalTax += totalTax;
                            grandTotal += total;
                            System.debug('grandPercentage: '+grandPercentage);
                            
                            pmw.pm.put('Charge_Bucket_'+agSeqNumber+'_Amount__c', amount);
                            pmw.pm.put('Charge_Bucket_'+agSeqNumber+'_Percentage__c', percentage);
                            pmw.pm.put('Charge_Bucket_'+agSeqNumber+'_SGST__c', sgst);
                            pmw.pm.put('Charge_Bucket_'+agSeqNumber+'_CGST__c', cgst);
                            pmw.pm.put('Charge_Bucket_'+agSeqNumber+'_Total_Tax__c', totalTax);
                            
                            if(String.isNotBlank(pmw.pm.Milestone_Type__c) && pmw.pm.Milestone_Type__c.equals('Date Linked')) {
                                if(pmw.pm.Number_of_Days__c != null) {
                                    pmw.pm.Due_Date__c = System.today().addDays(Integer.valueOf(pmw.pm.Number_of_Days__c));
                                }
                                
                            } else if(String.isNotBlank(pmw.pm.Milestone_Type__c) && pmw.pm.Milestone_Type__c.equals('Construction Linked')) {
                                Date completionDate = null;
                                Boolean IsMilestoneAchieved = false;
                                Construction_Stage__c cStage = cStageMap.get(pmw.pm.Construction_Stage__c);
                                
                                if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c > System.today()) {
                                    completionDate = cStage.Actual_Completion_Date__c;
                                } else if(cStage.Actual_Completion_Date__c != null && cStage.Actual_Completion_Date__c <= System.today()) {
                                    completionDate = system.today().addDays(60);
                                    IsMilestoneAchieved = True;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c > System.today()) {
                                    completionDate = cStage.Expected_Completion_Date__c;
                                } else if(cStage.Expected_Completion_Date__c != null && cStage.Expected_Completion_Date__c <= System.today()) {
                                    completionDate = system.today();
                                }   
                                if(completionDate == null) {
                                    completionDate = system.today().addDays(365);
                                }
                                pmw.pm.Due_Date__c = completionDate.addDays(Integer.valueOf(pmw.pm.Number_of_Days__c));
                                
                                if(IsMilestoneAchieved) {
                                    pmw.pm.Milestone_Complete_At_Booking__c = true;
                                } else {
                                    pmw.pm.Milestone_Complete_At_Booking__c = false;
                                }
                            } else if(String.isNotBlank(pmw.pm.Milestone_Type__c) && pmw.pm.Milestone_Type__c.equals('Registration Linked')) {
                                //10% of Agreement Value is collected within 30 days.
                                //Hence setting the dates for registration demand as 60th day
                                pmw.pm.Due_Date__c = system.today().addDays(60);
                            }
                        }
                    }
                    paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(pmw.pm, pmw.constructionStageList, pmw.pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pmw.pm.Milestone_Complete_At_Booking__c));
                    count++;
                }
                paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(null, null, 'Total', grandPercentage, grandAmount, currencyFormat(grandAmount), grandTotalTax, currencyFormat(grandTotalTax), grandTotal, currencyFormat(grandTotal), true, true, false));
            }
        }
        
        // Update the last and second-to-last row elements in the list
        if (allPriceInfoMap != null & paymentMilestoneWrapperList != null && !paymentMilestoneWrapperList.isEmpty()) {
            // Retrieve the last element in the list
            PaymentMilestoneWrapper lastRowElement = paymentMilestoneWrapperList[paymentMilestoneWrapperList.size() - 1];
            // Retrieve the second-to-last element in the list
            PaymentMilestoneWrapper secondToLastElement = paymentMilestoneWrapperList[paymentMilestoneWrapperList.size() - 2];
            
            // Calculate differences for the last row
            Decimal amountDiffLatest = allPriceInfoMap.get('Agreement Value') - lastRowElement.amount;
            Decimal taxDiffLatest = allPriceInfoMap.get('Agreement Value TAX') - lastRowElement.tax;
            
            // Update the last row element
            if (amountDiffLatest != 0) {
                lastRowElement.amount = lastRowElement.amount + amountDiffLatest;
                lastRowElement.amountString = currencyFormat(lastRowElement.amount);
                system.debug('Grand Total Updated Amount: ' + lastRowElement.amountString);
                
                
                secondToLastElement.amount = secondToLastElement.amount + amountDiffLatest;
                secondToLastElement.amountString = currencyFormat(secondToLastElement.amount);
                system.debug('Last Milestone Updated Amount: ' + secondToLastElement.amountString);
                
                for(Integer i = 1; i <= 5; i++) {
                    if(String.isNotBlank((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c'))) {
                        if(((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                            secondToLastElement.pm.put('Charge_Bucket_'+i+'_Amount__c', ((Decimal)secondToLastElement.pm.get('Charge_Bucket_'+i+'_Amount__c') + amountDiffLatest));
                        }
                    }
                }
            }
            
            if (taxDiffLatest != 0) {
                lastRowElement.tax = lastRowElement.tax + taxDiffLatest;
                lastRowElement.taxString = currencyFormat(lastRowElement.tax);
                system.debug('Grand Total Updated Tax: ' + lastRowElement.taxString);
                
                secondToLastElement.tax = secondToLastElement.tax + taxDiffLatest;
                secondToLastElement.taxString = currencyFormat(secondToLastElement.tax);
                system.debug('Last Milestone Updated Tax: ' + secondToLastElement.taxString);
                
                for(Integer i = 1; i <= 5; i++) {
                    if(String.isNotBlank((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c'))) {
                        if(((String)secondToLastElement.pm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                            secondToLastElement.pm.put('Charge_Bucket_'+i+'_Total_Tax__c', ((Decimal)secondToLastElement.pm.get('Charge_Bucket_'+i+'_Total_Tax__c') + taxDiffLatest));
                        }
                    }
                }
            }
            
            if (lastRowElement.amount != null && lastRowElement.tax != null) {
                lastRowElement.Total = lastRowElement.amount + lastRowElement.tax;
                lastRowElement.totalString = currencyFormat(lastRowElement.Total);
                
                secondToLastElement.Total = secondToLastElement.amount + secondToLastElement.tax;
                secondToLastElement.totalString = currencyFormat(secondToLastElement.Total);
            }
        }
        system.debug('paymentMilestoneWrapperList: '+paymentMilestoneWrapperList);
        return paymentMilestoneWrapperList;
    }
    
    public static List<Construction_Stage__c> getConsturctionStageList(Id pId, Id tId) {
        List<Construction_Stage__c> cStageList = new List<Construction_Stage__c>();
        String[] types = new String[]{'Construction_Stage__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Construction_Stage__c Where Tower__c = \''+tId+'\' AND Tower__r.Project__c = \''+pId+'\' ORDER BY Sequence_Number__c ASC'; 
        system.debug(soqlQuery);
        cStageList = Database.query(soqlQuery);
        if (cStageList.size() > 0) {
            return cStageList;
        } else {
            return null;
        }
    }
    
    
    
    public static Map<Id, Construction_Stage__c> getConstructionStagesMap(Id pId, Id tId) {
        Map<Id, Construction_Stage__c> cStageMap = new Map<Id, Construction_Stage__c>();
        List<Construction_Stage__c> cStageList = getConsturctionStageList(pId, tId);
        
        if(cStageList != null) {
            for(Construction_Stage__c cs: cStageList) {
                cStageMap.put(cs.Id, cs);
            }
        }
        return cStageMap;
    }
    
    public class PaymentMilestoneWrapper {
        @AuraEnabled
        public Payment_Scheme_Milestone__c psm {get;set;}
        @AuraEnabled
        public Payment_Milestone__c pm {get;set;}
        @AuraEnabled
        public List<Construction_Stage__c> constructionStageList {get;set;}
        @AuraEnabled
        public String milestoneName {get;set;}
        @AuraEnabled
        public Decimal percentage {get;set;}
        @AuraEnabled
        public String percentageString {get;set;}
        @AuraEnabled
        public Decimal amount {get;set;}
        @AuraEnabled
        public String amountString {get;set;}
        @AuraEnabled
        public Decimal tax {get;set;}
        @AuraEnabled
        public String taxString {get;set;}
        @AuraEnabled
        public Decimal total {get;set;}
        @AuraEnabled
        public String totalString {get;set;}
        @AuraEnabled
        public Boolean isTotal {get;set;}
        @AuraEnabled
        public Boolean agMilestone {get;set;}
        @AuraEnabled
        public String completedMilestone {get;set;}
        
        public PaymentMilestoneWrapper(){}
        public PaymentMilestoneWrapper(Payment_Milestone__c pm, List<Construction_Stage__c> csList, String milestoneName, Decimal percentage, Decimal amount, String amountString, Decimal tax, String taxString, Decimal total, String totalString, Boolean isTotal, Boolean agMilestone, Boolean completedMilestone) {
            //this.psm = psm;
            this.pm = pm;
            this.constructionStageList = csList;
            this.milestoneName = milestoneName;
            this.percentage = percentage;
            this.percentageString = String.valueOf(percentage)+'%';
            this.amount = amount;
            this.amountString = amountString;
            this.tax = tax;
            this.taxString = taxString;
            this.total = total;
            this.totalString = totalString;
            this.isTotal = isTotal;
            this.agMilestone = agMilestone;
            if(completedMilestone)
                this.completedMilestone = 'background-color:#D7BF5E';
        }
    }
    
    
    
    
    
    public static String currencyFormat(Decimal amt) {
        String formattedAmount = '';
        Decimal tempAmt = amt.setscale(2,RoundingMode.HALF_UP);
        String stringAmt = tempAmt.toPlainString();
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(stringAmt)) {
            tempStr = stringAmt.split('\\.');
            if(tempStr != null && tempStr.size() ==2) {
                decimalPart = tempStr[1];
            }
        }
        formattedAmount = (tempAmt.format().contains('.')?tempAmt.format():(tempAmt.format()+'.'+decimalPart));
        return formattedAmount+ '/-';
    }
    
}