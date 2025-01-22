global class Ex_CallCustomerServices {
    @Auraenabled(cacheable=true)
    public static List<campWrapper> getCampaign(String recordId, String getFormType){
        System.debug('getFormType: '+getFormType);
        List<campWrapper> campWrapperList = new List<campWrapper>();
        List<Campaign__c> campList = new List<Campaign__c>();
        List<String> getCampList = new List<String>();
        List<Lead__c> ldlist = new List<Lead__c>();
        List<Ola_Pickup__c> olaPickupList = new  List<Ola_Pickup__c> ();
        List<Opportunity__c> oppList = new List<Opportunity__c> ();
        List<CP_Project__c> cpProjectList =  new List<CP_Project__c> ();
        if((String.isNotBlank(recordId)) && recordId != null){
            if(String.isNotBlank(getFormType) && getFormType == 'Large'){
                ldlist = [Select Id, Project__c, Campaign__c,Mobile__c,Phone__c from Lead__c where Id =: recordId];
                System.debug('getLead: '+ldlist);
                if(!ldlist.isEmpty() && ldlist != null){
                    campList = [Select Id, Project__c,IsActive__c, Ozontel_Campaign_Name__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Project__c =: ldlist[0].Project__c AND Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = false AND IsActive__c = true];
                }
            }else{
                ldlist = [Select Id, Project__c, Campaign__c,Mobile__c,Phone__c,Campaign__r.Ozontel_Campaign_Name__c,Campaign__r.Virtual_Number__c from Lead__c where Id =: recordId];
                System.debug('getLead: '+ldlist);
                if(!ldlist.isEmpty() && ldlist != null){
                    campList = [Select Id, Project__c,IsActive__c, Ozontel_Campaign_Name__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Project__c =: ldlist[0].Project__c AND Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = true AND IsActive__c = true];
                }
            }
            if(!ldlist.isEmpty() && ldlist != null){
                if(!campList.isEmpty() && campList != null){
                    for(Campaign__c c: campList){
                        campWrapperList.add(new campWrapper(c.Ozontel_Campaign_Name__c,c.Virtual_Number__c));
                    }
                }
            }else {
                olaPickupList = [Select Id, Lead__r.Mobile__c, Opportunity__r.Mobile__c, Visit_Pre_Registration__r.Mobile__c, Lead__r.Phone__c,Opportunity__r.Phone__c from Ola_Pickup__c where Id =: recordId ];
                System.debug('olaPickupList: '+olaPickupList);                
                if(!olaPickupList.isEmpty() && olaPickupList != null){
                    if(String.isNotBlank(getFormType) && getFormType == 'Large'){
                        campList = [Select Id, Project__c, Ozontel_Campaign_Name__c,IsActive__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND  Offline_Campaign__c = false AND IsActive__c = true];
                        System.debug('campList: '+campList);
                    }else{
                        campList = [Select Id, Project__c, Ozontel_Campaign_Name__c,IsActive__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = true AND IsActive__c = true];
                        System.debug('campList: '+campList);
                    }
                    if(!campList.isEmpty() && campList != null){
                        for(Campaign__c c: campList){
                             campWrapperList.add(new campWrapper(c.Ozontel_Campaign_Name__c,c.Virtual_Number__c));
                        }
                    }
                }else{
                    if(String.isNotBlank(getFormType) && getFormType == 'Large'){
                        oppList = [Select Id, Mobile__c,Phone__c,Project__c from Opportunity__c where Id =: recordId ];
                        if(!oppList.isEmpty() && oppList != null){
                            campList = [Select Id, Project__c, Ozontel_Campaign_Name__c,IsActive__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Project__c =: oppList[0].Project__c AND Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = false  AND IsActive__c = true];
                        }
                    }else{
                        oppList = [Select Id, Mobile__c,Phone__c,Project__c from Opportunity__c where Id =: recordId];
                        if(!oppList.isEmpty() && oppList != null){
                            campList = [Select Id, Project__c, Ozontel_Campaign_Name__c,IsActive__c, Virtual_Number__c, Offline_Campaign__c, Is_CTI_Campaign__c from Campaign__c where Project__c =: oppList[0].Project__c AND Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = true AND IsActive__c = true];
                        }
                    }
                    System.debug('oppList: '+oppList);
                    System.debug('campList:'+campList);
                    if(!oppList.isEmpty() && oppList != null){
                        if(!campList.isEmpty() && campList != null){
                            for(Campaign__c c: campList){
                                 campWrapperList.add(new campWrapper(c.Ozontel_Campaign_Name__c,c.Virtual_Number__c));
                            }
                        }                        
                    }else{
                        cpProjectList = [Select Id,Mobile__c From CP_Project__c where Mobile__c != null AND Id=: recordId];
                        if(String.isNotBlank(getFormType) && getFormType == 'Large'){
                            campList = [Select Id, Project__c, Ozontel_Campaign_Name__c,  Virtual_Number__c, IsActive__c, Offline_Campaign__c, Is_CTI_Campaign__c   from Campaign__c where Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = false  AND IsActive__c = true];
                             System.debug('campList: '+campList);
                        }else{
                            campList = [Select Id, Project__c, Ozontel_Campaign_Name__c, Virtual_Number__c,IsActive__c, Offline_Campaign__c, Is_CTI_Campaign__c   from Campaign__c where Ozontel_Campaign_Name__c != null AND Virtual_Number__c != null AND Is_CTI_Campaign__c = true AND Offline_Campaign__c = true  AND IsActive__c = true];
                        }
                        System.debug('campList: '+campList);
                        if(!campList.isEmpty() && campList != null){
                            for(Campaign__c c: campList){
                                 campWrapperList.add(new campWrapper(c.Ozontel_Campaign_Name__c,c.Virtual_Number__c));
                            }
                        }else{
                            return null;
                        }
                    }
                }
            }
        }
        System.debug('campWrapperList: '+campWrapperList);
        if(!campWrapperList.isEmpty() && campWrapperList != null){
            return campWrapperList;
        }else{
            return null;
        }
    }
    
    @Auraenabled(cacheable=true)
    public static list<callWrapper> getMobileNumber(String recordId){
        System.debug('recordId: '+recordId);
        List<callWrapper> getMobileWrapper = new List<callWrapper>();
        List<Lead__c> ldlist = new List<Lead__c>();
        List<Ola_Pickup__c> olaPickupList = new  List<Ola_Pickup__c> ();
        List<Opportunity__c> oppList = new List<Opportunity__c> ();
        List<CP_Project__c> cpProjectList =  new List<CP_Project__c> ();
        if((String.isNotBlank(recordId)) && recordId != null){
            ldlist = [Select Id, Project__c, Campaign__c,Mobile__c,Phone__c from Lead__c where Id =: recordId AND IsConverted__c = false AND Mobile__c != null];
            System.debug('getLead: '+ldlist);
            if(!ldlist.isEmpty() && ldlist != null){
                if(ldlist[0].Phone__c != null && ldlist[0].Mobile__c != null){
                    getMobileWrapper.add(new callWrapper('XXXXXX'+ldlist[0].Mobile__c.substring(ldlist[0].Mobile__c.length() - 4) ,'XXXXXX'+ldlist[0].Phone__c.substring(ldlist[0].Phone__c.length() - 4) , ldlist[0].Mobile__c , ldlist[0].Phone__c));  
                }else{
                    getMobileWrapper.add(new callWrapper('XXXXXX'+ldlist[0].Mobile__c.substring(ldlist[0].Mobile__c.length() - 4) ,'',ldlist[0].Mobile__c,''));   
                }
            }else {
                olaPickupList = [Select Id, Primary_Mobile__c, Alternate_Mobile__c, Lead__r.Mobile__c, Opportunity__r.Mobile__c, Visit_Pre_Registration__r.Mobile__c, Lead__r.Phone__c,Opportunity__r.Phone__c from Ola_Pickup__c where Id =: recordId];
                System.debug('olaPickupList: '+olaPickupList);                
                if(!olaPickupList.isEmpty() && olaPickupList != null){
                    if(olaPickupList[0].Lead__r != null && olaPickupList[0].Primary_Mobile__c != null && olaPickupList[0].Alternate_Mobile__c != null){
                        getMobileWrapper.add(new callWrapper('XXXXXX'+olaPickupList[0].Primary_Mobile__c.substring(olaPickupList[0].Primary_Mobile__c.length() - 4) ,'XXXXXX'+olaPickupList[0].Alternate_Mobile__c.substring(olaPickupList[0].Alternate_Mobile__c.length() - 4),olaPickupList[0].Primary_Mobile__c, olaPickupList[0].Alternate_Mobile__c));
                    }else if(olaPickupList[0].Lead__r != null && olaPickupList[0].Primary_Mobile__c != null){
                        getMobileWrapper.add(new callWrapper('XXXXXX'+olaPickupList[0].Primary_Mobile__c.substring(olaPickupList[0].Primary_Mobile__c.length() - 4) , '', olaPickupList[0].Primary_Mobile__c,''));
                    }else if(olaPickupList[0].Opportunity__r != null && olaPickupList[0].Alternate_Mobile__c != null && olaPickupList[0].Primary_Mobile__c != null){
                        getMobileWrapper.add(new callWrapper('XXXXXX'+olaPickupList[0].Primary_Mobile__c.substring(olaPickupList[0].Primary_Mobile__c.length() - 4) ,'XXXXXX'+olaPickupList[0].Alternate_Mobile__c.substring(olaPickupList[0].Alternate_Mobile__c.length() - 4),olaPickupList[0].Primary_Mobile__c, olaPickupList[0].Alternate_Mobile__c));
                    }else if(olaPickupList[0].Opportunity__r != null && olaPickupList[0].Primary_Mobile__c != null){
                        getMobileWrapper.add(new callWrapper('XXXXXX'+olaPickupList[0].Primary_Mobile__c.substring(olaPickupList[0].Primary_Mobile__c.length() - 4) , '', olaPickupList[0].Primary_Mobile__c,''));
                    }else if(olaPickupList[0].Visit_Pre_Registration__r != null && olaPickupList[0].Primary_Mobile__c != null){
                        getMobileWrapper.add( new callWrapper('XXXXXX'+olaPickupList[0].Primary_Mobile__c.substring(olaPickupList[0].Primary_Mobile__c.length() - 4) ,'',olaPickupList[0].Primary_Mobile__c,''));
                    }
                }else{
                    oppList = [Select Id, Mobile__c,Phone__c from Opportunity__c where Id =: recordId AND Mobile__c != null];
                    if(!oppList.isEmpty() && oppList != null){
                        if(oppList[0].Mobile__c != null && oppList[0].Phone__c != null){
                            getMobileWrapper.add(new callWrapper('XXXXXX'+oppList[0].Mobile__c.substring(oppList[0].Mobile__c.length() - 4), 'XXXXXX'+ oppList[0].Phone__c.substring(oppList[0].Phone__c.length() - 4), oppList[0].Mobile__c, oppList[0].Phone__c));
                            
                        }else{
                            getMobileWrapper.add(new callWrapper('XXXXXX'+oppList[0].Mobile__c.substring(oppList[0].Mobile__c.length() - 4), '',oppList[0].Mobile__c,''));
                            
                        }
                    }else{
                        cpProjectList = [Select Id,Mobile__c From CP_Project__c where Mobile__c != null AND Id =: recordId];
                        if(!cpProjectList.isEmpty() && cpProjectList != null){
                            getMobileWrapper.add(new callWrapper('XXXXXX'+cpProjectList[0].Mobile__c.substring(cpProjectList[0].Mobile__c.length() - 4),'',cpProjectList[0].Mobile__c,''));
                        }else{
                            return null;
                        }
                        
                    }
                }
            }
        }else{
            return null;
        }
        System.debug('getMobileWrapper: '+getMobileWrapper);
        if(!getMobileWrapper.isEmpty() && getMobileWrapper != null){
            return getMobileWrapper;
        }else{
            return null;
        }
    }
    
    @Auraenabled(cacheable=false)
    global static String ClickToCall(String customerPh, String campaignName, String did, String getFormType, String uui){
        List<User> uList = new List<User>();
        String userName = '';
        String apiKey = '';
        String agentId = '';
        String parameterString = '';
        String endPoint = '';
        System.debug('uui: '+uui);
        
        try{
            uList = [Select Id,Name, Ozonetel_AgentId__c From User Where Id =: UserInfo.getUserId()];
            if(!uList.isEmpty() && uList != null) {
                agentId = uList[0].Ozonetel_AgentId__c;
                System.debug('agentId: '+agentId);
            }
            if(system.label.Ozontel_Username != null && system.label.Ozonetel_Apikey != null){
                userName = system.label.Ozontel_Username;
                apiKey = system.label.Ozonetel_Apikey ;
            }
            if(String.isNotBlank(did) && String.isNotBlank(customerPh) && String.isNotBlank(getFormType) && getFormType == 'Small' && String.isNotBlank(uui)){
                parameterString = 'apiKey='+apiKey+'&userName='+userName+'&custNumber='+customerPh+'&phoneName='+agentId+'&did='+did+'&uui='+uui;   
                endPoint = 'https://in1-ccaas-api.ozonetel.com/CAServices/PhoneManualDial.php?'+parameterString;   
            }else{
                parameterString = 'api_key='+apiKey+'&username='+userName+'&agentID='+agentId+'&campaignName='+campaignName+'&customerNumber='+customerPh+'&uui='+uui;   
                endPoint = 'https://in1-ccaas-api.ozonetel.com/CAServices/AgentManualDial.php?'+parameterString;
            }
        
            System.debug('click2call URL:' + endpoint);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setMethod('GET');        
            request.setEndPoint(endpoint);        
            System.Debug('Request:'+request);
            System.debug('ResponseStart: ');
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()) {
                response = httpProtocol.send(request);
            }/* else {
response.setBody('DUMMY');
}*/
            system.debug('ResponseCode: '+response.getStatusCode());        
            system.debug('Response: '+response.getBody());
            String tempResponse = response.getBody() + '- called customer';// on: ' + customerPh;
            return (tempResponse);
            
        }catch(Exception e){
            return null;
        }    
        
    }
    Public Class campWrapper{
        @Auraenabled
        public String ozoneTelcampName{get;set;}
        @Auraenabled
        public String didNumber{get;set;}
        
        public campWrapper(String ozoneTelcampName,String didNumber){
            this.ozoneTelcampName = ozoneTelcampName;
            this.didNumber = didNumber;
        }
        
        
    }
    
    public class callWrapper{
        @Auraenabled
        public String maskcallNo{get;set;}
        @Auraenabled
        public String maskAlternateNo {get;set;}
        @Auraenabled
        public String callNo{get;set;}
        @Auraenabled
        public String AlternateNo {get;set;}
        
        public callWrapper(String maskcallNo, String maskAlternateNo, String callNo,String AlternateNo){
            this.maskcallNo = maskcallNo;
            this.maskAlternateNo = maskAlternateNo;
            this.callNo = callNo;
            this.AlternateNo = AlternateNo;
        }
    }
}