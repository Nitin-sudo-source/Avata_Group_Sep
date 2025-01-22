/* Developer .: Aditya Marne, Yash Jain, Harshal More */
/* Disclaimer .: Please do not make any changes without informing the developers mentioned above*/
/* Currently used send Bulk Message */
public class WhatsAppMessageBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    private Set<Id> Ids;
    private String SobjectName;
    private String TemplateId;
    
    public WhatsAppMessageBatch(Set<Id> Ids, String SobjectName, String TemplateId){
        this.Ids = Ids;
        this.SobjectName = SobjectName;
        this.TemplateId = TemplateId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {    
        String query = '';
        if(SobjectName.contains('Lead__c')){
            query = 'SELECT Id, Last_Name__c, Mobile__c, Phone__c FROM Lead__c WHERE Id IN :Ids';
        }/*else if(SobjectName.contains('Account')){
            query = 'SELECT Id, Name, PersonMobilePhone, Phone, POC_Mobile__c FROM Account WHERE Id IN :Ids';
        }*/
        else if(SobjectName.contains('Opportunity__c')){
            query = 'SELECT Id, Name, Mobile__c FROM Opportunity__c WHERE Id IN :Ids';
        }
        /*else if(SobjectName.contains('Channel_Partner__c')){
            query = 'SELECT Id, Name, Mobile__c FROM Channel_Partner__c WHERE Id IN :Ids';
        }*/
        else if(SobjectName.contains('Booking__c')){
            query = 'SELECT Id, Name, Mobile__c FROM Booking__c WHERE Id IN :Ids';
        }
        if(query != null && query != '')
            return Database.getQueryLocator(query);
        else
            return null;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<WhatsApp_Message__c> whatsappList = new List<WhatsApp_Message__c>();
        List<WhatsAppMessageWrapper> messageWrappers = new List<WhatsAppMessageWrapper>();
        
        List<Lead__c> Leadlist = [SELECT Id, Last_Name__c, Mobile__c, Project__c, Phone__c, Project__r.Name FROM Lead__c WHERE Id IN :Ids];
        system.debug('Leadlist::'+Leadlist);
        
        Set<String> projectNames = new Set<String>();
        if(Leadlist!=null && !Leadlist.isEmpty()){
            for (Lead__c lead : Leadlist) {
                projectNames.add(lead.Project__r.Name);
            }
        }
        
        List<Opportunity__c> opplist = [SELECT Id, Name, Mobile__c,Project__c, Project__r.Name FROM Opportunity__c WHERE Id IN :Ids];
        system.debug('opplist::'+opplist);
        
        if(opplist!=null && !opplist.isEmpty()){
            for (Opportunity__c opp : opplist) {
                projectNames.add(opp.Project__r.Name);
            }
        }

        List<Booking__c> bookinglist = [SELECT Id, Name, Mobile__c, Project__r.Name FROM Booking__c WHERE Id IN :Ids];
        System.debug('bookinglist::'+bookinglist);
        
        if(bookinglist!=null && !bookinglist.isEmpty()){
            for (Booking__c booking : bookinglist) {
                projectNames.add(booking.Project__r.Name);
            }
        }
        
        System.debug('projectNames::'+projectNames);
        
        
        List<WA_API_Details_Gupshup__c> api = [SELECT Name__c, isActive__c, appId__c, Connection__c, EndPoint__c, token__c,EndPoint_URL__c,API_Key__c,
                                               Channel__c, Source_Phone__c, src_name__c,Project_Name__c FROM WA_API_Details_Gupshup__c 
                                               WHERE  isActive__c =: TRUE AND Project_Name__c IN:projectNames];
        System.debug('List of API .: ' + api);
        
        if(!api.isEmpty()){
            try {
                List<Whatsapp_Template__c> wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c,Public_Link_1__c,
                                                 Sample_Text__c, API_Hit_Status__c, Request__c, Response__c, Template_ID__c,Project__c,Template_Kind__c,
                                                 Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c,
                                                 Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c
                                                 FROM Whatsapp_Template__c
                                                 WHERE Id = :TemplateId LIMIT 1];
                System.debug('List of Template .: ' + wt);
                
               if (!wt.isEmpty()){
                    String phone = '';
                    if(!scope.isEmpty()){
                        for(SObject s : scope){
                            // Bulk_Test__c b = new Bulk_Test__c();
                            phone = Ex_WhatsappMessageServicesNew.getPhoneNumber(s);
                            //Generate Parameters and store it in List for POST 
                            List<String> parameterList = new List<String>();
                            String serializedList = '';
                            if(wt[0].Parameters__c != null){
                                
                                List<String> paramList = wt[0].Parameters__c.split(',');
                                for(String parameter : paramList){
                                    String values = Ex_WhatsappMessageServicesNew.regenerateHTMLString(s.Id, parameter);
                                    parameterList.add(values);
                                }
                                serializedList = JSON.serialize(parameterList);
                                System.debug('Serialized List: ' + serializedList);
                            }else{
                                serializedList = '[]';
                            }
                            
                            //Message that is visible to User
                            String WhatsAppMessage = Ex_WhatsappMessageServicesNew.generateHTMLString(s.Id, wt[0].Parameters__c, wt[0].Template__c);
                            WhatsAppMessage = Ex_WhatsappMessageServicesNew.removeHtmlTags(whatsappMessage);
                            
                            //Adding the details to Wrapper
                            messageWrappers.add(new WhatsAppMessageWrapper(phone, wt[0].Template_ID__c, serializedList, s.Id, WhatsAppMessage));
                        }
                        System.debug('messageWrappers .: '+messageWrappers.size());
                        
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
                                body += '&message={"'+type+'":{"link":"'+wt[0].Public_Link_1__c+'","filename":"Document"},"type":"'+type+'"}';
                            }else if(wt[0].Type__c == 'IMAGE'){
                                String type = wt[0].Type__c.toLowerCase();
                                body += '&message={"'+type+'":{"link":"'+wt[0].Public_Link_1__c+'"},"type":"'+type+'"}';
                            }else if(wt[0].Type__c == 'VIDEO'){
                                String type = wt[0].Type__c.toLowerCase();
                                body += '&message={"'+type+'":{"link":"'+wt[0].Public_Link_1__c+'"},"type":"'+type+'"}';
                            }
                            
                            System.debug('requestBody .: '+body);
                            request.setBody(body);  
                            
                            // Create an HTTP instance and send the request
                            Http http = new Http();
                            HttpResponse response = http.send(request);
                            System.debug('Response -- '+response.getStatusCode());
                            Map<String, Object> parsedResponse = new Map<String, Object>();
                            
                            
                            WhatsApp_Message__c w = new WhatsApp_Message__c();
                            w.Message_Text__c = wrap.messsage;
                            w.Outbound__c = true;
                            w.Message_Type__c = 'Bulk';
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
                            }else if(SObjectName.contains('Account')){
                                w.Account__c = rec;
                            }
                            String statusCode = String.valueOf(response.getStatusCode());
                            
                            if(statusCode.startsWith('2')){
                                
                                System.debug('Status .: '+response.getStatus());
                                System.debug('API Response .: '+response.getBody());
                                
                                w.API_Status__c = 'Success';
                                w.API_Response__c = response.getBody();
                                w.Success__c = true;
                                String responseBody = response.getBody();
                                // Assuming the response body is in JSON format
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
                }
            } catch (Exception e) {
                System.debug('Error .: '+e.getMessage());
            } 
            
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks here
    }
}