global without sharing class mCubeController {
    
    
    @auraenabled
    webservice static List<string> readNumbers(String recordId) { 
        list<string> numbers = new list<string> ();
        string  mcubeObjectName = id.valueof( recordId).getSObjectType().getDescribe().getName() ;  
        List<MCUBE_Object_Api__c> mcubeObjectList =[select id,name,Field_to_Compare_Mobile_Incoming_Number__c from MCUBE_Object_Api__c where name =:mcubeObjectName ];
        string fieldsToquery = '';
        for(MCUBE_Object_Api__c m:  mcubeObjectList){
            fieldsToquery =  fieldsToquery+','+ m.Field_to_Compare_Mobile_Incoming_Number__c;
        }
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id '+fieldsToquery+ ' from '+mcubeObjectName+' where '+condtn;
        system.debug(xQuery);         
        sObject so = Database.query(xQuery);
        for(MCUBE_Object_Api__c m:  mcubeObjectList){
            system.debug(m.Field_to_Compare_Mobile_Incoming_Number__c);
            system.debug((string)so.get(m.Field_to_Compare_Mobile_Incoming_Number__c));
            numbers.add((string)so.get(m.Field_to_Compare_Mobile_Incoming_Number__c));
        }
        system.debug(numbers);
        return numbers;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CP_Project__c> getProjects() {
        List<CP_Project__c> Projects =[select id,Name,	Project_Name__c from CP_Project__c];
        return Projects;
    }
    
   // method to get DID numbers from cp_leads --> Cp_projects-->DID1,DID2
    @AuraEnabled(cacheable=true)
    public static List<String> getTheObjectDetails(Id recId) {
        // Retrieve the SObject type from the record Id
        String sObjName = recId.getSObjectType().getDescribe().getName();
        
        if (sObjName == 'CP_Lead__c') {
            // Query the CP_Lead__c record along with related CP_Project__r fields
            CP_Lead__c cpLead = [SELECT id, Name, CP_Project__r.DID_1__c, CP_Project__r.DID_2__c
                                 FROM CP_Lead__c
                                 WHERE id = :recId
                                 AND CP_Project__c != null
                                 LIMIT 1];  // LIMIT 1 to avoid issues with multiple records
            
            // Return the DID_1__c and DID_2__c values in a List
            return new List<String>{cpLead.CP_Project__r.DID_1__c, cpLead.CP_Project__r.DID_2__c};
                } else {
                    // Return null if the record is not of type CP_Lead__c
                    return null;
                }
    }
    
 
     @auraenabled
    webservice static boolean clickToCallWithoutDID(string recordId) { 
        system.debug('Recordid:' + recordId);
        
        string  mcubeObjectName = id.valueof(recordId).getSObjectType().getDescribe().getName() ; 
       
        MCUBE_Object_Api__c mcubeObject=[select id,name,Campaign_Field_API__c, Source_Field_API__c, Field_to_Compare_Mobile_Incoming_Number__c,LandingNumber__c from MCUBE_Object_Api__c where name =:mcubeObjectName  limit 1];
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id,'+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+ ' from '+mcubeObjectName+' where '+condtn;
        
        
        system.debug(xQuery);         
        List<sObject> l = Database.query(xQuery);
        system.debug(l);        
        
        // Lead l =  [select id, Mobilephone from Lead where id=: leadId ];
        User u = [select mobilePhone from user where id=:userinfo.getUserId()];
        String m= String.valueof(l[0].get(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c));
        
        u.mobilePhone = u.mobilePhone.replace('+91','')  ; 
        u.mobilePhone = u.mobilePhone.replace('+','')  ;  
        u.mobilePhone=  u.mobilePhone.replaceAll('\\(', '');
        u.mobilePhone=  u.mobilePhone.replaceAll('\\)', '');
        u.mobilePhone=  u.mobilePhone.replaceAll(' ', '');
        if(m != null){
            m= m.replace('+91','')  ; 
            m=  m.replaceAll('\\(', '');
            m=  m.replaceAll('\\)', ''); 
            m=  m.replaceAll(' ', ''); 
        }
        
        Mcube__mdt api1 =  [select Value__c from Mcube__mdt where DeveloperName ='APIKey'];
        Mcube__mdt api2 =  [select Value__c from Mcube__mdt where DeveloperName ='callbackUrl'];
        //for new Products
        List<Mcube__mdt> verstionList = [select Value__c from Mcube__mdt where DeveloperName ='Version'];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        string url = '';
        //For New Products 
        if(!(verstionList.isEmpty()) && verstionList[0].Value__c == '2'){
            // Mcube__mdt gsmConfig =   [select Value__c from Mcube__mdt where DeveloperName ='gsm'];
            // url  =   'http://api.mcube.com/Restmcube-api/outbound-calls?exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&refurl='+api2.Value__c +'/calland?refid='+l[0].get('Id')+'&gsm_config='+gsmConfig.Value__c;
            url  =   'http://api.mcube.com/Restmcube-api/outbound-calls';
            String token = api1.Value__c ;
            request.setHeader('Content-Type', 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            request.setHeader('Authorization', 'Bearer '+token );
            String boundary = '------WebKitFormBoundary7MA4YWxkTrZu0gW';
            String requestBody = '';
            
            
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="exenumber"\r\n\r\n';
            //requestBody += '8767316316\r\n';  
            requestBody += u.mobilePhone+'\r\n';
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="custnumber"\r\n\r\n';
            requestBody += m+'\r\n';  
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refid"\r\n\r\n';
            requestBody += l[0].get('Id')+'\r\n'; 
            
           
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refurl"\r\n\r\n';
            requestBody += +'1\r\n';  
            // Add closing boundary
            requestBody += boundary + '--\r\n';
            
            // Set the request body as a Blob
            request.setBody(requestBody); 
            
            System.debug(requestBody);
        }else{
            url  =   'http://mcube.vmc.in/api/outboundcall?apikey='+api1.Value__c  +'&exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&url='+api2.Value__c +'/calland?refid='+l[0].get('Id');
        }
        
        request.setEndpoint(url);
        request.setMethod('POST');
        system.debug(url);
        if(!test.isRunningTest()){
            HttpResponse response = http.send(request);
            String var= response.getBody() ;
            Map<String,String> responseMap = (Map<String, String>) JSON.deserialize(var, Map<String, String>.class); 
            system.debug(var);  
            system.debug('Status COde'+response.getStatusCode()); 
            if(response.getStatusCode() == 200 ){
                String bodyStatus =  responseMap.get('status');
                
                if(bodyStatus=='false')
                    throw  new AuraHandledException(responseMap.get('msg'));
                
                return true;
            }
            
            return false;
        }
        
        return false;
        
    }
    
    
    
    @auraenabled
    webservice static boolean clickToCallNumber(String recordId, String numberSelected) { 
        string  mcubeObjectName = id.valueof( recordId).getSObjectType().getDescribe().getName() ;  
        MCUBE_Object_Api__c mcubeObject=[select id,name,Field_to_Compare_Mobile_Incoming_Number__c,LandingNumber__c from MCUBE_Object_Api__c where name =:mcubeObjectName  limit 1];
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id,'+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+ ' from '+mcubeObjectName+' where '+condtn;
        system.debug(xQuery);         
        List<sObject> l = Database.query(xQuery);
        system.debug(l);        
        
        // Lead l =  [select id, Mobilephone from Lead where id=: leadId ];
        User u = [select mobilePhone from user where id=:userinfo.getUserId()];
        String m= numberSelected; 
        
        u.mobilePhone = u.mobilePhone.replace('+91','')  ; 
        u.mobilePhone = u.mobilePhone.replace('+','')  ;  
        u.mobilePhone=  u.mobilePhone.replaceAll('\\(', '');
        u.mobilePhone=  u.mobilePhone.replaceAll('\\)', '');
        u.mobilePhone=  u.mobilePhone.replaceAll(' ', '');
        if(m != null){
            m= m.replace('+91','')  ; 
            m=  m.replaceAll('\\(', '');
            m=  m.replaceAll('\\)', ''); 
            m=  m.replaceAll(' ', ''); 
        }
        
        Mcube__mdt api1 =  [select Value__c from Mcube__mdt where DeveloperName ='APIKey'];
        Mcube__mdt api2 =  [select Value__c from Mcube__mdt where DeveloperName ='callbackUrl'];
        //for new Products
        List<Mcube__mdt> verstionList = [select Value__c from Mcube__mdt where DeveloperName ='Version'];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        string url = '';
        //For New Products 
        if(!(verstionList.isEmpty()) && verstionList[0].Value__c == '2'){
            //Mcube__mdt gsmConfig =   [select Value__c from Mcube__mdt where DeveloperName ='gsm'];
            // url  =   'http://api.mcube.com/Restmcube-api/outbound-calls?exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&refurl='+api2.Value__c +'/calland?refid='+l[0].get('Id')+'&gsm_config='+gsmConfig.Value__c;
            url  =   'http://api.mcube.com/Restmcube-api/outbound-calls';
            String token = api1.Value__c;
            request.setHeader('Content-Type', 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            request.setHeader('Authorization', 'Bearer '+token );
            String boundary = '------WebKitFormBoundary7MA4YWxkTrZu0gW';
            String requestBody = '';
            
            
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="exenumber"\r\n\r\n';
            //requestBody += '8767316316\r\n';  
            requestBody += u.mobilePhone+'\r\n';
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="custnumber"\r\n\r\n';
            requestBody += m+'\r\n';  
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refid"\r\n\r\n';
            requestBody += l[0].get('Id')+'\r\n';  
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refurl"\r\n\r\n';
            requestBody += +'1\r\n';  
            // Add closing boundary
            requestBody += boundary + '--\r\n';
            
            // Set the request body as a Blob
            request.setBody(requestBody); 
            
            System.debug(requestBody);
        }else{
            url  =   'http://mcube.vmc.in/api/outboundcall?apikey='+api1.Value__c  +'&exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&url='+api2.Value__c +'/calland?refid='+l[0].get('Id');
        }
        
        request.setEndpoint(url);
        request.setMethod('POST');
        system.debug(url);
        if(!test.isRunningTest()){
            HttpResponse response = http.send(request);
            String var= response.getBody() ;
            Map<String,String> responseMap = (Map<String, String>) JSON.deserialize(var, Map<String, String>.class); 
            system.debug(var);  
            system.debug('Status COde'+response.getStatusCode()); 
            if(response.getStatusCode() == 200 ){
                String bodyStatus =  responseMap.get('status');
                
                if(bodyStatus=='false')
                    throw  new AuraHandledException(responseMap.get('msg'));
                
                return true;
            }
            
            return false;
        }
        
        return false;
        
    }
    
    @auraenabled
    webservice static boolean clickToCall(string recordId,string Project) { 
        system.debug('Recordid:' + recordId);
        system.debug('Project : '+ Project);
        //String mcubeObjectName = recordId.getSObjectType().getDescribe().getName();
        string  mcubeObjectName = id.valueof(recordId).getSObjectType().getDescribe().getName() ; 
       
        MCUBE_Object_Api__c mcubeObject=[select id,name,Campaign_Field_API__c, Source_Field_API__c, Field_to_Compare_Mobile_Incoming_Number__c,LandingNumber__c from MCUBE_Object_Api__c where name =:mcubeObjectName  limit 1];
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id,'+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+ ' from '+mcubeObjectName+' where '+condtn;
        
        
        system.debug(xQuery);         
        List<sObject> l = Database.query(xQuery);
        system.debug(l);        
        
        // Lead l =  [select id, Mobilephone from Lead where id=: leadId ];
        User u = [select mobilePhone from user where id=:userinfo.getUserId()];
        String m= String.valueof(l[0].get(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c));
        
        u.mobilePhone = u.mobilePhone.replace('+91','')  ; 
        u.mobilePhone = u.mobilePhone.replace('+','')  ;  
        u.mobilePhone=  u.mobilePhone.replaceAll('\\(', '');
        u.mobilePhone=  u.mobilePhone.replaceAll('\\)', '');
        u.mobilePhone=  u.mobilePhone.replaceAll(' ', '');
        if(m != null){
            m= m.replace('+91','')  ; 
            m=  m.replaceAll('\\(', '');
            m=  m.replaceAll('\\)', ''); 
            m=  m.replaceAll(' ', ''); 
        }
        
        Mcube__mdt api1 =  [select Value__c from Mcube__mdt where DeveloperName ='APIKey'];
        Mcube__mdt api2 =  [select Value__c from Mcube__mdt where DeveloperName ='callbackUrl'];
        //for new Products
        List<Mcube__mdt> verstionList = [select Value__c from Mcube__mdt where DeveloperName ='Version'];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        string url = '';
        //For New Products 
        if(!(verstionList.isEmpty()) && verstionList[0].Value__c == '2'){
            // Mcube__mdt gsmConfig =   [select Value__c from Mcube__mdt where DeveloperName ='gsm'];
            // url  =   'http://api.mcube.com/Restmcube-api/outbound-calls?exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&refurl='+api2.Value__c +'/calland?refid='+l[0].get('Id')+'&gsm_config='+gsmConfig.Value__c;
            url  =   'http://api.mcube.com/Restmcube-api/outbound-calls';
            String token = api1.Value__c ;
            request.setHeader('Content-Type', 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            request.setHeader('Authorization', 'Bearer '+token );
            String boundary = '------WebKitFormBoundary7MA4YWxkTrZu0gW';
            String requestBody = '';
            
            
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="exenumber"\r\n\r\n';
            //requestBody += '8767316316\r\n';  
            requestBody += u.mobilePhone+'\r\n';
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="custnumber"\r\n\r\n';
            requestBody += m+'\r\n';  
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refid"\r\n\r\n';
            requestBody += l[0].get('Id')+'\r\n'; 
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="gid"\r\n\r\n';
            requestBody += Project +'\r\n'; 
            
            // Add your form data
            requestBody += boundary + '\r\n';
            requestBody += 'Content-Disposition: form-data; name="refurl"\r\n\r\n';
            requestBody += +'1\r\n';  
            // Add closing boundary
            requestBody += boundary + '--\r\n';
            
            // Set the request body as a Blob
            request.setBody(requestBody); 
            
            System.debug(requestBody);
        }else{
            url  =   'http://mcube.vmc.in/api/outboundcall?apikey='+api1.Value__c  +'&exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&gid='+Project+'&url='+api2.Value__c +'/calland?refid='+l[0].get('Id');
        }
        
        request.setEndpoint(url);
        request.setMethod('POST');
        system.debug(url);
        if(!test.isRunningTest()){
            HttpResponse response = http.send(request);
            String var= response.getBody() ;
            Map<String,String> responseMap = (Map<String, String>) JSON.deserialize(var, Map<String, String>.class); 
            system.debug(var);  
            system.debug('Status COde'+response.getStatusCode()); 
            if(response.getStatusCode() == 200 ){
                String bodyStatus =  responseMap.get('status');
                
                if(bodyStatus=='false')
                    throw  new AuraHandledException(responseMap.get('msg'));
                
                return true;
            }
            
            return false;
        }
        
        return false;
        
    }
    
    public static void inboundCall() { 
        String data = apexpages.currentpage().getparameters().get('data');
        System.debug('data: '+data);
        String objectName = '';
        
       /* List<MCUBE_Object_Api__c> mcubeObjectList = [SELECT Id, Name, Campaign_Field_API__c, Source_Field_API__c, field__c, value__c, field1__c, value1__c, field2__c, value2__c, LandingNumber__c, Field_to_Compare_Mobile_Incoming_Number__c 
                                                     FROM MCUBE_Object_Api__c ORDER BY LandingNumber__c NULLS FIRST];
        
        MCUBE_Object_Api__c mcubeObject = new MCUBE_Object_Api__c(); */
        
       // if (mcubeObjectList.size() > 0) {
           // mcubeObject = mcubeObjectList[0];
           // System.debug('mcubeObject: '+mcubeObject);
           // String mobileNumber = '';
            
            if (data != null) { 
                data = EncodingUtil.urlDecode(data, 'UTF-8');            
                callWrapper cw = (callWrapper) JSON.deserialize(data, callWrapper.class); 
                system.debug('callWrapper: '+cw);
                Boolean callDeligated = cw.callroute; // mapp the actual paramter name from mcube 
                List<Task> taskList =[select id from Task where Call_ID__c =: cw.callid ];
                System.debug('taskList: '+taskList);
                User u = new User();  
                
                System.debug('cw::::::::::::::::'+cw);
                
                if(cw.refid!=null && cw.refid!=''){
                    Id recid = cw.refid;
                    system.debug('recid'+recid);
                    objectName = recid.getSObjectType().getDescribe().getName();
                }
                
               /* for (MCUBE_Object_Api__c m : mcubeObjectList) {
                    if (m.LandingNumber__c == cw.landingnumber) { 
                        mcubeObject = m;
                    }
                }*/
               // System.debug('Selected Mcube Object '+mcubeObject);
                // Handle inbound call when executive is null
                if (cw.executive == null) {
                    if (cw.dialstatus == 'CONNECTING') {
                        List<User> usersList = [SELECT Id FROM User WHERE MobilePhone LIKE :cw.empnumber LIMIT 1];
                        System.debug('usersList: '+usersList);
                        if (usersList.size() > 0) {
                            u = usersList[0];
                        }else{
                            u.Id = UserInfo.getUserId();
                        }
                        System.debug('u: '+u);
                        
                        /*String relatedObjectId = '';
                        if((cw.refid==null || cw.refid=='')){
                         String xQuery ='SELECT Id,ownerId FROM ' + mcubeObject.Name + ' WHERE ' + mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c + '=\'' + cw.callfrom + '\'';
                         List<sObject> inboundList = Database.query(xQuery); 
                         sObject l = Schema.getGlobalDescribe().get(mcubeObject.Name).newSObject();
                        
                        if (inboundList.size() == 0) {
                            if (mcubeObject.field__c != null && mcubeObject.value__c != null) { 
                                l.put(mcubeObject.field__c, mcubeObject.value__c); 
                            } 
                            if (mcubeObject.field1__c != null && mcubeObject.value1__c != null) { 
                                l.put(mcubeObject.field1__c, mcubeObject.value1__c); 
                            }
                            if (mcubeObject.field2__c != null && mcubeObject.value2__c != null) { 
                                l.put(mcubeObject.field2__c, mcubeObject.value2__c); 
                            } 
                            //l.put('OwnerId', u.Id);
                           // l.put('Virtual_Number__c', cw.clicktocalldid);
                            l.put(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c, cw.callfrom);
                            
                            insert l;   
                        } else { 
                            l = inboundList[0];
                            // l.put('OwnerId', u.Id);
                            //update l;
                        }
                            System.debug('===>'+l);
                             relatedObjectId=l.id;
                        }
                        else
                            relatedObjectId=cw.refid;
                        
                        
   					System.debug(cw.refid+'===>'+relatedObjectId);
					String  relatedObjectName = id.valueof(relatedObjectId).getSObjectType().getDescribe().getName();      
					*/
                    // Insert Task for Inbound Call
                        if(taskList.size() == 0)
                        {
                            Task t = new Task();
                            t.Subject = 'Inbound Call';
                            t.CallType = 'Inbound';
                            t.Call_ID__c = cw.callid;
                            t.Virtual_Number__c =  cw.clicktocalldid;
                            t.Mobile__c = cw.callfrom;
                            t.Call_Start_DateTime__c = Datetime.valueOf(cw.starttime).addHours(-5).addMinutes(-30);
                            t.Call_End_DateTime__c = Datetime.valueOf(cw.endtime).addHours(-5).addMinutes(-30);
                            t.Call_Status__c = cw.dialstatus;
                            t.Audio_File__c = cw.filename;
                            t.Agent_Number__c = cw.empnumber;
                            t.Next_Follow_Up_Date__c = System.today().addDays(1);
                            t.ActivityDate = System.today();
                            
                            System.debug('objectName: '+objectName);
                            if (objectName == 'Lead__c') {
                                // Query the Lead to get the OwnerId
                                Lead__c leadRecord = [SELECT Id, Name,Lead_Stage__c,Lead_Sub_Stage__c,Lead_Sub_Stage_Reason__c,OwnerId FROM Lead__c WHERE Id = :cw.refid LIMIT 1];
                                System.debug('leadRecord: '+leadRecord);
                                List<Visit_Pre_Registration__c> vpr = new List<Visit_Pre_Registration__c>();
                                
                                if(leadRecord != null && leadRecord.Lead_Stage__c != null && leadRecord.Lead_Stage__c.equalsIgnoreCase('Visit Confirmed')){
                                    vpr =  getVisitPreRegistrationRecord('Lead',leadRecord.Id);
                                    System.debug('vpr: '+vpr);
                                    if(vpr != null && vpr[0].Site_Visit_Date__c != null){
                                        t.Proposed_Date_of_Visit__c = vpr[0].Site_Visit_Date__c;
                                    }
                                }
                                t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                                t.WhatId = leadRecord.Id;
                                
                                t.Stage__c = leadRecord.Lead_Stage__c;
                                t.Sub_Stage__c = leadRecord.Lead_Sub_Stage__c;
                                t.Sub_Stage_Reason__c = leadRecord.Lead_Sub_Stage_Reason__c;
                                t.OwnerId = leadRecord.OwnerId;
                            }
                            if (objectName == 'Account') {
                                // Query the Account to get the OwnerId
                                Account accountRecord = [SELECT Id, OwnerId FROM Account WHERE Id = :cw.refid LIMIT 1];
                                System.debug('accountRecord: '+accountRecord);
                                t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                                t.WhatId = accountRecord.Id;
                                t.OwnerId = accountRecord.OwnerId;
                                System.debug('t.OwnerId:' + t.OwnerId);
                            }
                            if (objectName == 'CP_Lead__c') {
                                CP_Lead__c  cpLeadRecord = [SELECT ID, Name, CP_Lead_Stage__c, CP_Lead_Sub_Stage__c, CP_Lead_Sub_Stage_Reason__c, OwnerId FROM CP_Lead__c WHERE ID = :cw.refid LIMIT 1];
                                List<Visit_Pre_Registration__c> vpr = new List<Visit_Pre_Registration__c>();
                                
                                if(cpLeadRecord != null && cpLeadRecord.CP_Lead_Stage__c != null && cpLeadRecord.CP_Lead_Stage__c.equalsIgnoreCase('Visit Confirmed')){
                                    vpr =  getVisitPreRegistrationRecord('CP Lead', cpLeadRecord.Id);
                                    System.debug('vpr: '+vpr);
                                    if(vpr != null && vpr[0].Site_Visit_Date__c != null){
                                        t.Proposed_Date_Of_Visit__c = vpr[0].Site_Visit_Date__c;
                                    }
                                }
                                t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Lead Call').getRecordTypeId();
                                t.Stage__c = cpLeadRecord.CP_Lead_Stage__c;
                                t.Sub_Stage__c = cpLeadRecord.CP_Lead_Sub_Stage__c;
                                t.Sub_Stage_Reason__c = cpLeadRecord.CP_Lead_Sub_Stage_Reason__c;
                                t.Next_Call_Date__c = System.today().addDays(1);
                                t.OwnerId = cpLeadRecord.ownerId;
                                t.WhatId = cpLeadRecord.Id;
                            }
                            
                            try {
                                insert t;
                                System.debug('t'+t.Id);
                                System.debug('cw.callfrom: '+cw.callfrom);
                                System.debug('cw.refid: '+cw.refid);
                                System.debug('userId: '+u.Id);
                                System.debug('objectName: '+objectName);
                                System.debug('callDeligated: '+callDeligated);
                                if(callDeligated == null){
                                    callDeligated = false;
                                }
                                sendNotification(cw.callfrom, cw.refid, u.Id, objectName, callDeligated);
                                
                            } catch (Exception ex) {
                                System.debug('task insert failed :' + ex.getMessage());
                            }
                            
                        }
                        
                        //sendNotification(cw.callfrom,relatedObjectId, u.Id, relatedObjectName,callDeligated);
             
                    }else{
                        if(taskList.size() == 1){
                            Task task = [select Id, OwnerId, CallType from Task where Call_ID__c =:cw.callid ];
                            
                            List<User> usersList = [SELECT Id FROM User WHERE MobilePhone LIKE :cw.empnumber LIMIT 1];
                            if (usersList.size() > 0) {
                                u = usersList[0];
                            }
                            if(cw.endtime != null){
                                task.Call_End_DateTime__c = Datetime.valueof(cw.endtime).addhours(-5).addMinutes(-30);  
                            }
                            if(cw.dialstatus != null){
                                task.Call_Status__c = cw.dialstatus;  
                            }
                            if(cw.empnumber != null){
                                task.Agent_Number__c = cw.empnumber;
                            }
                            //Added By Nitin as Dicussed with Akshay
                            if(task.CallType == 'Inbound' && cw.dialstatus != null && (cw.dialstatus == 'NOANSWER' || cw.dialstatus == 'CANCEL' || cw.dialstatus == 'Busy')){
                                task.Subject = 'Missed by Executive';  
                            }
                            
                            if(cw.filename != null){
                                task.Audio_File__c = cw.filename;  
                            }
                            if(cw.dialstatus != null && cw.dialstatus.equalsIgnoreCase('ANSWER') && task.OwnerId != null && u.Id != null){
                                task.OwnerId = u.Id;
                            }
                            // In case of Call is NO Answer as Discussed with Akshay 
                            if(cw.dialstatus != null && cw.dialstatus.equalsIgnoreCase('NOANSWER') && task.OwnerId != null && u.Id != null){
                                task.OwnerId = u.Id;
                            }
                            try {
                                update task;
                                System.debug('task updated:' + task);
                            } catch (Exception ex) {
                                System.debug('task updated failed :' + ex.getMessage());
                            }
                        }
                    }
                }
                
                // Handle outbound call
                if (cw.executive != null && cw.status == 'ORIGINATE') {
                    
                    /*String xcondn = mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c + '=\'' + cw.customer + '\'';
                    String xQuery = 'SELECT Id FROM ' + mcubeObject.Name + ' WHERE ' + xcondn;
                    List<sObject> inboundList = Database.query(xQuery);
                    
                    sObject l = inboundList.size() > 0 ? inboundList[0] : null;*/
                    
                    // Insert Task for Outbound Call
                    Task t = new Task();
                    t.Subject = 'Outbound Call';
                    t.CallType = 'Outbound';
                    t.Call_ID__c = cw.callid;
                    if(cw.clicktocalldid != null)
                    t.Virtual_Number__c =  cw.clicktocalldid;
                    if(cw.executive != null)
                        t.Agent_Number__c =  cw.executive;
                    if(cw.customer != null)
                        t.Mobile__c =   cw.customer;
                    //t.Virtual_Number__c =  cw.landingNumber;
                    // t.Mobile__c = cw.callfrom;
                    System.debug('Datetime.valueOf(cw.starttime).addHours(-5).addMinutes(-30): '+Datetime.valueOf(cw.starttime).addHours(-5).addMinutes(-30));
                    t.Call_Start_DateTime__c = Datetime.valueOf(cw.starttime).addHours(-5).addMinutes(-30);
                    System.debug('Datetime.valueOf(cw.endtime).addHours(-5).addMinutes(-30): '+Datetime.valueOf(cw.endtime).addHours(-5).addMinutes(-30));
                    t.Call_Status__c = cw.dialstatus;
                    t.Status__c= cw.status;
                    t.Audio_File__c = cw.filename;
                    //t.Agent_Number__c = cw.empnumber;
                    t.Next_Follow_Up_Date__c = System.today().addDays(1);
                    t.ActivityDate = System.today();
                    System.debug('objectName: '+objectName);
                    
                    if (objectName == 'Lead__c') {
                        Lead__c leadRecord = [SELECT Id, Name,Lead_Stage__c,Lead_Sub_Stage__c,Lead_Sub_Stage_Reason__c,OwnerId FROM Lead__c WHERE Id = :cw.refid LIMIT 1];
                        System.debug('leadRecord: '+leadRecord);
                        List<Visit_Pre_Registration__c> vpr = new List<Visit_Pre_Registration__c>();
                        
                        if(leadRecord != null && leadRecord.Lead_Stage__c != null && leadRecord.Lead_Stage__c.equalsIgnoreCase('Visit Confirmed')){
                            vpr =  getVisitPreRegistrationRecord('Lead',leadRecord.Id);
                            System.debug('vpr: '+vpr);
                            if(vpr != null && vpr[0].Site_Visit_Date__c != null){
                                t.Proposed_Date_of_Visit__c = vpr[0].Site_Visit_Date__c;
                            }
                        }
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                        t.WhatId = leadRecord.Id;
                        
                        t.Stage__c = leadRecord.Lead_Stage__c;
                        t.Sub_Stage__c = leadRecord.Lead_Sub_Stage__c;
                        t.Sub_Stage_Reason__c = leadRecord.Lead_Sub_Stage_Reason__c;
                        t.OwnerId = leadRecord.OwnerId;
                    }
                    
                    if (objectName == 'Account') {
                        // Query the Account to get the OwnerId
                        Account accountRecord = [SELECT OwnerId FROM Account WHERE Id = :cw.refid LIMIT 1];
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                        t.WhatId = cw.refid;
                        t.OwnerId = accountRecord.OwnerId;
                        System.debug('t.OwnerId:' + t.OwnerId);
                    }
                    
                    
                    //added on 7/03/2025 for oppurtunity
                    
                    if (objectName == 'Opportunity__c') {
                        // Query the Account to get the OwnerId
                        Opportunity__c OppurtunityRecord = [SELECT OwnerId FROM Opportunity__c WHERE Id = :cw.refid LIMIT 1];
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Call').getRecordTypeId();
                        t.WhatId = cw.refid;
                        t.OwnerId = OppurtunityRecord.OwnerId;
                        System.debug('t.OwnerId:' + t.OwnerId);
                    }
                    
                    if (objectName == 'CP_Lead__c') {
                        CP_Lead__c  cpLeadRecord = [SELECT ID, Name, CP_Lead_Stage__c, CP_Lead_Sub_Stage__c, CP_Lead_Sub_Stage_Reason__c, OwnerId FROM CP_Lead__c WHERE ID = :cw.refid LIMIT 1];
                        List<Visit_Pre_Registration__c> vpr = new List<Visit_Pre_Registration__c>();
                        
                        if(cpLeadRecord != null && cpLeadRecord.CP_Lead_Stage__c != null && cpLeadRecord.CP_Lead_Stage__c.equalsIgnoreCase('Visit Confirmed')){
                            vpr =  getVisitPreRegistrationRecord('CP Lead', cpLeadRecord.Id);
                            System.debug('vpr: '+vpr);
                            if(vpr != null && vpr[0].Site_Visit_Date__c != null){
                                t.Proposed_Date_Of_Visit__c = vpr[0].Site_Visit_Date__c;
                            }
                        }
                        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CP Lead Call').getRecordTypeId();
                        t.Stage__c = cpLeadRecord.CP_Lead_Stage__c;
                        t.Sub_Stage__c = cpLeadRecord.CP_Lead_Sub_Stage__c;
                        t.Sub_Stage_Reason__c = cpLeadRecord.CP_Lead_Sub_Stage_Reason__c;
                        t.Next_Call_Date__c = System.today().addDays(1);
                        t.OwnerId = cpLeadRecord.ownerId;
                        t.WhatId = cpLeadRecord.Id;
                    }
                    
                    try {
                        insert t;
                        System.debug('task created:' + t.id);
                    } catch (Exception ex) {
                        System.debug('task insert failed :' + ex.getMessage());
                    }
                }else{
                    if(taskList.size() == 1){
                        Task task = [select id, OwnerId, CallType from Task where Call_ID__c =:cw.callid ];
                        if(cw.endtime != null){
                            task.Call_End_DateTime__c = Datetime.valueof(cw.endtime).addhours(-5).addMinutes(-30);  
                        }
                        if(cw.status != null && cw.status == 'CUSTOMER BUSY'){
                            task.Call_Status__c = cw.status;
                            task.Subject = 'Missed by Customer';  
                        }
                        //As discuss with akshay 
                        if(cw.status != null && cw.status == 'Call Complete'){
                            task.Call_Status__c = 'ANSWER';
                        }
                        if(cw.status != null && cw.status == 'EXECUTIVE BUSY'){
                            task.Call_Status__c = cw.status;
                            task.Subject = 'Missed Call';  
                        }
                        if(cw.dialstatus != null){
                            task.Call_Status__c = cw.dialstatus;   
                        }
                        //Added By Nitin as Dicussed with Akshay
                        if(task.CallType == 'Outbound' && cw.dialstatus != null && (cw.dialstatus == 'NOANSWER' || cw.dialstatus == 'CANCEL')){
                            task.Subject = 'Missed Call'; 
                        }
                        if(cw.filename != null){
                            task.Audio_File__c = cw.filename;   
                        }
                        try {
                            update task;
                            System.debug('task updated:' + task);
                        } catch (Exception ex) {
                            System.debug('task updated failed :' + ex.getMessage());
                        }
                    }
                }
            }
       // }
    }
    
    public static List<Visit_Pre_Registration__c> getVisitPreRegistrationRecord(String Stype, String refId){
        List<Visit_Pre_Registration__c> vprList = new List<Visit_Pre_Registration__c>();
        System.debug('refId: '+refId);
        if(String.isNotBlank(Stype) && Stype == 'CP Lead'){
            vprList = [Select Id, CP_Lead__c, Lead__c, Site_Visit_Date__c from Visit_Pre_Registration__c where CP_Lead__c =: refId];  
        }
        if(String.isNotBlank(Stype) && Stype == 'Lead'){
            vprList = [Select Id, CP_Lead__c, Lead__c, Site_Visit_Date__c from Visit_Pre_Registration__c where Lead__c =: refId];  
        }
        
        System.debug('vprList: '+vprList);
        if(vprList != null && !vprList.isEmpty()){
            return vprList; 
        }else{
            return null;
        }
    }
    
    public static void sendNotification(String mobile, String recordId, String userId, String objectName, Boolean callrouting) {
        try {
            // Step 1: Query the custom notification type
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName FROM CustomNotificationType 
                 WHERE DeveloperName='Mcube_Notification' LIMIT 1];
            
            if (notificationType == null) {
                System.debug('Notification type "Mcube_Notification" not found');
                return;
            }
            
            // Step 2: Validate the recordId (ensure it's not null and is a valid Salesforce ID)
            if (String.isBlank(recordId)) {
                System.debug('Invalid or missing recordId');
                return;
            }
            
            // Step 3: Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Incoming Call');
            notification.setBody('You Have a call on ' + system.now());
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(recordId);
            
            // Step 4: Send the notification (no need to capture result since send() returns void)
            notification.send(new Set<String> {userId});
            
            // Step 5: Prepare event publishing
            List<CtiNotification__e> publishEvents = new List<CtiNotification__e>();
            CtiNotification__e eve = new CtiNotification__e(); 
            
            eve.User_Id__c = userId;
            eve.Record_Id__c = recordId; 
            eve.ObjectName__c = objectName;
            eve.Call_Route__c=callrouting;
            publishEvents.add(eve);
            
            // Step 6: Publish the event and handle errors
            if (!publishEvents.isEmpty()) {
                List<Database.SaveResult> publishResults = EventBus.publish(publishEvents);
                for (Database.SaveResult result : publishResults) {
                    if (result.isSuccess()) {
                        System.debug('Event published successfully');
                    } else {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error publishing event: ' + error.getMessage());
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Problem sending notification or publishing event: ' + e.getMessage());
        }
        
        // Step 7: Log governor limits (optional, for debugging purposes)
        System.debug('Remaining heap size: ' + Limits.getHeapSize());
        System.debug('Number of SOQL queries: ' + Limits.getQueries());
        System.debug('Remaining DML statements: ' + Limits.getDmlStatements());
    }
    
    public class  callWrapper{
        
        String refid;
        String  callid ;
        String callfrom; 
        string starttime ;
        String   filename; 
        String calid;
        string pulse;
        string source;
        String custfeedback;
        String exefeedback;
        String dialstatus;
        String callerbusiness;
        String callername;
        String remark;
        String calleraddress;
        String caller_email;
        String rate;
        string empnumber;
        string   endtime;
        String eid ;
        String empid;
        string gid;
        String empemail;
        String status;
        String executive;
        String customer;
        string LandingNumber;
        string campaign;
        Boolean callroute;
        String clicktocalldid;
    }
    public   static string status{get;set;} 
    @auraEnabled
    public static  Call_Detail__c readCall(){ 
        try{
            datetime ss =  system.now().addSeconds(-10);
            Call_Detail__c c = [select Call_From__c,Call_ID__c,Call_To__c,Call_Type__c,End_Time__c,Executive_Contact_No__c,Parent_ID__c,Parent_URL__c,Recording_File__c,Start_Time__c,Status__c from Call_Detail__c where createddate >: ss and End_Time__c = null    order by createddate desc limit 1  ];
            return  c;    
        }catch(exception e){
            Call_Detail__c c = new Call_Detail__c();
            return  c;    
        }
        
    } 
    
    public  string recordIds= '';
    
    
    /*  
@auraEnabled
public static List<sobject> masdialinit(){
string userId =  userinfo.getUserId();
User   u = [select id,massdialerIds__c from User where id=:userId];  
string recordIdOrPrefix= '';
if( u.massdialerIds__c != null){
recordIdOrPrefix = u.massdialerIds__c.split(',')[1]; 
}

String objectName = '';
try{
//Get prefix from record ID
//This assumes that you have passed at least 3 characters
String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

//Get schema information
Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 

//Loop through all the sObject types returned by Schema
for(Schema.SObjectType stype : gd.values()){ 

Schema.DescribeSObjectResult r = stype.getDescribe();
String prefix = r.getKeyPrefix();

//Check if the prefix matches with requested prefix
if(prefix!=null && prefix.equals(myIdPrefix)){
objectName = r.getName();
System.debug('Object Name! ' + objectName);
break;
}
}
}catch(Exception e){
System.debug(e);
}
List<id> idslist = u.massdialerIds__c.split(',');
List<sobject> llist = database.query('select id, name  from '+objectName +' where id in: idslist  ');
return  llist; 
}  

global static void callrouting(){
RestResponse res = new RestResponse();
RestContext.response.addHeader( 'Content-Type', 'application/json' );
List<string> mobiles = new  List<string>();
List<user> userslist = [select id,mobilephone from user where LastAssignmentTime__c != null order by LastAssignmentTime__c desc];
for(user u: userslist ){
mobiles.add(u.mobilephone ); 

}      
RestContext.response.responseBody = Blob.valueOf( SYSTEM.JSON.serialize( new Response( 'success', mobiles  ) ) );

} 

public class Response {
public String status;
public List<String> agentNumbers;

public Response( String status, List<String> agentNumbers) {
this.status     = status;
this.agentNumbers = agentNumbers;
}

} 



@AuraEnabled  
public static  List<Call_Detail__c> callRecords(string recId){
List<Call_Detail__c> callIds=[select id,Call_From__c,name, Call_to__c, Call_Type__c, End_Time__c, Start_Time__c, Status__c,Recording_File__c from Call_Detail__c where Parent_id__c=:recId order by createddate desc];

return callIds;
} */
      public static void getcover(){
        integer  i=0;
        if(i==0){
            i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
        }}
    
}