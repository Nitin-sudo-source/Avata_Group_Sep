public class Ex_DeleteWhatsappTemplate{

    @AuraEnabled
    public static String DeleteTemplate(String recId){
        String result = null;
        List<WA_API_Details_Gupshup__c> WhatsappDetails = [select Id, IsDeleted, Name, EndPoint__c, token__c, Connection__c,
                                                           appId__c, Source_Phone__c, src_name__c, Channel__c, Name__c,
                                                           isActive__c, HandleId_Endpoint__c, API_Key__c, EndPoint_URL__c
                                                           /*APIKey__c, Key_API__c*/ from WA_API_Details_Gupshup__c where isActive__c =: true];
        
		List<Whatsapp_Template__c> whatsapptemplate = [Select Id, Whatsapp_Template_Name__c from Whatsapp_Template__c where Id =: recId];

        
        if(!WhatsappDetails.isEmpty() && WhatsappDetails != null && !whatsapptemplate.isEmpty() && whatsapptemplate != null){
            
            
            String appId = WhatsappDetails[0].appId__c;
            String elementName = whatsapptemplate[0].Whatsapp_Template_Name__c;
            String partnerAppToken = WhatsappDetails[0].token__c;
            
            // Construct the endpoint URL
            String endpoint = WhatsappDetails[0].EndPoint__c + appId + '/template/' + elementName;
            
            Integration_Log__c IntLogs = new Integration_Log__c();
            IntLogs.EndPoint__c = endpoint;
            
            
            // Create an HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('DELETE');
            req.setHeader('Authorization', partnerAppToken);
            
            // Create an HTTP object to send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check the response
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                // Successful deletion
                IntLogs.API_Hit_Status__c = 'Success';
                System.debug('Template deleted successfully');
               	result = 'success';
                Delete whatsapptemplate;
                
            } else {
                // Handle error
                IntLogs.Whatsapp_Template__c = whatsapptemplate[0].Id;
                IntLogs.API_Hit_Status__c = 'Failed';
                result = 'error';
                System.debug('Error deleting template. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
            
            IntLogs.Request__c = req.getBody();
            IntLogs.Response__c = res.getBody();
            
            insert IntLogs;
            
            return result;
        }
        else{
            return result;
        }
    }
}