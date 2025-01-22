/* Developer .: Aditya Marne, Yash Jain, Harshal More */
/* Disclaimer .: Please do not make any changes without informing the developers mentioned above*/
/* Currently for sending Whatsapp Bulk message Dashboard */
public with sharing class Ex_LeadDashboard {
    
    @AuraEnabled
    public static List<String> getCategory(String Objects, String selectedproject){
        System.debug('Object .: '+Objects);
        Set<String> category = new Set<String>();
        Map<String, String> categoryMap = new Map<String, String>();
        List<String> categoryList = new List<String>();
        List<Whatsapp_Template__c> wt = [SELECT Id, Name, Whatsapp_Template_Name__c, Template_Category__c,Project__c, Object__c 
                                          FROM Whatsapp_Template__c 
                                          WHERE Object__c =: Objects AND Template_Category__c != null AND Project__c =:selectedproject];
        for(Whatsapp_Template__c w : wt){
            System.debug('Template Category  .:'+w.Template_Category__c);
            category.add(w.Template_Category__c);
        }
		categoryList.addAll(category);
        System.debug('categoryList .: '+categoryList);
        return categoryList; 
    }
    
    @AuraEnabled
    public static List<Whatsapp_Template__c> getTemplate(String category, String Objects, String selectedproject) {
        List<Whatsapp_Template__c> template = new List<Whatsapp_Template__c>();
        System.debug('Object .: '+Objects);
        String SObjectName = Objects;
        if(SObjectName.contains('Lead__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c, Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c,Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED' 
                        AND Object__c =: 'Lead__c' AND Project__c =:selectedproject];
        }
        else if(SObjectName.contains('Opportunity__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c, Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c 
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED'
                        AND Object__c =: 'Opportunity__c' AND Project__c =:selectedproject];
        }
        else if(SObjectName.contains('Booking__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c, Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED'
                        AND Object__c =: 'Booking__c' AND Project__c =:selectedproject];
        }
        else if(SObjectName.contains('Site_Visit__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c,Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED'
                        AND Object__c =: 'Site_Visit__c' AND Project__c =:selectedproject ];
        }
         else if(SObjectName.contains('Channel_Partner__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c,Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED'
                        AND Object__c =: 'Channel_Partner__c' AND Project__c =:selectedproject];
        }
        else if(SObjectName.contains('Quotation__c')){
            template = [SELECT Id, Name, Whatsapp_Template_Name__c, Template__c, Object__c, Sample_Text__c,
                        Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                        Public_Link_1__c FROM Whatsapp_Template__c
                        where Template_Category__c =: category AND Template_Approval_Status__c =: 'APPROVED'
                        AND Object__c =: 'Quotation__c' AND Project__c =:selectedproject];
        }
        
        /*List<Whatsapp_Template__c> templates = [SELECT Id, Name, Folder__c,Whatsapp_Template_Name__c, Template__c, Object__c,
                                                Parameters__c, Contains_Media__c, Contains_Document__c, Template_Category__c,
                                                Public_Link_1__c FROM Whatsapp_Template__c 
                                                where Template_Category__c =: category AND Object__c =: 'Lead' AND
                                                Template_Approval_Status__c =: 'APPROVED' ];*/


        System.debug('templates -- ' + template);

        return template;
    }
    
    @AuraEnabled(cacheable=true)
        public static String previewTemplate(String tId){
        System.debug('Template Id .: '+tId);
        List<Whatsapp_Template__c> template = new List<Whatsapp_Template__c>();
        try{
            if(tId != null){
                Whatsapp_Template__c wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c, Sample_Text__c, API_Hit_Status__c, Request__c, 
                                           Response__c, Template_ID__c, Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c
                                           from Whatsapp_Template__c 
                                           WHERE Id =: tId LIMIT 1];
                
                String sampletext = Ex_WhatsappTemplateApproval.removeHtmlTags(wt.Template__c);
                String samplePreview = '';
                System.debug('newText .: ' + sampletext);
                if(wt.Sample_Text__c != null && wt.Parameters__c != null)
                    samplePreview = Ex_WhatsappTemplateApproval.CheckSampleText(wt.Sample_Text__c, sampletext);
                else 
                    samplePreview = sampletext;
                System.debug('samplePreview .: ' + samplePreview);
                return samplePreview;
            }
            else{
                System.debug('Error getting Template Id');
                return null;
            }
        }
        catch(Exception e){
            System.debug('Error .: '+e.getMessage());
            return null;
        }
        
    }


   /* @AuraEnabled(cacheable=true)
    public static List<SObject> getLeadsByDateAndProject(Date startDate, Date endDate, String projectFilter, String Objects, String status, String ownername) {
        System.debug('Project List::'+projectFilter);
        System.debug('Start Date .: '+startDate);
        System.debug('End Date .: '+endDate);
        System.debug('Object .: '+Objects);
        system.debug('status :'+status);
        system.debug('ownername :'+ownername);
        
        String SObjectName = Objects;
        List<SObject> recordsList = new List<SObject>();
        String query;
        
        if (SObjectName.contains('CLead__c')) {
            
            if(startDate!=null && endDate!=null){
                system.debug('in date CLead__c::');
                query = 'SELECT Id, First_Name__c, Last_Name__c,Lead_Status__c,OwnerId,Owner.Name,Parent_Source__c,Sub_Source__c, CreatedDate, Project__c,Project_Name__c, Phone__c, Send_Whatsapp__c, X91_MobileNumber__c FROM CLead__c WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate'; //AND isConverted__c = FALSE'
            } else{
                query = 'SELECT Id, First_Name__c, Last_Name__c,Lead_Status__c,OwnerId,Owner.Name,Parent_Source__c,Sub_Source__c, CreatedDate, Project__c,Project_Name__c, Phone__c, Send_Whatsapp__c, X91_MobileNumber__c FROM CLead__c'; //AND isConverted__c = FALSE'
            }
          
        }
        else if(SObjectName.contains('Inquiry__c')){
            if(startDate!=null && endDate!=null){
                system.debug('in date Inquiry__c::');
                query = 'SELECT Id, Name,Inq_frm_Customer_Full_Name__c,First_Name__c,Last_Name__c,OwnerId,Owner.Name,Inq_pkl_Status__c,X91_plus_Mobile_Number__c, CreatedDate,Project_Name__c,Parent_Source_pklst__c,Sub_Source__c, Mobile__c, Inq_rltn_Project_Society__c FROM Inquiry__c WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate';
            } else {
                query = 'SELECT Id, Name,Inq_frm_Customer_Full_Name__c,First_Name__c,Last_Name__c,OwnerId,Owner.Name,Inq_pkl_Status__c,X91_plus_Mobile_Number__c, CreatedDate,Project_Name__c,Parent_Source_pklst__c,Sub_Source__c, Mobile__c, Inq_rltn_Project_Society__c FROM Inquiry__c';
            }
            
        }
        
        
        if (SObjectName.contains('CLead__c')) {
            if (status != null && status!='') {
                system.debug('status new :' +status);
                List<String> statusList = status.split(',');
                String inClause = '\'';
                inClause += String.join(statusList, '\',\'');
                inClause += '\'';
                
                query += ' AND Lead_Status__c IN (' + inClause + ')';
            }
       
        }
        
        if (Objects.contains('Inquiry__c')) {
            if (status != null) {
                List<String> stageList = status.split(',');
                String stageClause = '\'';
                stageClause += String.join(stageList, '\',\'');
                stageClause += '\'';
                
                query += ' AND Inq_pkl_Status__c IN (' + stageClause + ')';
            }
            
            
        }
        
        if(projectFilter != null  && !SObjectName.contains('Account') && !SObjectName.contains('Channel_Partner__c')){
            query += ' AND Project__c = :projectFilter';      
        }
        
        if(ownername != null  && !SObjectName.contains('Account') && !SObjectName.contains('Channel_Partner__c')){
            query += ' AND OwnerId = :ownername';      
        }
        
        query += ' ORDER BY CreatedDate DESC';
        
        system.debug('query :'+query);
        recordsList = Database.query(query);
        
        return recordsList;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getLeadsByDateAndProject(Date startDate, Date endDate, String projectFilter, String Objects, String status, String ownername) {
        System.debug('Parameters - ProjectFilter: ' + projectFilter + ', StartDate: ' + startDate + ', EndDate: ' + endDate + ', Objects: ' + Objects + ', Status: ' + status + ', OwnerName: ' + ownername);
        
        List<SObject> recordsList = new List<SObject>();
        String query;
        
        if (String.isNotBlank(Objects)) {
            if (Objects == 'Lead__c') {
                System.debug('IncLead: ');
                query = 'SELECT Id, First_Name__c, Last_Name__c, Lead_Stage__c,Mobile__c, OwnerId, Owner.Name, Lead_Source__c, Lead_Sub_Source__c, CreatedDate, Project__c, Project_Name__c, Phone__c, Send_Whatsapp__c FROM Lead__c WHERE ';
            } else if (Objects == 'Opportunity__c') {
                query = 'SELECT Id, Name,Mobile__c, OwnerId, Owner.Name, Opportunity_Stage__c, CreatedDate, Lead_Source__c, Lead_Sub_Source__c,Project__c,Project__r.Name FROM Opportunity__c WHERE ';
            } else if (Objects == 'Booking__c'){
                query = 'SELECT Id, Name,OwnerId,Primary_Applicant_Name__c,Owner.Name,Project__c,Opportunity__c,Mobile__c,Project__r.Name,Booking_Stage__c,Opportunity__r.Name,CreatedDate FROM Booking__c WHERE ';
            } else {
                return recordsList; 
            }
            
            
            List<String> filters = new List<String>();
            
            if (startDate != null && endDate != null) {
                System.debug('startDateendDate: ');
                filters.add('CreatedDate >= :startDate AND CreatedDate <= :endDate');
            }
            
            if (String.isNotBlank(status)) {
                List<String> statusList = status.split(',');
                if (Objects == 'Lead__c') {
                    System.debug('Instatus: '+status);
                    filters.add('Lead_Stage__c IN :statusList');
                    
                } else if (Objects == 'Opportunity__c') {
                    filters.add('Opportunity_Stage__c IN :statusList');
                    
                } else if (Objects == 'Booking__c') {
                    filters.add('Booking_Stage__c IN :statusList');
                }
            }
            
            if (String.isNotBlank(projectFilter)) {
                if (Objects == 'Lead__c') {
                    filters.add('Project__c = :projectFilter');
                } else if (Objects == 'Opportunity__c') {
                    filters.add('Project__c = :projectFilter');
                } else if(Objects == 'Booking__c'){
                    filters.add('Project__c = :projectFilter');
                    
                }
            }
            
            if (String.isNotBlank(ownername)) {
                System.debug('Inownername: '+ownername);
                filters.add('OwnerId = :ownername');
            }
            
            
            if (filters.isEmpty()) {
                query = query.replace(' WHERE ', '');
            } else {
                query += String.join(filters, ' AND ');
            }
            
            query += ' ORDER BY CreatedDate DESC';
            
            System.debug('Final Query: ' + query);
            recordsList = Database.query(query);
        }
        
        return recordsList;
    }
    
    @AuraEnabled(cacheable=true)
    public static String updateLeadSendWhatsApp(List<Id> Ids, String Template, String Objects) {
        system.debug('Ids::'+Ids);
        try {
            Set<Id> recordId = new Set<Id>();
            if(!Ids.isEmpty()){
                for(Id i : Ids){
                    recordId.add(i);
                } 
            }
            system.debug('recordId::'+recordId);
            system.debug('Template::'+Template);
            system.debug('Objects::'+Objects);
            if(!recordId.isEmpty() && Objects != '' && Template != ''){
                WhatsAppMessageBatch batchJob = new WhatsAppMessageBatch(recordId, Objects, Template);
                
                Database.executeBatch(batchJob, 1);
                return 'Success';
            }
            
            return 'Failed';
        } catch (Exception e) {
            System.debug( 'Error .:' + e.getMessage());
            return 'Error';
        }
    }

    public class WhatsAppMessageWrapper {
        public String mobile { get; set; }
        public String templateId { get; set; }
        public List<String> parameters { get; set; }
        public String recordId {get; set;}
        public String messsage {get; set;}
        
        public WhatsAppMessageWrapper(String mobile, String templateId, List<String> parameters, String recordId, String messsage) {
            this.mobile = mobile;
            this.templateId = templateId;
            this.parameters = parameters;
            this.recordId = recordId;
            this.messsage = messsage;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        Schema.DisplayType fieldType = fieldResult.getType();
        if (fieldType == Schema.DisplayType.PICKLIST) {
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        }
        return picklistValues;
    }

      @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues1(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        Schema.DisplayType fieldType = fieldResult.getType();
        if (fieldType == Schema.DisplayType.PICKLIST) {
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        }
        return picklistValues;
    }

     @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues2(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        Schema.DisplayType fieldType = fieldResult.getType();
        if (fieldType == Schema.DisplayType.PICKLIST) {
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        }
        return picklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues3(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        Schema.DisplayType fieldType = fieldResult.getType();
        if (fieldType == Schema.DisplayType.PICKLIST) {
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        }
        return picklistValues;
    }
}  

//     System.debug('After Leads To Update');
//     String sObjectName = Objects;
//     System.debug('sObjectName .: '+sObjectName);
//     
//     //Ex_LeadTriggerHandlerServices.SendTemplate(leadIds, Template.Name);
//     System.debug('On the way to Success');
//     return 'Success';
// } catch (Exception e) {
//     return 'Error: ' + e.getMessage();
// }