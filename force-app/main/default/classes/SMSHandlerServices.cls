public class SMSHandlerServices {
   
    @future(Callout=true) 
    public static void outboundSMS(set<Id> smsIds){
        system.debug('Inside::outboundSMS');
        string myphone = '';
        string mymsg = '';
        string strURL = ''; 
        string tempId = '';
        
        if(smsIds != null && smsIds.size() > 0) {
            List<SMS__c> smslist = new list<SMS__c> ();
            smslist = [SELECT Id,Name, Sender_Mobile_No__c,Message__c,Template_Id__c FROM 
                       SMS__c where Id in :smsIds];
            
            
            List <Vendor__c> vendorlist = new List<Vendor__c>();       
            vendorlist = [SELECT id, Name, Vendor_Url__c ,Param_1_Name__c,Param_1_Value__c,Param_1_Status__c,
                          Param_2_Name__c, Param_2_Value__c, Param_2_Status__c,
                          Param_3_Name__c, Param_3_Value__c, Param_3_Status__c,
                          Param_4_Name__c, Param_4_Value__c, Param_4_Status__c,
                          Param_5_Name__c, Param_5_Value__c, Param_5_Status__c
                          FROM Vendor__c WHERE Vendor_Status__c = true limit 1]; 
            
            for(SMS__c newsms :smslist) {
                if(newsms.Sender_Mobile_No__c!= null) {
                    myphone = newsms.Sender_Mobile_No__c;
                }       
                if(newsms.Message__c!= null) {
                    mymsg = newsms.Message__c;
                }
                if(newsms.Template_Id__c != null){
                    tempId = newsms.Template_Id__c;
                }
                
                mymsg = EncodingUtil.URLENCODE(mymsg,'UTF-8');
                mymsg = mymsg.replace('%2B%E2%80%9D','%20');
                mymsg = mymsg.replace('%2B%E2%80%9C','%20');
                mymsg = mymsg.replace('+','%20');
                
                if(vendorlist != null && !vendorlist.isEmpty() && vendorlist[0].Param_1_Status__c == TRUE && 
                   vendorlist[0].Param_2_Status__c == TRUE && vendorlist[0].Param_3_Status__c  == TRUE && vendorlist[0].Param_4_Status__c == TRUE) {        
                       strURL = vendorlist[0].Vendor_Url__c + 
                           '?'+vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c + 
                           '&' + vendorlist[0].Param_3_Name__c + '=' + vendorlist[0].Param_3_Value__c +
                           '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c + 
                           '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c + 
                           '&templateId='+ tempId +
                           '&mobile='+ myphone + 
                           '&message='+ mymsg ;
                   }
                system.debug('Url:::'+strURL);
                if(strURL != null){
                    if(!Test.isRunningTest()) {
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint (strURL);
                        req.setMethod ('POST');
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        system.debug('HTTPResponse : '+ res);  
                    }    
                }
            }
        }
    } 
}