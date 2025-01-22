public class Ex_whatsAppMsgService {  
    
    @AuraEnabled
    public static string getSObjectName(String recId){
        try {
            System.debug('recId .: ' + recId);
            Id recordId = (Id) recId;
            
            String SObjectName = recordId.getSObjectType().getDescribe().getName();
            
            List<Lead__c> LeadList = new List<Lead__c>();
            List<Opportunity__c> OpportunityList = new List<Opportunity__c>();
            List<Booking__c> BookingList = new List<Booking__c>();
            
            if(SObjectName.contains('Lead__c')){
                LeadList = [select Id, First_Name__c,Project__r.Name, Last_Name__c from Lead__c where Id =: recId]; 
            }
            else if(SObjectName.contains('Opportunity__c')){
                OpportunityList = [select Id, Name,Project__r.Name from Opportunity__c where Id =: recId]; 
            }
            else if(SObjectName.contains('Booking__c')){
                BookingList = [select Id, Opportunity__r.Name,Project__r.Name from Booking__c where Id =: recId]; 
            }
            else{
                return null;
            }
            
            if(!LeadList.isEmpty() && LeadList != null){
                if(LeadList[0].First_Name__c != null && LeadList[0].Last_Name__c != null)
                    return LeadList[0].First_Name__c + ' ' + LeadList[0].Last_Name__c;
                else if(LeadList[0].First_Name__c != null)
                    return LeadList[0].First_Name__c;
                else
                    return LeadList[0].Last_Name__c;
            }
            else if(!OpportunityList.isEmpty() && OpportunityList != null){
                if(OpportunityList[0].Name != null)
                    return OpportunityList[0].Name;
                else
                    return null;
            }
            else if(!BookingList.isEmpty() && BookingList != null){
                if(BookingList[0].Opportunity__r.Name != null)
                    return BookingList[0].Opportunity__r.Name;
                else
                    return null;
            }
            else
                return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static DateTime getConversationStartDateTime(String recId) {
        try {
            System.debug('recId = ' + recId);
            Id recordId = (Id) recId;
            
            String SObjectName = recordId.getSObjectType().getDescribe().getName();
            
            if (SObjectName.contains('Lead__c')) {
                List<Lead__c> LeadList = [SELECT Id, Conversation_End_Date_Time__c, First_Name__c, Last_Name__c FROM Lead__c WHERE Id = :recId];
                if (!LeadList.isEmpty()) {
                    return LeadList[0].Conversation_End_Date_Time__c;
                } else {
                    return null;
                }
            } else if (SObjectName.contains('Opportunity__c')) {
                List<Opportunity__c> OpportunityList = [SELECT Id, Conversation_End_Date_Time__c FROM Opportunity__c WHERE Id = :recId];
                if (!OpportunityList.isEmpty()) {
                    return OpportunityList[0].Conversation_End_Date_Time__c;
                } else {
                    return null;
                }
            } else if (SObjectName.contains('Booking__c')) {
                List<Booking__c> BookingList = [SELECT Id, Conversation_End_Date_Time__c FROM Booking__c WHERE Id = :recId];
                if (!BookingList.isEmpty()) {
                    return BookingList[0].Conversation_End_Date_Time__c;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<WhatsApp_Message__c> AllMsgs(String recId) {
        System.debug('recId = ' + recId);
        Id recordId = (Id) recId;
         
        String SObjectName = recordId.getSObjectType().getDescribe().getName();
        
        List<WhatsApp_Message__c> listWhatAppMsg = new List<WhatsApp_Message__c>();
        
        if (SObjectName.contains('Lead__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c 
                              FROM WhatsApp_Message__c  WHERE Lead__c = :recId 
                              ORDER BY CreatedDate ASC];
        } else if (SObjectName.contains('Opportunity__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c 
                              FROM WhatsApp_Message__c  WHERE Opportunity__c = :recId 
                              ORDER BY CreatedDate ASC];
        } else if (SObjectName.contains('Booking__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c
                              FROM WhatsApp_Message__c  WHERE Booking__c = :recId 
                              ORDER BY CreatedDate ASC];
        }
        
        System.debug('List of WhatsApp Message: ' + listWhatAppMsg);
        return listWhatAppMsg;                
    }

    
    @AuraEnabled(cacheable=false)
    public static List<WhatsApp_Message__c> refreshMessages(String recId) {
        System.debug('recId .: ' + recId);
        Id recordId = (Id) recId;
        
        String SObjectName = recordId.getSObjectType().getDescribe().getName();
        
        List<WhatsApp_Message__c> listWhatAppMsg = new List<WhatsApp_Message__c>();
        
        if (SObjectName.contains('Lead__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c 
                              FROM WhatsApp_Message__c WHERE Lead__c = :recId ORDER BY CreatedDate ASC];
        } else if (SObjectName.contains('Opportunity__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c 
                              FROM WhatsApp_Message__c WHERE Opportunity__c = :recId ORDER BY CreatedDate ASC];
        } else if (SObjectName.contains('Booking__c')) {
            listWhatAppMsg = [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, API_Error_Message__c, 
                              API_Request__c, API_Response__c, API_Status__c, Account__c, Contains_File__c, Customer_Phone__c, End_Point__c, 
                              Interactive__c, Lead__c, Message_Text__c, Message_Type__c, Opportunity__c, Outbound__c, Public_Link__c, Quick_Replies__c,
                              Reply1__c, Reply2__c, Success__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Value_1__c, Value_2__c, Number_Changed__c 
                              FROM WhatsApp_Message__c WHERE Booking__c = :recId ORDER BY CreatedDate ASC];
        }
        
        System.debug('List of WhatsApp Message .: ' + listWhatAppMsg);
        return listWhatAppMsg;                
    }

    
    @AuraEnabled
    public static void InsertMessage(String msg, String recordId){
        Set<Id> Ids = new Set<Id>();
        Ids.add(recordId);
        try {
            if(!Ids.isEmpty() && !String.isBlank(msg))
                Ex_WhatsappMessageServicesNew.sendMessage(Ids,msg );
        } catch (Exception e) {
            System.debug('Error .: '+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String InsertAttachment(Map<String, Object> attachmentData, String caption) {
        /*System.debug('attachmentData = ' + attachmentData);
        String publicLink ;
        try {
            String fileName = (String) attachmentData.get('FileName');
            String contentType = (String) attachmentData.get('ContentType');
            String body = (String) attachmentData.get('Body');
            Id parentId = (Id) attachmentData.get('ParentId');
            
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(body);
            System.debug('cv.VersionData is'+cv.VersionData);
            cv.Title = filename;
            System.debug('cv.Title is'+cv.Title);
            cv.PathOnClient = filename;
            System.debug('cv.PathOnClient is'+cv.PathOnClient);
            
            //Edited by Harshal
            
            insert cv;
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id AND isLatest = true].ContentDocumentId;
            System.debug('conDocId is -- ' + conDocId);
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = parentId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            // Generate the public link for the ContentVersion associated with the record
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :parentId LIMIT 1];
            if (!cdlList.isEmpty()) {
                ContentDocumentLink link = cdlList[0];
                Id contentDocumentId = link.ContentDocumentId;
                
                ContentDistribution cd = new ContentDistribution();
                cd.ContentVersionId = cv.Id; // Associate with the ContentVersion, not ContentDocument
                cd.Name = 'Public Link';
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                insert cd;
                
                cd = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1];
                publicLink = cd.DistributionPublicUrl;
                System.debug('Public Link: ' + publicLink);
                // Calling updateRecordWithPublicLink to add Public Link  
                // updateRecordWithPublicLink(recordId, publicLink, i);
            }
            System.debug('returned cv is::' + cv.Title);
            
            List<WhatsApp_Message__c> whatsappMessage = [Select Id, Public_Link__c, Contains_File__c from WhatsApp_Message__c where Id =: cdl.LinkedEntityId];
            whatsappMessage[0].Contains_File__c = true;
            whatsappMessage[0].Public_Link__c = publicLink;
            whatsappMessage[0].Message_Text__c = caption;
            if(whatsappMessage != null & !whatsappMessage.isEmpty()){
                Update whatsappMessage;
            }
            System.debug('attachment = ' + cv.Id);
            return 'Attachment saved successfully';
        } catch (Exception e) {
            return 'Error saving attachment: ' + e.getMessage();
        }*/
        
        return null;
    }
    
    @AuraEnabled
    public static void SendTemplate(String tId, String recId){
        Set<Id> Ids = new Set<Id>();
        Ids.add(recId);
        
        List<Whatsapp_Template__c> wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c,
                                         Sample_Text__c, API_Hit_Status__c, Request__c, Response__c, Template_ID__c,
                                         Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c,
                                         Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c,Public_Link_1__c
                                         FROM Whatsapp_Template__c
                                         WHERE Id = :tId LIMIT 1];
        
        if(!wt.isEmpty()){
            String templateID = wt[0].Template_ID__c;
            try {
                if(!Ids.isEmpty() && !String.isBlank(templateID))
                    Ex_WhatsappMessageServicesNew.Ex_WhatsappMsg(Ids,templateID );
            } catch (Exception e) {
                System.debug('Error .: '+e.getMessage());
            }
            System.debug('Sucess .: ');
        }else{
            System.debug('Failed .: ');
        }
        
    }
    
    
    @AuraEnabled
    public static List<Whatsapp_Template__c> getTemplate(String recId, String category) {
        List<Whatsapp_Template__c> templates = new List<Whatsapp_Template__c>(); 
        Id recordId = (Id) recId;
        String SObjectName = recordId.getSObjectType().getDescribe().getName();
        System.debug('SObjectName .: ' + SObjectName);
        
        List<Lead__c> Leadlist = [SELECT Id, Last_Name__c, Mobile__c, Project__c, Phone__c, Project__r.Name FROM Lead__c WHERE Id =:recId];
        system.debug('Leadlist::'+Leadlist);
        
        Set<String> projectNames = new Set<String>();
        if(Leadlist!=null && !Leadlist.isEmpty()){
            for (Lead__c lead : Leadlist) {
                projectNames.add(lead.Project__c);
            }
        }
        
        List<Opportunity__c> opplist = [SELECT Id, Name, Mobile__c,Project__c, Project__r.Name FROM Opportunity__c WHERE Id =:recId];
        system.debug('opplist::'+opplist);
        
        if(opplist!=null && !opplist.isEmpty()){
            for (Opportunity__c opp : opplist) {
                projectNames.add(opp.Project__c);
            }
        }

        List<Booking__c> bookinglist = [SELECT Id, Name, Mobile__c,Project__c, Project__r.Name FROM Booking__c WHERE Id  =:recId];
        System.debug('bookinglist::'+bookinglist);
        
        if(bookinglist!=null && !bookinglist.isEmpty()){
            for (Booking__c booking : bookinglist) {
                projectNames.add(booking.Project__c);
            }
        }
        
        System.debug('projectNames::'+projectNames);
        
        if (SObjectName.contains('Lead__c')) {
            system.debug('inLead__c::');
            templates = [SELECT Id, Name, Template__c, Parameters__c, Contains_Media__c, Object__c, Whatsapp_Template_Name__c,
                         Contains_Document__c, Template_Category__c, Public_Link_1__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c,
                         Value_1__c, Value_2__c, Reply1__c, Reply2__c,Project__c,Template_Kind__c 
                         FROM Whatsapp_Template__c 
                         WHERE Template_Category__c = :category AND Template_Approval_Status__c = 'APPROVED' 
                         AND Object__c = 'Lead__c'
                         AND (Project__c IN :projectNames OR Template_Kind__c = 'General')];
            system.debug('templateslead::'+templates);
        } else if (SObjectName.contains('Opportunity__c')) {
            templates = [SELECT Id, Name, Template__c, Parameters__c, Contains_Media__c, Object__c, Whatsapp_Template_Name__c,
                         Contains_Document__c, Template_Category__c, Public_Link_1__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c,
                         Value_1__c, Value_2__c, Reply1__c, Reply2__c,Project__c,Template_Kind__c 
                         FROM Whatsapp_Template__c 
                         WHERE Template_Category__c = :category AND Template_Approval_Status__c = 'APPROVED' 
                         AND Object__c = 'Opportunity__c'
                         AND (Project__c IN :projectNames OR Template_Kind__c = 'General')];
            system.debug('templatesopp::'+templates);
        } else if (SObjectName.contains('Booking__c')) {
            templates = [SELECT Id, Name, Template__c, Parameters__c, Contains_Media__c, Object__c, Whatsapp_Template_Name__c,
                         Contains_Document__c, Template_Category__c, Public_Link_1__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c,
                         Value_1__c, Value_2__c, Reply1__c, Reply2__c,Project__c,Template_Kind__c 
                         FROM Whatsapp_Template__c 
                         WHERE Template_Category__c = :category AND Template_Approval_Status__c = 'APPROVED' 
                         AND Object__c = 'Booking__c'
                         AND (Project__c IN :projectNames OR Template_Kind__c = 'General')];
            system.debug('templatesbooking::'+templates);
        }
        
        if (!templates.isEmpty()) {
            for (Whatsapp_Template__c template : templates) {
                if (template.Template__c != null) {
                    template.Template__c = removeHtmlTags(template.Template__c);
                }
            }
        }
        
        System.debug('templates .: ' + templates);
        
        return templates;
    }

    
    // Helper function to remove HTML tags using regular expressions
    public static String removeHtmlTags(String input) {
        // Replace any HTML tags with an empty string
        String replacetagswithn = input.replaceAll('</p>', '\n'); 
        return replacetagswithn.replaceAll('<[^>]+>', '');
    }
    
    
    @AuraEnabled
    public static String regenerateHTMLString(String recordId, String template) {
        System.debug('recordId = ' + recordId);
        
        SObject record = getRecordById(recordId);
        
        if (record != null) {
            List<SObject> recordList = getAllRecordDetails(recordId);
            System.debug('Record List: ' + recordList);
            
            String replacementString = template;
            Pattern p = Pattern.compile('\\{!(.*?)\\}');
            Matcher m = p.matcher(template);
            System.debug('m:' + m);
            
            while (m.find()) {
                System.debug('inside while loop:');
                List<String> objectAndField = new List<String>();
                String mergeFieldWithoutQuote = m.group().substring(2, m.group().length() - 1);
                System.debug('mergeFieldWithoutQuote:' + mergeFieldWithoutQuote);
                objectAndField = mergeFieldWithoutQuote.split('\\.');
                System.debug(objectAndField[0]);
                System.debug(objectAndField[1]);
                String replaceableString = getFieldValue(recordList, objectAndField[0], objectAndField[1]);
                
                if (replaceableString != null) {
                    System.debug('replaceable string:' + replaceableString);
                    replacementString = replacementString.replace(m.group(), replaceableString);
                } else {
                    replaceableString = '';
                    replacementString = replacementString.replace(m.group(), replaceableString);
                }
            }
            System.debug('replacementString :' + replacementString);
            return replacementString;
        }
        
        return '';
    }
    
    @AuraEnabled
    public static String generateHTMLString(String recordId, String parameters, String template) {
        System.debug('recordId = ' + recordId);
        
        SObject record = getRecordById(recordId);
        
        if (record != null) {
            List<SObject> recordList = getAllRecordDetails(recordId);
            System.debug('Record List: ' + recordList);
            
            // Split the parameters field into an array
            if(parameters != null){
                List<String> parameterValues = parameters.split(',');
                
                // Replace placeholders in the template with parameter values
                for (Integer i = 0; i < parameterValues.size(); i++) {
                    String placeholder = '{{' + (i + 1) + '}}';
                    String replaceableString = parameterValues[i].trim();
                    template = template.replace(placeholder, replaceableString);
                }
            }
            
            return regenerateHTMLString(recordId,template);
        }
        
        return '';
    }
    
    
    @AuraEnabled
    public static List<SObject> getAllRecordDetails(String recordId) {
        System.debug('recordId = ' + recordId);
        
        List<SObject> recordList = new List<SObject>();
        
        Id recId = (Id)recordId;
        
        if (recId != null) {
            Schema.DescribeSObjectResult describeResult = recId.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
            
            Set<String> objectNames = new Set<String>();
            for (String fieldAPIName : fieldMap.keySet()) {
                objectNames.add(fieldMap.get(fieldAPIName).getDescribe().getSObjectType().getDescribe().getName());
            }
            
            String queryFields = String.join(new List<String>(fieldMap.keySet()), ',');
            
            String soqlQuery = 'SELECT ' + queryFields  + ' FROM ' + String.join(new List<String>(objectNames), ',') + ' WHERE Id = \'' + recId + '\''; 
            System.debug(soqlQuery);
            
            recordList = Database.query(soqlQuery);
            System.debug('Record List: ' + recordList);
        }
        
        return recordList;
    }
    
    @AuraEnabled
    public static SObject getRecordById(String recordId) {
        SObject record;
        
        try {
            Id recId = (Id)recordId;
            record = Database.query('SELECT Id FROM ' + recId.getSObjectType().getDescribe().getName() + ' WHERE Id = :recId LIMIT 1');
        } catch (Exception e) {
            record = null;
        }
        System.debug('Record Type .: '+record);
        
        return record;
    }
    
    @AuraEnabled
    public static String getFieldValue(List<SObject> recordList, String objectName, String fieldName) {
        for (SObject record : recordList) {
            if (record.getSObjectType().getDescribe().getName() == objectName && record.get(fieldName) != null) {
                return String.valueOf(record.get(fieldName));
            }
        }
        
        return null;
    }
    
    
}