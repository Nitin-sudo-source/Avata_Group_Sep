/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 10-01-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
public class Ex_SMSTriggerHandlerServices {
    
    @future(Callout=true)
    public static void outboundSMS(Set<Id> smsIds){
        system.debug('InsideoutboundSMS: ');
        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
        Map<String, Object> payload = new Map<String, Object>();
        Map<String, Object> dataMap = new Map<String, Object>();
        List<SMS__c> updateAPIResponse = new List<SMS__c>();
        
        string myphone = '';
        string mymsg = '';
        string strURL = ''; 
        string tempId = '';
        
        if(smsIds != null && smsIds.size() > 0) {
            List<SMS__c> smslist = new list<SMS__c> ();
            smslist = [SELECT Id,Name, Mobile__c, Message__c, Template_Id__c FROM 
                       SMS__c where Id in :smsIds];
            for(SMS__c newsms :smslist) {
                if(newsms.Mobile__c!= null) {
                    myphone = newsms.Mobile__c;
                }       
                if(newsms.Message__c!= null) {
                    mymsg = newsms.Message__c;
                }
                if(newsms.Template_Id__c != null){
                    tempId = newsms.Template_Id__c;
                }
                dataMap.put('TransactionId', '');
                dataMap.put('countrycode', '91');
                dataMap.put('number', myphone);
                dataMap.put('message', mymsg);
                dataMap.put('url', '');
                dataList.add(dataMap);
                
                if(!Test.isRunningTest()) {
                    payload.put('api', System.label.API_Key_SMS);
                    payload.put('senderid', System.label.senderid);
                    payload.put('campaignid', System.label.campaignid);
                    payload.put('channel', System.label.channel);
                    payload.put('dcs', '0');
                    payload.put('shorturl', System.label.shorturl);
                    payload.put('data', dataList);
                    
                    String jsonPayload = JSON.serialize(payload);
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(System.label.End_Point_Url); 
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');
                    req.setBody(jsonPayload);
                    
                    Http http = new Http();
                    HttpResponse res = new HttpResponse();
                    try {
                        res = http.send(req);
                        newsms.put('Request_Body__c', jsonPayload);
                        if(res.getStatusCode() == 200){
                            System.debug('res.getBody(): '+res.getBody());
                            newsms.put('Response_Body__c', res.getBody());
                        }
                        if (res.getStatusCode() != 200) {
                            System.debug('res.getStatusCode(): '+res.getStatusCode());
                            newsms.put('Error_Body__c', 'Error: ' + res.getStatusCode() + ' - ' + res.getBody());
                        }
                    }Catch(Exception ex){
                        
                        newsms.put('Error_Body__c', 'Exception: ' + ex.getMessage());
                    }
                }
                updateAPIResponse.add(newsms);
            }
        }
        System.debug('updateAPIResponse: '+updateAPIResponse);
        if(!updateAPIResponse.isEmpty() && updateAPIResponse != null){
            update updateAPIResponse;
        }
    }
}