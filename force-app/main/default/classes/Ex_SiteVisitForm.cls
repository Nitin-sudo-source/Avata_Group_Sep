//-------------------------------------------//
//  Project: Satyam Developers
//  Created By: Exceller tech
//  Created Date: 07-11-2023
//-------------------------------------------//
public with sharing class Ex_SiteVisitForm {
    @AuraEnabled(cacheable=true)
    public static Map<string,string> selectProject(){
        Map<String,String> projMap = new  Map<String,String>();
        for(Project__c proj : [select Id,Name FROM Project__c]){
            projMap.put(proj.Id,proj.Name);
        }
        system.debug('projMap is::'+projMap); 
        return projMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getConfigPicklistValues() {
        List<String> pickListValues = new List<String>();
        
        Schema.DescribeFieldResult objFieldDescribe = Site_Visit__c.Configuration_Required__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            
            System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            pickListValues.add(objPickList.getLabel());
        }
        return pickListValues;
    }
    
    
    
    @AuraEnabled
    public static Project__c projectImage(String pid){
        List<Project__c> project = [Select Id, Name, Project_Logo__c, Master_OTP__c from Project__c where Id =: pid];
        if(!project.isEmpty() && project != null){
            return project[0];
        }else{
            return null;
        }
       // String imageData = project[0].Project_Logo__c;
        //system.debug('imageData is::'+imageData);
        //return imageData;
    }
    
    
    
    @AuraEnabled
    public static List<CP_Project__c> getChannelPartners(String proj, String cpName){
        system.debug('cpName: '+cpName);
        System.debug('proj: '+proj);
        
        /*  Map<String,String> cpMap = new  Map<String,String>();
List<CP_Project__c> channelPartnerList= [Select Id,CP_Account__c,CP_Account__r.Name,CP_Account__r.RecordType.Name 
from CP_Project__c 
where CP_Account__r.RecordType.Name ='CP Account' AND Project__c =: proj AND(Name like % )];
for(CP_Project__c cp : channelPartnerList){
cpMap.put(cp.CP_Account__r.Id,cp.CP_Account__r.Name);
}
system.debug('channelPartnerList is::'+cpMap);
return cpMap;*/
        List<CP_Project__c> cpProjectOwnerList = New List<CP_Project__c>();
        
        if(cpName != null && cpName != ''){
            String searchKey = cpName +'%';
            cpProjectOwnerList= [Select Id,CP_Account__c, CP_Account__r.Name, CP_Account__r.RecordType.Name,
                                 CP_Account__r.MahaRERA_Registration_No__c, Project__c,CP_Account__r.Phone 
                                 from CP_Project__c where CP_Account__r.RecordType.Name ='CP Account' AND
                                 Project__c=: proj AND (CP_Account__r.Name != null AND CP_Account__r.Name LIKE : searchKey)];
        }
        System.debug('cpProjectOwnerList: '+cpProjectOwnerList);
        if(cpProjectOwnerList != null && !cpProjectOwnerList.IsEmpty()){
            return cpProjectOwnerList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Id getCPProjectOwner(Id cpId, Id proj){
        Id cpProjectOwnerId; 
        List<CP_Project__c> cpProjectOwnerList= [Select Id,Name,OwnerId 
                                                 from CP_Project__c 
                                                 where Project__c=: proj AND CP_Account__c=: cpId];
        system.debug('cpProjectOwnerList is::'+cpProjectOwnerList);
        cpProjectOwnerId = cpProjectOwnerList[0].OwnerId;
        if(cpProjectOwnerList[0].OwnerId != null){
            return cpProjectOwnerId;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<Visit_Pre_Registration__c> checkCPData(String code, String Proj){
        System.debug('code: '+code);
        System.debug('Proj: '+Proj);       
        try {
            List<Visit_Pre_Registration__c> cpList = [select Id,Pre_registration_OTP__c,Project__c,Project__r.Name,CP_Project__r.CP_Account__c,CP_Project__r.CP_Account__r.Name,
                                                      CP_Project__c,Lead__c,Lead__r.Name,Lead__r.Lead_Source__c,Customer_Name__c,Mobile__c,Budget__c,Lead__r.Channel_Partner__r.Name,
                                                      Configuration_required__c,SPOC__c,Lead__r.Channel_Partner__c,Status__c , Lead__r.Owner.FirstName ,Sourcing_Manager_Name__c,CP_Name__c,
                                                      Opportunity__c, Opportunity__r.Channel_Partner__c, Opportunity__r.Lead_Source__c,Opportunity__r.Channel_Partner__r.Name , Lead__r.CP_Project__c, Opportunity__r.CP_Project__c,
                                                      Opportunity__r.Account__c, Opportunity__r.Mobile__c, Lead__r.Mobile__c, CreatedDate
                                                      from Visit_Pre_Registration__c 
                                                      where Pre_registration_OTP__c =:code AND Project__c=:Proj AND Status__c = 'Valid'];
            system.debug('cpList is: '+cpList);
            if(!cpList.isEmpty() && cpList != null){
                return cpList; 
            }else{
                return null; 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, List<SObject>> searchForData(String num, String project) {
        Map<String, List<SObject>> searchMap = new Map<String, List<SObject>>();
        try{
            if (num != null) {
                List<Account> accountData = [SELECT Id, Name,Salutation,FirstName,Phone,LastName, PersonMobilePhone,PersonEmail,
                                             Locality__c,City_Name__c,Country__c,Locality_details__c,City_Type__c 
                                             FROM Account 
                                             WHERE /*RecordType.DeveloperName ='CP_Account' AND*/ (PersonMobilePhone =: num OR Phone =: num)];
                system.debug('accountData::'+accountData);
                if (!accountData.isEmpty()) {
                    searchMap.put('Account', accountData);
                } 
                List<Lead__c> leadData = [SELECT Id, Name, First_Name__c, Last_Name__c, Mobile__c, Email__c,Presales_Manager__r.Name,
                                          Created_Date__c,Lead_Source__c,PresalesManager__c,Configuration_Required__c,Channel_Partner__c,CP_Project__c,
                                          Channel_Partner__r.Name FROM Lead__c 
                                          WHERE (Mobile__c =:num OR Phone__c =:num) AND IsConverted__c = false AND Project__c =:project];
                system.debug('leadData::'+leadData);
                if (!leadData.isEmpty()) {
                    searchMap.put('Lead', leadData);
                }
                List<Opportunity__c> opportunityData = [SELECT Id, Name, Mobile__c, Email__c,Lead_Source__c,SalesManager__c,SourcingManager__c,Channel_Partner__c,
                                                        Channel_Partner__r.Name, CP_Project__c,
                                                        Last_SV_Date__c,First_Site_Visit_Date__c,Opportunity_Stage__c,Last_Source_Changed_By__c,Project__r.TAT__c
                                                        FROM Opportunity__c 
                                                        WHERE (Mobile__c =:num OR Phone__c =:num) AND Project__c =:project AND Is_Active__c = TRUE];
                
                system.debug('opportunityData::'+opportunityData);
                if (!opportunityData.isEmpty()) {
                    searchMap.put('Opportunity', opportunityData);
                }
            }
            system.debug('searchMap::'+searchMap);
            return searchMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<String> submits(Id ldId, Id opId, Id acId, Id cp, Id CPProjectOwner, String cpProjectId, String Mobile, String project, String email, String mastersource, String lname, String fname, String salutation, String configuration, String country, String cityType, boolean status, string otp, String cityName, String locality, String locDetails, String rrName, Boolean isSourceChanged){
        System.debug('ldId: '+ldId);
        System.debug('status: '+status);
        System.debug('cpProjectId: '+cpProjectId);
        System.debug('cp: '+cp);
        System.debug('CPProjectOwner: '+CPProjectOwner);
        System.debug('mastersource: '+mastersource);
        
        List<Lead__c> leadList = new List<Lead__c>(); 
        List<Opportunity__c> oppoList = new List<Opportunity__c>(); 
        List<Lead__c> newLeadList = new List<Lead__c>(); 
        List<Lead__c> lList = new List<Lead__c>();
        List<String> result = new List<String>();
        List<Account> accList = new List<Account>();
        String OldOppId = '';
        String NewOppId = '';
        String svCount = '';
        
        Boolean isAccountFound = false;
        Boolean isOpportunityFound = false;
        Boolean isLeadFound = false;
        List<Site_Visit__c> svList = new List<Site_Visit__c>();  
        Boolean isSuccess = false;
        Boolean isError = false;
        
        
        if(acId != null && String.isNotBlank(acId)){
            accList = [Select Id from Account where Id =: acId AND IsPersonAccount = true];
            if(accList != null && !acclist.isEmpty()){
                isAccountFound = true;
                if(String.isNotBlank(project)){
                    oppoList = [Select Id,Site_Visit_Count__c,Account__c,Project__c ,Project_Type__c,Budget__c,Buying_Purpose__c,Possession_Timeframe_Required__c, OwnerId, Alternate_Email_Id__c, Phone__c,
                                Account__r.Age_Group__c,Account__r.Gender__c,Account__r.Occupation__c,Account__r.Martial_Status__c,Account__r.Current_Residence_Configuration__c,Account__r.Designation__c,Channel_Partner__c,Sourcing_Manager__c
                                from Opportunity__c 
                                where (Account__c =: acId) AND Project__c =: project AND Is_Active__c = true];
                    System.debug('oppoList is::'+oppoList);
                }
                if(!oppoList.isEmpty() && oppoList != null){
                    isOpportunityFound = true;
                    svList = [Select Id from Site_Visit__c where Opportunity__c =: oppoList[0].Id];
                    system.debug('svList: '+svList);
                }
            }
        }
        if(oppoList.isEmpty()){
            if(ldId != null && String.isNotBlank(project)){
                lList = [Select Id,IsConverted__c,First_Name__c,Last_Name__c,Phone__c,Alternate_Email_Id__c,Lead_Stage__c,Lead_Sub_Stages__c, CP_Project__c,
                         Email__c,Mobile__c,OwnerId,Age_Group__c,Gender__c,Designation__c,Occupation__c,Marital_Status__c,Channel_Partner__c,
                         Current_Resdient_Configuration__c,Campaign__c,Campaign_Code__c,Lead_Sub_Source__c,Ethnicity__c, Family_Size__c,Industry__c,
                         Lead_Source__c,Source_Description__c,Project__c,Budget_Range__c,Buying_Purpose__c,Configuration_Required__c,Current_Resident_Status__c, Religion__c,
                         Project_Type__c,Possession_Timeframe_Required__c,Source_of_Finance__c,Presale_Next_Follow_up_Date__c,Presales_Call_Count__c,
                         Last_Presales_Call_Date__c,Presale_Date_of_Visit__c,Presale_Call_Comment__c,Presales_Comment_History__c,Presales_Call_Status__c, Company_Name__c,
                         ConvertedAccountId__c,ConvertedOpportunityId__c from Lead__c where Id=:ldId AND Project__c=:project AND IsConverted__c = false];
                system.debug('lList is::'+lList);
                if(!lList.isEmpty() && lList != null){
                    isLeadFound = true;
                }
            }else {
                lList = [Select Id,IsConverted__c,First_Name__c,Last_Name__c,Phone__c,Alternate_Email_Id__c,Lead_Stage__c,Lead_Sub_Stages__c, CP_Project__c,
                         Email__c,Mobile__c,OwnerId,Age_Group__c,Gender__c,Designation__c,Occupation__c,Marital_Status__c,Channel_Partner__c,
                         Current_Resdient_Configuration__c,Campaign__c,Campaign_Code__c,Lead_Sub_Source__c,Ethnicity__c, Family_Size__c,Industry__c,
                         Lead_Source__c,Source_Description__c,Project__c,Budget_Range__c,Buying_Purpose__c,Configuration_Required__c,Current_Resident_Status__c,
                         Project_Type__c,Possession_Timeframe_Required__c,Source_of_Finance__c,Presale_Next_Follow_up_Date__c,Presales_Call_Count__c,
                         Last_Presales_Call_Date__c,Presale_Date_of_Visit__c,Presale_Call_Comment__c,Presales_Comment_History__c,Presales_Call_Status__c, Company_Name__c, 	Religion__c,
                         ConvertedAccountId__c,ConvertedOpportunityId__c from Lead__c WHERE (Mobile__c =:Mobile OR Phone__c =:Mobile) AND IsConverted__c = false AND Project__c =:project];
                system.debug('lList is::'+lList);
                if(!lList.isEmpty() && lList != null){
                    isLeadFound = true;
                }
                
            }
        }
        if(isAccountFound) {
            if(isOpportunityFound && !isLeadFound) {
                try {
                    Site_Visit__c sv = new Site_Visit__c();
                    sv.Opportunity__c = oppoList[0].Id;
                    if(oppoList[0].Site_Visit_Count__c == Null || oppoList[0].Site_Visit_Count__c == 0)
                        sv.Site_Visit_Count__c = 1;
                    else
                        sv.Site_Visit_Count__c = oppoList[0].Site_Visit_Count__c + 1;
                    sv.Salutation__c = salutation;
                    sv.First_Name__c = fname;
                    sv.Last_Name__c = lname;
                    sv.Mobile__c = Mobile;
                    sv.Email__c = email;
                    sv.Country__c = country;
                    sv.City_Type__c = cityType;
                    sv.City_Name__c = cityName;
                    sv.Locality__c = locality;
                    sv.Locality_details__c = locDetails;
                    sv.Lead_Source__C = mastersource;
                    sv.Project_Name__c = project;
                    sv.Configuration_Required__c = configuration;
                    sv.Lead_Source__c = mastersource;
                    if(mastersource == 'Channel Partner'){
                        sv.Channel_Partner__c = cp;  
                        sv.Sourcing_Manager__c = CPProjectOwner;
                        sv.CP_Project__c = cpProjectId;
                    }
                    sv.Referrer_Name__c = rrName;
                    sv.Site_Visit_Date__c = system.now();
                    
                    if(!oppoList.isEmpty() && oppoList != null){
                        System.debug('oppoList: For Existing Opp: '+ oppoList);
                        if(oppoList[0].Project_Type__c != null)
                            sv.Project_Type__c = oppoList[0].Project_Type__c;
                        if(oppoList[0].Budget__c != null)
                            sv.Budget__c = oppoList[0].Budget__c;
                        if(oppoList[0].Buying_Purpose__c != null)
                            sv.Buying_Purpose__c = oppoList[0].Buying_Purpose__c;
                        if(oppoList[0].Possession_Timeframe_Required__c != null)
                            sv.Possession_Timeframe_Required__c = oppoList[0].Possession_Timeframe_Required__c;
                        if(oppoList[0].Account__r.Age_Group__c != null)
                            sv.Age__c = oppoList[0].Account__r.Age_Group__c;
                        if(oppoList[0].Account__r.Gender__c != null)
                            sv.Gender__c = oppoList[0].Account__r.Gender__c;
                        if(oppoList[0].Account__r.Occupation__c != null)
                            sv.Occupation__c = oppoList[0].Account__r.Occupation__c;
                        if(oppoList[0].Account__r.Designation__c != null)
                            sv.Designation__c = oppoList[0].Account__r.Designation__c;
                        if(oppoList[0].Account__r.Martial_Status__c != null)
                            sv.Martial_Status__c = oppoList[0].Account__r.Martial_Status__c;
                        if(oppoList[0].Account__r.Current_Residence_Configuration__c != null)
                            sv.Current_Residence_Configuration__c = oppoList[0].Account__r.Current_Residence_Configuration__c;
                        if(oppoList[0].Phone__c != null)  
                            sv.Phone__c = oppoList[0].Phone__c;
                        if(oppoList[0].Alternate_Email_Id__c != null)  
                            sv.Alternate_Email_Id__c = oppoList[0].Alternate_Email_Id__c;
                        if(oppoList[0].Sourcing_Manager__c != null)
                            sv.Sourcing_Manager__c = oppoList[0].Sourcing_Manager__c;
                        
                    }
                    insert sv;
                    result.add(sv.Id);
                    oppoList[0].Site_Visit_Count__c = oppoList[0].Site_Visit_Count__c + 1;
                    oppoList[0].Last_SV_Date__c = system.now();
                    if(isSourceChanged == true){
                        oppoList[0].Last_Source_Changed_By__c = system.today();
                    }
                    update oppoList[0];
                    List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    System.debug('Success Accountfound && OpportunityFound :'+lstSV);
                }catch(Exception Ex) {
                    isError = true; 
                    System.debug('Error Occur '+ Ex.getMessage());
                }
                if(!result.isEmpty() && result != null){
                    return result;
                }
                
                
            } else if(!isOpportunityFound && isLeadFound) {
                try {
                    lList[0].First_Name__c = fname;
                    lList[0].Last_Name__c = lname;
                    lList[0].Lead_Stage__c = 'Visit Done';
                    lList[0].Lead_Sub_Stages__c = 'Visit Done';
                    lList[0].Configuration_Required__c = configuration;
                    lList[0].Lead_Source__c = mastersource;
                    if(mastersource == 'Channel Partner'){
                        lList[0].Channel_Partner__c = cp;  
                        lList[0].CP_Project__c = cpProjectId;
                    }
                    
                    update lList[0];
                    
                    List<Lead__c> newLeadLst = new List<Lead__c>();
                    newLeadLst.add(lList[0]);
                    
                    if(!newLeadLst.isEmpty() && newLeadLst != null){
                        Ex_LeadConversionServices.convertLead(newLeadLst);
                    }
                    
                    Lead__c convertedLead = [Select ConvertedAccountId__c, ConvertedOpportunityId__c from Lead__c where Id =: lList[0].Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c, Last_SV_attended_by__c from Opportunity__c where Id =: convertedLead.ConvertedOpportunityId__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Opportunity
                    Site_Visit__c sv = new Site_Visit__c();
                    if(convertedLead.ConvertedOpportunityId__c != null)
                        sv.Opportunity__c = convertedLead.ConvertedOpportunityId__c;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    sv.Salutation__c = salutation;
                    sv.First_Name__c = fname;
                    sv.Last_Name__c = lname;
                    sv.Mobile__c = Mobile;
                    sv.Email__c = email;
                    sv.Country__c = country;
                    sv.City_Type__c = cityType;
                    sv.City_Name__c = cityName;
                    sv.Locality__c = locality;
                    sv.Locality_details__c = locDetails;
                    sv.Lead_Source__C = mastersource;
                    if(mastersource == 'Channel Partner'){
                        sv.Channel_Partner__c = cp;  
                        sv.Sourcing_Manager__c = CPProjectOwner;
                    }
                    //sv.Channel_Partner__c = cp;
                    sv.Project_Name__c = project;
                    sv.Configuration_Required__c = configuration;
                    sv.Lead_Source__c = mastersource;
                    sv.Referrer_Name__c = rrName;
                    sv.Site_Visit_Date__c = system.now();
                    
                    if(!lList.isEmpty() && lList != null){
                        System.debug('lList: For Existing Lead: '+ lList);
                        if(lList[0].Project_Type__c != null)
                            sv.Project_Type__c = lList[0].Project_Type__c;
                        if(lList[0].Budget_Range__c != null)
                            sv.Budget__c = lList[0].Budget_Range__c;
                        if(lList[0].Buying_Purpose__c != null)
                            sv.Buying_Purpose__c = lList[0].Buying_Purpose__c;
                        if(lList[0].Possession_Timeframe_Required__c != null)
                            sv.Possession_Timeframe_Required__c = lList[0].Possession_Timeframe_Required__c;
                        if(lList[0].Age_Group__c != null)
                            sv.Age__c = lList[0].Age_Group__c;
                        if(lList[0].Gender__c != null)
                            sv.Gender__c = lList[0].Gender__c;
                        if(lList[0].Occupation__c != null)
                            sv.Occupation__c = lList[0].Occupation__c;
                        if(lList[0].Designation__c != null)
                            sv.Designation__c = lList[0].Designation__c;
                        if(lList[0].Marital_Status__c != null)
                            sv.Martial_Status__c = lList[0].Marital_Status__c;
                        if(lList[0].Current_Resdient_Configuration__c != null)//Current_Resident_Status__c
                            sv.Current_Residence_Configuration__c = lList[0].Current_Resdient_Configuration__c;
                        if(lList[0].Current_Resident_Status__c != null)
                            sv.Current_Residence_Status__c = lList[0].Current_Resident_Status__c;
                        if(lList[0].Ethnicity__c != null)
                            sv.Ethnicity__c = lList[0].Ethnicity__c;
                        if(lList[0].Family_Size__c != null)
                            sv.Family_Size__c = lList[0].Family_Size__c;
                        if(lList[0].Industry__c != null)
                            sv.Industry__c = lList[0].Industry__c;
                        if(lList[0].OwnerId != null)
                            sv.Presales_Manager__c = lList[0].OwnerId;
                        if(lList[0].Company_Name__c != null)
                            sv.Company_Name__c = lList[0].Company_Name__c;
                        if(lList[0].Phone__c != null)
                            sv.Phone__c = lList[0].Phone__c;
                        if(lList[0].Alternate_Email_Id__c != null)
                            sv.Alternate_Email_Id__c = lList[0].Alternate_Email_Id__c;
                        if(lList[0].Email__c != null)
                            sv.Email__c = lList[0].Email__c;
                         if(lList[0].Religion__c != null)
                            sv.Religion__c = lList[0].Religion__c;
                         if(lList[0].Ethnicity__c != null)
                            sv.Ethnicity__c = lList[0].Ethnicity__c;
                        
                    }
                    
                    insert sv;
                    result.add(sv.Id);
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    System.debug('Success Accountfound && isLeadFound :'+ lstSV);
                    
                }catch(Exception ex) {
                    isError = true; 
                    System.debug('Error Occur '+ Ex.getMessage());
                }
                if(!result.isEmpty() && result != null){
                    return result;
                }
                
            } else if(!isOpportunityFound && !isLeadFound) {
                try {
                    
                    String owner = UserInfo.getUserId();
                    system.debug('lead owner is::'+owner);
                    Lead__c l = new Lead__c();
                    l.OwnerId = owner;
                    l.Last_Name__c = lname;
                    l.First_Name__c = fname;
                    l.Mobile__c = Mobile; 
                    l.Email__c = email;
                    l.Lead_Source__c = mastersource;
                    if(mastersource == 'Channel Partner'){
                        l.Channel_Partner__c = cp; 
                        l.CP_Project__c = cpProjectId;
                        //l.Sourcing_Manager__c = CPProjectOwner;
                    }
                    l.Project__c = project;
                    l.Configuration_Required__c = configuration;
                    l.IsConverted__c = true;
                    l.Lead_Stage__c = 'Visit Done';
                    l.Lead_Sub_Stages__c = 'Visit Done';
                    insert l;
                    
                    List<Lead__c> leadList1 = new List<Lead__c>();
                    leadList1.add(l);
                    
                    if(!leadList1.isEmpty() && leadList1 != null){
                        Ex_LeadConversionServices.convertLead(leadList1);
                    }
                    
                    Lead__c convertedLead = [Select ConvertedAccountId__c, ConvertedOpportunityId__c from Lead__c where Id =: leadList1[0].Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c, Last_SV_attended_by__c, Last_SV_Date__c from Opportunity__c where Id =: convertedLead.ConvertedOpportunityId__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Converted Opportunity
                    Site_Visit__c sv = new Site_Visit__c();
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    sv.Salutation__c = salutation;
                    sv.First_Name__c = fname;
                    sv.Last_Name__c = lname;
                    sv.Mobile__c = Mobile;
                    sv.Email__c = email;
                    sv.Country__c = country;
                    sv.City_Type__c = cityType;
                    sv.City_Name__c = cityName;
                    sv.Locality__c = locality;
                    sv.Locality_details__c = locDetails;
                    sv.Lead_Source__C = mastersource;
                    if(mastersource == 'Channel Partner'){
                        sv.Channel_Partner__c = cp;  
                        sv.CP_Project__c = cpProjectId;
                        //sv.Sourcing_Manager__c = CPProjectOwner;
                    }
                    // sv.Channel_Partner__c = cp;
                    sv.Project_Name__c = project;
                    sv.Configuration_Required__c = configuration;
                    sv.Lead_Source__c = mastersource;
                    sv.Referrer_Name__c = rrName;
                    sv.Site_Visit_Date__c = system.now();
                    // sv.Sourcing_Manager__c = CPProjectOwner;
                    insert sv;
                    result.add(sv.Id);
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    if(status == true && otp != null){
                        Visit_Pre_Registration__c preList = [Select Id,Name,Status__c,Pre_registration_OTP__c 
                                                             from Visit_Pre_Registration__c
                                                             where Pre_registration_OTP__c=: otp];
                        system.debug('preList is::'+preList);
                        if(preList != null){
                            preList.Status__c = 'Completed'; 
                        }
                        update preList;
                    }
                    isSuccess = true;
                    System.debug('Success Accountfound :'+ lstSV);
                }catch(Exception ex) {
                    isError = true; 
                    System.debug('Error Occur '+ Ex.getMessage());
                }
                if(!result.isEmpty() && result != null){
                    return result;
                }
            }
        } else{
            if(isLeadFound) {
                // try {
                System.debug('Inside Lead Found neww:');
                lList[0].First_Name__c = fname;
                lList[0].Last_Name__c = lname;
                lList[0].Lead_Stage__c = 'Visit Done';
                lList[0].Lead_Sub_Stages__c = 'Visit Done';
                lList[0].Lead_Source__c = mastersource;
                lList[0].Configuration_Required__c = configuration;
                if(mastersource == 'Channel Partner'){
                    lList[0].Channel_Partner__c = cp;  
                    lList[0].CP_Project__c = cpProjectId;
                }
                
                update lList[0];
                System.debug('lListupdate: '+lList[0]);
                
                List<Lead__c> newLeadLst = new List<Lead__c>();
                newLeadLst.add(lList[0]);
                
                if(!newLeadLst.isEmpty() && newLeadLst != null){
                    Ex_LeadConversionServices.convertLead(newLeadLst);
                }
                
                Lead__c convertedLead = [Select ConvertedAccountId__c, ConvertedOpportunityId__c from Lead__c where Id =: lList[0].Id AND IsConverted__c = true];
                system.debug('Converted Lead: '+convertedLead);
                
                Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c, Last_SV_attended_by__c from Opportunity__c where Id =: convertedLead.ConvertedOpportunityId__c];
                system.debug('Converted Opportunity: '+convertedOpp);
                
                //Tag Site Visit Against Opportunity
                Site_Visit__c sv = new Site_Visit__c();
                if(convertedLead.ConvertedOpportunityId__c != null)
                    sv.Opportunity__c = convertedLead.ConvertedOpportunityId__c;
                sv.Site_Visit_Date__c = system.now();
                sv.Site_Visit_Count__c = 1;
                sv.Salutation__c = salutation;
                sv.First_Name__c = fname;
                sv.Last_Name__c = lname;
                sv.Mobile__c = Mobile;
                sv.Email__c = email;
                sv.Country__c = country;
                sv.City_Type__c = cityType;
                sv.City_Name__c = cityName;
                sv.Locality__c = locality;
                sv.Locality_details__c = locDetails;
                sv.Lead_Source__C = mastersource;
                if(mastersource == 'Channel Partner'){
                    sv.Channel_Partner__c = cp;
                    sv.CP_Project__c = cpProjectId;
                    sv.Sourcing_Manager__c = CPProjectOwner;
                }
                
                sv.Project_Name__c = project;
                sv.Configuration_Required__c = configuration;
                sv.Lead_Source__c = mastersource;
                sv.Referrer_Name__c = rrName;
                sv.Site_Visit_Date__c = system.now();
                
                if(!lList.isEmpty() && lList != null){
                    System.debug('lList: For Existing Lead: '+ lList);
                    if(lList[0].Project_Type__c != null)
                        sv.Project_Type__c = lList[0].Project_Type__c;
                    if(lList[0].Budget_Range__c != null)
                        sv.Budget__c = lList[0].Budget_Range__c;
                    if(lList[0].Buying_Purpose__c != null)
                        sv.Buying_Purpose__c = lList[0].Buying_Purpose__c;
                    if(lList[0].Possession_Timeframe_Required__c != null)
                        sv.Possession_Timeframe_Required__c = lList[0].Possession_Timeframe_Required__c;
                    if(lList[0].Age_Group__c != null)
                        sv.Age__c = lList[0].Age_Group__c;
                    if(lList[0].Gender__c != null)
                        sv.Gender__c = lList[0].Gender__c;
                    if(lList[0].Occupation__c != null)
                        sv.Occupation__c = lList[0].Occupation__c;
                    if(lList[0].Designation__c != null)
                        sv.Designation__c = lList[0].Designation__c;
                    if(lList[0].Marital_Status__c != null)
                        sv.Martial_Status__c = lList[0].Marital_Status__c;
                    if(lList[0].Current_Resdient_Configuration__c != null)//Current_Resident_Status__c
                        sv.Current_Residence_Configuration__c = lList[0].Current_Resdient_Configuration__c;
                    if(lList[0].Current_Resident_Status__c != null)
                        sv.Current_Residence_Status__c = lList[0].Current_Resident_Status__c;
                    if(lList[0].Ethnicity__c != null)
                        sv.Ethnicity__c = lList[0].Ethnicity__c;
                    if(lList[0].Family_Size__c != null)
                        sv.Family_Size__c = lList[0].Family_Size__c;
                    if(lList[0].Industry__c != null)
                        sv.Industry__c = lList[0].Industry__c;
                    if(lList[0].OwnerId != null)
                        sv.Presales_Manager__c = lList[0].OwnerId;
                    if(lList[0].Company_Name__c != null)
                        sv.Company_Name__c = lList[0].Company_Name__c;
                    if(lList[0].Phone__c != null)
                        sv.Phone__c = lList[0].Phone__c;
                    if(lList[0].Alternate_Email_Id__c != null)
                        sv.Alternate_Email_Id__c = lList[0].Alternate_Email_Id__c;
                    if(lList[0].Email__c != null)
                        sv.Email__c = lList[0].Email__c;
                    if(lList[0].Religion__c != null)
                        sv.Religion__c = lList[0].Religion__c;
                }
                insert sv;
                result.add(sv.Id);
                
                //Update Opportunity
                convertedOpp.Site_Visit_Count__c = 1;
                convertedOpp.Last_SV_Date__c = system.now();
                update convertedOpp;
                
                List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                isSuccess = true;
                System.debug('Success isLeadFound :'+ lstSV);
                
                // }catch(Exception ex) {
                isError = true; 
                // System.debug('Error Occur ');
                // }
                if(!result.isEmpty() && result != null){
                    return result;
                }
                
            } else {
                try {
                    String owner = UserInfo.getUserId();
                    system.debug('lead owner is::'+owner);
                    Lead__c l = new Lead__c();
                    l.OwnerId = owner;
                    l.Last_Name__c = lname;
                    l.First_Name__c = fname;
                    l.Mobile__c = Mobile; 
                    l.Email__c = email;
                    l.Lead_Source__c = mastersource;
                    if(mastersource == 'Channel Partner'){
                        l.Channel_Partner__c = cp;
                        l.CP_Project__c = cpProjectId;
                    }
                    
                    l.Project__c = project;
                    l.Configuration_Required__c = configuration;
                    l.IsConverted__c = true;
                    l.Lead_Stage__c = 'Visit Done';
                    l.Lead_Sub_Stages__c = 'Visit Done';
                    insert l;
                    
                    List<Lead__c> leadList1 = new List<Lead__c>();
                    leadList1.add(l);
                    
                    if(!leadList1.isEmpty() && leadList1 != null){
                        Ex_LeadConversionServices.convertLead(leadList1);
                    }
                    
                    Lead__c convertedLead = [Select Id, ConvertedAccountId__c, ConvertedOpportunityId__c from Lead__c where Id =: leadList1[0].Id AND IsConverted__c = true];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, Site_Visit_Count__c, Last_SV_attended_by__c, Last_SV_Date__c from Opportunity__c where Id =: convertedLead.ConvertedOpportunityId__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Converted Opportunity
                    Site_Visit__c sv = new Site_Visit__c();
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.now();
                    sv.Site_Visit_Count__c = 1;
                    sv.Salutation__c = salutation;
                    sv.First_Name__c = fname;
                    sv.Last_Name__c = lname;
                    sv.Mobile__c = Mobile;
                    sv.Email__c = email;
                    sv.Country__c = country;
                    sv.City_Type__c = cityType;
                    sv.City_Name__c = cityName;
                    sv.Locality__c = locality;
                    sv.Locality_details__c = locDetails;
                    sv.Lead_Source__C = mastersource;
                    if(mastersource == 'Channel Partner'){
                        sv.Channel_Partner__c = cp;
                        sv.Sourcing_Manager__c = CPProjectOwner;
                        sv.CP_Project__c = cpProjectId;
                    }
                    sv.Project_Name__c = project;
                    sv.Configuration_Required__c = configuration;
                    sv.Lead_Source__c = mastersource;
                    sv.Referrer_Name__c = rrName;
                    sv.Site_Visit_Date__c = system.now();
                    
                    insert sv;
                    System.debug('sv: '+sv.Id);
                    result.add(sv.Id);
                    
                    //Update Opportunity
                    convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    
                    if(status == true && otp != null){
                        Visit_Pre_Registration__c preList = [Select Id,Name,Status__c,Pre_registration_OTP__c 
                                                             from Visit_Pre_Registration__c
                                                             where Pre_registration_OTP__c=: otp];
                        system.debug('preList is::'+preList);
                        if(preList != null){
                            preList.Status__c = 'Completed'; 
                        }
                        update preList;
                    }
                    isSuccess = true;
                    System.debug('Success Fresh Lead :'+ lstSV);
                }catch(Exception ex) {
                    isError = true; 
                    System.debug('Error Occur ');
                }
                if(!result.isEmpty() && result != null){
                    return result;
                }
            }
        }
        return result;
    }    
    
    @AuraEnabled
    Public static String getSiteName(string sId){
        System.debug('SId: '+sId);
        String svName = '';
        if(sId != null){
            List<Site_Visit__c> svList = [Select Id,Name from Site_Visit__c where Id=:sId];
            // system.debug(svList[0].Name);
            if(svList != null){
                svName = svList[0].Name; 
            }
        }
        return svName;       
    }
    
    @AuraEnabled
    public static String createSMS(String mobile,  String project){
        
        String OTP = '';
        Integer len = 6;
        Integer randomInt = (Integer)(Math.random() * 900000) + 100000;
        OTP = String.valueOf(randomInt).substring(0,len);  
        List<Project__c> pList = new List<Project__c>();
        pList = [Select Id, SV_OTP_Template_ID__c, SMS_Company_Name__c from Project__c where Id =: project AND SV_OTP_Template_ID__c != null AND SMS_Company_Name__c != null];
        System.debug('pList: '+pList);
        
        //create SMS
        SMS__c sms = new SMS__c();
        sms.Name = 'SMS: '+ mobile;
        if(String.isNotBlank(mobile)){
            sms.Sender_Mobile_No__c = mobile;        
        }
        if(pList[0].SV_OTP_Template_ID__c != null){
            sms.Template_Id__c = pList[0].SV_OTP_Template_ID__c;
        }
        /* if(System.label.TemplateSMSforOTP != null){
sms.Template_Id__c = System.label.TemplateSMSforOTP;
}*/
        sms.Message__c = 'Your OTP for mobile verification is: '+  OTP +' Please share this code to complete the verification process. Thank you. '+ pList[0].SMS_Company_Name__c ;
        try{
            insert sms;
            System.debug('sms: '+sms);
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
        if(sms != null){
            return OTP;
        }else{
            return 'Something Went Wrong Please Contact System Administrator ';
        }
    } 
}