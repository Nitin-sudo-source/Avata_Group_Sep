/* Developer .: Aditya Marne, Yash Jain, Harshal More */
/* Disclaimer .: Please do not make any changes without informing the developers mentioned above */
/* Currently used to send Trigger Based Message */
public class Ex_WhatsappMessageServicesNew {
    
    @InvocableMethod(label='Send Template')
    public static void Ex_WhatsappUsingFlow(List<String> id_templateIdList){
        Set<Id> Ids = new Set<Id>();
        String templateId = '';
        if(!id_templateIdList.isEmpty()){
            for (String id_templateId : id_templateIdList) {
                List<String> parameterList = id_templateId.split(',');
                
                Id recordId = (Id) parameterList[0];
                templateId = parameterList[1];
                
                Ids.add(recordId);
            }
        }
        if(!Ids.isEmpty() && templateId != null)
            Ex_WhatsappMessageServicesNew.Ex_WhatsappMsg(Ids , templateId);
    }
    
    @future(callout=true)
    public static void Ex_WhatsappMsg(Set<Id> recordIds, String templateId) {
        
        List<Lead__c> Leadlist = [SELECT Id, Last_Name__c, Mobile__c, Project__c, Phone__c, Project__r.Name FROM Lead__c WHERE Id IN :recordIds];
        system.debug('Leadlist::'+Leadlist);
        
        Set<String> projectNames = new Set<String>();
        if(Leadlist!=null && !Leadlist.isEmpty()){
            for (Lead__c lead : Leadlist) {
                projectNames.add(lead.Project__r.Name);
            }
        }
        
        List<Opportunity__c> opplist = [SELECT Id, Name, Mobile__c, Project__r.Name FROM Opportunity__c WHERE Id IN :recordIds];
        system.debug('opplist::'+opplist);
        
        if(opplist!=null && !opplist.isEmpty()){
            for (Opportunity__c opp : opplist) {
                projectNames.add(opp.Project__r.Name);
            }
        }

        List<Booking__c> bookinglist = [SELECT Id, Name, Mobile__c, Project__r.Name FROM Booking__c WHERE Id IN :recordIds];
        System.debug('bookinglist::'+bookinglist);
        
        if(bookinglist!=null && !bookinglist.isEmpty()){
            for (Booking__c booking : bookinglist) {
                projectNames.add(booking.Project__r.Name);
            }
        }
        
        System.debug('projectNames::'+projectNames);

        List<WhatsAppMessageWrapper> messageWrappers = new List<WhatsAppMessageWrapper>();
        List<WhatsApp_Message__c> whatsappList = new List<WhatsApp_Message__c>();
        List<WA_API_Details_Gupshup__c> api = [SELECT Name__c, isActive__c, appId__c,EndPoint_URL__c, Connection__c, EndPoint__c, token__c,
                                               Channel__c, Source_Phone__c, src_name__c,API_Key__c,Project_Name__c FROM WA_API_Details_Gupshup__c
                                               WHERE isActive__c = true AND Project_Name__c IN:projectNames];
        
        System.debug('List of API .: ' + api);
        
        if (!api.isEmpty()) {
            try{
                List<Whatsapp_Template__c> wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c, Project__c,
                                                 Sample_Text__c, API_Hit_Status__c, Request__c, Response__c, Template_ID__c,
                                                 Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c,Public_Link_1__c,
                                                 Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c
                                                 FROM Whatsapp_Template__c
                                                 WHERE Template_ID__c = :templateId ];
                
                System.debug('List of Template .: ' + wt);
                
                if (!wt.isEmpty()) {
                    Whatsapp_Template__c whatsapptemp = wt[0];
                    String phone = '';
                    
                    List<Lead__c> Lead = [SELECT Id, Last_Name__c, Mobile__c, Project__c, Phone__c,Project__r.Name FROM Lead__c WHERE Id IN :recordIds AND Project__r.Name =:api[0].Project_Name__c];
                    System.debug('Lead: '+Lead);
                    if (!Lead.isEmpty()) {
                        for (Lead__c record : Lead) {
    
                            
                            //Get Phone Details 
                            phone = Ex_WhatsappMessageServicesNew.getPhoneNumber(record);
                            
                            //Generate Parameters and store it in List for POST 
                            List<String> parameterList = new List<String>();
                             String serializedList = '';
                            if(whatsapptemp.Parameters__c != null){
                                
                                List<String> paramList = whatsapptemp.Parameters__c.split(',');
                                for(String parameter : paramList){
                                    String values = Ex_WhatsappMessageServicesNew.regenerateHTMLString(record.Id, parameter);
                                    parameterList.add(values);
                                }
                                System.debug('ParameterList .: '+parameterList);
                                System.debug('paramList .: '+paramList);
                                System.debug('Size of ParameterList .: '+parameterList.size());
                                System.debug('Size of paramList .: '+paramList.size());
                                
                            
                                serializedList = JSON.serialize(parameterList);
                                System.debug('Serialized List .: ' + serializedList);
                            } else{
                                serializedList = '[]';
                            }
                            
                            //Message that is visible to User
                            String WhatsAppMessage = Ex_WhatsappMessageServicesNew.generateHTMLString(record.Id, whatsapptemp.Parameters__c, whatsapptemp.Template__c);
                            WhatsAppMessage = Ex_WhatsappMessageServicesNew.removeHtmlTags(whatsappMessage);
                            
                            //Adding the details to Wrapper
                            messageWrappers.add(new WhatsAppMessageWrapper(phone, whatsapptemp.Template_ID__c, serializedList, record.Id, WhatsAppMessage));
                        }
                        
                        System.debug('messageWrappers .: '+messageWrappers);
                    }
                    
                    List<Opportunity__c> opp = [SELECT Id, Name, Mobile__c FROM Opportunity__c WHERE Id IN: recordIds AND Project__r.Name =:api[0].Project_Name__c];
                    if (!opp.isEmpty()) {
                        for (Opportunity__c record : opp) {
                            //Get Phone Details 
                            phone = Ex_WhatsappMessageServicesNew.getPhoneNumber(record);
                            
                            //Generate Parameters and store it in List for POST 
                            List<String> parameterList = new List<String>();
                            String serializedList = '';
                            if(wt[0].Parameters__c != null){
                                
                                List<String> paramList = wt[0].Parameters__c.split(',');
                                for(String parameter : paramList){
                                    String values = Ex_WhatsappMessageServicesNew.regenerateHTMLString(record.Id, parameter);
                                    parameterList.add(values);
                                }
                                serializedList = JSON.serialize(parameterList);
                                System.debug('Serialized List .: ' + serializedList);
                            } else{
                                serializedList = '[]';
                            }
                            
                            //Message that is visible to User
                            String WhatsAppMessage = Ex_WhatsappMessageServicesNew.generateHTMLString(record.Id, wt[0].Parameters__c, wt[0].Template__c);
                            WhatsAppMessage = Ex_WhatsappMessageServicesNew.removeHtmlTags(whatsappMessage);
                            
                            //Adding the details to Wrapper
                            messageWrappers.add(new WhatsAppMessageWrapper(phone, wt[0].Template_ID__c, serializedList, record.Id, WhatsAppMessage));
                            
                        }
                        System.debug('messageWrappers .: '+messageWrappers);
                    }

                    List<Booking__c> bk = [SELECT Id, Name, Mobile__c FROM Booking__c WHERE Id IN: recordIds AND Project__r.Name =:api[0].Project_Name__c];
                    if (!bk.isEmpty()) {
                        for (Booking__c record : bk) {
                            //Get Phone Details 
                            phone = Ex_WhatsappMessageServicesNew.getPhoneNumber(record);
                            
                            //Generate Parameters and store it in List for POST 
                            List<String> parameterList = new List<String>();
                            String serializedList = '';
                            if(wt[0].Parameters__c != null){
                                
                                List<String> paramList = wt[0].Parameters__c.split(',');
                                for(String parameter : paramList){
                                    String values = Ex_WhatsappMessageServicesNew.regenerateHTMLString(record.Id, parameter);
                                    parameterList.add(values);
                                }
                                serializedList = JSON.serialize(parameterList);
                                System.debug('Serialized List .: ' + serializedList);
                            } else{
                                serializedList = '[]';
                            }
                            
                            //Message that is visible to User
                            String WhatsAppMessage = Ex_WhatsappMessageServicesNew.generateHTMLString(record.Id, wt[0].Parameters__c, wt[0].Template__c);
                            WhatsAppMessage = Ex_WhatsappMessageServicesNew.removeHtmlTags(whatsappMessage);
                            
                            //Adding the details to Wrapper
                            messageWrappers.add(new WhatsAppMessageWrapper(phone, wt[0].Template_ID__c, serializedList, record.Id, WhatsAppMessage));
                            
                        }
                        System.debug('messageWrappers .: '+messageWrappers);
                    }

                   
                    for(WhatsAppMessageWrapper wrap : messageWrappers){
                        System.debug('mobile .: '+wrap.mobile);
                        System.debug('templateId .: '+wrap.templateId);
                        System.debug('parameters .: '+wrap.parameters);
                        System.debug('recordId .: '+wrap.recordId);
                        
                        //Set the Endpoint URL
                        String submitTemplateEndpoint = api[0].EndPoint_URL__c + '/wa/api/v1/template/msg';
                        System.debug('Endpoint .: '+submitTemplateEndpoint);
                       
                        // Create an HTTP request
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(submitTemplateEndpoint);
                        request.setMethod('POST');
                        
                        // Set the request header
                        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        request.setHeader('Cache-Control','no-cache');
                        request.setHeader('cache-control', 'no-cache');
                        request.setHeader('apikey', api[0].API_Key__c);
                        
                        //Set the body
                        String body = 'channel='+api[0].Channel__c;
                        body += '&source='+api[0].Source_Phone__c;
                        body += '&destination='+wrap.mobile;
                        body += '&src.name='+api[0].src_name__c;
                        body += '&template={"id":"'+wrap.templateId+'","params":'+wrap.parameters+'}';
                        
                        
                        if(wt[0].Type__c == 'DOCUMENT'){
                            String type = wt[0].Type__c.toLowerCase();
                            body += '&message={"'+type+'":{"link":"'+whatsapptemp.Public_Link_1__c+'","filename":"Document"},"type":"'+type+'"}';
                        }else if(wt[0].Type__c == 'IMAGE'){
                            String type = wt[0].Type__c.toLowerCase();
                            body += '&message={"'+type+'":{"link":"'+whatsapptemp.Public_Link_1__c+'"},"type":"'+type+'"}';
                        }else if(wt[0].Type__c == 'VIDEO'){
                            String type = wt[0].Type__c.toLowerCase();
                            body += '&message={"'+type+'":{"link":"'+whatsapptemp.Public_Link_1__c+'"},"type":"'+type+'"}';
                        }
                        
                        //String requestBody = JSON.serialize(requestBodyMap);
                        System.debug('requestBody .: '+body);
                        request.setBody(body);  
                        
                        // Create an HTTP instance and send the request
                        Http http = new Http();
                        HttpResponse response = http.send(request);
                        System.debug('Response .: '+response.getStatusCode());
                        Map<String, Object> parsedResponse = new Map<String, Object>();
                        
                        
                        WhatsApp_Message__c w = new WhatsApp_Message__c();
                        w.Message_Text__c = wrap.messsage;
                        w.Outbound__c = true;
                        w.Message_Type__c = 'Template';
                        w.Customer_Phone__c = wrap.mobile;
                        w.API_Request__c = body;
                        w.End_Point__c = submitTemplateEndpoint;
                        
                        if (!String.isBlank(wt[0].Type_1__c) && !String.isBlank(wt[0].Title_1__c) && !String.isBlank(wt[0].Value_1__c)) {
                            w.Type_1__c = wt[0].Type_1__c;
                            w.Title_1__c = wt[0].Title_1__c;
                            w.Value_1__c = wt[0].Value_1__c;
                            w.Interactive__c = true;
                        }
                        if (!String.isBlank(wt[0].Type_2__c) && !String.isBlank(wt[0].Title_2__c) && !String.isBlank(wt[0].Value_2__c)) {
                            w.Type_2__c = wt[0].Type_2__c;
                            w.Title_2__c = wt[0].Title_2__c;
                            w.Value_2__c = wt[0].Value_2__c;
                        }
                        if (!String.isBlank(wt[0].Reply1__c) && !String.isBlank(wt[0].Reply2__c)) {
                            w.Reply1__c = wt[0].Reply1__c;
                            w.Reply2__c = wt[0].Reply2__c;
                            w.Quick_Replies__c = true;
                        }

                        
                        Id rec = (Id) wrap.recordId;
                        String SObjectName = rec.getSObjectType().getDescribe().getName();
                        System.debug('SObjectName .: '+SObjectName);
                        if(SObjectName.contains('Lead__c')){
                            w.Lead__c = rec;
                        }else if(SObjectName.contains('Opportunity__c')){
                            w.Opportunity__c = rec;
                        }else if(SObjectName.contains('Booking__c')){
                            w.Booking__c = rec;
                        }
                        String statusCode = String.valueOf(response.getStatusCode());
                        
                        if(statusCode.startsWith('2')){

                            System.debug('Status --'+response.getStatus());
                            System.debug('API Response -- '+response.getBody());
                            
                            w.API_Status__c = 'Success';
                            w.API_Response__c = response.getBody();
                            w.Success__c = true;
                            String responseBody = response.getBody();
                            // Access specific values from the response
                            parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                            // Access specific values from the response
                            if (parsedResponse.containsKey('messageId')) {
                                w.Message_Id__c = (String) parsedResponse.get('messageId');
                                System.debug('Message Id .: '+w.Message_Id__c);
                            }
                        }
                        else{
                            w.API_Response__c = response.getBody();
                            w.API_Status__c = 'Failed';
                            
                            System.debug('Response .: '+response.getBody());
                            
                            Map<String, Object> responseBodyforError = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            
                            if (responseBodyforError.containsKey('message')) {
                                w.API_Error_Message__c = (String) responseBodyforError.get('message');
                            }
                        }
                        whatsappList.add(w);
                    }
                    
                    if(!whatsappList.isEmpty())
                        insert whatsappList;
                    
                }
            }catch(Exception e){
                System.debug('Error sending Message .: '+e.getMessage());
            }   
        }
    }

    @future(callout=true)
    public static void sendMessage(Set<Id> recordIds, String message) {
        
        List<Lead__c> Leadlist = [SELECT Id, Last_Name__c, Mobile__c, Project__c, Phone__c, Project__r.Name FROM Lead__c WHERE Id IN :recordIds];
        system.debug('Leadlist::'+Leadlist);
        
        Set<String> projectNames = new Set<String>();
        if(Leadlist!=null && !Leadlist.isEmpty()){
            for (Lead__c lead : Leadlist) {
                projectNames.add(lead.Project__r.Name);
            }
        }
        
        List<Opportunity__c> opplist = [SELECT Id, Name, Mobile__c, Project__r.Name FROM Opportunity__c WHERE Id IN :recordIds];
        system.debug('opplist::'+opplist);
        
        if(opplist!=null && !opplist.isEmpty()){
            for (Opportunity__c opp : opplist) {
                projectNames.add(opp.Project__r.Name);
            }
        }

        List<Booking__c> bookinglist = [SELECT Id, Name, Mobile__c, Project__r.Name FROM Booking__c WHERE Id IN :recordIds];
        System.debug('bookinglist::'+bookinglist);
        
        if(bookinglist!=null && !bookinglist.isEmpty()){
            for (Booking__c booking : bookinglist) {
                projectNames.add(booking.Project__r.Name);
            }
        }
        
        System.debug('projectNames::'+projectNames);

        List<WhatsApp_Message__c> whatsappList = new List<WhatsApp_Message__c>();
        List<WA_API_Details_Gupshup__c> api = [SELECT Name__c, isActive__c, appId__c, Connection__c, EndPoint__c, token__c,
                                               Channel__c, API_Key__c, Source_Phone__c, src_name__c,Project_Name__c FROM WA_API_Details_Gupshup__c
                                               WHERE isActive__c = true AND Project_Name__c IN:projectNames];
        
        System.debug('List of API .: ' + api);
        
        if (!api.isEmpty()) {
            try {          
                if (String.isNotBlank(message)) {
                    String msg = message;
                    
                    for (Id recordId : recordIds) {
                        String sObjectType = recordId.getSObjectType().getDescribe().getName();
                        String mobileField = '';
                        Id objectId = recordId;
                        
                        if (sObjectType == 'Lead__c') {
                            Lead__c lead = [SELECT Id, Mobile__c FROM Lead__c WHERE Id = :recordId AND Project__r.Name =:api[0].Project_Name__c LIMIT 1];
                            if (lead != null && !String.isBlank(lead.Mobile__c)) {
                                mobileField = lead.Mobile__c;
                            }
                        } else if (sObjectType == 'Opportunity__c') {
                            Opportunity__c opportunity = [SELECT Id, Mobile__c FROM Opportunity__c WHERE Id = :recordId AND Project__r.Name =:api[0].Project_Name__c LIMIT 1];
                            if (opportunity != null && !String.isBlank(opportunity.Mobile__c)) {
                                mobileField = opportunity.Mobile__c;
                            }
                        } else if (sObjectType == 'Booking__c') {
                            Booking__c booking = [SELECT Id, Mobile__c FROM Booking__c WHERE Id = :recordId AND Project__r.Name =:api[0].Project_Name__c LIMIT 1];
                            if (booking != null && !String.isBlank(booking.Mobile__c)) {
                                mobileField = booking.Mobile__c;
                            }
                        }
                        
                        if (!String.isBlank(mobileField)) {
                            //Set the Endpoint URL
                            String sendMessageEndpoint = 'https://api.gupshup.io/sm/api/v1/msg';
                            
                            // Create an HTTP request
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint(sendMessageEndpoint);
                            request.setMethod('POST');
                            
                            // Set the request headers
                            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                            request.setHeader('accept', 'application/json');
                            request.setHeader('apikey', api[0].API_Key__c);
                            
                            // Set the request body
                            String requestBody = 'message={"type":"text","text":"' + msg + '"}' +
                                '&channel=whatsapp' +
                                '&source=' + api[0].Source_Phone__c +
                                '&destination=' + mobileField +
                                '&src.name=' + api[0].src_name__c;
                            request.setBody(requestBody);
                            
                            // Create an HTTP instance and send the request
                            Http http = new Http();
                            HttpResponse response = http.send(request);
                            
                            // Handling the response
                            WhatsApp_Message__c whatsappMessage = new WhatsApp_Message__c();
                            whatsappMessage.Message_Text__c = msg;
                            whatsappMessage.Outbound__c = true;
                            whatsappMessage.Message_Type__c = 'Normal';
                            whatsappMessage.Customer_Phone__c = mobileField;
                            whatsappMessage.API_Request__c = requestBody;
                            whatsappMessage.End_Point__c = sendMessageEndpoint;
                            
                            if (sObjectType == 'Lead__c') {
                                whatsappMessage.Lead__c = objectId;
                            } else if (sObjectType == 'Opportunity__c') {
                                whatsappMessage.Opportunity__c = objectId;
                            } else if (sObjectType == 'Booking__c') {
                                whatsappMessage.Booking__c = objectId;
                            }
                            
                            if (response.getStatusCode() == 202) {
                                whatsappMessage.API_Status__c = 'Success';
                                whatsappMessage.API_Response__c = response.getBody();
                                whatsappMessage.Success__c = true;
                            } else {
                                whatsappMessage.API_Status__c = 'Failed';
                                whatsappMessage.API_Response__c = response.getBody();
                                whatsappMessage.API_Error_Message__c = 'Error sending WhatsApp message';
                            }
                            
                            whatsappList.add(whatsappMessage);
                        }
                    }
                    
                    if (!whatsappList.isEmpty()) {
                        insert whatsappList;
                    }
                }
            } catch (Exception e) {
                System.debug('Error sending Message: ' + e.getMessage());
            }
        }
    }

    public static String getPhoneNumber(Sobject record){
        String phone = '';
        
        if (record.get('Mobile__c') != null) {
            phone = String.valueOf(record.get('Mobile__c'));
        } else if (record.get('Phone__c') != null) {
            phone = String.valueOf(record.get('Phone__c'));
        } else if (record.get('PersonMobilePhone') != null) {
            phone = String.valueOf(record.get('PersonMobilePhone'));
        } else if (record.get('POC_Mobile__c') != null) {
            phone = String.valueOf(record.get('POC_Mobile__c'));
        } else if (record.get('Phone') != null) {
            phone = String.valueOf(record.get('Phone'));
        }
        
        if (phone.length() == 10) {
            phone = '91' + phone;
        }
        
        return phone;
    }
    
    @AuraEnabled
    public static String regenerateHTMLString(String recordId, String template) {
        System.debug('recordId = ' + recordId);
        
        //SObject record = Ex_WhatsappMessageServicesNew.getRecordById(recordId);
        
        if (recordId != null) {
            List<SObject> recordList = Ex_WhatsappMessageServicesNew.getAllRecordDetails(recordId);
            //System.debug('Record List: ' + recordList);
            
            String replacementString = template;
            Pattern p = Pattern.compile('\\{!(.*?)\\}');
            Matcher m = p.matcher(template);
            //System.debug('m:' + m);
            
            while (m.find()) {
                List<String> objectAndField = new List<String>();
                String mergeFieldWithoutQuote = m.group().substring(2, m.group().length() - 1);
                
                objectAndField = mergeFieldWithoutQuote.split('\\.');
                System.debug(objectAndField[0]);
                System.debug(objectAndField[1]);
                
                String replaceableString = Ex_WhatsappMessageServicesNew.getFieldValue(recordList, objectAndField[0], objectAndField[1]);
                
                if (replaceableString != null) {
                    replacementString = replacementString.replace(m.group(), replaceableString);
                } else {
                    replaceableString = '';
                    replacementString = replacementString.replace(m.group(), replaceableString);
                }
            }
            return replacementString;
        }
        
        return '';
    }
    
    @AuraEnabled
    public static SObject getRecordById(String recordId) {
        SObject record;
        
        try {
            Id recId = (Id)recordId;
            record = Database.query('SELECT Id FROM ' + recId.getSObjectType().getDescribe().getName() + ' WHERE Id = \''+ recId +'\' LIMIT 1');
        } catch (Exception e) {
            record = null;
        }
        
        return record;
    }
    
    @AuraEnabled
    public static List<SObject> getAllRecordDetails(String recordId) {
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
            
            recordList = Database.query(soqlQuery);
        }
        
        return recordList;
    }
    
    @AuraEnabled
    public static String generateHTMLString(String recordId, String parameters, String template) {
        
        //SObject record = getRecordById(recordId);
        
        if (recordId != null) {
            //List<SObject> recordList = getAllRecordDetails(recordId);
            
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
    public static String getFieldValue(List<SObject> recordList, String objectName, String fieldName) {
        for (SObject record : recordList) {
            if (record.getSObjectType().getDescribe().getName() == objectName && record.get(fieldName) != null) {
                return String.valueOf(record.get(fieldName));
            }
        }
        
        return null;
    }
    
    // Helper function to remove HTML tags using regular expressions
    public static String removeHtmlTags(String input) {
        // Replace any HTML tags with an empty string
        String replacetagswithn = input.replaceAll('</p>', '\n'); 
        return replacetagswithn.replaceAll('<[^>]+>', '').unescapeHtml4();
    }
    
    public class WhatsAppMessageWrapper {
        public String mobile { get; set; }
        public String templateId { get; set; }
        public String parameters { get; set; }
        public String recordId {get; set;}
        public String messsage {get; set;}
        
        public WhatsAppMessageWrapper(String mobile, String templateId, String parameters, String recordId, String messsage) {
            this.mobile = mobile;
            this.templateId = templateId;
            this.parameters = parameters;
            this.recordId = recordId;
            this.messsage = messsage;
        }
    }
    
}