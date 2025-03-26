public class Ex_VisitPreRegDuplicationHandlerServices {

    public static Map<Visit_Pre_Registration__c, List<duplicateWrapper>> duplicationCheck(List<Visit_Pre_Registration__c> vprList){
        Map<Visit_Pre_Registration__c, List<duplicateWrapper>> duplicateWrapper = new Map<Visit_Pre_Registration__c, List<duplicateWrapper>>();
        Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> vprDulicateLeadMobile = new Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>>();
        Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> vprDulicateCPLeadMobile = new Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>>();
        String LeadORCPLead = '';
        
        if(!vprList.isEmpty() && vprList!=null){
            for(Visit_Pre_Registration__c vpr : vprList){
                if(vpr.Lead__c!=null && vpr.CP_Lead__c==null)
                    LeadORCPLead = 'Lead';
                if(vpr.CP_Lead__c!=null && vpr.Lead__c==null)
                    LeadORCPLead = 'CP Lead';
            }
        }
        
        if(LeadORCPLead=='Lead'){
            vprDulicateLeadMobile = vprDuplicationCheckByLeadMobileWithProject(vprList);
            if(!vprDulicateLeadMobile.isEmpty() && vprDulicateLeadMobile!=null){
                for(Visit_Pre_Registration__c vpr : vprDulicateLeadMobile.keySet()){
                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                    for(Visit_Pre_Registration__c dup : vprDulicateLeadMobile.get(vpr)){
                        dwList.add(new duplicateWrapper(dup, 'Lead'));
                    }
                    duplicateWrapper.put(vpr, dwList);
                }
            }
        }
        
        if(LeadORCPLead=='CP Lead'){
            vprDulicateCPLeadMobile = vprDuplicationCheckByCPLeadMobileWithProject(vprList);
            if(!vprDulicateCPLeadMobile.isEmpty() && vprDulicateCPLeadMobile!=null){
                for(Visit_Pre_Registration__c vpr : vprDulicateCPLeadMobile.keySet()){
                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                    for(Visit_Pre_Registration__c dup : vprDulicateCPLeadMobile.get(vpr)){
                        dwList.add(new duplicateWrapper(dup, 'CP Lead'));
                    }
                    duplicateWrapper.put(vpr, dwList);
                }
            }
        }
        
        return duplicateWrapper;
    }
    
    public static Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> vprDuplicationCheckByLeadMobileWithProject(List<Visit_Pre_Registration__c> vprList){
        Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> duplicateVPRLeadMapMobileWithProject = new Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMobileMap = new Map<String, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMapWithProject = new Map<String, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> duplicateLeadMapMobilewithProject = new Map<String, List<Visit_Pre_Registration__c>>();
        List<Visit_Pre_Registration__c> duplicateVPRLeadListMobile = new List<Visit_Pre_Registration__c>();
        //List<Date> SVDateList = new List<Date>();
        Set<Id> vprIdSet = new Set<Id>();
        
        /*if(!vprList.isEmpty() && vprList!=null){
            for(Visit_Pre_Registration__c vpr : vprList){
                SVDateList.add(Date.valueOf(vpr.Site_Visit_Date__c));
            }
        }*/
        
        incomingVPRMobileMap = getIncomingVPRMap('Mobile',vprList);
        incomingVPRMapWithProject = getIncomingVPRMapWithProject('Mobile',vprList);
        vprIdSet = getVPRIdSet(vprList);
        
        if(incomingVPRMobileMap!=null && !incomingVPRMobileMap.isEmpty()){
            duplicateVPRLeadListMobile = [Select Id, Name, Lead__c, Pre_Registration_Expiry__c, Mobile_Number__c, Project__c, Project__r.Name 
                                      	from Visit_Pre_Registration__c where Mobile_Number__c IN: incomingVPRMobileMap.keySet() AND Lead__c != NULL AND Id NOT IN: vprIdSet];
        	
            if(!duplicateVPRLeadListMobile.isEmpty() && duplicateVPRLeadListMobile!=null){
                //for(DateTime svDate : SVDateList){
                    //system.debug('sv Date:'+svDate);
                    for(Visit_Pre_Registration__c vpr : duplicateVPRLeadListMobile){
                        if(vpr.Project__c!=null){
                            system.debug('today'+system.today());
                            if(system.Today()<=Date.valueOf(vpr.Pre_Registration_Expiry__c)){
                                system.debug('expirtyDate:'+Date.valueOf(vpr.Pre_Registration_Expiry__c));
                                if(!duplicateLeadMapMobilewithProject.containsKey(vpr.Mobile_Number__c+'-'+vpr.Project__c)){
                                    List<Visit_Pre_Registration__c> newVprList = new List<Visit_Pre_Registration__c>();
                                    newVprList.add(vpr);
                                    duplicateLeadMapMobilewithProject.put(vpr.Mobile_Number__c+'-'+vpr.Project__c,newVprList);
                                }else{
                                    duplicateLeadMapMobilewithProject.get(vpr.Mobile_Number__c+'-'+vpr.Project__c).add(vpr);
                                }
                            }
                        }
                    }
                //}
            }
            
            for(String mobileWithProject : incomingVPRMapWithProject.keySet()){
                if(duplicateLeadMapMobilewithProject.containsKey(mobileWithProject)){
                    for(Visit_Pre_Registration__c vpr : incomingVPRMapWithProject.get(mobileWithProject)){
                        duplicateVPRLeadMapMobileWithProject.put(vpr, duplicateLeadMapMobilewithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return duplicateVPRLeadMapMobileWithProject;        
    }
    
    public static Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> vprDuplicationCheckByCPLeadMobileWithProject(List<Visit_Pre_Registration__c> vprList){
        Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>> duplicateVPRCPLeadMapMobileWithProject = new Map<Visit_Pre_Registration__c, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMobileMap = new Map<String, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMapWithProject = new Map<String, List<Visit_Pre_Registration__c>>();
        Map<String, List<Visit_Pre_Registration__c>> duplicateCPLeadMapMobilewithProject = new Map<String, List<Visit_Pre_Registration__c>>();
        List<Visit_Pre_Registration__c> duplicateVPRCPLeadListMobile = new List<Visit_Pre_Registration__c>();
        //List<Date> SVDateList = new List<Date>();
        Set<Id> vprIdSet = new Set<Id>();
        
        /*if(!vprList.isEmpty() && vprList!=null){
            for(Visit_Pre_Registration__c vpr : vprList){
                SVDateList.add(Date.valueOf(vpr.Site_Visit_Date__c));
            }
        }*/
        
        incomingVPRMobileMap = getIncomingVPRMap('Mobile',vprList);
        incomingVPRMapWithProject = getIncomingVPRMapWithProject('Mobile',vprList);
        vprIdSet = getVPRIdSet(vprList);
        
        if(incomingVPRMobileMap!=null && !incomingVPRMobileMap.isEmpty()){
            duplicateVPRCPLeadListMobile = [Select Id, Name, CP_Lead__c, Pre_Registration_Expiry__c, Mobile_Number__c, Project__c, Project__r.Name 
                                            from Visit_Pre_Registration__c where Mobile_Number__c IN: incomingVPRMobileMap.keySet() AND CP_Lead__c != NULL AND Id NOT IN: vprIdSet];
            
            if(!duplicateVPRCPLeadListMobile.isEmpty() && duplicateVPRCPLeadListMobile!=null){
                //for(DateTime svDate : SVDateList){
                    //system.debug('sv Date:'+svDate);
                    for(Visit_Pre_Registration__c vpr : duplicateVPRCPLeadListMobile){
                        if(vpr.Project__c!=null){
                            if(system.Today()<=Date.valueOf(vpr.Pre_Registration_Expiry__c)){
                                system.debug('expirtyDate:'+vpr.Pre_Registration_Expiry__c);
                                if(!duplicateCPLeadMapMobilewithProject.containsKey(vpr.Mobile_Number__c+'-'+vpr.Project__c)){
                                    List<Visit_Pre_Registration__c> newVprList = new List<Visit_Pre_Registration__c>();
                                    newVprList.add(vpr);
                                    duplicateCPLeadMapMobilewithProject.put(vpr.Mobile_Number__c+'-'+vpr.Project__c,newVprList);
                                }else{
                                    duplicateCPLeadMapMobilewithProject.get(vpr.Mobile_Number__c+'-'+vpr.Project__c).add(vpr);
                                }
                            }
                        }
                    }
                //}
            }
            
            for(String mobileWithProject : incomingVPRMapWithProject.keySet()){
                if(duplicateCPLeadMapMobilewithProject.containsKey(mobileWithProject)){
                    for(Visit_Pre_Registration__c vpr : incomingVPRMapWithProject.get(mobileWithProject)){
                        duplicateVPRCPLeadMapMobileWithProject.put(vpr, duplicateCPLeadMapMobilewithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return duplicateVPRCPLeadMapMobileWithProject;
    }
    
    public static Map<String, List<Visit_Pre_Registration__c>> getIncomingVPRMap(String type, List<Visit_Pre_Registration__c> vprList){
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMap = new Map<String, List<Visit_Pre_Registration__c>>();
        
        if(type.equalsIgnoreCase('Mobile')){
            for(Visit_Pre_Registration__c vpr : vprList){
                if(vpr.Mobile_Number__c!=null){
                    if(!incomingVPRMap.containsKey(vpr.Mobile_Number__c)){
                        List<Visit_Pre_Registration__c> newVprList = new List<Visit_Pre_Registration__c>();
                        newVprList.add(vpr);
                        incomingVPRMap.put(vpr.Mobile_Number__c, newVPRList);
                    }else{
                        incomingVPRMap.get(vpr.Mobile_Number__c).add(vpr);
                    }
                }
            }
        }
        return incomingVPRMap;
    }
    
    public static Map<String, List<Visit_Pre_Registration__c>> getIncomingVPRMapWithProject(String type, List<Visit_Pre_Registration__c> vprList){
        Map<String, List<Visit_Pre_Registration__c>> incomingVPRMapWithProject = new Map<String, List<Visit_Pre_Registration__c>>();
        
        if(type.equalsIgnoreCase('Mobile')){
            for(Visit_Pre_Registration__c vpr : vprList){
                if(!incomingVPRMapWithProject.containsKey(vpr.Mobile_Number__c+'-'+vpr.Project__c)){
                    List<Visit_Pre_Registration__c> newVPRList = new List<Visit_Pre_Registration__c>();
                    newVPRList.add(vpr);
                    incomingVPRMapWithProject.put(vpr.Mobile_Number__c+'-'+vpr.Project__c,newVPRList);
                }else{
                    incomingVPRMapWithProject.get(vpr.Mobile_Number__c+'-'+vpr.Project__c).add(vpr);
                }
            }
        }
        return incomingVPRMapWithProject;
    }
    
    public static Set<Id> getVPRIdSet(List<Visit_Pre_Registration__c> vprList){
        Set<Id> vprIdSet = new Set<Id>();
        for(Visit_Pre_Registration__c vpr : vprList){
            vprIdSet.add(vpr.Id);
        }
        return vprIdSet;
    }
    
    public class duplicateWrapper{
        public Visit_Pre_Registration__c dupVisitPreReg {get;set;}
        public String Type;
        
        public duplicateWrapper(Visit_Pre_Registration__c dupVisitPreReg, String Type){
            this.dupVisitPreReg = dupVisitPreReg;
            this.type = type;
        }
    }
    
}