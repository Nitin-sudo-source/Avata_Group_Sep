//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 06-09-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
@RestResource(urlMapping='/CreateLead/*')
global class Ex_RESTWebIntegration {
    @HttpPost
    global static REST_Result createLead(REST_Request req) {
        REST_Result r = new REST_Result();
        try {
            Digital_Lead__c dl = new Digital_Lead__c();
            dl.First_Name__c = req.firstName;
            dl.Last_Name__c = req.lastName;
            dl.Mobile__c = req.mobile;
            dl.Email__c = req.email;
            dl.Alternate_Email__c = req.officialEmail;
            dl.Company_Name__c = req.companyName;
            dl.Location__c = req.location;
            dl.Campaign_Code__c = req.campaignCode;
            dl.Platform__c = req.LeadIdentifier;
            insert dl;
            
            r.returnCode = 0;
            r.digitalLeadId = dl.Id;
            r.message = 'Request Processed Successfully';
            return r;
        } catch(Exception ex) {
            system.debug('Error: '+ex.getMessage());
            r.returnCode = 1;
            r.message = 'Request Failed: '+ex.getMessage();
            return r;
        }
    }
    
    global class REST_Result {
        webservice Integer returnCode;
        webservice String digitalLeadId;
        webservice String message;
    }
    
    global class REST_Request {
        webservice String firstName;
        webservice String lastName;
        webservice String mobile;
        webservice String email;
        webservice String officialEmail;
        webservice String companyName;
        webservice String location;
        webservice String campaignCode;
        webservice String LeadIdentifier;
    }
}