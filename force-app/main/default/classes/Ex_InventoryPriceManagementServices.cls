public class Ex_InventoryPriceManagementServices {
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
        String soqlQuery = 'Select ' + queryFields  + ', Tower__r.Project__c, Tower__r.Project__r.Name, Tower__r.Name,Tower__r.Project__r.Threshold_Amount__c, Tower__r.Project__r.Threshold_Percentage__c from Unit__c Where Id = \''+uId+'\''; 
        system.debug(soqlQuery);
        unitList = Database.query(soqlQuery);
        if (unitList.size() > 0) {
            return unitList[0];
        } else {
            return null;
        }
    }
    
    public static Opportunity__c getOpportunityInfo(Id oppId) {
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        String[] types = new String[]{'Opportunity__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Opportunity__c Where Id = \''+oppId+'\''; 
        system.debug(soqlQuery);
        oppList = Database.query(soqlQuery);
        if (oppList.size() > 0) {
            return oppList[0];
        } else {
            return null;
        }
    }
    
    public static List<Payment_Scheme__c> getPaymentSchemeInfo(Id tId) {
        List<Payment_Scheme__c> schemeList = new List<Payment_Scheme__c>();
        String[] types = new String[]{'Payment_Scheme__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Payment_Scheme__c Where Tower__c = \''+tId+'\' AND Active__c = true'; 
        system.debug(soqlQuery);
        schemeList = Database.query(soqlQuery);
        if (schemeList.size() > 0) {
            return schemeList;
        } else {
            return null;
        }
    }
    
    
    
    public static List<CarParkWrapper> getCarParkInfo(Id pId, Id tId) { 
        List<CarParkWrapper> carParkList = new List<CarParkWrapper>();
        List<AggregateResult> cpList = new List<AggregateResult>();
        
        Project__c pro = [SELECT Id, Name, Car_Park_Maintain_At__c FROM Project__c WHERE Id = :pId];
        
        if (pro != null) {
            if (!String.isBlank(pro.Car_Park_Maintain_At__c) && pro.Car_Park_Maintain_At__c.equalsIgnoreCase('Project')) {
                cpList = [SELECT Count(Id) cpCount, Car_Park_Type__c, MAX(Amount__c) cpAmount FROM Car_Park__c
                          WHERE Status__c = 'Available' AND Project__c = :pId
                          GROUP BY Car_Park_Type__c ORDER BY Car_Park_Type__c];
                System.debug('cpList: ' + cpList);                
            }
            else if (!String.isBlank(pro.Car_Park_Maintain_At__c) && pro.Car_Park_Maintain_At__c.equalsIgnoreCase('Tower')) {
                cpList = [SELECT Count(Id) cpCount, Car_Park_Type__c, MAX(Amount__c) cpAmount FROM Car_Park__c
                          WHERE Status__c = 'Available' AND Project__c = :pId AND Tower__c = :tId
                          GROUP BY Car_Park_Type__c ORDER BY Car_Park_Type__c];
                System.debug('cpList: ' + cpList);
            }
        }
        
        if (cpList != null && !cpList.isEmpty()) {
            for(AggregateResult ag: cpList) {
                carParkList.add(new CarParkWrapper((String)ag.get('Car_Park_Type__c'), (Decimal)ag.get('cpCount'), (Decimal)ag.get('cpAmount'), 0, currencyFormat((Decimal)ag.get('cpAmount'))));
            }
        }
        return carParkList;
    }
    
    public static List<Discount__c> getProjectLevelDiscountInfo(Id pId) {
        List<Discount__c> discountList = new List<Discount__c>();
        String[] types = new String[]{'Discount__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Discount__c Where Project__c = \''+pId+'\' AND Active__c = true'; 
        system.debug(soqlQuery);
        discountList = Database.query(soqlQuery);
        if (discountList.size() > 0) {
            return discountList;
        } else {
            return null;
        }
    }
    
    public static List<Discount__c> getTowerLevelDiscountInfo(Id pId, Id tId) {
        List<Discount__c> discountList = new List<Discount__c>();
        String[] types = new String[]{'Discount__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Discount__c Where Project__c = \''+pId+'\' AND Tower__c = \''+tId+'\' AND Active__c = true'; 
        if(String.isNotBlank(soqlQuery) && soqlQuery != ''){
            discountList = Database.query(soqlQuery);    
        }
        system.debug('discountList ::::'+discountList);
        if (discountList.size() > 0 && !discountList.isEmpty() && discountList != null) {
            return discountList;
        } else {
            return null;
        }
    }
    
    public static Map<String, Decimal> getAllPriceInfo(Id uId, Map<String, List<String>> priceListGroupMap, Map<String, Pricing_List__c> priceListMap, Decimal carParkPrice, Decimal discountPrice) {
        Unit__c u = getUnitInfo(uId);
        Decimal avAmount = 0;
        Decimal avWithoutCarPark = 0;
        
        if(u != null) {
            Map<String, Decimal> allPriceInfoMap = new Map<String, Decimal>();
            Pricing_List__c pl = new Pricing_List__c();
            pl.Unit__c = u.Id;
            pl.Charge_Bucket__c = 'Agreement Value';
            pl.Charge_Name__c = 'Parking Charges';
            pl.Charge_Type__c = 'Lumpsum';
            if(carParkPrice != null){
                pl.Charge_Amount__c = carParkPrice;
            }
            
            priceListMap.put(pl.Charge_Name__c, pl);
            if(carParkPrice != null){
                allPriceInfoMap.put('Total Car Park Price', carParkPrice);
            }
            
            for(String priceGroup: priceListGroupMap.keySet()) {
                if(!priceGroup.equalsIgnoreCase('Statutory Charges')) {
                    for(String priceList: priceListGroupMap.get(priceGroup)) {
                        Decimal amount = 0;
                        Decimal sgst = 0;
                        Decimal cgst = 0;
                        System.debug('carParkPrice::::::::::::: '+carParkPrice);
                        if(priceListMap.containsKey(priceList)) {
                            if(priceListMap.get(priceList).Charge_Name__c.equalsIgnoreCase('Parking Charges')) {
                                avAmount += carParkPrice;
                                amount = carParkPrice;
                               // System.debug('carParkPrice::::::::::::: '+carParkPrice);
                               // System.debug('priceListMap::::::::::::: '+priceListMap.get('Basic Charge').GST__c);
                                
                                sgst =priceListMap.get('Basic Charge').GST__c != null && carParkPrice != null ? (((carParkPrice / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP):0;
                                cgst = priceListMap.get('Basic Charge').GST__c != null && carParkPrice != null ? (((carParkPrice / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP):0;
                            } else {
                                avAmount += (priceListMap.get(priceList).Actual_Cost__c ).setscale(0,RoundingMode.HALF_UP);
                                avWithoutCarPark += (priceListMap.get(priceList).Actual_Cost__c ).setscale(0,RoundingMode.HALF_UP);
                                amount = (priceListMap.get(priceList).Actual_Cost__c).setscale(0,RoundingMode.HALF_UP);
                                sgst = (priceListMap.get(priceList).GST_Amount__c / 2).setscale(0,RoundingMode.HALF_UP);
                                cgst = (priceListMap.get(priceList).GST_Amount__c / 2).setscale(0,RoundingMode.HALF_UP);
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
            
            if(allPriceInfoMap.containsKey('Agreement Value')) {
                if(discountPrice != 0 && discountPrice != null ) {
                    //Discount Price will be deducted from Basic Charge also recalculate taxes
                    allPriceInfoMap.put('Basic Charge', allPriceInfoMap.get('Basic Charge') - discountPrice);
                    Decimal sgstBasic =  (((allPriceInfoMap.get('Basic Charge') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                    Decimal cgstBasic =  (((allPriceInfoMap.get('Basic Charge') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                    allPriceInfoMap.put('Basic Charge SGST', sgstBasic);
                    allPriceInfoMap.put('Basic Charge CGST', cgstBasic);
                    allPriceInfoMap.put('Basic Charge TAX', sgstBasic + cgstBasic);
                    system.debug('allPriceInfoMap'+allPriceInfoMap);
                    
                    //Discount Price will be deducted from Agreement Value Group also recalculate taxes
                    allPriceInfoMap.put('Agreement Value', allPriceInfoMap.get('Agreement Value') - discountPrice);
                    Decimal sgstBasicDiff = (((allPriceInfoMap.get('Agreement Value') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                    Decimal cgstBasicDiff = (((allPriceInfoMap.get('Agreement Value') / 100) * priceListMap.get('Basic Charge').GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                    //Decimal sgstBasicDiff = ((priceListMap.get('Basic Charge').GST_Amount__c / 2) - sgstBasic).setscale(0,RoundingMode.HALF_UP);
                    //Decimal cgstBasicDiff = ((priceListMap.get('Basic Charge').GST_Amount__c / 2) - cgstBasic).setscale(0,RoundingMode.HALF_UP);
                    allPriceInfoMap.put('Agreement Value SGST', sgstBasicDiff);
                    allPriceInfoMap.put('Agreement Value CGST', cgstBasicDiff);
                    allPriceInfoMap.put('Agreement Value TAX', sgstBasicDiff + cgstBasicDiff);
                }
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
                    if(priceListMap.get(priceList).Charge_Type__c.equalsIgnoreCase('Percentage')) {
                        if(allPriceInfoMap.containsKey('Agreement Value')) {
                            amount = ((allPriceInfoMap.get('Agreement Value') * priceListMap.get(priceList).Charge_Percentage__c) / 100).setscale(0,RoundingMode.HALF_UP);
                            sgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                            cgst = (((amount / 100) * priceListMap.get(priceList).GST__c) / 2).setscale(0,RoundingMode.HALF_UP);
                        }   
                    } else {
                        amount = (priceListMap.get(priceList).Actual_Cost__c).setscale(0,RoundingMode.HALF_UP);
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
    
    public static Map<String, Pricing_List__c> getPriceListMap(Id uId) {
        if(uId != null) {
            Map<String, Pricing_List__c> priceListMap = new Map<String, Pricing_List__c>();
            List<Pricing_List__c> priceList = getPriceListInfo(uId);
            
            if(priceList != null) {
                for(Pricing_List__c pl: priceList) {
                    priceListMap.put(pl.Charge_Name__c, pl);
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
            List<Pricing_List__c> priceList = getPriceListInfo(uId);
            
            if(priceList != null) {
                for(Pricing_List__c pl: priceList) {
                    if(priceListGroupMap.containsKey(pl.Charge_Bucket__c)) {
                        priceListGroupMap.get(pl.Charge_Bucket__c).add(pl.Charge_Name__c);
                    } else {
                        List<String> newList = new List<String>();
                        newList.add(pl.Charge_Name__c);
                        priceListGroupMap.put(pl.Charge_Bucket__c, newList);
                    }
                }
                if(priceListGroupMap.containsKey('Agreement Value') ){
                    priceListGroupMap.get('Agreement Value').add('Parking Charges');
                }
            }
            System.debug('priceListGroupMapApex: '+priceListGroupMap);
            return priceListGroupMap;
        } else {
            return null;
        }
    }
    
    public static List<Pricing_List__c> getPriceListInfo(Id uId) {
        List<Pricing_List__c> priceList = new List<Pricing_List__c>();
        String[] types = new String[]{'Pricing_List__c'};
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
        String soqlQuery = 'Select ' + queryFields  + ' from Pricing_List__c Where Unit__c = \''+uId+'\' ORDER BY Charge_Bucket__c, Charge_Name__c ASC'; 
        system.debug(soqlQuery);
        priceList = Database.query(soqlQuery);
        if (priceList.size() > 0) {
            return priceList;
        } else {
            return null;
        }
    }
    
    public static List<PaymentMilestoneWrapper> getPaymentSummaryInfo(Id uId, Id schemeId, Map<String, Decimal> allPriceInfoMap, Map<String, Pricing_List__c> priceListMap) {
        List<PaymentMilestoneWrapper> paymentMilestoneWrapperList = new List<PaymentMilestoneWrapper>();
        List<Payment_Scheme_Milestone__c> psMilestoneList = getPaymentSchemeMilestoneInfo(schemeId);
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
                
                for(Payment_Scheme_Milestone__c psm: psMilestoneList) {
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
                    
                    for(Integer i = 1; i <= 5; i++) {
                        if(String.isNotBlank((String)psm.get('Charge_Bucket_'+i+'__c'))) { 
                            pm.put('Charge_Bucket_'+i+'__c', psm.get('Charge_Bucket_'+i+'__c'));
                            
                            if(((String)psm.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
                                //Calculation for agreement value bucket
                                if(((String)psm.get('Charge_Bucket_'+i+'_Type__c')).equalsIgnoreCase('Percentage') && psm.get('Charge_Bucket_'+i+'_Percentage__c') != null && psm.get('Charge_Bucket_'+i+'_Percentage__c') != 0) {
                                    amount = (((Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c') * allPriceInfoMap.get('Agreement Value')) / 100).setscale(0,RoundingMode.HALF_UP);
                                    percentage = (Decimal)psm.get('Charge_Bucket_'+i+'_Percentage__c');
                                } else {
                                    amount = ((Decimal)psm.get('Charge_Bucket_'+i+'_Amount__c')).setscale(0,RoundingMode.HALF_UP);
                                    percentage = (((Decimal)psm.get('Charge_Bucket_'+i+'_Amount__c') / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                                }
                                if(psm.Token_Amount__c != null && psm.Token_Amount__c != 0) {
                                    tokenAmount = psm.Token_Amount__c;
                                }
                                if(psm.Deduct_Token__c && tokenAmount != 0) {
                                    amount = amount - tokenAmount;
                                    percentage = ((amount / allPriceInfoMap.get('Agreement Value')) * 100).setscale(2,RoundingMode.HALF_UP);
                                    psm.put('Charge_Bucket_'+i+'_Type__c', 'Amount');
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
                    if(pm.Milestone_Complete_At_Booking__c && psm.Payment_Scheme__r.Is_Mergeable__c) {
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
                            paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(psm, pm, cStageList, pm.Milestone_Name__c, totalMergePercentage, totalMergeAmount, currencyFormat(totalMergeAmount), totalMergeTax, currencyFormat(totalMergeTax), totalMergeTotal, currencyFormat(totalMergeTotal), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                        } else {
                            paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(psm, pm, cStageList, pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                        }
                    } else {
                        paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(psm, pm, cStageList, pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pm.Milestone_Complete_At_Booking__c));
                    }
                }
                paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(null, null, null, 'Total', grandPercentage, grandAmount, currencyFormat(grandAmount), grandTotalTax, currencyFormat(grandTotalTax), grandTotal, currencyFormat(grandTotal), true, true, false));
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
    
    public static List<String> validateUpdatedPaymentSchedule(Integer agSeqNumber, Map<String, Decimal> allPriceInfoMap, List<PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
        List<String> validationErrorList = new List<String>();
        
        if(!updatedPaymentMilestoneWrapperList.isEmpty() && updatedPaymentMilestoneWrapperList != null) {
            Decimal totalAmount = 0;
            Decimal totalPercentage = 0;
            Integer errorCount = 0;
            
            for(PaymentMilestoneWrapper pmw: updatedPaymentMilestoneWrapperList) {
                if(pmw.agMilestone && pmw.pm != null && pmw.psm != null) {
                    if(((String)pmw.psm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')).equalsIgnoreCase('Percentage')) {
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
    
    public static List<PaymentMilestoneWrapper> getUpdatedPaymentSchedule(Unit__c u, Integer agSeqNumber, Map<String, Pricing_List__c> priceListMap, Map<String, Decimal> allPriceInfoMap, List<PaymentMilestoneWrapper> updatedPaymentMilestoneWrapperList) {
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
                
                for(PaymentMilestoneWrapper pmw: updatedPaymentMilestoneWrapperList) {
                    Decimal amount = 0;
                    Decimal percentage = 0;
                    Decimal sgst = 0;
                    Decimal cgst = 0;
                    Decimal totalTax = 0;
                    Decimal total = 0;
                    Boolean agMilestone = false;
                    
                    if(pmw.agMilestone && pmw.pm != null && pmw.psm != null) {
                        if(((String)pmw.pm.get('Charge_Bucket_'+agSeqNumber+'__c')).equalsIgnoreCase('Agreement Value')) {
                            if(((String)pmw.psm.get('Charge_Bucket_'+agSeqNumber+'_Type__c')).equalsIgnoreCase('Percentage')) {
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
                            agMilestone = true;
                            totalTax = sgst + cgst;
                            total = amount + totalTax;
                            grandAmount += amount;
                            grandPercentage += percentage;
                            grandSGST += sgst;
                            grandCGST += cgst;
                            grandTotalTax += totalTax;
                            grandTotal += total;
                            
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
                    paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(pmw.psm, pmw.pm, pmw.constructionStageList, pmw.pm.Milestone_Name__c, percentage, amount, currencyFormat(amount), totalTax, currencyFormat(totalTax), total, currencyFormat(total), false, agMilestone, pmw.pm.Milestone_Complete_At_Booking__c));
                    count++;
                }
                paymentMilestoneWrapperList.add(new PaymentMilestoneWrapper(null, null, null, 'Total', grandPercentage, grandAmount, currencyFormat(grandAmount), grandTotalTax, currencyFormat(grandTotalTax), grandTotal, currencyFormat(grandTotal), true, true, false));
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
    
    public static List<Payment_Scheme_Milestone__c> getPaymentSchemeMilestoneInfo(Id schemeId) {
        List<Payment_Scheme_Milestone__c> psMilestoneList = new List<Payment_Scheme_Milestone__c>();
        String[] types = new String[]{'Payment_Scheme_Milestone__c'};
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
        String soqlQuery = 'Select Construction_Stage__r.Name, Payment_Scheme__r.Is_Mergeable__c, ' + queryFields  + '  from Payment_Scheme_Milestone__c Where Payment_Scheme__c = \''+schemeId+'\' ORDER BY Sequence_No__c ASC'; 
        system.debug(soqlQuery);
        psMilestoneList = Database.query(soqlQuery);
        if (psMilestoneList.size() > 0) {
            return psMilestoneList;
        } else {
            return null;
        }
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
    
    public static Quotation__c getQuotationInfo(Id qId) {
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
        String soqlQuery = 'Select ' + queryFields  + ', Tower__r.Booking_Approver__c from Quotation__c Where Id = \''+qId+'\''; 
        system.debug(soqlQuery);
        qList = Database.query(soqlQuery);
        if (qList.size() > 0) {
            return qList[0];
        } else {
            return null;
        }
    }
    
    public static Map<String, Team_Member__c> getApprovalTeamMemberDetails(Id pId, String teamName) {
        Map<String, Team_Member__c> teamMemberMap = new Map<String, Team_Member__c>();
        List<Team__c> teamList = new List<Team__c>();
        List<Team_Member__c> teamMemberList = new List<Team_Member__c>();
        
        teamList = [Select Id, Name, Project__c, Team_Type__c from Team__c where Project__c =: pId AND Team_Type__c =: teamName];
        system.debug('teamList: '+teamList);
        
        if(!teamList.isEmpty() && teamList != null) {
            teamMemberList = [Select Id, Name, User__c, Team__c, User_Active_Status__c, Availability__c, Sequence_Number__c from Team_Member__c
                              where Team__c =: teamList[0].Id AND User_Active_Status__c = true ORDER BY Sequence_Number__c ASC];
            system.debug('teamMemberList: '+teamMemberList);
            
            if(!teamMemberList.isEmpty() && teamMemberList != null) {
                for(Team_Member__c tm: teamMemberList) {
                    teamMemberMap.put('Level '+tm.Sequence_Number__c, tm);
                }
            }
        }
        system.debug('teamMemberMap: '+teamMemberMap);
        return teamMemberMap;
    }
    
    public static Decimal calculateNPV(List<PaymentMilestoneWrapper> paymentMilestoneWrapperList, Id pId) {
        Decimal NPV = 0.0;
        Decimal NPVRate = 0;
        Integer dayDifference = 0; 
        Decimal NPVofMoney = 0.0;
        Decimal TotalNPV = 0.0;
        
        List<Project__c> pList = [Select Id, Name, NPV__c from Project__c where Id =: pId];      
        if(!pList.isEmpty() && pList != null) {
            if(pList[0].NPV__c != null){
                NPV = pList[0].NPV__c;  
            }  
            NPVRate = (NPV/365/100).setscale(18, RoundingMode.HALF_UP) + 1;
        }
        if(NPV != 0) {
            for(PaymentMilestoneWrapper pmw : paymentMilestoneWrapperList) {
                NPVOfMoney =  0.0;
                if(pmw.pm.Due_Date__c != null) {
                    dayDifference = system.today().DaysBetween(pmw.pm.Due_Date__c);
                    NPVofMoney = pmw.amount / NPVRate.pow(dayDifference);
                    system.debug('NPVofMoney: '+NPVofMoney);
                    TotalNPV = TotalNPV + NPVofMoney;
                }
            }
        }
        return (TotalNPV.setscale(0,RoundingMode.HALF_UP));
    }
    
    
    public class CarParkWrapper {
        @AuraEnabled
        public String carParkType {get;set;}
        @AuraEnabled
        public Decimal carParkAvailableCount {get;set;}
        @AuraEnabled
        public Decimal carParkAmount {get;set;}
        @AuraEnabled
        public Decimal carParkRequiredCount {get;set;}
        @AuraEnabled
        public String carParkAmountString {get;set;}
        
        public CarParkWrapper(){}
        public CarParkWrapper(String cpType, Decimal cpAvailableCount, Decimal cpAmount, Decimal cpRequiredCount, String cpAmountString) {
            this.carParkType = cpType;
            this.carParkAvailableCount = cpAvailableCount;
            this.carParkAmount = cpAmount;
            this.carParkRequiredCount = cpRequiredCount;
            this.carParkAmountString = cpAmountString;
        }
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
        public PaymentMilestoneWrapper(Payment_Scheme_Milestone__c psm, Payment_Milestone__c pm, List<Construction_Stage__c> csList, String milestoneName, Decimal percentage, Decimal amount, String amountString, Decimal tax, String taxString, Decimal total, String totalString, Boolean isTotal, Boolean agMilestone, Boolean completedMilestone) {
            this.psm = psm;
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
    
    public static Legal_Entity__c getLegalEntityDetails(Id unitId, Id TId,Id pId) {
        Legal_Entity__c le = new Legal_Entity__c();
        Id leId = null;
        
        List<Unit__c> uid = [Select Id, Name, Legal_Entity__r.Id from Unit__c where Id = : unitId];
        
        if(uid != null && uid.size() > 0) {
            leId =uid[0].Legal_Entity__r.Id; 
        }
        if(leId == null) {
            List<Tower__c> T = [Select Id, Name, Legal_Entity__r.Id from Tower__c where Id = : TId];
            if(T != null && T.size() > 0)
                leId = T[0].Legal_Entity__r.Id;
        }
        System.debug('ledId:' + leId);
        if(leId == null) {
            List<Project__c> P = [Select Id, Name, Legal_Entity__r.Id from Project__c where Id = : pId];
            if(P != null && P.size() > 0)
                leId = P[0].Legal_Entity__r.Id;
        }
        if(leId != null) {
            le = [Select Name,Account_Name_Flat_Cost__c, Account_Name_Tax__c, Account_Number_Flat_Cost__c, Account_Number_Tax__c,
                  Bank_Name_Flat_Cost__c,Bank_Name_Tax__c, Branch_Name_Flat_Cost__c ,Branch_Name_Tax__c, IFSC_Code_Flat_Cost__c,
                  
                  IFSC_Code_Tax__c
                  FROM Legal_Entity__c where Id = : leId];
        }
        System.debug('ledId:' + leId);        
        return le;     
    }
    
}