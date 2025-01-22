public class Ex_ScreenPopupCallController {
        public String mobileNo {get;set;}
        public String callerId {get;set;}
        public String uui{get;set;}
        
        public Ex_ScreenPopupCallController() {
            
            Map<String, String> mapT = ApexPages.currentPage().getParameters();
            for(String key: mapT.keySet()) {
                System.debug('key: '+key+' value: '+mapT.get(key));
            }
            if(ApexPages.currentPage().getParameters().containsKey('phone'))  {     
                mobileNo = ApexPages.currentPage().getParameters().get('phone'); 
            }
            system.debug('mobileNo: '+mobileNo);
            if(ApexPages.currentPage().getParameters().containsKey('did'))  {     
                callerId = ApexPages.currentPage().getParameters().get('did'); 
            }
            system.debug('callerId: '+callerId);
            if(ApexPages.currentPage().getParameters().containsKey('uui'))  {     
                uui = ApexPages.currentPage().getParameters().get('uui'); 
            }
            system.debug('uui: '+uui);
        }
        
        public pageReference screenPop() {
            pageReference pRef;
            String projectId = null;
            List<Campaign__c> cList = new List<Campaign__c>();
            List<Lead__c> leadList = new List<Lead__c>();
            List<Opportunity__c> oppList = new List<Opportunity__c>();
            List<CP_Project__c> cpProjectList = new List<CP_Project__c>();
            List<Ola_Pickup__c> olaList = new List<Ola_Pickup__c>();
            
            
            if(String.isNotBlank(callerId) && callerId != null) {
                cList = [Select Id, Virtual_Number__c, Source__c, Project__c from Campaign__c
                         where IsActive__c = true AND Is_CTI_Campaign__c = true AND Virtual_Number__c =: callerId];
                system.debug('cList: '+cList);
                
                if(!cList.isEmpty() && cList != null) {
                    projectId = cList[0].Project__c;
                }
            }
            if(String.isNotBlank(uui) && uui != null) {
                oppList = [Select Id, Mobile__c, Phone__c  from Opportunity__c where id =: uui];
                System.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty() && oppList != null) {
                    pRef = new PageReference('/' + oppList[0].Id);
                } else {
                    leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c,Phone__c from Lead__c where id =: uui];
                    system.debug('leadList: '+leadList); 
                    
                    if(!leadList.isEmpty() && leadList != null) {
                        pRef = new PageReference('/' + leadList[0].Id);
                    } else{
                        cpProjectList = [Select Id, Name, OwnerId from CP_Project__c where Id =: uui];
                        system.debug('cpProjectList: '+cpProjectList);
                        if(!cpProjectList.isEmpty() && cpProjectList != null){
                            pRef = new PageReference('/' + cpProjectList[0].Id);
                        }else{
                            olaList = [Select Id, Name, OwnerId from Ola_Pickup__c where Id =: uui];
                            system.debug('olaList: '+olaList);
                            if(!olaList.isEmpty() && olaList != null){
                                pRef = new PageReference('/' + olaList[0].Id);
                            }
                        }
                    } 
                }
            }else{
                if(String.isNotBlank(mobileNo) && mobileNo != ''){
                    if(mobileNo.length() > 10) {
                        mobileNo = mobileNo.substring(mobileNo.length()-10);
                    }
                    oppList = [Select Id, Mobile__c, Phone__c  from Opportunity__c where (Mobile__c =: mobileNo OR Phone__c =: mobileNo) AND Is_Active__c = true AND Project__c =: projectId ];
                    System.debug('oppList: '+oppList);
                    
                    if(!oppList.isEmpty() && oppList != null) {
                        pRef = new PageReference('/' + oppList[0].Id);
                    } else {
                        leadList = [Select Id, First_Name__c, Last_Name__c, Mobile__c,Phone__c from Lead__c where (Mobile__c =: mobileNo OR Phone__c =: mobileNo) AND IsConverted__c = false AND Project__c =: projectId ];
                        system.debug('leadList: '+leadList); 
                        
                        if(!leadList.isEmpty() && leadList != null) {
                            pRef = new PageReference('/' + leadList[0].Id);
                        }
                        
                    }
                }
            }
            return pRef;
        }
    }