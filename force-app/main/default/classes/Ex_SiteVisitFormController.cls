public class Ex_SiteVisitFormController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> selectProject(){
        Map<String,String> projMap = new  Map<String,String>();
        List<Project__c> projectList = new List<Project__c>();
        projectList = [select Id, Name, Project_Type__c FROM Project__c];
        System.debug('projectList: '+projectList);
        if(!projectList.isEmpty() && projectList != null){
            for(Project__c proj : projectList){
                projMap.put(proj.Id,proj.Name);
            }
        }
        if(projMap != null && !projMap.isEmpty()){
            return projMap;
        }else{
            return null;  
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String projectImage(String projectId){
        List<Project__c> pList = new List<Project__c>();
        pList = [Select Id, Project_Logo__c from Project__c where Id =: projectId];
        if(pList != null && !pList.isEmpty()){
            return pList[0].Project_Logo__c;
        }else{
            return null;
        }
    }
    
    public class SiteVisitWrapper{
        @AuraEnabled 
        public Site_Visit__c sv { get; set; }
        
        public SiteVisitWrapper(){
            sv = new Site_Visit__c();
        }
    }  
    
    @AuraEnabled(cacheable=false)
    public static AccountWrapper getAccountWrapper(){
        AccountWrapper ac = new AccountWrapper();
        return ac;
    }
    
    public class AccountWrapper{
        @AuraEnabled 
        public Account ac { get; set; }
        
        public AccountWrapper(){
            ac = new Account();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static ChannelPartnerWrapper getChannelPartnerWrapper(){
        ChannelPartnerWrapper cp = new ChannelPartnerWrapper();
        return cp;
    }
    
    public class ChannelPartnerWrapper{
        @AuraEnabled 
        public Channel_Partner__c cp { get; set; }
        
        public ChannelPartnerWrapper(){
            cp = new Channel_Partner__c();
        }
    }  
    
    @AuraEnabled(cacheable=false)
    public static CP_Project__c createChannelPartner(ChannelPartnerWrapper cpWrapper, String projectId) {
        System.debug('cpWrapper .: ' + cpWrapper);
        System.debug('projectId .: ' + projectId);
        
        if (String.isEmpty(projectId)) {
            throw new AuraHandledException('Project ID is required.');
        }
        
        List<Project__c> projects = [SELECT Id, Name, Sourcing_Manager__c FROM Project__c WHERE Id =: projectId];
        
        if (projects.isEmpty() || projects[0].Sourcing_Manager__c == null) {
            return null;
        }
        
        Channel_Partner__c cp = new Channel_Partner__c();
        System.debug('cpWrapper:: '+cpWrapper);
        
        if (cpWrapper.cp.Name != null)
            cp.Name = cpWrapper.cp.Name;
        if (cpWrapper.cp.Mobile__c != null)
            cp.Mobile__c = cpWrapper.cp.Mobile__c;
        if (cpWrapper.cp.CP_Firm_Type__c != null)
            cp.CP_Firm_Type__c = cpWrapper.cp.CP_Firm_Type__c;
        if (cpWrapper.cp.PAN_No__c != null)
            cp.PAN_No__c = cpWrapper.cp.PAN_No__c;
        
        if (cpWrapper.cp.MahaRERA_Registration_No__c != null) {
            cp.MahaRERA_Registration_No__c = cpWrapper.cp.MahaRERA_Registration_No__c;
            cp.RERA_Available__c = 'Yes';
        } else {
            cp.RERA_Available__c = 'No';
        }
        if (projects[0].Sourcing_Manager__c != null){
        cp.OwnerId = projects[0].Sourcing_Manager__c;
        }
        cp.IS_CP_Created_From_Walk_in_From__c = true;
        
        try {
            insert cp;
            System.debug('Channel Partner Created: ' + cp.Id);
        } catch (DmlException ex) {
            System.debug('DML Exception: ' + ex.getDmlMessage(0));
            throw new AuraHandledException('Failed to create Channel Partner: ' + ex.getDmlMessage(0));
        }
        
        if (cp.Id == null) {
            return null;
        }
        
        // Fetch newly inserted Channel Partner
        List<Channel_Partner__c> cpList = [SELECT Id, Name, CP_unique_Code__c FROM Channel_Partner__c WHERE Id =: cp.Id];
        
        if (cpList.isEmpty()) {
            return null;
        }
        
        CP_Project__c cproj = new CP_Project__c();
        if (projectId != null){
            cproj.Project__c = projectId;
        }
        if (cpList[0].Id != null){
            cproj.Channel_Partner__c = cpList[0].Id;
        }
        if (projects[0].Sourcing_Manager__c != null){
            cproj.OwnerId = projects[0].Sourcing_Manager__c;
        }
        List<CP_Project__c> cpProjectList = new List<CP_Project__c>();
        
        try {
            insert cproj;
            System.debug('CP Project Created: ' + cproj.Id);
            
            if (cproj.Id != null) {
                cpProjectList = [SELECT Id, Project__r.Name, Channel_Partner__c, Channel_Partner__r.Name, 
                                 Owner.FirstName, Owner.LastName, OwnerId 
                                 FROM CP_Project__c WHERE Id =: cproj.Id];
            }
        } catch (DmlException ex) {
            System.debug('Error While Creating CP Project: ' + ex.getDmlMessage(0));
            throw new AuraHandledException('Error While Creating CP Project: ' + ex.getDmlMessage(0));
        }
        
        return (!cpProjectList.isEmpty()) ? cpProjectList[0] : null;
    }

    @AuraEnabled(cacheable=false)
    public static Lead__c getCodeDetails(String projectId, String regCode) {
        System.debug('projectId: ' + projectId);
        System.debug('regCode: ' + regCode);
        
        if (String.isNotBlank(regCode) && String.isNotBlank(projectId)) {
            String queryString = 'SELECT Id, Name, Project__r.Name, Mobile__c, Phone__c, Email__c FROM Lead__c ' +
                'WHERE Name =: regCode ' +
                'AND Project__c = :projectId '+
                'AND IsConverted__c = false';
            
            List<Lead__c> cpList = Database.query(queryString);
            System.debug('cpList: ' + cpList);
            
            if (!cpList.isEmpty()) {
                return cpList[0];
            }
        }
        
        return null;
    }
    
    @AuraEnabled(cacheable=false)
    public static SiteVisitWrapper getSVWrapper(String projectId, String leadId, String oppId, String accId){
        SiteVisitWrapper sv = new SiteVisitWrapper();
        sv.sv.Mobile__c = '';
        sv.sv.Email__c = '';
        Lead__c ld = new Lead__c();
        Account acc = new Account();
        Opportunity__c opp = new Opportunity__c();
        if(String.isNotBlank(accId)){
            acc = [SELECT Id, Salutation, OwnerId, Owner.Name, FirstName, LastName, Flat_No__c,
                   PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Name,
                   BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                   IsPersonAccount, Current_Residence_Configuration__c, Company_Name__c,
                   Ethnicity__c, Age_Group__c, Designation__c, Family_Size__c, Industry__c, Gender__c,
                   Occupation__c, Marital_Status__c, Current_Resident_Status__c,  City__c, Locality__c, Country__c, State__c, Pincode__c,
                   City_1__c, Locality_1__c, Country_1__c, State_1__c, Pincode_1__c,Source_of_Finance__c
                   FROM Account
                   WHERE Id =: accId];
            
            System.debug('acc:-'+ acc);
            if(acc != null){
                if(acc.Source_of_Finance__c != null)
                    sv.sv.Source_of_Finance__c = acc.Source_of_Finance__c;
                if(acc.Current_Residence_Configuration__c != null)
                    sv.sv.Current_Residence_Configuration__c = acc.Current_Residence_Configuration__c;
                if(acc.Current_Residence_Configuration__c != null)
                    sv.sv.Current_Residence_Configuration__c = acc.Current_Residence_Configuration__c;
                if(acc.PersonEmail != null)
                    sv.sv.Email__c = acc.PersonEmail;
                if(acc.Salutation != null)
                    sv.sv.Salutation__c = acc.Salutation;
                if(acc.FirstName != null)
                    sv.sv.First_Name__c = acc.FirstName;
                if(acc.LastName != null)
                    sv.sv.Last_Name__c = acc.LastName;
                if(acc.Ethnicity__c != null)
                    sv.sv.Ethnicity__c = acc.Ethnicity__c;
                if(acc.Age_Group__c != null)
                    sv.sv.Age_Group__c = acc.Age_Group__c;
                if(acc.Designation__c != null)
                    sv.sv.Designation__c = acc.Designation__c;
                if(acc.Ethnicity__c != null)
                    sv.sv.Ethnicity__c = acc.Ethnicity__c;
                if(acc.Family_Size__c != null)
                    sv.sv.Family_Size__c = acc.Family_Size__c;
                if(acc.Industry__c != null)
                    sv.sv.Industry__c = acc.Industry__c;
                if(acc.Gender__c != null)
                    sv.sv.Gender__c = acc.Gender__c; 
                if(acc.PersonMobilePhone != null)
                    sv.sv.Mobile__c = acc.PersonMobilePhone;
                if(acc.Phone != null)
                    sv.sv.Phone__c = acc.Phone;
                if(acc.Alternate_Email__c != null)
                    sv.sv.Alternate_Email_Id__c = acc.Alternate_Email__c;
                if(acc.Marital_Status__c != null)
                    sv.sv.Marital_Status__c = acc.Marital_Status__c;
                if(acc.Company_Name__c != null)
                    sv.sv.Company_Name__c = acc.Company_Name__c;
                if(acc.Occupation__c != null)
                    sv.sv.Occupation__c = acc.Occupation__c;
                if(acc.Current_Resident_Status__c != null)
                    sv.sv.Current_Residence_Status__c = acc.Current_Resident_Status__c;
                
                //Address Details
                if(acc.City__c != null)
                    sv.sv.City__c = acc.City__c;
                if(acc.Locality__c != null)
                    sv.sv.Locality__c = acc.Locality__c;
                if(acc.Country__c != null)
                    sv.sv.Country__c = acc.Country__c;
                if(acc.State__c != null)
                    sv.sv.State__c = acc.State__c;
                if(acc.Pincode__c != null)
                    sv.sv.Pincode__c = acc.Pincode__c;
                
                // Flat no details
                if(acc.Flat_No__c != null){
                    sv.sv.Flat_No__c = acc.Flat_No__c;
                }
                
                //Office Address Details
                if(acc.City_1__c != null)
                    sv.sv.City_1__c = acc.City_1__c;
                if(acc.Locality_1__c != null)
                    sv.sv.Locality_1__c = acc.Locality_1__c;
                if(acc.Country_1__c != null)
                    sv.sv.Country_1__c = acc.Country_1__c;
                if(acc.State_1__c != null)
                    sv.sv.State_1__c = acc.State_1__c;
                if(acc.Pincode_1__c != null)
                    sv.sv.Pincode_1__c = acc.Pincode_1__c;
            }
        }
        
        System.debug('oppId: '+oppId);
        if(String.isNotBlank(acc.Id) && oppId != null && String.isNotBlank(projectId)){
            opp = [SELECT Id, Name, Is_Active__c,  Channel_Partner__c, Channel_Partner__r.OwnerId,Walkin_Referrer_Name__c,
                   Referrer_Name__c, Configuration_Required__c, Budget__c, Lead_Source__c, Buying_Purpose__c, Possession_Timeframe_Required__c,
                   Walkin_Source__c, Walkin_Sub_Source__c, CP_Project__r.OwnerId, CP_Project__c, Preferred_Location__c, Source_of_Finance__c,
                   Source_Description__c, Project_Type__c, Lead_Sub_source__c, Actual_Budget__c, Presales_Manager__c, Project__r.Project_Type__c    
                   
                   FROM Opportunity__c WHERE Account__C =: acc.Id AND Id =:oppId  AND (Project__c = :projectId) 
                   AND (Is_Active__c = true)];
            if(opp != null){
                if(opp.Lead_Source__c != null)
                    sv.sv.Lead_Source__c = opp.Lead_Source__c;
                if(opp.Lead_Sub_source__c != null)
                    sv.sv.Lead_Sub_source__c = opp.Lead_Sub_source__c;
                if(opp.Walkin_Source__c != null)
                    sv.sv.Walk_In_Source__c = opp.Walkin_Source__c;
                if(opp.Walkin_Sub_Source__c != null)
                    sv.sv.Walk_In_Sub_Source__c = opp.Walkin_Sub_Source__c;
                
                if(opp.Lead_Source__c == 'Channel Partner'){
                    sv.sv.Channel_Partner__c = opp.Channel_Partner__c;
                    sv.sv.Sourcing_Manager__c =  opp.CP_Project__r.OwnerId;
                    sv.sv.CP_Project__c = opp.CP_Project__c;
                }
                if(opp.Lead_Source__c == 'Reference'){
                    sv.sv.Referrer_Name__c = opp.Walkin_Referrer_Name__c;
                    system.debug('Reference_Name__c:: '+ sv.sv.Referrer_Name__c);
                }
                if(opp.Walkin_Source__c == 'Channel Partner'){
                    sv.sv.Channel_Partner__c = opp.Channel_Partner__c;
                    sv.sv.Sourcing_Manager__c =  opp.CP_Project__r.OwnerId;
                    sv.sv.CP_Project__c = opp.CP_Project__c;
                }
                
                if(opp.Buying_Purpose__c != null)
                    sv.sv.Buying_Purpose__c = opp.Buying_Purpose__c;
                if(opp.Possession_Timeframe_Required__c != null)
                    sv.sv.Possession_Timeframe_Required__c = opp.Possession_Timeframe_Required__c;
                if(opp.Configuration_Required__c != null)
                    sv.sv.Configuration_Required__c = opp.Configuration_Required__c;
                if(opp.Budget__c != null)
                    sv.sv.Budget__c = opp.Budget__c;  
                if(opp.Actual_Budget__c != null)
                    sv.sv.Actual_Budget__c = opp.Actual_Budget__c;
                if(opp.Preferred_Location__c != null)
                    sv.sv.Preferred_Location__c = opp.Preferred_Location__c;
                if(opp.Source_of_Finance__c != null)
                    sv.sv.Source_of_Finance__c = opp.Source_of_Finance__c;
                if(opp.Source_Description__c != null)
                    sv.sv.Source_Description__c = opp.Source_Description__c;
                if(opp.Project_Type__c != null)
                    sv.sv.Project_Type__c = opp.Project_Type__c;
                
                if(opp.Presales_Manager__c != null)
                    sv.sv.Presales_Manager__c = opp.Presales_Manager__c;
                if(opp.Project__r.Project_Type__c != null)
                    sv.sv.Project_Type__c = opp.Project__r.Project_Type__c;
                System.debug('sv.sv.Project_Type__c.:' + sv.sv.Project_Type__c);
            }
        }
        
        if(String.isNotBlank(leadId) && String.isNotBlank(projectId)){
            ld = [SELECT Id, Salutation__c, Full_Name__c , Mobile__c, Phone__c, OwnerId, Project__c, Owner.FirstName, Owner.LastName,
                  Actual_Budget__c, Age_Group__c, Alternate_Email__c, Apply_Round_Robin__c,Preferred_Location__c,
                  Budget_Range__c, Buying_Purpose__c,
                  Configuration_Required__c, Account__c, Opportunity__c, Possession_Timeframe_Required__c,
                  Created_Date__c, Current_Resident_Configuration__c, Current_Resident_Status__c,
                  Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c,
                  Last_Name__c, Occupation__c, Company_Name__c, Marital_Status__c, Channel_Partner__r.Name, Clash__c, Clash_Details__c,
                  Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c, Referrer_Name__c, Channel_Partner__c,Project__r.Opportunity_Source_TAT__c,
                  Source_of_Finance__c, CP_Project__r.OwnerId, CP_Project__c, Walkin_Source__c, Walkin_Sub_Source__c , Direct_Lead__c, Project_Type__c, Project__r.Project_Type__c
                  FROM Lead__c WHERE Id =: leadId AND Project__c =: projectId AND IsConverted__c = False];
            System.debug('ld: ' + ld);
            if(ld != null){
                if(ld.Salutation__c != null)
                    sv.sv.Salutation__c = ld.Salutation__c;
                if(ld.Mobile__c != null)
                    sv.sv.Mobile__c = ld.Mobile__c;
                if(ld.Phone__c != null)
                    sv.sv.Phone__c = ld.Phone__c;
                if(ld.First_Name__c != null)
                    sv.sv.First_Name__c = ld.First_Name__c;
                if(ld.Last_Name__c != null)
                    sv.sv.Last_Name__c = ld.Last_Name__c;
                if(ld.Project_Type__c != null)
                    sv.sv.Project_Type__c = ld.Project_Type__c;
                if(ld.Project__r.Project_Type__c != null)
                    sv.sv.Project_Type__c = ld.Project__r.Project_Type__c;
                if(ld.Lead_Source__c != null)
                    sv.sv.Lead_Source__c = ld.Lead_Source__c;
                if(ld.Lead_Sub_Source__c != null)
                    sv.sv.Lead_Sub_Source__c = ld.Lead_Sub_Source__c;
                if(ld.Walkin_Source__c != null)
                    sv.sv.Walk_in_Source__c = ld.Walkin_Source__c;
                if(ld.Walkin_Sub_Source__c != null)
                    sv.sv.Walk_in_Sub_Source__c = ld.Walkin_Sub_Source__c;
                if(ld.Lead_Source__c == 'Channel Partner'){
                    sv.sv.Channel_Partner__c = ld.Channel_Partner__c;
                    sv.sv.Sourcing_Manager__c =  ld.CP_Project__r.OwnerId;
                    sv.sv.CP_Project__c = ld.CP_Project__c;
                }
                if(ld.Walkin_Source__c == 'Channel Partner'){
                    sv.sv.Channel_Partner__c = ld.Channel_Partner__c;
                    sv.sv.Sourcing_Manager__c =  ld.CP_Project__r.OwnerId;
                    sv.sv.CP_Project__c = ld.CP_Project__c;
                }
                if(ld.Email__c != null){
                    sv.sv.Email__c = ld.Email__c;
                }
                if(ld.Alternate_Email__c != null)
                    sv.sv.Alternate_Email_Id__c = ld.Alternate_Email__c;
                
                if(ld.Lead_Source__c == 'Reference'){
                    sv.sv.Referrer_Name__c = ld.Referrer_Name__c;
                    system.debug('Reference_Name__c:: '+ sv.sv.Referrer_Name__c);
                }
                
                if(ld.Configuration_Required__c != null)
                    sv.sv.Configuration_Required__c = ld.Configuration_Required__c;
                if(ld.Budget_Range__c != null)
                    sv.sv.Budget__c = ld.Budget_Range__c;
                if(ld.Actual_Budget__c != null)
                    sv.sv.Actual_Budget__c = ld.Actual_Budget__c;
                if(ld.Preferred_Location__c != null)
                    sv.sv.Preferred_Location__c = ld.Preferred_Location__c;
                if(ld.Configuration_Required__c != null)
                    sv.sv.Configuration_Required__c = ld.Configuration_Required__c;
                if(ld.Buying_Purpose__c != null)
                    sv.sv.Buying_Purpose__c = ld.Buying_Purpose__c;
                if(ld.Possession_Timeframe_Required__c != null)
                    sv.sv.Possession_Timeframe_Required__c = ld.Possession_Timeframe_Required__c;
                
                //Demographics Details
                if(ld.Ethnicity__c != null)
                    sv.sv.Ethnicity__c = ld.Ethnicity__c;
                if(ld.Current_Resident_Configuration__c != null)
                    sv.sv.Current_Residence_Configuration__c = ld.Current_Resident_Configuration__c;
                if(ld.Age_Group__c != null)
                    sv.sv.Age_Group__c = ld.Age_Group__c;
                if(ld.Designation__c != null)
                    sv.sv.Designation__c = ld.Designation__c;
                if(ld.Ethnicity__c != null)
                    sv.sv.Ethnicity__c = ld.Ethnicity__c;
                if(ld.Family_Size__c != null)
                    sv.sv.Family_Size__c = ld.Family_Size__c;
                if(ld.Industry__c != null)
                    sv.sv.Industry__c = ld.Industry__c;
                if(ld.Gender__c != null)
                    sv.sv.Gender__c = ld.Gender__c; 
                if(ld.Company_Name__c != null)
                    sv.sv.Company_Name__c = ld.Company_Name__c;
                if(ld.Age_Group__c != null)
                    sv.sv.Age_Group__c = ld.Age_Group__c;
                if(ld.Marital_Status__c != null)
                    sv.sv.Marital_Status__c = ld.Marital_Status__c;
                if(ld.Current_Resident_Status__c != null)
                    sv.sv.Current_Residence_Status__c = ld.Current_Resident_Status__c;
                if(ld.Occupation__c != null){}
                sv.sv.Occupation__c = ld.Occupation__c;
                if(ld.Source_of_Finance__c != null)
                    sv.sv.Source_of_Finance__c = ld.Source_of_Finance__c;
                
                if(ld.Clash__c != null)
                    sv.sv.Clash__c = ld.Clash__c;
                if(ld.Clash_Details__c != null)
                    sv.sv.Clash_Details__c = ld.Clash_Details__c;
                if(ld.OwnerId != null)
                    sv.sv.Presales_Manager__c = ld.OwnerId;
            }
        }
        return sv;
    }
    
    //Search Data according to the Mobile, Email and Project --> Account, Opportunity and Lead
    @AuraEnabled
    public static Map<String, List<SObject>> searchForData(String num, String email,String projectId) {
        List<Lead__c> leadList = new List<Lead__c>();
        List<Account> accountList = new List<Account>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        system.debug('Mobile No .: ' + num);
        system.debug('Email .: ' + email);
        System.debug('Project .: '+projectId);
        
        Map<String, List<SObject>> searchMap = new Map<String, List<SObject>>();
        try {
            if (num != null && String.isNotBlank(num)) {
                accountList = [SELECT Id, Salutation, OwnerId, Owner.Name, FirstName, LastName, 
                               PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Name,
                               BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                               IsPersonAccount, Current_Residence_Configuration__c, Company_Name__c,
                               Ethnicity__c, Age_Group__c, Designation__c, Family_Size__c, Industry__c, Gender__c,
                               City_1__c, Locality_1__c, Country_1__c, State_1__c, Pincode_1__c
                               FROM Account
                               WHERE (PersonMobilePhone = :num OR Phone = :num) AND IsPersonAccount = TRUE];
                System.debug('Mob AccountList .: ' + accountList);
            }
            
            if (accountList.isEmpty() && email != null && String.isNotBlank(email)) {
                accountList = [SELECT Id, Salutation, OwnerId, Owner.Name, FirstName, LastName, 
                               PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Name,
                               BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                               IsPersonAccount, Current_Residence_Configuration__c, Company_Name__c,
                               Ethnicity__c, Age_Group__c, Designation__c, Family_Size__c, Industry__c, Gender__c
                               
                               FROM Account
                               WHERE ((PersonEmail = :email OR Alternate_Email__c = :email) OR 
                                      (PersonMobilePhone = :num OR Phone = :num)) AND IsPersonAccount = TRUE];
                System.debug('Email AccountList: ' + accountList);
            }
            
            if (!accountList.isEmpty()) {
                searchMap.put('Account', accountList);
            }
            System.debug('accountList .: '+accountList);
            if (!accountList.isEmpty()) {
                oppList = [SELECT Id, Name, Account__c, Is_Active__c,  Opportunity_Stage__c, 
                           Project__r.Opportunity_Source_TAT__c, First_Site_Visit_Date__c, Channel_Partner__c, CP_Project__c, 
                           Referrer_Name__c,
                           Project__c, Last_SV_Date__c, Lead_Source__c, Closing_Manager__c, Closing_Manager__r.Name, 
                           Owner.FirstName, Owner.LastName, Lead_Sub_Source__c, Source_Description__c, Walkin_Source__c, Walkin_Sub_Source__c,
                           Last_SV_attended_by__c, Channel_Partner__r.Name , Sourcing_Manager__c, Sourcing_Manager__r.Name
                           FROM Opportunity__c
                           WHERE Account__c =: accountList[0].Id AND (Project__c = :projectId) 
                           AND (Is_Active__c = true) ];
            }
            
            if (!oppList.isEmpty()) {
                searchMap.put('Opportunity .: ', oppList);
            }
            System.debug('oppList .: '+oppList);
            
            if (num != null && String.isNotBlank(num) && (projectId != null && String.isNotBlank(projectId))) {
                
                leadList = [SELECT Id, Salutation__c,  CreatedDate, Last_Presales_Call_Date__c, First_Name__c, 
                            Last_Name__c, Full_Name__c, Mobile__c, Email__c, Phone__c, OwnerId, Project__c, Owner.FirstName,
                            Channel_Partner__c, CP_Project__c, Referrer_Name__c, Direct_Lead__c,
                            Owner.LastName, Channel_Partner__r.Name, Clash__c, Clash_Details__c, Lead_Source__c, Walkin_Source__c,
                            Walkin_Sub_Source__c
                            FROM Lead__c WHERE (Mobile__c = :num OR Phone__c = :num) 
                            AND Project__c =: projectId AND IsConverted__c = False];
                System.debug('leadList .: ' + leadList);
            }
            
            if (leadList.isEmpty() && email != null && String.isNotBlank(email) && projectId != null && String.isNotBlank(projectId)) {
                
                leadList = [SELECT Id, Salutation__c,  CreatedDate, Last_Presales_Call_Date__c, First_Name__c, 
                            Last_Name__c, Full_Name__c, Mobile__c, Phone__c, Email__c, OwnerId, Project__c, Owner.FirstName, 
                            Channel_Partner__c, CP_Project__c, Referrer_Name__c, Direct_Lead__c,
                            Owner.LastName, Channel_Partner__r.Name, Clash__c, Clash_Details__c, Lead_Source__c, Walkin_Source__c,
                            Walkin_Sub_Source__c
                            FROM Lead__c WHERE (Email__c = :email OR Alternate_Email__c = :email) 
                            AND Project__c =: projectId AND IsConverted__c = False];
                
                System.debug('leadList .: ' + leadList);
            }
            if (!leadList.isEmpty()) {
                searchMap.put('Lead', leadList);
            }
            System.debug('searchMap .: ' + searchMap);
            return searchMap;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            // Modified by Priyanshu Agarkar
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            // Modified by Priyanshu Agarkar
        }
    }
    
    @AuraEnabled
    public static List<String> submit(String projectId, String leadId, String oppId, String accId, SiteVisitWrapper svWrapper, 
                                      Boolean changeStatus, String regCode, Boolean isSourceChanged){
                                          System.debug('leadId: '+leadId);
                                          System.debug('oppId: '+oppId);
                                          System.debug('accId: '+accId);
                                          System.debug('svWrapper: '+svWrapper);
                                          Boolean isAccountFound = false;
                                          Boolean isOpportunityFound = false;
                                          Boolean isLeadFound = false;
                                          List<Opportunity__c> oppoList = new List<Opportunity__c>(); 
                                          List<Lead__c> lList = new List<Lead__c>();
                                          List<Account> accList = new List<Account>();
                                          Boolean isSuccess = false;
                                          Boolean isError = false;
                                          List<String> result = new List<String>();
                                          String getNumber = '';
                                          String cpLeadId = '';
                                          String siteHeadApprover = '';
                                          
                                          if(String.isNotBlank(projectId)){
                                              Project__c p = [select Id, Site_Head__c from Project__c where Id =: projectId];
                                              if(p != null && p.Site_Head__c != null){
                                                  siteHeadApprover = p.Site_Head__c;
                                              }
                                          }
                                          
                                          
                                          if(accId != null && String.isNotBlank(accId)){
                                              accList = [Select Id from Account where Id =: accId AND IsPersonAccount = true];
                                              System.debug('accList: '+accList);
                                              if(accList != null && !acclist.isEmpty()){
                                                  isAccountFound = true;
                                                  if(String.isNotBlank(projectId)){
                                                      oppoList = [Select Id, First_Site_Visit_Date__c,  Name, Mobile__c, Email__c, SV_Count__c,Account__c,
                                                                  Project__c ,Project_Type__c, CP_Project__c, /* Edited by Priyanshu Agarkar */ Opportunity_Validity_Date__c, Project__r.Source_TAT__c/* Edited by Priyanshu Agarkar */, 
                                                                  Budget__c,Buying_Purpose__c,Possession_Timeframe_Required__c, OwnerId, Alternate_Email_Id__c, Phone__c, 
                                                                  Project__r.Opportunity_Source_TAT__c, Owner.Name,Project__r.Name, Opportunity_Stage__c ,Last_SV_Date__c, 
                                                                  Owner.FirstName, Owner.LastName , Is_Active__c,Actual_Budget__c,
                                                                  Presales_Manager__c, Account__r.Designation__c, Account__r.Ethnicity__c, Account__r.Family_Size__c, 
                                                                  Account__r.Industry__c, Account__r.Occupation__c, Account__r.Marital_Status__c, Account__r.Age_Group__c, 
                                                                  Account__r.Gender__c, Last_Source_Changed_Date__c,Account__r.Source_of_Finance__c,
                                                                  Lead_Source__c, Lead_Sub_Source__c, Walkin_Source__c, Walkin_Sub_Source__c, Preferred_Location__c, 
                                                                  Sourcing_Manager__c, CP_Project__r.OwnerId, Source_Description__c, Account__r.Current_Residence_Configuration__c, 
                                                                  Referrer_Name__c, Configuration_Required__c, Account__r.Company_Name__c,Account__r.Current_Resident_Status__c ,
                                                                  Channel_Partner__c, Channel_Partner__r.Name, Sourcing_Manager__r.Name, Is_Serviced__c,
                                                                  Account__r.PersonEmail, Project__r.Project_Type__c,Walkin_Referrer_Name__c  
                                                                  FROM Opportunity__c
                                                                  where (Account__c =: accId) AND Project__c =: projectId AND Is_Active__c = true];
                                                      System.debug('oppoList is::'+oppoList);
                                                  }
                                                  if(!oppoList.isEmpty() && oppoList != null){
                                                      isOpportunityFound = true;
                                                  }
                                              }
                                          }
                                          
                                          if(leadId != null && String.isNotBlank(projectId)){
                                              lList = [Select Id, Mobile__c,  Phone__c, OwnerId,  Project__c, Actual_Budget__c, Age_Group__c, Alternate_Email__c, Apply_Round_Robin__c,
                                                       Budget_Range__c, Buying_Purpose__c, CP_Project__c, CP_Project__r.OwnerId,
                                                       Configuration_Required__c, Account__c, Opportunity__c, Possession_Timeframe_Required__c,
                                                       Created_Date__c, Current_Resident_Configuration__c, Current_Resident_Status__c,
                                                       Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c,Conveted_DateTime__c,
                                                       Last_Name__c, Occupation__c, Company_Name__c, Marital_Status__c, Is_Serviced__c,Project__r.Opportunity_Source_TAT__c,
                                                       Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c, Referrer_Name__c, Channel_Partner__c,
                                                       Source_Description__c, Presales_Next_Follow_up_Date__c, Presales_Call_Count__c, Last_Presales_Call_Date__c, Presales_Date_of_Visit__c,
                                                       Presales_Call_Comment__c, Presales_Comment_History__c,   Clash__c, Clash_Details__c, Project_Type__c, Source_of_Finance__c, Walkin_Source__c, Walkin_Sub_Source__c,
                                                       Preferred_Location__c, Direct_Lead__c, Project__r.Project_Type__c     from Lead__c where Id =:leadId AND Project__c = :projectId AND IsConverted__c = false];
                                              system.debug('lList is::'+lList);
                                              if(!lList.isEmpty() && lList != null){
                                                  isLeadFound = true;
                                              }
                                              
                                          }
                                         
                                          
                                          
                                          System.debug('isOpportunityFound: '+isOpportunityFound);
                                          System.debug('isLeadFound: '+isLeadFound);
                                          System.debug('isAccountFound: '+isAccountFound);
                                          
                                          if(isAccountFound) {
                                              if((isAccountFound && isOpportunityFound) && !isLeadFound) {
                                                  try {
                                                      Site_Visit__c sv = new Site_Visit__c();
                                                      sv.Opportunity__c = oppoList[0].Id;
                                                      sv.OwnerId = oppoList[0].OwnerId;
                                                      sv.Sales_Manager__c = oppoList[0].OwnerId;
                                                      if(oppoList[0].SV_Count__c == Null || oppoList[0].SV_Count__c == 0)
                                                          sv.SV_Count__c = 1;
                                                      else
                                                          sv.SV_Count__c = oppoList[0].SV_Count__c + 1;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      sv.Email__c = svWrapper.sv.Email__c;
                                                      sv.Project__c = projectId;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      if(svWrapper.sv.Phone__c != null)
                                                          sv.Phone__c = svWrapper.sv.Phone__c;
                                                      if(svWrapper.sv.Alternate_Email_Id__c != null)
                                                          sv.Alternate_Email_Id__c = svWrapper.sv.Alternate_Email_Id__c;
                                                      if(svWrapper.sv.Clash__c != null)
                                                          sv.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      if(svWrapper.sv.Walk_In_source__c != null)
                                                          sv.Walk_In_source__c = svWrapper.sv.Walk_In_source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_source__c != null)
                                                          sv.Walk_In_Sub_source__c = svWrapper.sv.Walk_In_Sub_source__c;
                                                      
                                                      if(!oppoList.isEmpty() && oppoList != null){
                                                          System.debug('oppoList: For Existing Opp: '+ oppoList);
                                                          if(oppoList[0].Project__c != null)
                                                              sv.Project__c = oppoList[0].Project__c ;
                                                          // Modified : Priyanshu Agarkar
                                                          if(oppoList[0].Project__r.Project_Type__c != null)
                                                              sv.Project_Type__c = oppoList[0].Project__r.Project_Type__c;
                                                          System.debug('sv.Project_Type__c.:' + sv.Project_Type__c);
                                                          // Modification end
                                                          
                                                          //Modified : Harshal More
                                                          if(svWrapper.sv.Walk_In_Source__c != null)
                                                              oppoList[0].Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                          if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                              oppoList[0].Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                          
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Referrer_Name__c != null)
                                                                  oppoList[0].Walkin_Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                          }
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Channel_Partner__c != null)
                                                                  oppoList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                              if(svWrapper.sv.CP_Project__c != null)
                                                                  oppoList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                              if(svWrapper.sv.Sourcing_Manager__c != null)
                                                                  oppoList[0].Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                          }
                                                          //Modified : Harshal More
                                                          
                                                          //source Details
                                                          if(oppoList[0].Lead_Source__c != null)
                                                              sv.Lead_Source__c = oppoList[0].Lead_Source__c ;
                                                          if(oppoList[0].Lead_Sub_Source__c != null)
                                                              sv.Lead_Sub_Source__c = oppoList[0].Lead_Sub_Source__c ;
                                                          if(oppoList[0].Source_Description__c != null)
                                                              sv.Source_Description__c = oppoList[0].Source_Description__c;
                                                          if(oppoList[0].Project_Type__c != null)
                                                              sv.Project_Type__c = oppoList[0].Project_Type__c;
                                                          if(oppoList[0].Budget__c != null)
                                                              sv.Budget__c = oppoList[0].Budget__c;
                                                          if(oppoList[0].Buying_Purpose__c != null)
                                                              sv.Buying_Purpose__c = oppoList[0].Buying_Purpose__c;
                                                          if(oppoList[0].Possession_Timeframe_Required__c != null)
                                                              sv.Possession_Timeframe_Required__c = oppoList[0].Possession_Timeframe_Required__c;
                                                          if(oppoList[0].Actual_Budget__c != null)
                                                              sv.Actual_Budget__c = oppoList[0].Actual_Budget__c;
                                                          if(oppoList[0].Preferred_Location__c != null)
                                                              sv.Preferred_Location__c = oppoList[0].Preferred_Location__c;
                                                          if(oppoList[0].Account__r.Age_Group__c != null)
                                                              sv.Age_Group__c = oppoList[0].Account__r.Age_Group__c;
                                                          if(oppoList[0].Account__r.Gender__c != null)
                                                              sv.Gender__c = oppoList[0].Account__r.Gender__c;
                                                          if(oppoList[0].Account__r.Occupation__c != null)
                                                              sv.Occupation__c = oppoList[0].Account__r.Occupation__c;
                                                          if(oppoList[0].Account__r.Designation__c != null)
                                                              sv.Designation__c = oppoList[0].Account__r.Designation__c;
                                                          if(oppoList[0].Account__r.Marital_Status__c != null)
                                                              sv.Marital_Status__c = oppoList[0].Account__r.Marital_Status__c;
                                                          if(oppoList[0].Account__r.Current_Residence_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = oppoList[0].Account__r.Current_Residence_Configuration__c;
                                                          if(oppoList[0].Walkin_Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = oppoList[0].Walkin_Referrer_Name__c;
                                                          if(oppoList[0].Configuration_Required__c != null)
                                                              sv.Configuration_Required__c = oppoList[0].Configuration_Required__c;
                                                          if(oppoList[0].Account__r.Ethnicity__c != null)
                                                              sv.Ethnicity__c = oppoList[0].Account__r.Ethnicity__c;
                                                          if(oppoList[0].Account__r.Family_Size__c != null)
                                                              sv.Family_Size__c = oppoList[0].Account__r.Family_Size__c;
                                                          if(oppoList[0].Account__r.Industry__c != null)
                                                              sv.Industry__c = oppoList[0].Account__r.Industry__c;
                                                          if(oppoList[0].Account__r.Current_Resident_Status__c != null)
                                                              sv.Current_Residence_Status__c = oppoList[0].Account__r.Current_Resident_Status__c;
                                                          if(oppoList[0].Account__r.Current_Residence_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = oppoList[0].Account__r.Current_Residence_Configuration__c;
                                                          if(oppoList[0].Account__r.Source_of_Finance__c != null)
                                                              sv.Source_of_Finance__c = oppoList[0].Account__r.Source_of_Finance__c;
                                                          if(oppoList[0].Account__r.Company_Name__c != null)
                                                              sv.Company_Name__c = oppoList[0].Account__r.Company_Name__c;
                                                          if(oppoList[0].Account__r.PersonEmail != null) 
                                                              sv.Email__c = oppoList[0].Account__r.PersonEmail;
                                                          if(oppoList[0].Presales_Manager__c != null)
                                                              sv.Presales_Manager__c = oppoList[0].Presales_Manager__c;
                                                          
                                                          if(oppoList[0].Lead_Source__c == 'Channel Partner'){
                                                              if(oppoList[0].Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = oppoList[0].Channel_Partner__c;
                                                              if(oppoList[0].Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = oppoList[0].Sourcing_Manager__c;
                                                              if(oppoList[0].CP_Project__c != null)
                                                                  sv.CP_Project__c = oppoList[0].CP_Project__c;
                                                          }
                                                          
                                                          if(oppoList[0].Walkin_Source__c == 'Channel Partner'){
                                                              if(oppoList[0].Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = oppoList[0].Channel_Partner__c;
                                                              if(oppoList[0].Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = oppoList[0].Sourcing_Manager__c;
                                                              if(oppoList[0].CP_Project__c != null)
                                                                  sv.CP_Project__c = oppoList[0].CP_Project__c;
                                                          }
                                                          if(svWrapper.sv.Industry__c != null)
                                                              sv.Industry__c = svWrapper.sv.Industry__c;
                                                          
                                                          //Address Details
                                                          if(svWrapper.sv.City__c != null)
                                                              sv.City__c = svWrapper.sv.City__c;
                                                          if(svWrapper.sv.Locality__c != null)
                                                              sv.Locality__c = svWrapper.sv.Locality__c;
                                                          if(svWrapper.sv.Country__c != null)
                                                              sv.Country__c = svWrapper.sv.Country__c;
                                                          if(svWrapper.sv.State__c != null)
                                                              sv.State__c = svWrapper.sv.State__c;
                                                          if(svWrapper.sv.Pincode__c != null)
                                                              sv.Pincode__c = svWrapper.sv.Pincode__c;
                                                          
                                                          // Flat no details
                                                          if(svWrapper.sv.Flat_No__c != null){
                                                              sv.Flat_No__c = svWrapper.sv.Flat_No__c;
                                                          }
                                                          //office Address Details
                                                          if(svWrapper.sv.City_1__c != null)
                                                              sv.City_1__c = svWrapper.sv.City_1__c;
                                                          if(svWrapper.sv.Locality_1__c != null)
                                                              sv.Locality_1__c = svWrapper.sv.Locality_1__c;
                                                          if(svWrapper.sv.Country_1__c != null)
                                                              sv.Country_1__c = svWrapper.sv.Country_1__c;
                                                          if(svWrapper.sv.State_1__c != null)
                                                              sv.State_1__c = svWrapper.sv.State_1__c;
                                                          if(svWrapper.sv.Pincode_1__c != null)
                                                              sv.Pincode_1__c = svWrapper.sv.Pincode_1__c;
                                                          
                                                          if(svWrapper.sv.Walk_In_Source__c != svWrapper.sv.Lead_Source__c){
                                                              if(String.isNotBlank(siteHeadApprover))
                                                                  sv.Site_Visit_Approver__c = siteHeadApprover;
                                                          }
                                                      }
                                                      insert sv;
                                                      result.add(sv.Id);                    
                                                      if(oppoList[0].First_Site_Visit_Date__c != null)
                                                          oppoList[0].First_Site_Visit_Date__c = oppoList[0].First_Site_Visit_Date__c;
                                                      
                                                      /* Edited by Priyanshu Agarkar */
                                                      
                                                      System.debug('Before: '+oppoList[0].SV_Count__c);
                                                      if(oppoList[0].SV_Count__c == Null || oppoList[0].SV_Count__c == 0)
                                                          oppoList[0].SV_Count__c = 1;
                                                      else
                                                          oppoList[0].SV_Count__c = oppoList[0].SV_Count__c + 1;
                                                      oppoList[0].Last_SV_Date__c = sv.Site_Visit_Date__c;
                                                      System.debug('Aftre: '+oppoList[0].SV_Count__c);
                                                      if(isSourceChanged == true){
                                                          oppoList[0].Last_Source_Changed_Date__c = system.today();
                                                      }
                                                      
                                                      // Modified By Priyanshu Agarkar
                                                      oppoList[0].Latest_Enquiry_Date__c = system.now(); 
                                                      oppoList[0].Is_Serviced__c = false;
                                                      update oppoList[0];
                                                      system.debug('Latest Enquiry Date set in Opportunity: ' + oppoList[0].Latest_Enquiry_Date__c);
                                                      // Modified By Priyanshu Agarkar
                                                      
                                                      // update oppoList[0];
                                                      List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                                                      isSuccess = true;
                                                      System.debug('Success Accountfound && OpportunityFound :'+lstSV);
                                                  }catch(Exception Ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur '+ Ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  }
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }                
                                              } 
                                              else if(!isOpportunityFound && (isLeadFound  && isAccountFound)) {
                                                  try {
                                                      System.debug('isAccountFound: '+isAccountFound + 'isLeadFound: '+isLeadFound);
                                                      lList[0].Salutation__c = svWrapper.sv.Salutation__c;
                                                      lList[0].First_Name__c = svWrapper.sv.First_Name__c;
                                                      lList[0].Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      lList[0].Lead_Stage__c = 'Visit Done';
                                                      lList[0].Lead_Sub_Stage__c = 'Visit Done';
                                                      lList[0].Conveted_DateTime__c = System.Now();
                                                      lList[0].IsConverted__c = true;
                                                      if(svWrapper.sv.Budget__c != null)
                                                          lList[0].Budget_Range__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          lList[0].Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          lList[0].Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          lList[0].Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          lList[0].Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          lList[0].Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          lList[0].Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          lList[0].Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          lList[0].Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          lList[0].Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          lList[0].Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          lList[0].Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          lList[0].Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          lList[0].Occupation__c = svWrapper.sv.Occupation__c;
                                                      System.debug('lList[0].Occupation__c: ' + lList[0].Occupation__c);
                                                      if(svWrapper.sv.Industry__c != null)
                                                          lList[0].Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          lList[0].Designation__c = svWrapper.sv.Designation__c;
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          lList[0].Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_Source__c != null)
                                                          lList[0].Lead_Sub_Source__c = svWrapper.sv.Lead_Sub_Source__c;
                                                      //Modified : Harshal More
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          lList[0].Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          lList[0].Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              lList[0].Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              lList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              lList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      //Modified : Harshal More
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              lList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              lList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      if(svWrapper.sv.Clash__c != null)
                                                          lList[0].Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          lList[0].Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      if(svWrapper.sv.Project_Type__c != null)
                                                          lList[0].Project_Type__c = svWrapper.sv.Project_Type__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          lList[0].Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      
                                                      update lList[0];
                                                      List<Lead__c> newLeadLst = new List<Lead__c>();
                                                      newLeadLst.add(lList[0]);
                                                      
                                                      if(!newLeadLst.isEmpty() && newLeadLst != null){
                                                          Ex_LeadConversionServices.convertLead(newLeadLst);
                                                      }
                                                      
                                                      Lead__c convertedLead = [Select Account__c, Opportunity__c from Lead__c where Id =: lList[0].Id AND IsConverted__c = true];
                                                      system.debug('Converted Lead: '+convertedLead);
                                                      
                                                      Opportunity__c convertedOpp =  [SELECT Id, Name, SV_Count__c ,First_Site_Visit_Date__c, Last_SV_Date__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                                                      system.debug('Converted Opportunity: '+convertedOpp);
                                                      
                                                      // Modified By Priyanshu Agarkar
                                                      convertedOpp.Latest_Enquiry_Date__c = system.now();
                                                      convertedOpp.Is_Serviced__c = false;
                                                      update convertedOpp;
                                                      system.debug('Latest Enquiry Date set in Opportunity: ' + convertedOpp.Latest_Enquiry_Date__c);
                                                      // Modified By Priyanshu Agarkar
                                                      
                                                      //Tag Site Visit Against Opportunity
                                                      Site_Visit__c sv = new Site_Visit__c();
                                                      if(convertedLead.Opportunity__c != null)
                                                          sv.Opportunity__c = convertedLead.Opportunity__c;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      sv.Email__c = svWrapper.sv.Email__c;
                                                      sv.Project__c = projectId;
                                                      sv.SV_Count__c = 1;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      // Modified by Priyanshu Agarkar
                                                      if(sv.Clash__c = true && sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      if(svWrapper.sv.Phone__c != null)
                                                          sv.Phone__c = svWrapper.sv.Phone__c;
                                                      if(svWrapper.sv.Alternate_Email_Id__c != null)
                                                          sv.Alternate_Email_Id__c = svWrapper.sv.Alternate_Email_Id__c;
                                                      
                                                      if(!lList.isEmpty() && lList != null){
                                                          //source Details
                                                          if(lList[0].Lead_Source__c != null)
                                                              sv.Lead_Source__c = lList[0].Lead_Source__c ;
                                                          if(lList[0].Lead_Sub_Source__c != null)
                                                              sv.Lead_Sub_Source__c = lList[0].Lead_Sub_Source__c ;
                                                          if(lList[0].Source_Description__c != null)
                                                              sv.Source_Description__c = lList[0].Source_Description__c ;
                                                          // Walkin Source Details
                                                          // Modified : Priyanshu Agarkar
                                                          if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                              sv.Approval_Status__c = 'Pending for Approval';
                                                          // Modified by Priyanshu Agarkar
                                                          if(svWrapper.sv.Walk_In_Source__c != null)
                                                              sv.Walk_In_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                          if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                              sv.Walk_In_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                          
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                              if(svWrapper.sv.CP_Project__c != null)
                                                                  sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                              if(svWrapper.sv.Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                          }
                                                          
                                                          //Reference Name
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Referrer_Name__c != null)
                                                                  sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                          }
                                                          if(svWrapper.sv.Lead_Source__c == 'Reference' && svWrapper.sv.Lead_Source__c != null){
                                                              if(svWrapper.sv.Referrer_Name__c != null)
                                                                  sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                          }
                                                          
                                                          if(svWrapper.sv.Clash__c != null)
                                                              sv.Clash__c = svWrapper.sv.Clash__c;
                                                          if(svWrapper.sv.Clash_Details__c != null)
                                                              sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                          
                                                          //Requirement Details
                                                          if(svWrapper.sv.Current_Residence_Status__c != null)
                                                              sv.Current_Residence_Status__c = svWrapper.sv.Current_Residence_Status__c; 
                                                          if(svWrapper.sv.Configuration_Required__c != null)
                                                              sv.Configuration_Required__c = SvWrapper.sv.Configuration_Required__c;
                                                          if(svWrapper.sv.Budget__c != null)
                                                              sv.Budget__c = svWrapper.sv.Budget__c;
                                                          if(svWrapper.sv.Actual_Budget__c != null)
                                                              sv.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                          if(svWrapper.sv.Preferred_Location__c != null)
                                                              sv.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                          if(svWrapper.sv.Buying_Purpose__c != null)
                                                              sv.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                          if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                              sv.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                          
                                                          //Demograhics Details
                                                          if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                          if(svWrapper.sv.Source_of_Finance__c != null)
                                                              sv.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                          if(svWrapper.sv.Ethnicity__c != null)
                                                              sv.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                          if(svWrapper.sv.Age_Group__c != null)
                                                              sv.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                          if(svWrapper.sv.Marital_Status__c != null)
                                                              sv.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                          if(svWrapper.sv.Family_Size__c != null)
                                                              sv.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                          if(svWrapper.sv.Gender__c != null)
                                                              sv.Gender__c = svWrapper.sv.Gender__c;
                                                          if(svWrapper.sv.Company_Name__c != null)
                                                              sv.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                          if(svWrapper.sv.Occupation__c != null)
                                                              sv.Occupation__c = svWrapper.sv.Occupation__c;
                                                          System.debug('sv.Occupation__c:=' + sv.Occupation__c);
                                                          if(svWrapper.sv.Industry__c != null)
                                                              sv.Industry__c = svWrapper.sv.Industry__c;
                                                          if(svWrapper.sv.Designation__c != null)
                                                              sv.Designation__c = svWrapper.sv.Designation__c;
                                                          
                                                          //Address Details
                                                          if(svWrapper.sv.City__c != null)
                                                              sv.City__c = svWrapper.sv.City__c;
                                                          if(svWrapper.sv.Locality__c != null)
                                                              sv.Locality__c = svWrapper.sv.Locality__c;
                                                          if(svWrapper.sv.Country__c != null)
                                                              sv.Country__c = svWrapper.sv.Country__c;
                                                          if(svWrapper.sv.State__c != null)
                                                              sv.State__c = svWrapper.sv.State__c;
                                                          if(svWrapper.sv.Pincode__c != null)
                                                              sv.Pincode__c = svWrapper.sv.Pincode__c;
                                                          
                                                          // Flat no details
                                                          if(svWrapper.sv.Flat_No__c != null){
                                                              sv.Flat_No__c = svWrapper.sv.Flat_No__c;
                                                          }
                                                          //office Address Details
                                                          if(svWrapper.sv.City_1__c != null)
                                                              sv.City_1__c = svWrapper.sv.City_1__c;
                                                          if(svWrapper.sv.Locality_1__c != null)
                                                              sv.Locality_1__c = svWrapper.sv.Locality_1__c;
                                                          if(svWrapper.sv.Country_1__c != null)
                                                              sv.Country_1__c = svWrapper.sv.Country_1__c;
                                                          if(svWrapper.sv.State_1__c != null)
                                                              sv.State_1__c = svWrapper.sv.State_1__c;
                                                          if(svWrapper.sv.Pincode_1__c != null)
                                                              sv.Pincode_1__c = svWrapper.sv.Pincode_1__c;
                                                          
                                                          if(svWrapper.sv.Walk_In_Source__c != svWrapper.sv.Lead_Source__c){
                                                              if(String.isNotBlank(siteHeadApprover))
                                                                  sv.Site_Visit_Approver__c = siteHeadApprover;
                                                          }
                                                      }
                                                      insert sv;
                                                      result.add(sv.Id);
                                                      
                                                      //Update Opportunity
                                                      convertedOpp.SV_Count__c = 1;
                                                      convertedOpp.First_Site_Visit_Date__c = system.now();
                                                      convertedOpp.Last_SV_Date__c =  sv.Site_Visit_Date__c;
                                                      convertedOpp.Sourcing_Manager__c = sv.Sourcing_Manager__c;
                                                      update convertedOpp;
                                                      
                                                      List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                                                      isSuccess = true;
                                                      System.debug('Success Accountfound && isLeadFound :'+ lstSV);
                                                      
                                                  }catch(Exception ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur '+ Ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  }
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }
                                                  
                                              } 
                                              else if(!isOpportunityFound && !isLeadFound) {
                                                  System.debug('only Account Found: '+isAccountFound);
                                                  try {
                                                      Lead__c l = new Lead__c();
                                                      List<Project__c> pList = new List<Project__c>();
                                                      l.Salutation__c = svWrapper.sv.Salutation__c;
                                                      l.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      l.First_Name__c = svWrapper.sv.First_Name__c;
                                                      l.Mobile__c =  svWrapper.sv.Mobile__c;
                                                      l.Email__c = svWrapper.sv.Email__c;
                                                      l.Project__c = projectId;
                                                      l.IsConverted__c = true;
                                                      l.Lead_Stage__c = 'Visit Done';
                                                      l.Lead_Sub_Stage__c = 'Visit Done';
                                                      l.Conveted_DateTime__c = System.Now();
                                                      l.OwnerId = UserInfo.getUserId();
                                                      
                                                      //source Details
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          l.Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_Source__c != null)
                                                          l.Lead_Sub_Source__c = svWrapper.sv.Lead_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              l.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              l.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      
                                                      // Walkin Source Details
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          l.Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          l.Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              l.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              l.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      //Reference Name
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              l.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Lead_Source__c == 'Reference' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              l.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      //Clash Details
                                                      if(svWrapper.sv.Clash__c != null)
                                                          l.Clash__c = svWrapper.sv.Clash__c;      
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          l.Clash_Details__c = svWrapper.sv.Clash_Details__c;  
                                                      
                                                      //Requirement Details
                                                      if(svWrapper.sv.Current_Residence_Status__c != null)
                                                          l.Current_Resident_Status__c = svWrapper.sv.Current_Residence_Status__c; 
                                                      if(svWrapper.sv.Configuration_Required__c != null)
                                                          l.Configuration_Required__c = SvWrapper.sv.Configuration_Required__c;
                                                      if(svWrapper.sv.Budget__c != null)
                                                          l.Budget_Range__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          l.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          l.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          l.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          l.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      
                                                      //Demograhics Details
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          l.Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          l.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          l.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          l.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          l.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          l.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          l.Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          l.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          l.Occupation__c = svWrapper.sv.Occupation__c;
                                                      System.debug('l.Occupation__c:=' + l.Occupation__c);
                                                      if(svWrapper.sv.Industry__c != null)
                                                          l.Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          l.Designation__c = svWrapper.sv.Designation__c;
                                                      insert l;
                                                      
                                                      List<Lead__c> leadList1 = new List<Lead__c>();
                                                      leadList1.add(l);
                                                      
                                                      if(!leadList1.isEmpty() && leadList1 != null){
                                                          Ex_LeadConversionServices.convertLead(leadList1);
                                                      }
                                                      
                                                      Lead__c convertedLead = [Select Account__c, Opportunity__c from Lead__c where Id =: leadList1[0].Id AND IsConverted__c = true];
                                                      system.debug('Converted Lead: '+convertedLead);
                                                      
                                                      Opportunity__c convertedOpp =  [SELECT Id, Name, SV_Count__c ,First_Site_Visit_Date__c, Last_SV_Date__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                                                      system.debug('Converted Opportunity: '+convertedOpp);
                                                      
                                                      //Tag Site Visit Against Converted Opportunity
                                                      Site_Visit__c sv = new Site_Visit__c();
                                                      sv.Opportunity__c = convertedOpp.Id;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      sv.Email__c = svWrapper.sv.Email__c;
                                                      sv.Project__c = projectId;
                                                      sv.SV_Count__c = 1;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      
                                                      //source Details
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          sv.Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_Source__c != null)
                                                          sv.Lead_Sub_Source__c = svWrapper.sv.Lead_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                          if(svWrapper.sv.Sourcing_Manager__c != null)
                                                              sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                      }
                                                      // Walkin Source Details
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          sv.Walk_In_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          sv.Walk_In_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                          if(svWrapper.sv.Sourcing_Manager__c != null)
                                                              sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                      }
                                                      //Reference Name
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Lead_Source__c == 'Reference' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Clash__c != null)
                                                          sv.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      //Requirement Details
                                                      if(svWrapper.sv.Current_Residence_Status__c != null)
                                                          sv.Current_Residence_Status__c = svWrapper.sv.Current_Residence_Status__c; 
                                                      if(svWrapper.sv.Configuration_Required__c != null)
                                                          sv.Configuration_Required__c = SvWrapper.sv.Configuration_Required__c;
                                                      if(svWrapper.sv.Budget__c != null)
                                                          sv.Budget__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          sv.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          sv.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          sv.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          sv.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      
                                                      //Demograhics Details
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          sv.Current_Residence_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          sv.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          sv.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          sv.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          sv.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          sv.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          sv.Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          sv.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          sv.Occupation__c = svWrapper.sv.Occupation__c;
                                                      System.debug('sv.Occupation__c:= ' + sv.Occupation__c);
                                                      if(svWrapper.sv.Industry__c != null)
                                                          sv.Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          sv.Designation__c = svWrapper.sv.Designation__c;
                                                      
                                                      //Address Details
                                                      if(svWrapper.sv.City__c != null)
                                                          sv.City__c = svWrapper.sv.City__c;
                                                      if(svWrapper.sv.Locality__c != null)
                                                          sv.Locality__c = svWrapper.sv.Locality__c;
                                                      if(svWrapper.sv.Country__c != null)
                                                          sv.Country__c = svWrapper.sv.Country__c;
                                                      if(svWrapper.sv.State__c != null)
                                                          sv.State__c = svWrapper.sv.State__c;
                                                      if(svWrapper.sv.Pincode__c != null)
                                                          sv.Pincode__c = svWrapper.sv.Pincode__c;
                                                      
                                                      // Flat no details
                                                      if(svWrapper.sv.Flat_No__c != null){
                                                          sv.Flat_No__c = svWrapper.sv.Flat_No__c;
                                                      }
                                                      //office Address Details
                                                      if(svWrapper.sv.City_1__c != null)
                                                          sv.City_1__c = svWrapper.sv.City_1__c;
                                                      if(svWrapper.sv.Locality_1__c != null)
                                                          sv.Locality_1__c = svWrapper.sv.Locality_1__c;
                                                      if(svWrapper.sv.Country_1__c != null)
                                                          sv.Country_1__c = svWrapper.sv.Country_1__c;
                                                      if(svWrapper.sv.State_1__c != null)
                                                          sv.State_1__c = svWrapper.sv.State_1__c;
                                                      if(svWrapper.sv.Pincode_1__c != null)
                                                          sv.Pincode_1__c = svWrapper.sv.Pincode_1__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c != svWrapper.sv.Lead_Source__c){
                                                          if(String.isNotBlank(siteHeadApprover))
                                                              sv.Site_Visit_Approver__c = siteHeadApprover;
                                                      }
                                                      sv.OwnerId = UserInfo.getUserId();
                                                      insert sv;
                                                      result.add(sv.Id);
                                                      
                                                      Project__c relatedProject = [SELECT Project_Type__c FROM Project__c WHERE Id = :projectId LIMIT 1];
                                                      //Update Opportunity
                                                      convertedOpp.SV_Count__c = 1;
                                                      convertedOpp.Last_SV_Date__c =  System.now();
                                                      convertedOpp.First_Site_Visit_Date__c = system.now();
                                                      convertedOpp.Project_Type__c = relatedProject.Project_Type__c;
                                                      convertedOpp.Sourcing_Manager__c = sv.Sourcing_Manager__c;
                                                      update convertedOpp;
                                                      
                                                      List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                                                      
                                                      isSuccess = true;
                                                      System.debug('Success Accountfound :'+ lstSV);
                                                  }catch(Exception ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur '+ Ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  }
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }
                                              }
                                              else if(isOpportunityFound && isLeadFound){
                                                  System.debug('Inside Opp && Lead');
                                                  Site_Visit__c sv = new Site_Visit__c();
                                                  try{
                                                      
                                                      sv.Opportunity__c = oppoList[0].Id;
                                                      sv.OwnerId = oppoList[0].OwnerId;
                                                      sv.Sales_Manager__c = oppoList[0].OwnerId;
                                                      if(oppoList[0].SV_Count__c == Null || oppoList[0].SV_Count__c == 0)
                                                          sv.SV_Count__c = 1;
                                                      else
                                                          sv.SV_Count__c = oppoList[0].SV_Count__c + 1;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      sv.Email__c = svWrapper.sv.Email__c;
                                                      sv.Project__c = projectId;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      
                                                      // Modified by Priyanshu Agarkar
                                                      if(sv.Clash__c = true && sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      
                                                      if(svWrapper.sv.Phone__c != null)
                                                          sv.Phone__c = svWrapper.sv.Phone__c;
                                                      if(svWrapper.sv.Alternate_Email_Id__c != null)
                                                          sv.Alternate_Email_Id__c = svWrapper.sv.Alternate_Email_Id__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                          if(svWrapper.sv.Sourcing_Manager__c != null)
                                                              sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                      }
                                                      
                                                      if(svWrapper.sv.Clash__c != null)
                                                          sv.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      if(svWrapper.sv.Project_Type__c != null)
                                                          sv.Project_Type__c = svWrapper.sv.Project_Type__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          sv.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      
                                                      oppoList[0].Latest_Enquiry_Date__c = system.today(); 
                                                      // Modified by Priyanshu Agarkar
                                                      
                                                      if(!oppoList.isEmpty() && oppoList != null){
                                                          System.debug('oppoList: For Existing Opp: '+ oppoList);
                                                          //Modified : Harshal More
                                                          if(svWrapper.sv.Walk_In_Source__c != null)
                                                              oppoList[0].Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                          if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                              oppoList[0].Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Referrer_Name__c != null)
                                                                  oppoList[0].Walkin_Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                          }
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Channel_Partner__c != null)
                                                                  oppoList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                              if(svWrapper.sv.CP_Project__c != null)
                                                                  oppoList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                              if(svWrapper.sv.Sourcing_Manager__c != null)
                                                                  oppoList[0].Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                          }
                                                          
                                                          //Modified : Harshal More
                                                          if(oppoList[0].Project__c != null)
                                                              sv.Project__c = oppoList[0].Project__c ;
                                                          //source Details
                                                          if(oppoList[0].Lead_Source__c != null)
                                                              sv.Lead_Source__c = oppoList[0].Lead_Source__c ;
                                                          if(oppoList[0].Lead_Sub_Source__c != null)
                                                              sv.Lead_Sub_Source__c = oppoList[0].Lead_Sub_Source__c ;
                                                          if(oppoList[0].Source_Description__c != null)
                                                              sv.Source_Description__c = oppoList[0].Source_Description__c;
                                                          if(oppoList[0].Project_Type__c != null)
                                                              sv.Project_Type__c = oppoList[0].Project_Type__c;
                                                          if(oppoList[0].Budget__c != null)
                                                              sv.Budget__c = oppoList[0].Budget__c;
                                                          if(oppoList[0].Actual_Budget__c != null)
                                                              sv.Actual_Budget__c = oppoList[0].Actual_Budget__c;
                                                          if(oppoList[0].Preferred_Location__c != null)
                                                              sv.Preferred_Location__c = oppoList[0].Preferred_Location__c;
                                                          if(oppoList[0].Buying_Purpose__c != null)
                                                              sv.Buying_Purpose__c = oppoList[0].Buying_Purpose__c;
                                                          if(oppoList[0].Possession_Timeframe_Required__c != null)
                                                              sv.Possession_Timeframe_Required__c = oppoList[0].Possession_Timeframe_Required__c;
                                                          if(oppoList[0].Account__r.Age_Group__c != null)
                                                              sv.Age_Group__c = oppoList[0].Account__r.Age_Group__c;
                                                          if(oppoList[0].Account__r.Gender__c != null)
                                                              sv.Gender__c = oppoList[0].Account__r.Gender__c;
                                                          if(oppoList[0].Account__r.Occupation__c != null)
                                                              sv.Occupation__c = oppoList[0].Account__r.Occupation__c;
                                                          if(oppoList[0].Account__r.Designation__c != null)
                                                              sv.Designation__c = oppoList[0].Account__r.Designation__c;
                                                          if(oppoList[0].Account__r.Marital_Status__c != null)
                                                              sv.Marital_Status__c = oppoList[0].Account__r.Marital_Status__c;
                                                          if(oppoList[0].Account__r.Current_Residence_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = oppoList[0].Account__r.Current_Residence_Configuration__c;
                                                          if(oppoList[0].Walkin_Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = oppoList[0].Walkin_Referrer_Name__c;
                                                          if(oppoList[0].Configuration_Required__c != null)
                                                              sv.Configuration_Required__c = oppoList[0].Configuration_Required__c;
                                                          if(oppoList[0].Account__r.Current_Residence_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = oppoList[0].Account__r.Current_Residence_Configuration__c;
                                                          if(oppoList[0].Account__r.Source_of_Finance__c != null)
                                                              sv.Source_of_Finance__c = oppoList[0].Account__r.Source_of_Finance__c;
                                                          if(oppoList[0].Account__r.Ethnicity__c != null)
                                                              sv.Ethnicity__c = oppoList[0].Account__r.Ethnicity__c;
                                                          if(oppoList[0].Account__r.Family_Size__c != null)
                                                              sv.Family_Size__c = oppoList[0].Account__r.Family_Size__c;
                                                          if(oppoList[0].Account__r.Industry__c != null)
                                                              sv.Industry__c = oppoList[0].Account__r.Industry__c;
                                                          if(oppoList[0].Account__r.Company_Name__c != null)
                                                              sv.Company_Name__c = oppoList[0].Account__r.Company_Name__c;
                                                          if(oppoList[0].Account__r.PersonEmail != null) 
                                                              sv.Email__c = oppoList[0].Account__r.PersonEmail;
                                                          if(oppoList[0].Presales_Manager__c != null)
                                                              sv.Presales_Manager__c = oppoList[0].Presales_Manager__c;
                                                          if(oppoList[0].Lead_Source__c == 'Channel Partner' && oppoList[0].Lead_Source__c != null){
                                                              if(oppoList[0].Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = oppoList[0].Channel_Partner__c;
                                                              if(oppoList[0].CP_Project__c != null)
                                                                  sv.CP_Project__c = oppoList[0].CP_Project__c;
                                                              if(oppoList[0].Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = oppoList[0].Sourcing_Manager__c;
                                                          }
                                                      }
                                                      insert sv;
                                                      result.add(sv.Id);
                                                      if(oppoList[0].First_Site_Visit_Date__c != null)
                                                          oppoList[0].First_Site_Visit_Date__c = oppoList[0].First_Site_Visit_Date__c;
                                                      if(oppoList[0].SV_Count__c == Null || oppoList[0].SV_Count__c == 0)
                                                          oppoList[0].SV_Count__c = 1;
                                                      else
                                                          oppoList[0].SV_Count__c = oppoList[0].SV_Count__c + 1;
                                                      oppoList[0].Last_SV_Date__c = sv.Site_Visit_Date__c;
                                                      update oppoList[0];
                                                      
                                                      // Modified By Priyanshu Agarkar
                                                      oppoList[0].Latest_Enquiry_Date__c = system.now();
                                                      oppoList[0].Is_Serviced__c = False;
                                                      update oppoList[0];
                                                      system.debug('Latest Enquiry Date set in Opportunity: ' + oppoList[0].Latest_Enquiry_Date__c);
                                                      // Modified By Priyanshu Agarkar
                                                      
                                                      List<Lead__c> ldList = new List<Lead__c>();
                                                      ldList = [Select Id, Lead_Sub_Stage__c, Lead_Stage__c, Walkin_Source__c, Walkin_Sub_Source__c 
                                                                from Lead__c where Opportunity__c =: oppoList[0].Id];
                                                      if(!ldList.isEmpty() && ldList != null){
                                                          ldList[0].IsConverted__c = true;
                                                          ldList[0].Lead_Stage__c = 'Visit Done';
                                                          ldList[0].Lead_Sub_Stage__c = 'Visit Done';
                                                          ldList[0].Conveted_DateTime__c = System.Now();
                                                          //Modified : Harshal More
                                                          if(svWrapper.sv.Walk_In_Source__c != null)
                                                              ldList[0].Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                          if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                              ldList[0].Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                          //Modified : Harshal More
                                                      }
                                                      System.debug('ldList: '+ldList);
                                                      if(!ldList.isEmpty() && ldList != null){
                                                          update ldList[0];
                                                      }
                                                      List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                                                      isSuccess = true;
                                                      System.debug('Success Lead found && OpportunityFound :'+lstSV);
                                                  }catch(Exception Ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur '+ Ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  }
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }
                                              }
                                              
                                          } 
                                          else{
                                              if(isLeadFound && !isAccountFound) {
                                                  try {
                                                      List<Project__c> pList = new List<Project__c>();
                                                      System.debug('Inside Existing Lead Found'+ isLeadFound);
                                                      
                                                      lList[0].Salutation__c = svWrapper.sv.Salutation__c;
                                                      lList[0].First_Name__c = svWrapper.sv.First_Name__c;
                                                      lList[0].Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      lList[0].Lead_Stage__c = 'Visit Done';
                                                      lList[0].Lead_Sub_Stage__c = 'Visit Done';
                                                      lList[0].Conveted_DateTime__c = system.now();
                                                      lList[0].IsConverted__c = true;
                                                      
                                                      // Do not change existing Mobile__c if it already has a value
                                                      /*if(svWrapper.sv.Mobile__c != null)
                                                          lList[0].Mobile__c = svWrapper.sv.Mobile__c;
                                                      */
                                                      if(svWrapper.sv.Email__c != null)
                                                          lList[0].Email__c = svWrapper.sv.Email__c;
                                                      if(svWrapper.sv.Phone__c != null)
                                                          lList[0].Phone__c = svWrapper.sv.Phone__c;
                                                      if(svWrapper.sv.Alternate_Email_Id__c != null)
                                                          lList[0].Alternate_Email__c = svWrapper.sv.Alternate_Email_Id__c;
                                                      
                                                      //Project Requirement Details
                                                      
                                                      if(svWrapper.sv.Budget__c != null)
                                                          lList[0].Budget_Range__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          lList[0].Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          lList[0].Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          lList[0].Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          lList[0].Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      if(svWrapper.sv.Project_Type__c != null)
                                                          lList[0].Project_Type__c = svWrapper.sv.Project_Type__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          lList[0].Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          lList[0].Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Configuration_Required__c != null)
                                                          lList[0].Configuration_Required__c = svWrapper.sv.Configuration_Required__c;
                                                      
                                                      //Demographic Details
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          lList[0].Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          lList[0].Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          lList[0].Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          lList[0].Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          lList[0].Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          lList[0].Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          lList[0].Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          lList[0].Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          lList[0].Occupation__c = svWrapper.sv.Occupation__c;
                                                      if(svWrapper.sv.Industry__c != null)
                                                          lList[0].Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          lList[0].Designation__c = svWrapper.sv.Designation__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          lList[0].Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Current_Residence_Status__c != null)
                                                          lList[0].Current_Resident_Status__c = svWrapper.sv.Current_Residence_Status__c;
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          lList[0].Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      //Source Details
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          lList[0].Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_Source__c != null)
                                                          lList[0].Lead_Sub_Source__c = svWrapper.sv.Lead_Sub_Source__c;
                                                      //Walkin Details
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          lList[0].WalkIn_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          lList[0].WalkIn_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              lList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              lList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              lList[0].Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              lList[0].CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      if(svWrapper.sv.Clash__c != null)
                                                          lList[0].Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          lList[0].Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      
                                                      if(changeStatus){
                                                          lList[0].Lead_Source__c = 'Channel Partner';
                                                          lList[0].Lead_Sub_Source__c = 'Channel Partner';
                                                      }
                                                      update lList[0];
                                                      System.debug('lListupdate: '+lList[0]);
                                                      List<Lead__c> newLeadLst = new List<Lead__c>();
                                                      newLeadLst.add(lList[0]);
                                                      if(!newLeadLst.isEmpty() && newLeadLst != null){
                                                          Ex_LeadConversionServices.convertLead(newLeadLst);
                                                      }
                                                      Lead__c convertedLead = [Select Account__c, Opportunity__c from Lead__c where Id =: lList[0].Id AND IsConverted__c = true];
                                                      system.debug('Converted Lead: '+convertedLead);
                                                      
                                                      Opportunity__c convertedOpp =  [SELECT Id, Name, SV_Count__c ,First_Site_Visit_Date__c, Last_SV_Date__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                                                      system.debug('Converted Opportunity: '+convertedOpp);
                                                      
                                                      // Modified By Priyanshu Agarkar
                                                      convertedOpp.Latest_Enquiry_Date__c = system.now(); 
                                                      update convertedOpp;
                                                      system.debug('Latest Enquiry Date set in Opportunity: ' + convertedOpp.Latest_Enquiry_Date__c);
                                                      // Modified By Priyanshu Agarkar
                                                      
                                                      //Tag Site Visit Against Opportunity
                                                      Site_Visit__c sv = new Site_Visit__c();
                                                      if(convertedLead.Opportunity__c != null)
                                                          sv.Opportunity__c = convertedLead.Opportunity__c;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      sv.Email__c = svWrapper.sv.Email__c;
                                                      sv.Project__c = projectId;
                                                      sv.SV_Count__c = 1;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      
                                                      if(svWrapper.sv.Phone__c != null)
                                                          sv.Phone__c = svWrapper.sv.Phone__c;
                                                      if(svWrapper.sv.Alternate_Email_Id__c != null)
                                                          sv.Alternate_Email_Id__c = svWrapper.sv.Alternate_Email_Id__c;
                                                      if(svWrapper.sv.Clash__c != null)
                                                          sv.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      if(svWrapper.sv.Project_Type__c != null)
                                                          sv.Project_Type__c = svWrapper.sv.Project_Type__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          sv.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      
                                                      if(!lList.isEmpty() && lList != null){
                                                          System.debug('Existing Lead: '+ lList);
                                                          
                                                          // Modified : Priyanshu Agarkar
                                                          // Source Details
                                                          if(lList[0].Lead_Source__c != null)
                                                              sv.Lead_Source__c = lList[0].Lead_Source__c ;
                                                          if(lList[0].Lead_Sub_Source__c != null)
                                                              sv.Lead_Sub_Source__c = lList[0].Lead_Sub_Source__c ;
                                                          if(lList[0].Source_Description__c != null)
                                                              sv.Source_Description__c = lList[0].Source_Description__c ;
                                                          
                                                          //Walking Source
                                                          if(svWrapper.sv.Walk_In_Source__c != null)
                                                              sv.Walk_In_Source__c  = svWrapper.sv.Walk_In_Source__c;
                                                          if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                              sv.Walk_In_Sub_Source__c  = svWrapper.sv.Walk_In_Sub_Source__c;
                                                          
                                                          //Requirement Details Start
                                                          if(lList[0].Project__c != null)
                                                              sv.Project__c = lList[0].Project__c ;
                                                          if(lList[0].Budget_Range__c != null)
                                                              sv.Budget__c = lList[0].Budget_Range__c;
                                                          if(lList[0].Actual_Budget__c != null)
                                                              lList[0].Actual_Budget__c = lList[0].Actual_Budget__c;
                                                          if(svWrapper.sv.Preferred_Location__c != null)
                                                              lList[0].Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                          if(lList[0].Configuration_Required__c != null)
                                                              sv.Configuration_Required__c = lList[0].Configuration_Required__c;
                                                          if(lList[0].Buying_Purpose__c != null)
                                                              sv.Buying_Purpose__c = lList[0].Buying_Purpose__c;
                                                          if(lList[0].Possession_Timeframe_Required__c != null)
                                                              sv.Possession_Timeframe_Required__c = lList[0].Possession_Timeframe_Required__c;
                                                          if(lList[0].Project_Type__c != null)
                                                              sv.Project_Type__c = lList[0].Project_Type__c;
                                                          if(lList[0].Preferred_Location__c != null)
                                                              sv.Preferred_Location__c = lList[0].Preferred_Location__c;
                                                          if(lList[0].Actual_Budget__c != null)
                                                              sv.Actual_Budget__c = lList[0].Actual_Budget__c;
                                                          //Requirement Details End
                                                          //Demographic Details Start
                                                          if(lList[0].Age_Group__c != null)
                                                              sv.Age_Group__c = lList[0].Age_Group__c;
                                                          if(lList[0].Designation__c != null)
                                                              sv.Designation__c = lList[0].Designation__c;
                                                          if(lList[0].Gender__c != null)
                                                              sv.Gender__c = lList[0].Gender__c;
                                                          if(lList[0].Industry__c != null)
                                                              sv.Industry__c = lList[0].Industry__c;
                                                          if(lList[0].Marital_Status__c != null)
                                                              sv.Marital_Status__c = lList[0].Marital_Status__c;
                                                          if(lList[0].Family_Size__c != null)
                                                              sv.Family_Size__c = lList[0].Family_Size__c;
                                                          if(lList[0].Ethnicity__c != null)
                                                              sv.Ethnicity__c = lList[0].Ethnicity__c;
                                                          if(lList[0].Current_Resident_Status__c != null)
                                                              sv.Current_Residence_Status__c = lList[0].Current_Resident_Status__c;
                                                          if(lList[0].Occupation__c != null)
                                                              sv.Occupation__c = lList[0].Occupation__c;
                                                          if(lList[0].Current_Resident_Configuration__c != null)
                                                              sv.Current_Residence_Configuration__c = lList[0].Current_Resident_Configuration__c;
                                                          if(lList[0].Source_of_Finance__c != null)
                                                              sv.Source_of_Finance__c = lList[0].Source_of_Finance__c;
                                                          if(lList[0].Company_Name__c != null)
                                                              sv.Company_Name__c = lList[0].Company_Name__c;
                                                          //Demographic Details End
                                                          //Channel Partner Start while Lead Source 
                                                          if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                              if(svWrapper.sv.Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                              if(svWrapper.sv.CP_Project__c != null)
                                                                  sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                              if(svWrapper.sv.Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                          }
                                                          //Channel Partner end while Lead Source 
                                                          
                                                          //Channel Partner Start while Walkin Source 
                                                          if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                              if(svWrapper.sv.Channel_Partner__c != null)
                                                                  sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                              if(svWrapper.sv.CP_Project__c != null)
                                                                  sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                              if(svWrapper.sv.Sourcing_Manager__c != null)
                                                                  sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                          }
                                                          //Channel Partner end while Walkin Source
                                                          
                                                          //Other Details
                                                          if(lList[0].OwnerId != null)
                                                              sv.Presales_Manager__c = lList[0].OwnerId;
                                                          if(lList[0].Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = lList[0].Referrer_Name__c;
                                                          //other Details End
                                                          //Address Details
                                                          if(svWrapper.sv.City__c != null)
                                                              sv.City__c = svWrapper.sv.City__c;
                                                          if(svWrapper.sv.Locality__c != null)
                                                              sv.Locality__c = svWrapper.sv.Locality__c;
                                                          if(svWrapper.sv.Country__c != null)
                                                              sv.Country__c = svWrapper.sv.Country__c;
                                                          if(svWrapper.sv.State__c != null)
                                                              sv.State__c = svWrapper.sv.State__c;
                                                          if(svWrapper.sv.Pincode__c != null)
                                                              sv.Pincode__c = svWrapper.sv.Pincode__c;
                                                          
                                                          // Flat no details
                                                          if(svWrapper.sv.Flat_No__c != null){
                                                              sv.Flat_No__c = svWrapper.sv.Flat_No__c;
                                                          }
                                                          //office Address Details
                                                          if(svWrapper.sv.City_1__c != null)
                                                              sv.City_1__c = svWrapper.sv.City_1__c;
                                                          if(svWrapper.sv.Locality_1__c != null)
                                                              sv.Locality_1__c = svWrapper.sv.Locality_1__c;
                                                          if(svWrapper.sv.Country_1__c != null)
                                                              sv.Country_1__c = svWrapper.sv.Country_1__c;
                                                          if(svWrapper.sv.State_1__c != null)
                                                              sv.State_1__c = svWrapper.sv.State_1__c;
                                                          if(svWrapper.sv.Pincode_1__c != null)
                                                              sv.Pincode_1__c = svWrapper.sv.Pincode_1__c;
                                                          
                                                          if(svWrapper.sv.Walk_In_Source__c != svWrapper.sv.Lead_Source__c){
                                                              if(String.isNotBlank(siteHeadApprover))
                                                                  sv.Site_Visit_Approver__c = siteHeadApprover;
                                                          }
                                                      }
                                                      insert sv;
                                                      result.add(sv.Id);
                                                      
                                                      //Update Opportunity
                                                      convertedOpp.SV_Count__c = 1;
                                                      convertedOpp.Last_SV_Date__c =  sv.Site_Visit_Date__c;
                                                      convertedOpp.First_Site_Visit_Date__c = system.now();
                                                      convertedOpp.Sourcing_Manager__c = sv.Sourcing_Manager__c;
                                                      update convertedOpp;
                                                      
                                                      List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                                                      isSuccess = true;
                                                      System.debug('lstSV:'+ lstSV);
                                                      
                                                  }catch(Exception ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur While Existing Lead Present:  '+ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  } 
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }
                                                  
                                              } 
                                              else {
                                                  try {
                                                      System.debug('Fresh Lead: ');
                                                      Lead__c l = new Lead__c();
                                                      List<Project__c> pList = new List<Project__c>();
                                                      l.Salutation__c = svWrapper.sv.Salutation__c;
                                                      l.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      l.First_Name__c = svWrapper.sv.First_Name__c;
                                                      l.Mobile__c =  svWrapper.sv.Mobile__c;
                                                      if(svWrapper.sv.Email__c != null && svWrapper.sv.Email__c != '')
                                                          l.Email__c = svWrapper.sv.Email__c;
                                                      l.Project__c = projectId;
                                                      l.IsConverted__c = true;
                                                      l.Lead_Stage__c = 'Visit Done';
                                                      l.Lead_Sub_Stage__c = 'Visit Done';
                                                      l.Conveted_DateTime__c = System.Now();
                                                      //Modified : Harshal More (No Lead , Acc, Opp is found)
                                                      l.Direct_Lead__c = true;
                                                      //Modified : Harshal More
                                                      l.OwnerId = UserInfo.getUserId();
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      Project__c project = [SELECT Project_Type__c FROM Project__c WHERE Id = :projectId LIMIT 1];
                                                      if(project.Project_Type__c != null) {
                                                          l.Project_Type__c = project.Project_Type__c;
                                                      }
                                                      System.debug('Project Type: ' + l.Project_Type__c);
                                                      // Modification end
                                                      
                                                      if(svWrapper.sv.Budget__c != null)
                                                          l.Budget_Range__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          l.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          l.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          l.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          l.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          l.Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          l.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          l.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          l.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          l.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          l.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          l.Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          l.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          l.Occupation__c = svWrapper.sv.Occupation__c;
                                                      System.debug('l.Occupation__c:=' + l.Occupation__c);
                                                      if(svWrapper.sv.Industry__c != null)
                                                          l.Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          l.Designation__c = svWrapper.sv.Designation__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          l.Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_Source__c != null)
                                                          l.Lead_Sub_Source__c = svWrapper.sv.Lead_Sub_Source__c;
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              l.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              l.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      
                                                      // Walkin Source Details
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          l.Walkin_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          l.Walkin_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              l.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              l.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                      }
                                                      //Reference Name
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              l.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Reference' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              l.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Clash__c != null)
                                                          l.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          l.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      //Requirement Details
                                                      if(svWrapper.sv.Current_Residence_Status__c != null)
                                                          l.Current_Resident_Status__c = svWrapper.sv.Current_Residence_Status__c; 
                                                      if(svWrapper.sv.Configuration_Required__c != null)
                                                          l.Configuration_Required__c = SvWrapper.sv.Configuration_Required__c;
                                                      if(svWrapper.sv.Budget__c != null)
                                                          l.Budget_Range__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          l.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          l.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          l.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          l.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      //Demograhics Details
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          l.Current_Resident_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          l.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          l.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          l.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          l.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          l.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          l.Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          l.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          l.Occupation__c = svWrapper.sv.Occupation__c;
                                                      if(svWrapper.sv.Industry__c != null)
                                                          l.Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          l.Designation__c = svWrapper.sv.Designation__c;
                                                      insert l;
                                                      System.debug('lId: '+l.Id);
                                                      
                                                      List<Lead__c> leadList1 = new List<Lead__c>();
                                                      leadList1.add(l);
                                                      
                                                      if(!leadList1.isEmpty() && leadList1 != null){
                                                          Ex_LeadConversionServices.convertLead(leadList1);
                                                      }
                                                      System.debug('Going below for fetching converted lead');
                                                      Lead__c convertedLead = [Select Account__c, Opportunity__c from Lead__c 
                                                                               where Id =: leadList1[0].Id AND IsConverted__c = true];
                                                      system.debug('Converted Lead: '+convertedLead);
                                                      
                                                      Opportunity__c convertedOpp =  [SELECT Id, Name, SV_Count__c , Last_Source_Changed_Date__c, First_Site_Visit_Date__c, 
                                                                                      Last_SV_Date__c from Opportunity__c where Id =: convertedLead.Opportunity__c];
                                                      system.debug('Converted Opportunity: '+convertedOpp);
                                                      
                                                      Site_Visit__c sv = new Site_Visit__c();
                                                      //Tag Site Visit Against Converted Opportunity
                                                      sv.Opportunity__c = convertedOpp.Id;
                                                      sv.Salutation__c = svWrapper.sv.Salutation__c;
                                                      sv.First_Name__c = svWrapper.sv.First_Name__c;
                                                      sv.Last_Name__c = svWrapper.sv.Last_Name__c;
                                                      sv.Mobile__c = svWrapper.sv.Mobile__c;
                                                      if(svWrapper.sv.Email__c != null && svWrapper.sv.Email__c != ''){
                                                          sv.Email__c = svWrapper.sv.Email__c;
                                                      }
                                                      sv.Project__c = projectId;
                                                      sv.SV_Count__c = 1;
                                                      sv.Site_Visit_Date__c = system.now();
                                                      sv.OwnerId = UserInfo.getUserId();
                                                      
                                                      if(svWrapper.sv.Lead_Source__c != null)
                                                          sv.Lead_Source__c = svWrapper.sv.Lead_Source__c;
                                                      if(svWrapper.sv.Lead_Sub_source__c != null)
                                                          sv.Lead_Sub_source__c = svWrapper.sv.Lead_Sub_source__c;
                                                      
                                                      if(svWrapper.sv.Lead_Source__c == 'Channel Partner' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                          if(svWrapper.sv.Sourcing_Manager__c != null)
                                                              sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                      }
                                                      // Walkin Source Details
                                                      if(svWrapper.sv.Walk_In_Source__c != null)
                                                          sv.Walk_In_Source__c = svWrapper.sv.Walk_In_Source__c;
                                                      if(svWrapper.sv.Walk_In_Sub_Source__c != null)
                                                          sv.Walk_In_Sub_Source__c = svWrapper.sv.Walk_In_Sub_Source__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Channel Partner' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Channel_Partner__c != null)
                                                              sv.Channel_Partner__c = svWrapper.sv.Channel_Partner__c;
                                                          if(svWrapper.sv.CP_Project__c != null)
                                                              sv.CP_Project__c = svWrapper.sv.CP_Project__c;
                                                          if(svWrapper.sv.Sourcing_Manager__c != null)
                                                              sv.Sourcing_Manager__c = svWrapper.sv.Sourcing_Manager__c;
                                                      }
                                                      
                                                      if(svWrapper.sv.Is_New_CP_Created__c){
                                                          sv.Is_New_CP_Created__c = svWrapper.sv.Is_New_CP_Created__c;
                                                      }
                                                      
                                                      //Reference Name
                                                      if(svWrapper.sv.Walk_In_Source__c == 'Reference' && svWrapper.sv.Walk_In_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Lead_Source__c == 'Reference' && svWrapper.sv.Lead_Source__c != null){
                                                          if(svWrapper.sv.Referrer_Name__c != null)
                                                              sv.Referrer_Name__c = svWrapper.sv.Referrer_Name__c;                        
                                                      }
                                                      if(svWrapper.sv.Clash__c != null)
                                                          sv.Clash__c = svWrapper.sv.Clash__c;
                                                      if(svWrapper.sv.Clash_Details__c != null)
                                                          sv.Clash_Details__c = svWrapper.sv.Clash_Details__c;
                                                      
                                                      // Modified : Priyanshu Agarkar
                                                      if(svWrapper.sv.Clash__c != null && svWrapper.sv.Clash__c == true && svWrapper.sv.Clash_Details__c != null)
                                                          sv.Approval_Status__c = 'Pending for Approval';
                                                      // Modified by Priyanshu Agarkar
                                                      
                                                      //Requirement Details
                                                      if(svWrapper.sv.Current_Residence_Status__c != null)
                                                          sv.Current_Residence_Status__c = svWrapper.sv.Current_Residence_Status__c; 
                                                      if(svWrapper.sv.Configuration_Required__c != null)
                                                          sv.Configuration_Required__c = SvWrapper.sv.Configuration_Required__c;
                                                      if(svWrapper.sv.Budget__c != null)
                                                          sv.Budget__c = svWrapper.sv.Budget__c;
                                                      if(svWrapper.sv.Actual_Budget__c != null)
                                                          sv.Actual_Budget__c = svWrapper.sv.Actual_Budget__c;
                                                      if(svWrapper.sv.Preferred_Location__c != null)
                                                          sv.Preferred_Location__c = svWrapper.sv.Preferred_Location__c;
                                                      if(svWrapper.sv.Buying_Purpose__c != null)
                                                          sv.Buying_Purpose__c = svWrapper.sv.Buying_Purpose__c;
                                                      if(svWrapper.sv.Possession_Timeframe_Required__c != null)
                                                          sv.Possession_Timeframe_Required__c = svWrapper.sv.Possession_Timeframe_Required__c;
                                                      
                                                      //Demograhics Details
                                                      if(svWrapper.sv.Current_Residence_Configuration__c != null)
                                                          sv.Current_Residence_Configuration__c = svWrapper.sv.Current_Residence_Configuration__c;
                                                      if(svWrapper.sv.Source_of_Finance__c != null)
                                                          sv.Source_of_Finance__c = svWrapper.sv.Source_of_Finance__c;
                                                      if(svWrapper.sv.Ethnicity__c != null)
                                                          sv.Ethnicity__c = svWrapper.sv.Ethnicity__c;
                                                      if(svWrapper.sv.Age_Group__c != null)
                                                          sv.Age_Group__c = svWrapper.sv.Age_Group__c;
                                                      if(svWrapper.sv.Marital_Status__c != null)
                                                          sv.Marital_Status__c = svWrapper.sv.Marital_Status__c;
                                                      if(svWrapper.sv.Family_Size__c != null)
                                                          sv.Family_Size__c = svWrapper.sv.Family_Size__c;
                                                      if(svWrapper.sv.Gender__c != null)
                                                          sv.Gender__c = svWrapper.sv.Gender__c;
                                                      if(svWrapper.sv.Company_Name__c != null)
                                                          sv.Company_Name__c = svWrapper.sv.Company_Name__c;
                                                      if(svWrapper.sv.Occupation__c != null)
                                                          sv.Occupation__c = svWrapper.sv.Occupation__c;
                                                      if(svWrapper.sv.Industry__c != null)
                                                          sv.Industry__c = svWrapper.sv.Industry__c;
                                                      if(svWrapper.sv.Designation__c != null)
                                                          sv.Designation__c = svWrapper.sv.Designation__c;
                                                      
                                                      //Address Details
                                                      if(svWrapper.sv.City__c != null)
                                                          sv.City__c = svWrapper.sv.City__c;
                                                      if(svWrapper.sv.Locality__c != null)
                                                          sv.Locality__c = svWrapper.sv.Locality__c;
                                                      if(svWrapper.sv.Country__c != null)
                                                          sv.Country__c = svWrapper.sv.Country__c;
                                                      if(svWrapper.sv.State__c != null)
                                                          sv.State__c = svWrapper.sv.State__c;
                                                      if(svWrapper.sv.Pincode__c != null)
                                                          sv.Pincode__c = svWrapper.sv.Pincode__c;
                                                      
                                                      // Flat no details
                                                      if(svWrapper.sv.Flat_No__c != null){
                                                          sv.Flat_No__c = svWrapper.sv.Flat_No__c;
                                                      }
                                                      
                                                      
                                                      //office Address Details
                                                      if(svWrapper.sv.City_1__c != null)
                                                          sv.City_1__c = svWrapper.sv.City_1__c;
                                                      if(svWrapper.sv.Locality_1__c != null)
                                                          sv.Locality_1__c = svWrapper.sv.Locality_1__c;
                                                      if(svWrapper.sv.Country_1__c != null)
                                                          sv.Country_1__c = svWrapper.sv.Country_1__c;
                                                      if(svWrapper.sv.State_1__c != null)
                                                          sv.State_1__c = svWrapper.sv.State_1__c;
                                                      if(svWrapper.sv.Pincode_1__c != null)
                                                          sv.Pincode_1__c = svWrapper.sv.Pincode_1__c;
                                                      
                                                      if(svWrapper.sv.Walk_In_Source__c != svWrapper.sv.Lead_Source__c){
                                                          if(String.isNotBlank(siteHeadApprover))
                                                              sv.Site_Visit_Approver__c = siteHeadApprover;
                                                      }
                                                      
                                                      insert sv;
                                                      result.add(sv.Id);
                                                      convertedOpp.SV_Count__c = 1;
                                                      convertedOpp.Last_SV_Date__c = sv.Site_Visit_Date__c;
                                                      convertedOpp.First_Site_Visit_Date__c = system.now();
                                                      convertedOpp.Last_Source_Changed_Date__c = System.today();
                                                      convertedOpp.Sourcing_Manager__c = sv.Sourcing_Manager__c;
                                                      update convertedOpp;
                                                      List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                                                      isSuccess = true;
                                                      System.debug('Success Fresh Lead :'+ lstSV);
                                                  }catch(Exception ex) {
                                                      isError = true; 
                                                      System.debug('Error Occur '+ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                      throw new AuraHandledException('An error occurred: ' + ex.getMessage());
                                                      // Modified by Priyanshu Agarkar
                                                  }
                                                  if(!result.isEmpty() && result != null){
                                                      return result;
                                                  }
                                              }
                                          }
                                          return result;
                                      }  
    
    // Method to add days to a given date
    public static Date addDaysToDate(Datetime startDate, Decimal numberOfDays) {
        if (startDate == null || numberOfDays == null) {
            throw new IllegalArgumentException('Date and number of days cannot be null.');
        }
        
        // Convert the numberOfDays to an Integer
        Integer daysToAdd = numberOfDays.intValue();
        
        // Convert Datetime to Date
        Date startDateOnly = startDate.date();
        
        // Add days to the start date
        Date resultDate = startDateOnly.addDays(daysToAdd);
        
        return resultDate;
    }
    
    
    @AuraEnabled
    public static String getSiteName(String svId){
        System.debug('svId: '+svId);
        String svName = '';
        if(svId != null){
            List<Site_Visit__c> svList = [Select Id,Name from Site_Visit__c where Id=:svId];
            // system.debug(svList[0].Name);
            if(svList != null){
                svName = svList[0].Name; 
            }
        }
        return svName;       
    }
    
    //Edited by Harshal More
    //Date 05/09/2024
    @AuraEnabled
    public static CP_Project__c getCPProject(String accId, String projectId){
        List<CP_Project__c> returnCP = new List<CP_Project__c>();
        
        //Changed the query for Channel Partner since we had created a Channel Partner
        List<CP_Project__c> cpList = new List<CP_Project__c>();
        cpList = [Select Id, Name, Project__c, Owner.Name, Channel_Partner__c, Owner.LastName, Channel_Partner__r.Name, OwnerId 
                  from CP_Project__c where Channel_Partner__c =: accId AND Project__c =: projectId 
                  Order by CreatedDate Desc];
        System.debug('cpList: '+cpList);
        if(!cpList.isEmpty() && cpList != null){
            return cpList[0];
        }else{
            if(cpList.isEmpty()){
                CP_Project__c  cp = new CP_Project__c();
                cp.Project__c = projectId;
                cp.Channel_Partner__c = accId;
                cp.OwnerId = UserInfo.getUserId();
                insert cp;
                System.debug('newCP: '+cp.id);
                if(cp.Id != null){
                    returnCP.add(cp);
                }
            }else{
                return null;
            }
            return returnCP[0];
        }
        
    }
    
    //Edited by Harshal More
    @AuraEnabled
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, String projectId) { 
        System.debug('projectId: '+projectId);
        System.debug('sObjectApiName '+sObjectApiName);
        List <sObject> returnList = new List < sObject > ();
        
        if(String.isNotBlank(searchKey) && String.isNotBlank(sObjectApiName) && sObjectApiName.equalsIgnoreCase('User')){
            
            string sWildCardText = '%' + searchKey + '%';
            string sQuery = 'Select Id, Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
            for (sObject obj: database.query(sQuery)) {
                returnList.add(obj);
            }
        }
        
        if(String.isNotBlank(searchKey) && String.isNotBlank(sObjectApiName) && sObjectApiName.equalsIgnoreCase('Channel_Partner__c')){
            string sWildCardText = '%' + searchKey + '%';
            string sQuery = 'Select Id, Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
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
    
    @AuraEnabled(cacheable=false)
    //api used for auto complete suggestion for Address as user types
    public static string getLocationSuggestions(String apiKey, String input){
        try{
            
            string url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
                + 'input=' + EncodingUtil.urlEncode(input, 'UTF-8') +getKey(apiKey);
            string response = getResponse(url);
            System.debug('response .: '+response);
            return response;
            
        }catch(Exception e){
            System.debug('Error .: '+e.getMessage());
            // return e.getMessage();
            // Modified by Priyanshu Agarkar
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            // Modified by Priyanshu Agarkar
        }
        
    }
    
    @AuraEnabled(cacheable=false)
    public static string getPlaceInfo(String apiKey,string placeId){
        try{
            String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
                + 'placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
                + getKey(apiKey); 
            String response = getResponse(url);
            system.debug('response .: '+response);
            return response;
            
        }catch(Exception e){
            System.debug('Error .: '+e.getMessage());
            // return e.getMessage();
            // Modified by Priyanshu Agarkar
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            // Modified by Priyanshu Agarkar
        }
        
    }
    
    public static string getResponse(String url){
        try{
            Http httpCall = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setTimeout(120000);
            res = httpCall.send(req);
            string responsebody = res.getBody();
            system.debug('responsebody .: '+responsebody);
            
            return responsebody;
            
        }catch(Exception e){
            System.debug('Error .: '+e.getMessage());
            // return e.getMessage();
            // Modified by Priyanshu Agarkar
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            // Modified by Priyanshu Agarkar
        }
        
    }
    
    public static string getKey(String apiKey) {
        try{
            string key=apiKey;
            string output = '&key='+key;
            return output;
            
        }catch(Exception e){
            System.debug('Error .: '+e.getMessage());
            // return e.getMessage();
            // Modified by Priyanshu Agarkar
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            // Modified by Priyanshu Agarkar
        }
        
        
    }
}