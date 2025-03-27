public class Ex_CPProjectDuplicationHandlerServices {
    
    public static Map<CP_Project__c, List<DuplicateWrapper>> duplicationCheckCpProject(List<CP_Project__c> cpProjectPartnerList) {
        Map<CP_Project__c, List<DuplicateWrapper>> duplicateWrapperMap = new Map<CP_Project__c, List<DuplicateWrapper>>();
        Map<CP_Project__c, List<CP_Project__c>> CPProDuplicateMapAccount = new Map<CP_Project__c, List<CP_Project__c>>();
        
        
        CPProDuplicateMapAccount = CPProDuplicateCheckByPhoneWithProject(cpProjectPartnerList);
        system.debug('CPProDuplicateMapAccount : '+ CPProDuplicateMapAccount);
        
        if(!CPProDuplicateMapAccount.isEmpty() && CPProDuplicateMapAccount != null) {
            for(CP_Project__c a: CPProDuplicateMapAccount.keySet()) {
                List<DuplicateWrapper> dwList = new List<DuplicateWrapper>();
                for(CP_Project__c dupAccount: CPProDuplicateMapAccount.get(a)) {
                    dwList.add(new DuplicateWrapper('Cp Project', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<CP_Project__c, List<CP_Project__c>> CPProDuplicateCheckByPhoneWithProject(List<CP_Project__c> leadList) {
        Map<CP_Project__c, List<CP_Project__c>> cpProDuplicateMapAccountWithProject = new Map<CP_Project__c, List<CP_Project__c>>();
        Map<String, List<CP_Project__c>> incomingcpProAccountMap = new Map<String, List<CP_Project__c>>();
        Map<String, List<CP_Project__c>> incomingcpProPhoneWithProjectMap = new Map<String, List<CP_Project__c>>();
        Map<String, List<CP_Project__c>> duplicateMapPhoneWithProject = new Map<String, List<CP_Project__c>>();
        List<CP_Project__c> duplicateLeadList = new List<CP_Project__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingcpProAccountMap = getIncomingAccountMap('Account', leadList);
        incomingcpProPhoneWithProjectMap = getIncomingcpPOWithProjectMap('Account', leadList);
        incomingLeadIdSet = getcpProIdSet(leadList);
        
        if(!incomingcpProAccountMap.isEmpty() && incomingcpProAccountMap != null) {
            duplicateLeadList = [Select Id, Name, Channel_Partner__c, Project__c, OwnerId from CP_Project__c 
                                 where Channel_Partner__c IN: incomingcpProAccountMap.keySet() AND Id NOT IN: incomingLeadIdSet ];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(CP_Project__c dupLead: duplicateLeadList) {
                    if(!duplicateMapPhoneWithProject.containsKey(dupLead.Channel_Partner__c+'-'+dupLead.Project__c)) {
                        List<CP_Project__c> newLeadList = new List<CP_Project__c>();
                        newLeadList.add(dupLead);
                        duplicateMapPhoneWithProject.put(dupLead.Channel_Partner__c+'-'+dupLead.Project__c, newLeadList);
                    } else {
                        duplicateMapPhoneWithProject.get(dupLead.Channel_Partner__c+'-'+dupLead.Project__c).add(dupLead);
                    }
                }
            }
            
            for(String phoneWithProject: incomingcpProPhoneWithProjectMap.keySet()) {
                if(duplicateMapPhoneWithProject.containsKey(phoneWithProject)) {
                    for(CP_Project__c l: incomingcpProPhoneWithProjectMap.get(phoneWithProject)) {
                        cpProDuplicateMapAccountWithProject.put(l, duplicateMapPhoneWithProject.get(phoneWithProject));
                    }
                }
            }
        }
        System.debug('cpProDuplicateMapAccountWithProject '+cpProDuplicateMapAccountWithProject);
        return cpProDuplicateMapAccountWithProject;
    }
    
    
    
    
    public static Map<String, List<CP_Project__c>> getIncomingAccountMap(String Type, List<CP_Project__c> cpProjectList) {
        Map<String, List<CP_Project__c>> incomingCpMap = new Map<String, List<CP_Project__c>>();
        
        if(Type.equalsIgnoreCase('Account')) {
            for(CP_Project__c cp: cpProjectList) {
                if(cp.Project__c != null) {
                    if(!incomingCpMap.containsKey(cp.Channel_Partner__c)) {
                        List<CP_Project__c> newCpProjectList = new List<CP_Project__c>();
                        newCpProjectList.add(cp);
                        incomingCpMap.put(cp.Channel_Partner__c, newCpProjectList);
                    } else {
                        incomingCpMap.get(cp.Channel_Partner__c).add(cp);
                    }
                }
            }
        }
        System.debug('incomingCpMap  '+incomingCpMap);
        if(incomingCpMap!= null && !incomingCpMap.isEmpty())
            return incomingCpMap;
        else 
            return null;
    }
    
    public static Map<String, List<CP_Project__c>> getIncomingcpPOWithProjectMap(String Type, List<CP_Project__c> cpProjectList) {
        Map<String, List<CP_Project__c>> incomingCpPoWithProjectMap = new Map<String, List<CP_Project__c>>();
        
        if(Type.equalsIgnoreCase('Account')) {
            for(CP_Project__c cp: cpProjectList) {
                if( cp.Channel_Partner__c != null && cp.Project__c !=null) {
                    if(!incomingCpPoWithProjectMap.containsKey(cp.Channel_Partner__c+'-'+cp.Project__c)) {
                        List<CP_Project__c> newcpProjectList = new List<CP_Project__c>();
                        newcpProjectList.add(cp);
                        incomingCpPoWithProjectMap.put(cp.Channel_Partner__c+'-'+cp.Project__c, newcpProjectList);
                    } else {
                        incomingCpPoWithProjectMap.get(cp.Channel_Partner__c+'-'+cp.Project__c).add(cp);
                    }
                }
            }
        }
        System.debug('incomingCpPoWithProjectMap  '+incomingCpPoWithProjectMap);
        return incomingCpPoWithProjectMap;
    }
    public static Set<Id> getcpProIdSet(List<CP_Project__c> CpProList) {
        Set<Id> cpProIdSet = new Set<Id>();
        
        for(CP_Project__c cp: CpProList) {
            cpProIdSet.add(cp.Id);
        }
        system.debug('cpProIdSet'+cpProIdSet);
        return cpProIdSet;
    }
    
    //wrapper for duplication
    public class DuplicateWrapper { 
        public String cpProProject {get;set;}
        public CP_Project__c duplicateCPProject {get;set;}
        
        public DuplicateWrapper(String project, CP_Project__c cpProject) {
            this.cpProProject = project;
            this.duplicateCPProject = cpProject;
        }
    } 
}