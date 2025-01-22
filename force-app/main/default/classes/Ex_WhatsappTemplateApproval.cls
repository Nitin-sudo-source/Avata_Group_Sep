public class Ex_WhatsappTemplateApproval {
    //public static String apiEndpoint = 'https://connect.api-wa.co/project-apis/v1/project/64b515bf822fad1232720ad8/wa_template';
		
    public static void recordCreated(List<Whatsapp_Template__c> newTemplate){
        System.debug('New Template created is -- '+newTemplate);
        for(Whatsapp_Template__c template : newTemplate){
            System.debug('Name -- '+template.Whatsapp_Template_Name__c);
            System.debug('Template -- '+template.Template__c);
            System.debug('Template_Category__c -- '+template.Template_Category__c);
            System.debug('Type__c -- '+template.Type__c);
            System.debug('Sample_Text__c -- '+template.Sample_Text__c);
            List<ContentDocumentLink> cd = [SELECT Id, LinkedEntityId, ContentDocument.FileType FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =: template.Id];
            /*for (ContentDocumentLink cdList : cd){
                String fileType = cd[0].ContentDocument.FileType;
                String type;
                System.debug('fileType -- '+fileType);
                if(fileType =='JPEG' || fileType =='JPG' || fileType =='PNG'){
                	type = 'IMAGE';
                }
                else if(fileType =='MP4' ){
                	type = 'VIDEO';
                }
                else if(fileType =='PDF'){
                	type = 'FILE';
                }
                else{
                	type = 'TEXT';
                }
                
                
			}
                */
            //Calling the function
            if(String.isNotBlank(template.Whatsapp_Template_Name__c) && String.isNotBlank(template.Template__c)){
                Ex_WhatsappTemplateApproval.newTemplateApproval(template.Id);
            }
            else{
                System.debug('Null Template');
            } 
            
        }
    }
        
    @future(callout=true)
    public static void newTemplateApproval(String Id) {
        String sample_text = '';
        String handleId = '';
        
        Whatsapp_Template__c wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c, Sample_Text__c, API_Hit_Status__c, Request__c, 
                                   Response__c, Template_ID__c, Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c, 
                                   Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c, Media_HandleId__c,Project__c,Project__r.Name
                                   from Whatsapp_Template__c 
                                   WHERE Id =: Id LIMIT 1];
        List<WA_API_Details_Gupshup__c> api = new List<WA_API_Details_Gupshup__c>();
       
        
        System.debug('wt: ' + wt);
        System.debug('Name .: ' + wt.Whatsapp_Template_Name__c);
        System.debug('Category .: ' + wt.Template_Category__c);
        System.debug('ID .:' + Id);
        System.debug('Sample Text:' + wt.Sample_Text__c);
        System.debug('Handle Id .: '+wt.Media_HandleId__c);
		//String newtext = wt.Template__c;
        String newtext = Ex_WhatsappTemplateApproval.removeHtmlTags(wt.Template__c);
        System.debug('newText -- ' + newtext);
     	if(wt.Sample_Text__c != null && wt.Parameters__c != null)
        	sample_text = Ex_WhatsappTemplateApproval.CheckSampleText(wt.Sample_Text__c, newtext);
		else 
            sample_text = newtext;
        
        if(wt.Project__r.Name!=null && wt.Project__r.Name!=''){
             api = [SELECT appId__c, Connection__c, EndPoint__c, token__c,Project_Name__c
                                                   FROM WA_API_Details_Gupshup__c where IsActive__c = true AND Project_Name__c =:wt.Project__r.Name];
            system.debug('api::'+api);
        } else {
             api = [SELECT appId__c, Connection__c, EndPoint__c, token__c,Project_Name__c
                                                   FROM WA_API_Details_Gupshup__c where IsActive__c = true /*AND Project_Name__c =:wt.Project__r.Name*/];
            system.debug('api::'+api);
        }
        

        String submitTemplateEndpoint = api[0].EndPoint__c+api[0].appId__c+'/templates';
        System.debug('apiEndPoint .: '+submitTemplateEndpoint);
        
        Integration_Log__c IntLogs = new Integration_Log__c();
        IntLogs.Whatsapp_Template__c = wt.Id;
        IntLogs.EndPoint__c = submitTemplateEndpoint;
        
        // Create an HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(submitTemplateEndpoint);
        request.setMethod('POST');
        
        // Set the request header
        request.setHeader('token',api[0].token__c );
        //request.setHeader('Connection', api[0].Connection__c);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        System.debug('token .:' + api[0].token__c);
        System.debug('Connection .: ' + api[0].Connection__c);
        
        //Set the body
        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('elementName', wt.Whatsapp_Template_Name__c);  // Use the 'name' parameter
        requestBodyMap.put('languageCode', 'en_US');
        requestBodyMap.put('category', wt.Template_Category__c);
        if(wt.Media_HandleId__c == null || wt.Media_HandleId__c == '')
            requestBodyMap.put('templateType', wt.Type__c);
        else{
            requestBodyMap.put('templateType', wt.Type__c);
            requestBodyMap.put('exampleMedia', wt.Media_HandleId__c);
            requestBodyMap.put('appId', api[0].appId__c);
        }
        requestBodyMap.put('vertical', 'TEXT');
        requestBodyMap.put('header', '');
        requestBodyMap.put('content', newtext);
        requestBodyMap.put('example', sample_text);
        requestBodyMap.put('enableSample', String.valueOf(true));
        requestBodyMap.put('exampleHeader', '');
        requestBodyMap.put('allowTemplateCategoryChange', String.valueOf(true));

        // List<String> buttonList = new List<String>();
        List<Map<String, Object>> buttonList = new List<Map<String, Object>>();
        if(wt.Reply1__c != null || wt.Reply2__c != null) {
            for (Integer i = 1; i <= 2; i++) {
                String replyField = 'Reply' + i + '__c';
                Object replyFieldValue = wt.get(replyField);
                String buttonText = String.valueOf(replyFieldValue);

                // Check if the Reply field has a value
                if (buttonText != null ) {
                    // Add button dynamically
                    Map<String, Object> button = new Map<String, Object>{
                        'type' => 'QUICK_REPLY',
                        'text' => buttonText
                    };

                    buttonList.add(button);
                }
            }
            requestBodyMap.put('buttons', String.join(buttonList, ','));
        }
        else if((wt.Type_1__c != null && wt.Value_1__c != null && wt.Title_1__c != null) || 
        (wt.Type_2__c != null && wt.Value_2__c != null && wt.Title_2__c != null)) {

            if(wt.Type_1__c != null && wt.Value_1__c != null && wt.Title_1__c != null) {
                if(wt.Type_1__c == 'PHONE_NUMBER'){
                    Map<String, Object> button = new Map<String, Object>{
                        'type' => 'PHONE_NUMBER',
                        'text' => String.valueOf(wt.Title_1__c),    
                        'phone_number' => String.valueOf(wt.Value_1__c)
                    };
                    buttonList.add(button);
                }else{
                    Map<String, Object> button = new Map<String, Object>{
                        'type' => 'URL',
                        'text' => String.valueOf(wt.Title_1__c),    
                        'url' => String.valueOf(wt.Value_1__c)
                    };
                    buttonList.add(button);
                }
                
            }
            if(wt.Type_2__c != null && wt.Value_2__c != null && wt.Title_2__c != null) {
                if(wt.Type_2__c == 'URL'){
                    Map<String, Object> button = new Map<String, Object>{
                        'type' => 'URL',
                        'text' => String.valueOf(wt.Title_2__c),    
                        'url' => String.valueOf(wt.Value_2__c)
                    };
                    buttonList.add(button);
                }
            }
            System.debug('ButtonList .: '+buttonList);
            String buttonsJson = JSON.serialize(buttonList);
            System.debug('ButtonJson .: '+buttonsJson);
            requestBodyMap.put('buttons', buttonsJson);
            //requestBodyMap.put('buttons', String.join(buttonList, ','));
        }

        String requestBody = '';
        for (String key : requestBodyMap.keySet()) {
            if (!String.isEmpty(requestBody)) {
                requestBody += '&';
            }
            requestBody += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(requestBodyMap.get(key), 'UTF-8');
        }
        
        //String requestBody = JSON.serialize(requestBodyMap);
        System.debug('requestBody -- '+requestBody);
        request.setBody(requestBody);        
        System.debug('Request -- '+request);
        
        // Create an HTTP instance and send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response -- '+response.getStatusCode());
        Map<String, Object> parsedResponse = new Map<String, Object>();
        if(response.getStatusCode() == 200){
            
            System.debug('Status --'+response.getStatus());
            System.debug('API Response -- '+response.getBody());
            
            wt.API_Hit_Status__c = 'Success';
            IntLogs.API_Hit_Status__c = 'Success';
            
            String responseBody = response.getBody();
            // Assuming the response body is in JSON format
            parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            // Access specific values from the response
        }
        else{
            System.debug('Status --'+response.getStatus());
            System.debug('API Status Code -- '+response.getStatusCode());
            System.debug('API Response - - '+response.getBody());
            wt.API_Hit_Status__c = 'Failed';
            IntLogs.API_Hit_Status__c = 'Failed';
        }
        
        //wt.Request__c = requestBody;
        wt.Request__c = JSON.serialize(requestBodyMap);
        wt.Response__c = response.getBody();
        
        Map<String, Object> templateInfo  = (Map<String, Object>)parsedResponse.get('template');
        String templateId;
        String templatestatus;
        if(templateInfo != null){
            templateId = (String) templateInfo.get('id');
            System.debug('TemplateId .: '+templateId);
            
			templatestatus = (String) templateInfo.get('status');
            System.debug('templatestatus .: '+templatestatus);
        }
        
		wt.Template_ID__c = TemplateId;
        wt.Template_Approval_Status__c = templatestatus;
        //wt.Whatsapp_Template_Name__c = (String) parsedResponse.get('name');
        
        IntLogs.Request__c = requestBody;
        IntLogs.Response__c = response.getBody();
        
        IntLogs.Template_ID__c = TemplateId;
        IntLogs.Template_Approval_Status__c = templatestatus;
        
        System.debug('waId .:'+wt.Template_ID__c);
        System.debug('ilog .:'+wt);
        try{
            update wt;
            insert IntLogs;
            System.debug('Whatsapp_Template__c record Updated with Id .:' + wt.Id);
        } 
        catch (Exception e) {
            System.debug('Error Updating Whatsapp_Template__c record .: ' + e.getMessage());
        }
    }
    
    public static String removeHtmlTags(String input) {
        // Replace any HTML tags with an empty string
        String replacetagswithn = input.replaceAll('</p>', '\n'); 
        return replacetagswithn.replaceAll('<[^>]+>', '').unescapeHtml4();
    }
    
    @future(callout=true)
    public static void templateApprovalStatusUpdate(String Id){        
        Whatsapp_Template__c wt = [SELECT Id, Whatsapp_Template_Name__c, Template__c, Template_Category__c, Type__c, Sample_Text__c, API_Hit_Status__c, Request__c, 
                                   Response__c, Template_ID__c, Template_Approval_Status__c, Value_1__c, Value_2__c, Reply1__c, Reply2__c, Title_1__c, Title_2__c, Type_1__c, Type_2__c, Parameters__c,Project__c,Project__r.Name 
                                   from Whatsapp_Template__c
                                   WHERE Id =: Id LIMIT 1];
        
        List<WA_API_Details_Gupshup__c> apis = new  List<WA_API_Details_Gupshup__c>();
        
        if(wt.Project__r.Name!=null && wt.Project__r.Name!=''){
             apis = [SELECT appId__c, Connection__c, EndPoint__c, token__c,Project_Name__c
                                                   FROM WA_API_Details_Gupshup__c where IsActive__c = true AND Project_Name__c =:wt.Project__r.Name];
            system.debug('apis::'+apis);
        } else {
             apis = [SELECT appId__c, Connection__c, EndPoint__c, token__c,Project_Name__c
                                                   FROM WA_API_Details_Gupshup__c where IsActive__c = true /*AND Project_Name__c =:wt.Project__r.Name*/];
            system.debug('apis::'+apis);
        }
        
        
        String submitTemplateEndpoint = apis[0].EndPoint__c+apis[0].appId__c+'/templates';
        System.debug('apiEndPoint .: '+submitTemplateEndpoint);
        
        Integration_Log__c iLog = new Integration_Log__c();
        iLog.Whatsapp_Template__c = wt.Id;
        iLog.EndPoint__c = submitTemplateEndpoint;
        iLog.Check_for_Approval__c = true;
        
        // Create an HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(submitTemplateEndpoint);
        request.setMethod('GET');
        
        // Set the request header
        request.setHeader('token',apis[0].token__c );
        
        iLog.Request__c = String.valueOf(request);
        //Set the body
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        
        // Create an HTTP instance and send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response -- '+response.getStatusCode());
        Map<String, Object> parsedResponse = new Map<String, Object>();
        if(response.getStatusCode() == 200){
            System.debug('Status --'+response.getStatus());
            System.debug('API Response -- '+response.getBody());
            wt.API_Hit_Status__c = 'Success';
            iLog.API_Hit_Status__c = 'Success';
            String responseBody = response.getBody();
            System.debug('responseBody .: '+responseBody);
            // Assuming the response body is in JSON format
            parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('parsedResponse .: '+parsedResponse);
        }
        else{
            System.debug('Status --'+response.getStatus());
            System.debug('API Status Code -- '+response.getStatusCode());
            System.debug('API Response - - '+response.getBody());
            wt.API_Hit_Status__c = 'Failed';
            iLog.API_Hit_Status__c = 'Failed';
        }        
        
        // Map the JSON status to the corresponding Salesforce status
        if (String.isNotBlank(response.getBody())) {
            try {
                iLog.Response__c = response.getBody();
                List<Object> templateInfoList = (List<Object>)parsedResponse.get('templates');

                Long createdAtMillis = null;
                Long updatedAtMillis = null;

                for (Object templateObject : templateInfoList) {
                    Map<String, Object> templateInfo = (Map<String, Object>)templateObject;
                
                    String templateId = (String)templateInfo.get('id');
                    System.debug('TemplateId: ' + templateId);
                    
                    String templateStatus = (String)templateInfo.get('status');
                    System.debug('TemplateStatus: ' + templateStatus);

                    String templateReason = (String)templateInfo.get('reason');
                    System.debug('TemplateStatus: ' + templateReason);

                    Long templateCreatedMillis = (Long) templateInfo.get('createdOn');
                    DateTime templateCreated = (templateCreatedMillis != null) ? DateTime.newInstance(templateCreatedMillis ) : null;
                    System.debug('TemplateCreated: ' + templateCreated);

                    Long templateUpdatedMillis = (Long) templateInfo.get('modifiedOn');
                    DateTime templateUpdated = (templateUpdatedMillis != null) ? DateTime.newInstance(templateUpdatedMillis ) : null;
                    System.debug('TemplateUpdated: ' + templateUpdated);

                    if(wt.Template_ID__c == templateId){
                        wt.Template_Approval_Status__c = templateStatus;
                        iLog.Template_Approval_Status__c = templateStatus;
                        wt.Rejected_Reason__c = templateReason; // Reset rejected reason if it was previously set
                        iLog.Rejected_Reason__c = templateReason;
                        ILog.Template_ID__c = templateId; 


                        wt.Created_At__c = templateCreated;
                        wt.Updated_At__c = templateUpdated;
                        System.debug('wt.Created_At__c --'+wt.Created_At__c);
                        System.debug('wt.Updated_At__c --'+wt.Updated_At__c);
                        
                        iLog.Created_At__c = templateCreated;
                        iLog.Updated_At__c = templateUpdated;
                        System.debug('iLog.Created_At__c --'+iLog.Created_At__c);
                        System.debug('iLog.Updated_At__c --'+iLog.Updated_At__c);
                    }
                    
                    // Perform any further processing or store the values as needed
                }
                        
            } catch (Exception e) {
                System.debug('Error parsing JSON: ' + e.getMessage());
            }   
            try{
                update wt;
                insert iLog;
                System.debug('Whatsapp_Template__c record Updated with Id: ' + wt.Id);
            } 
            catch (Exception ex) {
                System.debug('Error Updating Whatsapp_Template__c record: ' + ex.getMessage());
            } 
        } 
    } 
    
    
    
    public static String CheckSampleText(String parameters, String template) {
        List<String> parameterValues = parameters.split(',');
        // Replace placeholders in the template with values from parameters
        for (Integer i = 1; i <= parameterValues.size(); i++) {
            String placeholder = '{{' + i + '}}';
            String parameterValue = parameterValues[i - 1];
            template = template.replace(placeholder, '[' + parameterValue + ']');
        }
        return template;
    }
}