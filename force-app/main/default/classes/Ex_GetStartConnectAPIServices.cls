//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 20-06-2024
//-------------------------------------------//
public class Ex_GetStartConnectAPIServices {
    
    @future(Callout=true)
    public static void getStartConnectData(Set<Id> leadId){
        System.debug('leadId: '+leadId);
        List<Lead__c> getList = new List<Lead__c>();
        List<Lead__c> leadList = new List<Lead__c>();
        
        if(!leadId.isEmpty()){
            getList = [Select Id, Name,Lead_Created_From__c,IsConverted__c, Lead_Source__c, Mobile__c, First_Name__c, Last_Name__c, Email__c, Project__c from Lead__c where Id IN: leadId AND IsConverted__c = false AND Lead_Created_From__c != 'CTI'];
        }
        String source = '';
        String user = '';
        String pass = '';
        String function = '';
        String phone_number = '';
        String phone_code = '';
        String list_id = '';
        String first_name = '';
        String last_name = '';
        String email = '';
        String vendor_lead_code = '';
        String strURL = '';
        String StartConnectUrl = '';
        
        
        if(System.label.StartConnectUser != null){
            user = System.label.StartConnectUser;
        }
        if(System.label.StartConnectPass != null){
            pass = System.label.StartConnectPass;
        }
        if(System.label.StartConnectListId != null){
            list_id = System.label.StartConnectListId;
        }
        if(System.label.StartConnectFunction != null){
            function = System.label.StartConnectFunction;
        }
        if(System.label.StartConnect != null){
            phone_code = System.label.StartConnect;
        }
        if(System.label.StartConnectUrl != null){
            StartConnectUrl = System.label.StartConnectUrl ;
        }
        
        System.debug('getList: '+getList);
        if(!getList.isEmpty() && getList != null){
            for(Lead__c l: getList){
                if(l.Lead_Source__c != null){
                    source = l.Lead_Source__c;
                }
                if(l.Mobile__c != null){
                    phone_number = l.Mobile__c;
                }
                if(l.First_Name__c != null){
                    first_name = l.First_Name__c;
                }
                if(l.Last_Name__c != null){
                    last_name = l.Last_Name__c;
                }
                if(l.Email__c != null){
                    email = l.Email__c;
                }
                if(l.Project__c != null){
                    vendor_lead_code = l.Project__c;
                }
                
                strURL = StartConnectUrl +
                    'source=' + EncodingUtil.urlEncode(source, 'UTF-8') + 
                    '&user=' + EncodingUtil.urlEncode(user, 'UTF-8') + 
                    '&pass=' + EncodingUtil.urlEncode(pass, 'UTF-8') + 
                    '&function=' + EncodingUtil.urlEncode(function, 'UTF-8') + 
                    '&phone_number=' + EncodingUtil.urlEncode(phone_number, 'UTF-8') + 
                    '&phone_code=' + EncodingUtil.urlEncode(phone_code, 'UTF-8') + 
                    '&list_id=' + EncodingUtil.urlEncode(list_id, 'UTF-8') + 
                    '&first_name=' + EncodingUtil.urlEncode(first_name, 'UTF-8') + 
                    '&last_name=' + EncodingUtil.urlEncode(last_name, 'UTF-8') + 
                    '&email=' + EncodingUtil.urlEncode(email, 'UTF-8') + 
                    '&vendor_lead_code=' + EncodingUtil.urlEncode(vendor_lead_code, 'UTF-8');
                System.debug('url: '+strURL);
                
                if(strURL != null){
                    if(!Test.isRunningTest()) {
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint (strURL);
                        req.setMethod ('POST');
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        system.debug('HTTPResponse : '+ res);  
                        system.debug('Responsebody : '+ res.getBody());  
                        if(req != null && res.getBody() != null){
                            l.Start_Connect_Status_Code__c = String.valueof(res);
                            l.Start_Connect_Response__c = res.getBody();
                            leadList.add(l);
                        }
                    }    
                }
            }
        }
        if(leadList != null && !leadList.isEmpty()){
            update leadList;
        }        
    }
}