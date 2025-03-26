// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 24-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
public class Ex_GREUpdateDetails {
    public class SVWrapper{
        @AuraEnabled 
        public Site_Visit__c sv { get; set; }
        public SVWrapper(){
            sv = new Site_Visit__c();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName/*, String projectId*/) { 
        //System.debug('projectId: '+projectId);
        System.debug('sObjectApiName '+sObjectApiName);
        List <sObject> returnList = new List < sObject > ();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();
        System.debug('recordTypeId: ' + recordTypeId);
        
        if(String.isNotBlank(searchKey) && String.isNotBlank(sObjectApiName) && sObjectApiName.equalsIgnoreCase('User')){
            
            string sWildCardText = '%' + searchKey + '%';
            string sQuery = 'Select Id, Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            }
        }
        
        if(String.isNotBlank(searchKey) && String.isNotBlank(sObjectApiName) && sObjectApiName.equalsIgnoreCase('Account')){
            string sWildCardText = '%' + searchKey + '%';
            string sQuery = 'Select Id, Name From ' + sObjectApiName + ' Where Name Like : sWildCardText AND RecordTypeId =: recordTypeId order by createdDate DESC LIMIT 5';
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            }
        }
        System.debug('returnList: '+returnList);
        System.debug('returnList: '+returnList.size());
        return returnList;
    }
    
    @AuraEnabled 
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName, String projectId) {
        System.debug('fetchDefaultRecord: '+recordId);
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            System.debug('obj: '+obj);
            return obj;
        }
        
        return null;
    }
    
    @AuraEnabled
    public static SVWrapper getSVWrapper(String svRecordId){
        SVWrapper sv = new SVWrapper();
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        svList = [Select Id, Name, Lead_Source__c, Lead_Sub_Source__c, Channel_Partner__c, Channel_Partner__r.Name, Project__c, Project__r.Name, Opportunity__c,
                  Opportunity__r.Last_Source_Change_Date__c, Project__r.TAT_Days_for_Walkin__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, GRE__c, Gender__c,
                  Opportunity__r.Fist_SV_Date__c, Is_Preregister_Visit__c
                  from Site_visit__c where Id=: svRecordId];
        System.debug('svList: '+svList);
        if(!svList.isEmpty() && svList != null){
            sv.sv = svList[0];
        }
        System.debug('sv: '+sv);
        return sv;
    }
    
    @AuraEnabled
    public static void updateSiteVisit(svWrapper svWrapper){
        System.debug('svWrapper: '+svWrapper);
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        Map<String, CP_Project__c> cpProjectMap = new Map<String, CP_Project__c>();
        Set<Id> channelPartnerIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        List<CP_Project__c> cpProjects = new List<CP_Project__c>();
         /*svList = [Select Id, Name from Site_Visit__c where Id =: svWrapper.sv.Id];
        System.debug('svList: '+svList);*/
        if(svWrapper != null){
            Site_Visit__c sv = svWrapper.sv;
            if(sv.Lead_Source__c.equalsIgnoreCase('Channel Partner') && sv.Channel_Partner__c != null && sv.Project__c != null){
                if (sv.Channel_Partner__c != null) {
                    channelPartnerIds.add(sv.Channel_Partner__c);
                }
                if (sv.Project__c != null) {
                    projectIds.add(sv.Project__c);
                }
                
                if(!channelPartnerIds.isEmpty() && projectIds != null){
                    cpProjects = [SELECT Id, Channel_Partner__c, Project_Name__c FROM CP_Project__c
                                  WHERE Channel_Partner__c IN :channelPartnerIds AND Project_Name__c IN :projectIds
                                 ];
                }
                System.debug('cpProjects: '+cpProjects);
                
                if(!cpProjects.isEmpty() && cpProjects != null){
                    for (CP_Project__c cpProject : cpProjects) {
                        if(!cpProjectMap.containsKey(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c)) {
                            cpProjectMap.put(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c, cpProject);
                        } else {
                            cpProjectMap.get(cpProject.Channel_Partner__c + '-' + cpProject.Project_Name__c);
                        }
                    }
                }
                System.debug('cpProjectMap: '+cpProjectMap);
                if(!cpProjectMap.isEmpty() && cpProjectMap != null){
                    if(!cpProjects.isEmpty() && cpProjects != null){
                        for (CP_Project__c cp : cpProjects) {
                            if(!cpProjectMap.containsKey(cp.Channel_Partner__c + '-' + cp.Project_Name__c)) {
                                sv.CP_Project__c = cpProjectMap.get(cp.Channel_Partner__c + '-' + cp.Project_Name__c).Id; 
                            } else {
                                sv.CP_Project__c = cpProjectMap.get(cp.Channel_Partner__c + '-' + cp.Project_Name__c).Id; 
                            }
                        } 
                    }
                }
            }
            if(sv != null){
                svList.add(sv);
            }
            System.debug('svList: '+svList);
            if(svList != null){
                update svList;
            }
        }
    }
}