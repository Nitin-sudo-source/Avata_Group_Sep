public with sharing class Ex_SetWebhookURL {
    public Ex_SetWebhookURL() {

    }

    @AuraEnabled(cacheable=true)
    public static List<CallBack_Webhook_URL__c> getCallBackURL(){
        try {
            
            List<CallBack_Webhook_URL__c> CallBackWebhookURL = [Select Name, Webhook_URL__c, Status__c, AutoNumber__c, Created_Date__c from CallBack_Webhook_URL__c ORDER BY Created_Date__c DESC];
        
            if (!CallBackWebhookURL.isEmpty() && CallBackWebhookURL != null) {
                
                return CallBackWebhookURL;

            }else {

                return null;

            }
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateURL(String URL, String projectId) {
        
        List<Project__c> ProjecList = [Select Id, Name from Project__c where Id =: projectId];
        
        if(!ProjecList.isEmpty() && ProjecList != null){

            List<WA_API_Details_Gupshup__c> GupShupDetails = [select Id, IsDeleted, Name, SetupOwnerId, CreatedDate, CreatedById,
                                                                LastModifiedDate, LastModifiedById, SystemModstamp, Channel__c,
                                                                Connection__c, EndPoint__c, Name__c, Source_Phone__c,
                                                                appId__c, isActive__c, src_name__c, token__c, Project_Name__c
                                                                from WA_API_Details_Gupshup__c where Project_Name__c =: ProjecList[0].Name];
            System.debug('GupShupDetails: '+GupShupDetails);
    
            String endpoint = 'https://partner.gupshup.io/partner/app/'+GupShupDetails[0].appId__c+'/callbackUrl';
            String accessToken = GupShupDetails[0].token__c;
            System.debug(URL);
            String callbackUrl = URL;
            String status;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('PUT');
            req.setHeader('Authorization', accessToken);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('callbackUrl=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8'));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Handle response if needed
            
            if (res.getStatusCode() == 200) {
    
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug(jsonResponse);
                status = (String) jsonResponse.get('status');
    
                if (status != null && status.equalsIgnoreCase('success')) {
                    System.debug('Callback URL updated successfully');
                } else {
                    System.debug('Failed to update Callback URL');
                }
    
            } else {
                System.debug('Error: ' + res.getBody());
                status = 'error';
            }
    
            List<CallBack_Webhook_URL__c> latestRecord = new List<CallBack_Webhook_URL__c>();
    
            latestRecord = [SELECT Name FROM CallBack_Webhook_URL__c ORDER BY CreatedDate DESC LIMIT 1];
            
            Integer autoNumber;
            if (latestRecord != null && !latestRecord.isEmpty()) {
                // Extract the auto number value from the latest record and increment it by 1
                autoNumber = Integer.valueOf(latestRecord[0].Name.substringAfter('-')) + 1;
            } else {
                // If no records are present, start with 1
                autoNumber = 1;
            }
    
        
            // Create the new record with the auto number
            CallBack_Webhook_URL__c rec = new CallBack_Webhook_URL__c();
            rec.Webhook_URL__c = URL;
            if(status == null){
                rec.Status__c = 'error';
            }
            rec.Status__c = status; // Set default status here
            rec.Created_Date__c = System.now();
            rec.Name = 'Webhook URL-' + autoNumber; // Set the auto number
            rec.AutoNumber__c = autoNumber;
            insert rec;
        }

    }
    
}