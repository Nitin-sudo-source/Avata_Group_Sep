public class Ex_GREUpdateDetails {
    public class SVWrapper{
        @AuraEnabled 
        public Site_Visit__c sv { get; set; }
        public SVWrapper(){
            sv = new Site_Visit__c();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, String projectId) { 
        System.debug('projectId: '+projectId);
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
         /*svList = [Select Id, Name from Site_Visit__c where Id =: svWrapper.sv.Id];
        System.debug('svList: '+svList);*/
        if(svWrapper != null){
            Site_Visit__c sv = svWrapper.sv;
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