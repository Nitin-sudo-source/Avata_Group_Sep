@RestResource(urlMapping='/PushLead/*')
global class Ex_RESTLeadDatapush {
   
    @HttpPOST
    global static Rest_result sendleaddata(String SFDC_Id) {
     
        Rest_result result = new Rest_result();
       
        try {        
            if (SFDC_Id != null && !String.isBlank(SFDC_Id)) {
               
                List<Lead__c> leadRecords = [SELECT Id,Name, Mobile__c, Full_Name__c, Email__c FROM Lead__c WHERE Id = :SFDC_Id AND IsConverted__c = False];
               
                if (leadRecords != null && !leadRecords.isEmpty()) {
                    Lead__c rec = leadRecords[0];
                   
                    result.returnCode = 200;
                    result.message = 'Lead Data Send Successfully';
                    result.LeadId = rec.Name;
                   
                } else {
                    result.returnCode = 204;
                    result.message = 'Invalid SFDC ID';
                    return result;
                }
            } else {
                result.returnCode = 204;
                result.message = 'Please Provide SFDC_Id';
                return result;
            }
        } catch (Exception ex) {
            result.returnCode = 500;
            result.message = 'Exception Occurred: ' + ex.getMessage();
        }
        return result;  
    }

    global class Rest_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String LeadId;
    }
}