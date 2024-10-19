// -------------------------------------------
//   Project: Avant Infra 
//   Created By: Exceller Tech
//   Created Date: 06-09-2024
//   Author: Nitin Choudhary    
// -------------------------------------------
global without sharing class Ex_SiteVisitForm {
    global class SVWrapper{
        @AuraEnabled 
        global Site_Visit__c sv { get; set; }
        global SVWrapper(){
            sv = new Site_Visit__c();
        }
    }
    
    @AuraEnabled(cacheable=true)
    global static Map<string,string> selectProject(){
        Map<String,String> projMap = new  Map<String,String>();
        for(Project__c proj : [select Id,Name FROM Project__c]){
            projMap.put(proj.Id,proj.Name);
        }
        system.debug('projMap is::'+projMap); 
        return projMap;
    }
    
    
    @AuraEnabled
    global static Project__c projectImage(String projectId){
        List<Project__c> project = [Select Id, Name, Project_Image__c from Project__c where Id =: projectId];
        if(!project.isEmpty() && project != null){
            return project[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    global static List<String> getSalutation() {
        List<String> pickListValues = new List<String>();
        Schema.DescribeFieldResult objFieldDescribe = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            pickListValues.add(objPickList.getLabel());
        }
        return pickListValues;
    }
    
    @AuraEnabled
    public static Visit_Pre_Registration__c checkCPData(String code, String Proj){
        System.debug('code: '+code);
        System.debug('Proj: '+Proj);       
        try {
            
            Visit_Pre_Registration__c cpList = [select Id, Visit_Pre_Registration_Code__c, Project__c , Project__r.Name, Customer_Name__c, Budget_Range__c, Configuration__c,
                                                Mobile_Number__c, Lead__c, Site_Visit_Date__c, Status__c, CP_Lead__c
                                                from Visit_Pre_Registration__c 
                                                where Visit_Pre_Registration_Code__c LIKE :code AND Project__c=:Proj AND Status__c != 'Completed'];
            system.debug('cpList is: '+cpList);
            if(cpList != null ){
                return cpList; 
            }else{
                return null; 
            }
        } catch (QueryException  ex) {
            throw new AuraHandledException(ex.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    global static SVWrapper getSVWrapper(String projectId, Id leadId ,Id oppId, Id accId, String cpLeadId){
        SVWrapper sv = new SVWrapper();
        system.debug('Id projectId::'+projectId);
        system.debug('Id leadId ::'+leadId);
        system.debug('Id oppId::'+oppId);
        system.debug('Id accId::'+accId);
        List<CP_lead__c> cpLeadList  = new List<CP_Lead__c>();
        
        if(accId != null ){
            Account acc = [Select Id, Name, Salutation, FirstName, LastName, Age_Group__c, Gender__c, Occupation__c, Marital_Status__c, Designation__c ,
                           BillingPostalCode, BillingCountry, BillingState, BillingCity, Industry__c, Family_Size__c, BillingStreet, Current_Resident_Status__c,  Current_Residence_Configuration__c,
                           City__c, State__c,  Office_Pincode__c, Residential_Address__c, Locality__c,
                           Office_Location__c, Company_Name__c, Employment_Type__c, Annual_Income__c, 
                           Ethnicity__c, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c from Account where Id =: accId AND IsPersonAccount = true];
            system.debug('acc:::'+acc);
            if(acc != null){
                if(acc.PersonEmail != null)
                    sv.sv.Email__c = acc.PersonEmail;
                if(acc.BillingCity != null) 
                    sv.sv.City__c = acc.BillingCity;
                if(acc.BillingState != null) 
                    sv.sv.State__c = acc.BillingState;
                if(acc.Residential_Address__c != null)
                    sv.sv.Residential_Address__c = acc.Residential_Address__c ;
                if(acc.Locality__c != null)
                    sv.sv.Locality__c = acc.Locality__c ;
                if(acc.BillingPostalCode != null) 
                    sv.sv.Pincode__c = acc.BillingPostalCode;
                if(acc.Current_Resident_Status__c != null)
                    sv.sv.Current_Resident_Status__c = acc.Current_Resident_Status__c;
                if(acc.Current_Residence_Configuration__c != null)
                    sv.sv.Current_Residence_Configuration__c = acc.Current_Residence_Configuration__c;
                if(acc.Salutation != null)
                    sv.sv.Salutation__c = acc.Salutation;
                if(acc.FirstName != null)
                    sv.sv.First_Name__c = acc.FirstName;
                if(acc.LastName != null)
                    sv.sv.Last_Name__c = acc.LastName;
                
                
                // Demographics Details
                if(acc.Age_Group__c != null)
                    sv.sv.Age_Group__c = acc.Age_Group__c;
                if(acc.Gender__c != null)
                    sv.sv.Gender__c = acc.Gender__c;
                if(acc.Marital_Status__c != null)
                    sv.sv.Marital_Status__c = acc.Marital_Status__c;
                if(acc.Ethnicity__c != null)
                    sv.sv.Ethnicity__c = acc.Ethnicity__c;
                if(acc.Occupation__c != null)
                    sv.sv.Occupation__c = acc.Occupation__c;
                if(acc.Industry__c != null)
                    sv.sv.Industry__c = acc.Industry__c;
                if(acc.Office_Location__c != null)
                    sv.sv.Office_Location__c = acc.Office_Location__c;
                if(acc.Company_Name__c != null)
                    sv.sv.Company_Name__c = acc.Company_Name__c;
                if(acc.Office_Pincode__c != null)
                    sv.sv.Office_Pincode__c = acc.Office_Pincode__c;
                if(acc.Current_Residence_Configuration__c != null)
                    sv.sv.Current_Residence_Configuration__c = acc.Current_Residence_Configuration__c;
                if(acc.Family_Size__c != null)
                    sv.sv.Family_Size__c = acc.Family_Size__c;
                if(acc.Current_Resident_Status__c != null)
                    sv.sv.Current_Resident_Status__c = acc.Current_Resident_Status__c;
                if(acc.Designation__c != null)
                    sv.sv.Designation__c = acc.Designation__c;
                
                if(acc.Employment_Type__c != null)
                    sv.sv.Employment_Type__c = acc.Employment_Type__c;
                if(acc.Annual_Income__c != null)
                    sv.sv.Annual_Income__c = acc.Annual_Income__c;
                
            }
            
            if(oppId != null && String.isNotBlank(projectId) && acc.Id != null){
                Opportunity__c opp = [Select Id, Name, Project__c, Account__c,  Configuration_Required__c, Stage__c, Project__r.Name,
                                      Channel_Partner__c,   OwnerId, Channel_Partner__r.Name, Presales_Manager__c, Referrer_Address__c,
                                      Possession_Timeframe__c,  Buying_Purpose__c, Budget_Range__c, Referrer_Mobile__c, 
                                      Source_Description__c, Sub_Source__c, Source__c, Project__r.TAT_Days_for_Walkin__c, Is_Active__c,
                                      Area_Sq_Ft__c, Location__c, Actual_budget__c, Referrer_Name__c,
                                      Source_of_Funding__c, Any_Pre_existing_Loans__c, Type_of_Pre_existing_Loan__c,
                                      Current_Outstanding_Amount__c, Sourcing_Manager__c, CP_Project__c, CP_Project__r.OwnerId, Is_Booked__c
                                      from Opportunity__c 
                                      where Id =: oppId AND Project__c =: projectId AND Account__c =: acc.Id AND Is_Booked__c = false];
                System.debug('opp: '+opp);
                if(opp != null){
                    sv.sv.Lead_Source__c = opp.Source__c;
                    sv.sv.Lead_Sub_Source__c = opp.Sub_Source__c;
                    
                    if(opp.Source__c == 'Channel Partner') {
                        if(opp.Channel_Partner__c != null)
                            sv.sv.Channel_Partner__c = opp.Channel_Partner__c;
                        if(opp.CP_Project__c != null)
                          sv.sv.CP_Project__c = opp.CP_Project__c;
                        if(opp.CP_Project__r.OwnerId != null)
                            sv.sv.Sourcing_Manager__c = opp.CP_Project__r.OwnerId;
                    }
                    
                    if(opp.Source__c == 'Reference') {
                        if(opp.Referrer_Name__c != null)
                            sv.sv.Referrer_Name__c = opp.Referrer_Name__c;
                        sv.sv.Referrer_Mobile__c = opp.Referrer_Mobile__c;
                        sv.sv.Referrer_Address__c = opp.Referrer_Address__c;
                        system.debug('Referrer_Name__c:: ' + sv.sv.Referrer_Name__c);
                    }
                    
                    if(opp.Configuration_Required__c != null)
                        sv.sv.Configuration_Required__c = opp.Configuration_Required__c;
                    
                    if(opp.Budget_Range__c != null)
                        sv.sv.Budget_Range__c = opp.Budget_Range__c;
                    
                    if(opp.Buying_Purpose__c != null)
                        sv.sv.Buying_Purpose__c = opp.Buying_Purpose__c;
                    
                    if(opp.Possession_Timeframe__c != null) {
                        sv.sv.Possession_Timeframe_Required__c = opp.Possession_Timeframe__c;
                    }
                    if(opp.Area_Sq_Ft__c != null)
                        sv.sv.Area_Sq_Ft__c = opp.Area_Sq_Ft__c;
                    
                    if(opp.Location__c != null)
                        sv.sv.Location__c = opp.Location__c;
                    
                    if(opp.Actual_budget__c != null)
                        sv.sv.Actual_budget__c = opp.Actual_budget__c;
                    
                    if(opp.Presales_Manager__c != null)
                        sv.sv.Presales_Manager__c = opp.Presales_Manager__c;
                    
                    if(opp.Source_of_Funding__c != null)
                        sv.sv.Source_of_Funding__c = opp.Source_of_Funding__c;
                    
                    if(opp.Any_Pre_existing_Loans__c != null)
                        sv.sv.Any_Pre_existing_Loans__c = opp.Any_Pre_existing_Loans__c;
                    
                    if(opp.Type_of_Pre_existing_Loan__c != null)
                        sv.sv.Type_of_Pre_existing_Loan__c = opp.Type_of_Pre_existing_Loan__c;
                    
                    if(opp.Current_Outstanding_Amount__c != null)
                        sv.sv.Current_Outstanding_Amount__c = opp.Current_Outstanding_Amount__c;
                    if(opp.Sourcing_Manager__c != null)
                        sv.sv.Sourcing_Manager__c = opp.Sourcing_Manager__c;
                    
                }
            }
        }
        if(leadId != null  && projectId != null){
            Lead__c ld = [Select Id, Actual_Budget__c, Age_Group__c, Alternate_Email__c,  Area_Sq_Ft__c, 
                          Budget_Range__c, Buying_Purpose__c, Campaign__c, Campaign_Code__c, Channel_Partner__c,
                          Configuration_Required__c,  Channel_Partner__r.OwnerId,
                          Created_Date__c, Current_Residence_Configuration__c, Current_Resident_Status__c, 
                          Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c, 
                          Last_Name__c, Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c,
                          Lead_Sub_Stage_Reason__c, Marital_Status__c, Mobile__c, Occupation__c, Alternate_Mobile__c, Possession_Timeframe__c,
                          Presales_Call_Comment_History__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c, Presales_Last_Call_Date__c, Presales_Last_Call_Status__c, 
                          Project__c, Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, 
                          Residential_Address__c, Locality__c, Salutation__c, Source_Description__c,
                          Office_Location__c, Company_Name__c, Location__c,
                          Office_Pincode__c,  CP_Project__r.OwnerId, CP_Project__c,
                          Owner.FirstName, Owner.LastName,  City__c, State__c, Pincode__c from Lead__c WHERE Id=:leadId AND IsConverted__c = false];
            System.debug('ld: '+ld);
            if(ld != null){
                //Basic Details
                if(ld.Salutation__c != null)
                    sv.sv.Salutation__c = ld.Salutation__c;
                sv.sv.First_Name__c = ld.First_Name__c;
                sv.sv.Last_Name__c = ld.Last_Name__c;
                if(ld.Email__c != null){
                    sv.sv.Email__c = ld.Email__c;
                }
                
                //source Details
                sv.sv.Lead_Source__c = ld.Lead_Source__c;
                sv.sv.Lead_Sub_Source__c = ld.Lead_Sub_Source__c;
                
                if(ld.Lead_Source__c == 'Channel Partner'){
                    sv.sv.Channel_Partner__c = ld.Channel_Partner__c;
                    sv.sv.CP_Project__c = ld.CP_Project__c;
                    sv.sv.Sourcing_Manager__c =  ld.CP_Project__r.OwnerId;
                }
                
                if(ld.Lead_Source__c == 'Reference'){
                    sv.sv.Referrer_Name__c = ld.Referrer_Name__c;
                    sv.sv.Referrer_Mobile__c = ld.Referrer_Mobile__c;
                    sv.sv.Referrer_Address__c = ld.Referrer_Address__c;
                    system.debug('Reference_Name__c:: '+ sv.sv.Referrer_Name__c);
                }
                
                
                //Demographics Details
                sv.sv.Age_Group__c = ld.Age_Group__c;
                sv.sv.Gender__c = ld.Gender__c;
                sv.sv.Marital_Status__c = ld.Marital_Status__c;
                sv.sv.Ethnicity__c = ld.Ethnicity__c;
                sv.sv.Occupation__c = ld.Occupation__c;
                sv.sv.Industry__c = ld.Industry__c;
                sv.sv.Office_Location__c = ld.Office_Location__c;
                sv.sv.Company_Name__c = ld.Company_Name__c;
                sv.sv.Office_Pincode__c = ld.Office_Pincode__c;
                sv.sv.Current_Residence_Configuration__c = ld.Current_Residence_Configuration__c;
                sv.sv.Family_Size__c = ld.Family_Size__c;
                sv.sv.Current_Resident_Status__c = ld.Current_Resident_Status__c;
                sv.sv.Designation__c = ld.Designation__c;
                
                //Requirement Details
                sv.sv.Configuration_Required__c = ld.Configuration_Required__c;
                sv.sv.Budget_Range__c = ld.Budget_Range__c;
                sv.sv.Buying_Purpose__c = ld.Buying_Purpose__c;
                sv.sv.Possession_Timeframe_Required__c = ld.Possession_Timeframe__c;
                sv.sv.Area_Sq_Ft__c = ld.Area_Sq_Ft__c;
                sv.sv.Location__c = ld.Location__c;
                sv.sv.Actual_budget__c = ld.Actual_budget__c;
                
                // Residential Address Details
                sv.sv.Residential_Address__C = ld.Residential_Address__c;
                sv.sv.City__c = ld.City__c;
                sv.sv.State__c = ld.State__c;
                sv.sv.Pincode__c = ld.Pincode__c;
                sv.sv.Locality__c = ld.Locality__c;
                
                //other Details
                sv.sv.Presales_Manager__c = ld.OwnerId;
            }
        }
        System.debug('cpLeadId: '+cpLeadId);
        if(String.isNotBlank(cpLeadId) && String.isNotBlank(projectId)){
            cpLeadList = [Select Id, Name, First_Name__c, Last_Name__c, Email__c, Channel_Partner_Name__c, CP_Project__r.OwnerId, CP_Project__c,
                          Age_Group__c, Gender__c, Marital_Status__c, Ethnicity__c, Occupation__c, Industry__c, Current_Resdient_Configuration__c, 
                          Family_Size__c, Current_Resident_Status__c, Designation__c, Configuration_Required__c, Budget_Range__c, 
                          Buying_Purpose__c, Location__c, Actual_Budget__c,
                          Alternate_Email__c, CP_Lead_Call_Comment_History__c, CP_Lead_Call_Count__c, CP_Lead_Next_Follow_up_Date__c, CP_Lead_Stage__c, 
                          Cp_Lead_Sub_Stage__c, Cp_Lead_Sub_Stage_Reason__c, Last_CP_Lead_Call_Comment__c, Last_CP_Lead_Call_Date__c, Proposed_Visit_Date__c 
                          from CP_Lead__c where Id=: cpLeadId];
            System.debug('cpLeadList: '+cpLeadList);
            if(!cpLeadList.isEmpty() && cpLeadList != null){
                CP_Lead__c cp = cpLeadList[0];
                sv.sv.First_Name__c = cp.First_Name__c;
                sv.sv.Last_Name__c = cp.Last_Name__c;
                if(cp.Email__c != null){
                    sv.sv.Email__c = cp.Email__c;
                }
                
                //source Details
                sv.sv.Lead_Source__c = 'Channel Partner';
                sv.sv.Lead_Sub_Source__c = 'Channel Partner';
                
                sv.sv.Channel_Partner__c = cp.Channel_Partner_Name__c;
                sv.sv.Sourcing_Manager__c =  cp.CP_Project__r.OwnerId;
                sv.sv.CP_Lead__c = cp.Id;
                sv.sv.CP_Project__c = cp.CP_Project__c;
                
                
                //Demographics Details
                sv.sv.Age_Group__c = cp.Age_Group__c;
                sv.sv.Gender__c = cp.Gender__c;
                sv.sv.Marital_Status__c = cp.Marital_Status__c;
                sv.sv.Ethnicity__c = cp.Ethnicity__c;
                sv.sv.Occupation__c = cp.Occupation__c;
                sv.sv.Industry__c = cp.Industry__c;
                // sv.sv.Office_Location__c = cp.Office_Location__c;
                // sv.sv.Company_Name__c = cp.Company_Name__c;
                // sv.sv.Office_Pincode__c = cp.Office_Pincode__c;
                sv.sv.Current_Residence_Configuration__c = cp.Current_Resdient_Configuration__c;
                sv.sv.Family_Size__c = cp.Family_Size__c;
                sv.sv.Current_Resident_Status__c = cp.Current_Resident_Status__c;
                sv.sv.Designation__c = cp.Designation__c;
                
                //Requirement Details
                sv.sv.Configuration_Required__c = cp.Configuration_Required__c;
                sv.sv.Budget_Range__c = cp.Budget_Range__c;
                sv.sv.Buying_Purpose__c = cp.Buying_Purpose__c;
                // sv.sv.Possession_Timeframe_Required__c = cp.Possession_Timeframe__c;
                //  sv.sv.Area_Sq_Ft__c = cp.Area_Sq_Ft__c;
                sv.sv.Location__c = cp.Location__c;
                if(cp.Actual_Budget__c != null)
                sv.sv.Actual_budget__c = Decimal.valueof(cp.Actual_Budget__c);
                
            }
        }
        
        
        System.debug('sv: '+sv);
        return sv;
    }
    
    @AuraEnabled(cacheable=false)
    global static Map<String,List<Sobject>> search(String num, String email, String projectId) {
        Boolean isSearch = false;
        Boolean isAccount = false;
        Boolean isLead = false;
        Boolean isOpp = false; 
        Boolean dupOpp = false;
        List<Account> accList = new List<Account>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        List<Lead__c> leadList = new List<Lead__c>();
        Map<String,List<Sobject>> searchMap = new Map<String,List<Sobject>>();
        
        
        if(num != Null && num != '') {
            accList = [Select  Name, Salutation, FirstName, LastName, Age_Group__c, Gender__c, Occupation__c, Marital_Status__c, Designation__c ,
                       BillingPostalCode, BillingCountry, BillingState, BillingCity, Industry__c, Family_Size__c, BillingStreet, Current_Resident_Status__c,  Current_Residence_Configuration__c,
                       City__c, State__c,  Pincode__c, Residential_Address__c, Locality__c, Office_Location__c,
                       Ethnicity__c, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Owner.Name from Account 
                       where (PersonMobilePhone =: num OR Phone =: num) AND IsPersonAccount = true];
            system.debug('accList: '+accList);
            
            if(!accList.isEmpty()) {
                isAccount = true;
                oppList = [Select Id, CreatedDate, Name, Project__c, Account__c,  Configuration_Required__c, Stage__c, Project__r.Name,
                           Channel_Partner__c, OwnerId, Channel_Partner__r.Name, Presales_Manager__c, Last_SV_Date__c, Sales_Manager__r.Name,
                           Possession_Timeframe__c,  Buying_Purpose__c, Budget_Range__c,
                           Source_Description__c, Sub_Source__c, Source__c, Project__r.TAT_Days_for_Walkin__c, Is_Active__c, Is_Booked__c from Opportunity__c
                           where Account__c =: accList[0].Id AND Project__c =: projectId AND Is_Booked__c = false];
                system.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty()) {
                    isOpp = true;
                }                
            } else {
                if(email != Null && email != '') {
                    accList = [Select  Name, Salutation, FirstName, LastName, Age_Group__c, Gender__c, Occupation__c, Marital_Status__c, Designation__c ,
                               BillingPostalCode, BillingCountry, BillingState, BillingCity, Industry__c, Family_Size__c, BillingStreet, Current_Resident_Status__c,  Current_Residence_Configuration__c,
                               City__c, State__c,  Pincode__c, Residential_Address__c, Locality__c, Office_Location__c,
                               Ethnicity__c, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Owner.Name from Account
                               where (PersonEmail =: email OR Alternate_Email__c =: email) AND IsPersonAccount = true];
                    system.debug('accList: '+accList);
                    
                    if(!accList.isEmpty()) {
                        isAccount = true;
                        
                        oppList = [Select Id, CreatedDate, Name, Project__c, Account__c,  Configuration_Required__c, Stage__c, Project__r.Name,
                                   Channel_Partner__c,   OwnerId, Channel_Partner__r.Name, Presales_Manager__c, Last_SV_Date__c, Sales_Manager__r.Name,
                                   Possession_Timeframe__c,  Buying_Purpose__c, Budget_Range__c,
                                   Source_Description__c, Sub_Source__c, Source__c, Project__r.TAT_Days_for_Walkin__c, Is_Active__c, Is_Booked__c from Opportunity__c
                                   where Account__c =: accList[0].Id AND Project__c =: projectId AND Is_Booked__c = false];
                        system.debug('oppList: '+oppList);
                        
                        if(!oppList.isEmpty()) {
                            isOpp = true;
                        }
                        
                    }
                } 
            }
            
            if(oppList.isEmpty()) {
                leadList = [Select Id, Full_Name__c,  Actual_Budget__c, Age_Group__c, Alternate_Email__c,
                            Budget_Range__c, Buying_Purpose__c, Campaign__c, Campaign_Code__c, Channel_Partner__c,
                            Configuration_Required__c, Channel_Partner__r.OwnerId,
                            Created_Date__c, Current_Residence_Configuration__c, Current_Resident_Status__c, 
                            Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c, 
                            Last_Name__c, Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c,
                            Lead_Sub_Stage_Reason__c, Marital_Status__c, Mobile__c, Occupation__c, Alternate_Mobile__c, Possession_Timeframe__c,
                            Presales_Call_Comment_History__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c, Presales_Last_Call_Date__c, Presales_Last_Call_Status__c, 
                            Project__c, Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, Residential_Address__c, Locality__c, Salutation__c, Source_Description__c,
                            Owner.FirstName, Owner.LastName,  City__c, State__c, Pincode__c, Project__r.Name, Owner.Name from Lead__c
                            where (Mobile__c =: num OR Alternate_Mobile__c =: num)  AND IsConverted__c = false];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty()) {
                    isLead = true;
                } else {
                    if(email != Null && email != '') {
                        leadList = [Select  Id, Full_Name__c, Actual_Budget__c, Age_Group__c, Alternate_Email__c,
                                    Budget_Range__c, Buying_Purpose__c, Campaign__c, Campaign_Code__c, Channel_Partner__c,
                                    Configuration_Required__c, Account__c, Opportunity__c, Channel_Partner__r.OwnerId,
                                    Created_Date__c, Current_Residence_Configuration__c, Current_Resident_Status__c, 
                                    Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c, 
                                    Last_Name__c, Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c,
                                    Lead_Sub_Stage_Reason__c, Marital_Status__c, Mobile__c, Occupation__c, Alternate_Mobile__c, Possession_Timeframe__c,
                                    Presales_Call_Comment_History__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c, Presales_Last_Call_Date__c, Presales_Last_Call_Status__c, 
                                    Project__c, Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, Residential_Address__c, Locality__c, Salutation__c, Source_Description__c,
                                    Owner.FirstName, Owner.LastName,  City__c, State__c, Pincode__c, Project__r.Name, Owner.Name from Lead__c
                                    where (Email__c =: email OR Alternate_Email__c =: email)  AND IsConverted__c = false];
                        system.debug('leadList: '+leadList);
                        
                        if(!leadList.isEmpty()) {
                            isLead = true;
                        }
                    }
                }
            }
        }
        if(isAccount){
            searchMap.put('Account',accList);
        }
        if(isOpp){
            searchMap.put('Opportunity',oppList);
        }
        if(isLead){
            searchMap.put('Lead',leadList);
        }
        System.debug('searchMap: '+searchMap);
        if(!searchMap.isEmpty() && searchMap != null)
            return searchMap;
        else
            return null;
        
        
    }
    
    @AuraEnabled
    global static Map<Id,String> submit(SVWrapper SVWrapper,String projectId, Boolean isQRUser, Boolean changeStatus, String vpId/*, Visit_Pre_Registration__c showVprDataArray*/){
        
        List<Account> accList = new List<Account>();
        List<Opportunity__c> oppList = new List<Opportunity__c>();
        List<Lead__c> leadList = new List<Lead__c>();
        List<Project__c> pList = new List<Project__c>();
        Map<Id,String> resultMap = new Map<Id,String>();
        List<Visit_Pre_Registration__c> updateVPRList = new List<Visit_Pre_Registration__c>();
        Boolean isAccountFound = false;
        Boolean isLeadFound = false;
        Boolean isOppFound = false;
        String mobile = '';
        String email = '';
        Boolean isSuccess = false;
        String message = '';
        if(SVWrapper.sv.Mobile__c != null){
            mobile = SVWrapper.sv.Mobile__c;
        }
        if(SVWrapper.sv.Email__c != null){
            email = SVWrapper.sv.Email__c;
        }
        if(isQRUser){
            SVWrapper.sv.Is_QR_Customer__c = isQRUser;
        }
        System.debug('mobile: '+mobile);
        System.debug('SVWrapper: '+SVWrapper);
        
        if(mobile != Null && !String.isBlank(mobile)) {
            accList = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail,
                       Office_Location__c
                       from Account
                       where (PersonMobilePhone =: mobile OR Phone =: mobile) AND IsPersonAccount = true];
            system.debug('accList: '+accList);
            
            if(!accList.isEmpty()) {
                isAccountFound = true;
                oppList = [Select Id, Name , SV_Count__c, Last_SV_Date__c,  Sub_Stage__c, Sub_Stage_Reason__c,
                           CreatedDate, Project__c, Account__c,  Configuration_Required__c, Stage__c, Project__r.Name,
                           Channel_Partner__c,   OwnerId, Channel_Partner__r.Name, Presales_Manager__c,
                           Possession_Timeframe__c,  Buying_Purpose__c, Budget_Range__c,
                           Source_Description__c, Sub_Source__c, Source__c, Project__r.TAT_Days_for_Walkin__c, Is_Active__c, Is_Booked__c from Opportunity__c
                           where Account__c =: accList[0].Id AND Project__c =: projectId AND Is_Booked__c = false];
                system.debug('oppList: '+oppList);
                if(!oppList.isEmpty()) {
                    isOppFound = true;
                }
            } else {
                if(email != Null && !String.isBlank(email)) {
                    accList = [Select Id, Salutation, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail,
                               Office_Location__c
                               from Account
                               where (PersonEmail =: email OR Alternate_Email__c =: email) AND IsPersonAccount = true];
                    system.debug('accList: '+accList);
                    if(!accList.isEmpty()) {
                        isAccountFound = true;
                        oppList = [Select Id, Name , SV_Count__c, Last_SV_Date__c,  Sub_Stage__c, Sub_Stage_Reason__c,
                                   CreatedDate, Project__c, Account__c,  Configuration_Required__c, Stage__c, Project__r.Name,
                                   Channel_Partner__c,   OwnerId, Channel_Partner__r.Name, Presales_Manager__c,
                                   Possession_Timeframe__c,  Buying_Purpose__c, Budget_Range__c,
                                   Source_Description__c, Sub_Source__c, Source__c, Project__r.TAT_Days_for_Walkin__c, Is_Active__c, Is_Booked__c  from Opportunity__c
                                   where Account__c =: accList[0].Id AND Project__c =:projectId AND Is_Booked__c = false];
                        system.debug('oppList: '+oppList);
                        if(!oppList.isEmpty()) {
                            isOppFound = true;
                        }
                    }
                }
            }
            if(oppList.isEmpty()) {
                leadList = [Select  Id, CP_Lead__c, Office_Location__c, Full_Name__c, Actual_Budget__c, Age_Group__c, Alternate_Email__c,
                            Budget_Range__c, Buying_Purpose__c, Campaign__c, Campaign_Code__c, Channel_Partner__c,
                            Configuration_Required__c, Account__c, Opportunity__c, Channel_Partner__r.OwnerId,
                            Created_Date__c, Current_Residence_Configuration__c, Current_Resident_Status__c, 
                            Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c, 
                            Last_Name__c, Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c,
                            Lead_Sub_Stage_Reason__c, Marital_Status__c, Mobile__c, Occupation__c, Alternate_Mobile__c, Possession_Timeframe__c,
                            Presales_Call_Comment_History__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c, Presales_Last_Call_Date__c, Presales_Last_Call_Status__c, 
                            Project__c, Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, Residential_Address__c, Locality__c, Salutation__c, Source_Description__c,
                            Owner.FirstName, Owner.LastName,  City__c, State__c, Pincode__c, Project__r.Name, Owner.Name from Lead__c
                            where (Mobile__c =: mobile OR Alternate_Mobile__c =: mobile) AND IsConverted__c = false];
                system.debug('leadList: '+leadList);
                if(!leadList.isEmpty()) {
                    isLeadFound = true;
                } else {
                    if(email != Null && !String.isBlank(email)) {
                        leadList = [Select  Id, CP_Lead__c, Office_Location__c, Full_Name__c, Actual_Budget__c, Age_Group__c, Alternate_Email__c,
                                    Budget_Range__c, Buying_Purpose__c, Campaign__c, Campaign_Code__c, Channel_Partner__c,
                                    Configuration_Required__c, Account__c, Opportunity__c, Channel_Partner__r.OwnerId,
                                    Created_Date__c, Current_Residence_Configuration__c, Current_Resident_Status__c, 
                                    Designation__c, Email__c, Ethnicity__c, Family_Size__c, First_Name__c, Gender__c, Industry__c, IsConverted__c, 
                                    Last_Name__c, Lead_Source__c, Lead_Stage__c, Lead_Sub_Source__c, Lead_Sub_Stage__c,
                                    Lead_Sub_Stage_Reason__c, Marital_Status__c, Mobile__c, Occupation__c, Alternate_Mobile__c, Possession_Timeframe__c,
                                    Presales_Call_Comment_History__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c, Presales_Last_Call_Date__c, Presales_Last_Call_Status__c, 
                                    Project__c, Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c, Referrer_Name__c, Referrer_Mobile__c, Referrer_Address__c, Residential_Address__c, Locality__c, Salutation__c, Source_Description__c,
                                    Owner.FirstName, Owner.LastName,  City__c, State__c, Pincode__c, Project__r.Name, Owner.Name from Lead__c
                                    where (Email__c =: email OR Alternate_Email__c =: email) AND Project__c =: projectId AND IsConverted__c = false];
                        system.debug('leadList: '+leadList);
                        if(!leadList.isEmpty()) {
                            isLeadFound = true;
                        }
                    }
                }
            }
        }
       // System.debug('showVprDataArray: '+showVprDataArray);
        System.debug('isLeadFound: '+isLeadFound);
        System.debug('isAccountFound: '+isAccountFound);
        System.debug('isOppFound: '+isOppFound);
        System.debug('SVWrapper: '+SVWrapper);
        Site_Visit__c sv = SVWrapper.sv;
        System.debug('svAssign: '+sv);
        sv.Project__c = projectId;
        if(changeStatus){
            sv.Is_Preregister_Visit__c = true;
            if(vpId != '' && String.isNotBlank(vpId)){
                List<Visit_Pre_Registration__c> vprList = new List<Visit_Pre_Registration__c>();
                vprList = [Select Id, Name, Site_Visit_Date__c, Status__c from Visit_Pre_Registration__c where Id =: vpId];
                if(vprList != null && !vprList.isEmpty()){
                    vprList[0].Site_Visit_Date__c = DateTime.now();
                    vprList[0].Status__c = 'Completed';
                    updateVPRList.add(vprList[0]);
                }
            }
        }
        System.debug('updateVPRList: '+updateVPRList);
        if(updateVPRList != null){
            update updateVPRList;
        }
        if(isAccountFound) {
            if(isOppFound && !isLeadFound) {
                try {
                    //Create Site Visit
                    if(oppList[0].Id != null && oppList != null){
                        sv.Opportunity__c = oppList[0].Id;
                        sv.Site_Visit_Date__c = System.Today();
                        
                        if(oppList[0].SV_Count__c == Null || oppList[0].SV_Count__c == 0) {
                            sv.Site_Visit_Count__c = 1;
                        } else {
                            sv.Site_Visit_Count__c = oppList[0].SV_Count__c + 1;
                        }
                        insert sv;
                       
                        if(oppList[0].Stage__c != null && oppList[0].Stage__c.equalsIgnoreCase('Lost')){
                            oppList[0].Stage__c = 'Created';
                             oppList[0].Sub_Stage__c = '';
                             oppList[0].Sub_Stage_Reason__c = '';
                            
                            
                        }
                        
                        //Update Opportunity
                        oppList[0].SV_Count__c = oppList[0].SV_Count__c + 1;
                        oppList[0].Last_SV_Date__c = system.now();
                        update oppList[0];
                        
                    }
                    List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    message = 'Site Visit Number is '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                    resultMap.put(sv.Id,message);
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    message = 'Error ' +ex.getMessage(); 
                }
            } else if(!isOppFound && !isLeadFound) {
                try {
                    Opportunity__c op = new Opportunity__c();
                    op.Account__c = accList[0].Id;
                    
                    if(sv.First_Name__c != Null)
                        op.Name = sv.First_Name__c;
                    else 
                        op.Name = '';
                    if(sv.Name != Null)
                        op.Name = sv.Last_Name__c;
                    else
                        op.Name = '';
                    // op = sv.Mobile__c;
                    op.Name = sv.First_Name__c +' '+ sv.Last_Name__c;
                    op.Project__c = projectId;
                    op.Stage__c = 'In Follow-up';
                    op.Sub_Stage__c = 'Cold';
                    op.Budget_Range__c = sv.Budget_Range__c;
                    op.Buying_Purpose__c = sv.Buying_Purpose__c;
                    op.Configuration_Required__c = sv.Configuration_Required__c;
                    op.Possession_Timeframe__c = sv.Possession_Timeframe_Required__c;
                    op.SV_Count__c = 1;
                    op.Last_SV_Date__c = system.now();
                    op.Fist_SV_Date__c = system.now();
                    op.SV_Count__c = 1;
                    insert op;
                    
                    sv.Opportunity__c = op.id;
                    sv.Site_Visit_Date__c = system.today();
                    sv.Site_Visit_Count__c = 1;
                    insert sv;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Project__c, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    message = 'Thank You! Site visit number is '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                    resultMap.put(sv.Id,message);
                } catch(Exception ex) {
                    system.debug('Error: '+ex);
                    message = 'Error ' +ex.getMessage();  
                }
            }
        } else {
            system.debug('Test');
            if(isLeadFound && !isAccountFound){
                try{
                    System.debug('Inside Lead Found:');
                    /*if(leadList[0].Project__c != pList[0].Id)
leadList[0].Project__c = pList[0].Id;*/
                    leadList[0].Project__c = projectId;
                    leadList[0].Lead_Stage__c = 'Visit Done';
                    leadList[0].Lead_Sub_Stage__c = 'Visit Done';
                    if(svWrapper.sv.CP_Lead__c != null){
                        leadList[0].CP_Lead__c = SVWrapper.sv.CP_Lead__c;
                    }
					update leadList[0];                    
                    
                    Ex_LeadConversionServices.convertLead(leadList);
                    
                    Lead__c convertedLead = [SELECT Converted_Account__c, Converted_Opportunity__c from Lead__c where Id =: leadList[0].Id];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp =  [SELECT Id, Name, SV_Count__c, Fist_SV_Date__c, Last_SV_Date__c, Last_SV_attended_by__c,
                                                   Presales_Last_Call_Date__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c,Presales_Call_Comment_History__c,
                                                   Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c from Opportunity__c where Id =: convertedLead.Converted_Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Opportunity
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = System.today(); //PP
                    sv.Site_Visit_Count__c = 1;
                    
                    insert sv;
                    
                    List<CP_lead__c> cpLeadList  = new List<CP_Lead__c>();
                    List<CP_lead__c> updateCPLeadList  = new List<CP_Lead__c>();
                    
                    if(SVWrapper.sv.CP_Lead__c != null){
                        cpLeadList = [Select Id, Name, First_Name__c, Last_Name__c, Email__c, Channel_Partner_Name__c, CP_Project__r.OwnerId, CP_Project__c,
                                      Age_Group__c, Gender__c, Marital_Status__c, Ethnicity__c, Occupation__c, Industry__c, Current_Resdient_Configuration__c, 
                                      Family_Size__c, Current_Resident_Status__c, Designation__c, Configuration_Required__c, Budget_Range__c, 
                                      Buying_Purpose__c, Location__c, Actual_Budget__c,
                                      Alternate_Email__c, CP_Lead_Call_Comment_History__c, CP_Lead_Call_Count__c, CP_Lead_Next_Follow_up_Date__c, CP_Lead_Stage__c, 
                                      Cp_Lead_Sub_Stage__c, Cp_Lead_Sub_Stage_Reason__c, Last_CP_Lead_Call_Comment__c, Last_CP_Lead_Call_Date__c, Proposed_Visit_Date__c 
                                      from CP_Lead__c where Id=: SVWrapper.sv.CP_Lead__c];
                        IF(!cpLeadList.isEmpty() && cpLeadList != null){
                            CP_Lead__c cp = cpLeadList[0];
                            cp.CP_Lead_Stage__c = 'Visit Done';
                            cp.Cp_Lead_Sub_Stage__c = 'Visit Done';
                            updateCPLeadList.add(cp);
                            
                            convertedOpp.Presales_Last_Call_Date__c = cp.Last_CP_Lead_Call_Date__c;
                            convertedOpp.Presales_Call_Count__c = CP.CP_Lead_Call_Count__c;
                            convertedOpp.Presales_Last_Call_Comment__c = CP.Last_CP_Lead_Call_Comment__c;
                            convertedOpp.Presales_Call_Comment_History__c = CP.CP_Lead_Call_Comment_History__c;
                            convertedOpp.Presales_Next_Follow_Up_Date__c = CP.CP_Lead_Next_Follow_up_Date__c;
                            convertedOpp.Presales_Proposed_Visit_Date__c = CP.Proposed_Visit_Date__c;
                        }
                    }
                    
                    //Update Opportunity
                    // convertedOpp.Site_Visit_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now(); //PP
                    convertedOpp.Fist_SV_Date__c = system.now();
                    convertedOpp.SV_Count__c = 1;
                    update convertedOpp;
                    
                    List<Site_Visit__c> lstSV = [Select Id, Name from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    message = 'Thank You! Site visit number is '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                    resultMap.put(sv.Id,message);
                    System.debug('updateCPLeadList: '+updateCPLeadList);
                    if(!updateCPLeadList.isEmpty() && updateCPLeadList != null){
                        update updateCPLeadList;
                    }
                }catch(Exception ex) {
                    system.debug('Error: '+ex);
                    message = 'Error ' +ex.getMessage();  
                }
                
            } else if(!isLeadFound && !isAccountFound) {
                try{
                    Lead__c l = new Lead__c();
                    //Basic Details
                    l.Salutation__c = sv.Salutation__c;
                    l.First_Name__c = sv.First_Name__c;
                    l.Last_Name__c = sv.Last_Name__c;
                    l.Mobile__c = sv.Mobile__c;
                    l.Email__c = sv.Email__c;
                    
                    
                    //Address Details
                    l.Residential_Address__c = sv.Residential_Address__c;
                    l.Locality__c = sv.Locality__c;
                    l.City__c = sv.City__c;
                    l.State__c = sv.State__c;
                    l.Pincode__c = sv.Pincode__c;
                    
                    
                    //Requirement Details
                    l.Project__c = projectId;
                    l.Configuration_Required__c = sv.Configuration_Required__c;
                    l.Budget_Range__c = sv.Budget_Range__c;
                    l.Buying_Purpose__c = sv.Buying_Purpose__c;
                    l.Possession_Timeframe__c = sv.Possession_Timeframe_Required__c;
                    l.Area_Sq_ft__c = sv.Area_Sq_ft__c;  
                    l.Location__c = sv.Location__c;
                    
                    //Demographic Details
                    l.Office_Location__c = sv.Office_Location__c;
                    l.Office_Pincode__c = sv.Office_Pincode__c;
                    l.Age_Group__c = sv.Age_Group__c;
                    l.Gender__c = sv.Gender__c;
                    l.Marital_Status__c = sv.Marital_Status__c;
                    l.Ethnicity__c = sv.Ethnicity__c;
                    l.Occupation__c = sv.Occupation__c;
                    l.Designation__c = sv.Designation__c;
                    l.Company_Name__c = sv.Company_Name__c;
                    l.Industry__c = sv.Industry__c;
                    l.Family_Size__c = sv.Family_Size__c;
                    l.Current_Resident_Status__c = sv.Current_Resident_Status__c;
                    l.Current_Residence_Configuration__c = sv.Current_Residence_Configuration__c;
                    
                    
                    
                    // Stage Details
                    l.Lead_Stage__c = 'Visit Done';
                    l.Lead_Sub_Stage__c = 'Visit Done';
                    
                    if(String.isNotBlank(projectId) && isQRUser){
                        pList = [Select Id, User__c from Project__c where Id =: projectId];
                        if(!pList.isEmpty() && pList[0].User__c != null){
                            l.OwnerId = pList[0].User__c;
                        }
                    }else{
                        l.OwnerId = UserInfo.getUserId();
                        system.debug('UserInfo'+l.OwnerId );
                    }
                    insert l;
                    
                    
                    List<Lead__c> lList = new List<Lead__c>();
                    lList.add(l);
                    Ex_LeadConversionServices.convertLead(lList);
                    
                    Lead__c convertedLead = [Select Converted_Account__c, Converted_Opportunity__c from Lead__c where Id = :l.Id ];
                    system.debug('Converted Lead: '+convertedLead);
                    
                    Opportunity__c convertedOpp = [SELECT Id, Name, SV_Count__c, Fist_SV_Date__c, Last_SV_Date__c, Last_SV_attended_by__c,
                                                   Presales_Last_Call_Date__c, Presales_Call_Count__c, Presales_Last_Call_Comment__c,Presales_Call_Comment_History__c,
                                                   Presales_Next_Follow_Up_Date__c, Presales_Proposed_Visit_Date__c from Opportunity__c where Id =: convertedLead.Converted_Opportunity__c];
                    system.debug('Converted Opportunity: '+convertedOpp);
                    
                    //Tag Site Visit Against Converted Opportunity
                    sv.Opportunity__c = convertedOpp.Id;
                    sv.Site_Visit_Date__c = system.today();
                    sv.Site_Visit_Count__c = 1;
                    
                    if(String.isNotBlank(projectId) && isQRUser){
                        pList = [Select Id, User__c from Project__c where Id =: projectId];
                        if(!pList.isEmpty() && pList[0].User__c != null){
                            SVWrapper.sv.OwnerId = pList[0].User__c;
                        }
                    }
                    
                    insert sv;
                    
                    
                    List<CP_lead__c> cpLeadList  = new List<CP_Lead__c>();
                    List<CP_lead__c> updateCPLeadList  = new List<CP_Lead__c>();
                    
                    if(SVWrapper.sv.CP_Lead__c != null){
                        cpLeadList = [Select Id, Name, First_Name__c, Last_Name__c, Email__c, Channel_Partner_Name__c, CP_Project__r.OwnerId, CP_Project__c,
                          Age_Group__c, Gender__c, Marital_Status__c, Ethnicity__c, Occupation__c, Industry__c, Current_Resdient_Configuration__c, 
                          Family_Size__c, Current_Resident_Status__c, Designation__c, Configuration_Required__c, Budget_Range__c, 
                          Buying_Purpose__c, Location__c, Actual_Budget__c,
                          Alternate_Email__c, CP_Lead_Call_Comment_History__c, CP_Lead_Call_Count__c, CP_Lead_Next_Follow_up_Date__c, CP_Lead_Stage__c, 
                          Cp_Lead_Sub_Stage__c, Cp_Lead_Sub_Stage_Reason__c, Last_CP_Lead_Call_Comment__c, Last_CP_Lead_Call_Date__c, Proposed_Visit_Date__c 
                          from CP_Lead__c where Id=: SVWrapper.sv.CP_Lead__c];
                        IF(!cpLeadList.isEmpty() && cpLeadList != null){
                            CP_Lead__c cp = cpLeadList[0];
                            cp.CP_Lead_Stage__c = 'Visit Done';
                            cp.Cp_Lead_Sub_Stage__c = 'Visit Done';
                            updateCPLeadList.add(cp);
                            
                            convertedOpp.Presales_Last_Call_Date__c = cp.Last_CP_Lead_Call_Date__c;
                            convertedOpp.Presales_Call_Count__c = CP.CP_Lead_Call_Count__c;
                            convertedOpp.Presales_Last_Call_Comment__c = CP.Last_CP_Lead_Call_Comment__c;
                            convertedOpp.Presales_Call_Comment_History__c = CP.CP_Lead_Call_Comment_History__c;
                            convertedOpp.Presales_Next_Follow_Up_Date__c = CP.CP_Lead_Next_Follow_up_Date__c;
                            convertedOpp.Presales_Proposed_Visit_Date__c = CP.Proposed_Visit_Date__c;
                        }
                    }
                    //Update Opportunity
                    convertedOpp.SV_Count__c = 1;
                    convertedOpp.Last_SV_Date__c = system.now();
                    convertedOpp.Fist_SV_Date__c = system.now();
                    update convertedOpp;
                    List<Site_Visit__c> lstSV = [Select Id, Name, ownerId from Site_Visit__c where Id =: sv.Id];
                    isSuccess = true;
                    message = 'Thank You! Site visit number is '+ lstSV[0].Name;
                    system.debug('Success Message: '+message);
                    resultMap.put(sv.Id,message);
                    System.debug('updateCPLeadList: '+updateCPLeadList);
                    if(!updateCPLeadList.isEmpty() && updateCPLeadList != null){
                        update updateCPLeadList;
                    }
                    
                    
                } catch(Exception ex) {
                    system.debug('Exception: '+ex);
                    message = 'Error ' +ex.getMessage();    
                }
            }
        }
        return resultMap;
    }
}