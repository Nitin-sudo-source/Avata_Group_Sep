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
    
    /*@Future(callout=true)
public static void sendBulkMessage(String myType , Set<Id> newSet){
List<Map<String, Object>> dataList = new List<Map<String, Object>>();
List<Sobject> records = new List<Sobject>();
List<Sobject> updateSobjectList = new List<Sobject>();
Map<String, Object> payload = new Map<String, Object>();
String query = '';
Boolean isLeadFound = false;
Boolean isSVFound = false;
Boolean isBookingFound = false;
Boolean isTaskFound = true;

if (myType == 'Lead__c') {
query = 'SELECT Id, First_Name__c, Last_Name__c, Mobile__c, OwnerId, Project__r.Name, Lead_Stage__c FROM Lead__c WHERE Id IN :newSet';
isLeadFound = true;
} else if (myType == 'Booking__c') {
query = 'SELECT Id, Name, Primary_Applicant_Name__c, Primary_Applicant_Mobile__c, Primary_Applicant_Email__c, Primary_Applicant_Address__c Project__r.Name, Unit__r.Name FROM Booking__c WHERE Id IN :newSet';
isBookingFound = true;
} else if (myType == 'Site_Visit__c') {
query = 'SELECT Id, First_Name__c, Last_Name__c, Mobile__c, Site_Visit_Date__c, Project__r.Name, OwnerId,  Residential_Address__c FROM Site_Visit__c WHERE Id IN :newSet';
isSVFound = true;
}else{
query = 'SELECT Id, First_Name__c, Last_Name__c, Mobile__c, OwnerId, Project__r.Name, Lead_Stage__c FROM Lead__c WHERE Id IN :newSet';
isTaskFound = true;
}

if (String.isNotBlank(query)) {
records = Database.query(query);
}
System.debug('records: '+records);
for(SObject record: records){
Map<String, Object> dataMap = new Map<String, Object>();
String objectName = id.valueof(record.Id).getSObjectType().getDescribe().getName();

//Lead
if(String.isNotBlank(objectName) && objectName == 'Lead__c'){
System.debug('Is Lead Message: ');

String customerName = (String) record.get('First_Name__c') + ' ' +(String) record.get('Last_Name__c');
String phoneNumber = (String) record.get('Mobile__c'); 
String ownerName = (String) record.get('OwnerId');

//2 As soon as the lead Stage Change to Prospects 
if((String) record.get('Lead_Stage__c') != null && (String) record.get('Lead_Stage__c') == 'Prospects'){
String message = 'Dear' + customerName + ', Thank you for your continued interest in the property. You are a few steps away from your dream house. Lets Schedule your visit by proposing Date & Time. Looking forward to your response. Avants Group';
dataMap.put('message', message);
payload.put('templateid', System.label.templateid_Lead_Prospect);
}else{
// 1 As soon as the lead is created / Form fill has been done
String message = 'Thanks for contacting Avant Group! Your dedicated query manager will contact you shortly, to better understand your requirement. Meanwhile you can explore us on www.avantinfra.com';
dataMap.put('message', message);
payload.put('templateid', System.label.templateid_Lead);
}
dataMap.put('TransactionId', '');
dataMap.put('countrycode', '91');
dataMap.put('number', phoneNumber);
dataMap.put('url', '');
dataList.add(dataMap);
}

if(String.isNotBlank(objectName) && ObjectName == 'Site_Visit__c'){
System.debug('Is Site_Visit__c Message: ');
String customerName = (String) record.get('First_Name__c') + ' ' +(String) record.get('Last_Name__c');
String phoneNumber = (String) record.get('Mobile__c'); 
Date svDate = (Date) record.get('Site_Visit_Date__c');  
String projectName = getProjectName((String) record.get('Project__c'));
String ownerName = getOwnerName((String) record.get('OwnerId'));
String address = (String) record.get('Residential_Address__c');
String message = 'Dear ' + customerName + ', Thank you for scheduling a site visit! We’ve confirmed your appointment for ' + svDate+ 'for ' + projectName + ' at ' + address + 
'. Our team will be there to assist you and ensure everything goes smoothly. If you need to make any changes or have any specific requests for the visit, feel free to let us know. Looking forward to meeting you! ' + ownerName + ', Avants Group';  
dataMap.put('TransactionId', '');
dataMap.put('countrycode', '91');
dataMap.put('number', phoneNumber);
dataMap.put('message', message);
dataMap.put('url', '');
dataList.add(dataMap);
payload.put('templateid', System.label.template_sv);
}

if(String.isNotBlank(objectName) && objectName == 'Booking__c'){
System.debug('Is Booking__c Message: ');
String customerName = (String) record.get('Primary_Applicant_Name__c') ;
String phoneNumber = (String) record.get('Primary_Applicant_Mobile__c'); 
Date svDate = (Date) record.get('Booking_Date__c');  
String projectName = getProjectName((String) record.get('Project__c'));
String unitName = getunitName((String) record.get('Unit__c'));
String ownerName = getOwnerName((String) record.get('OwnerId'));
String address = (String) record.get('Primary_Applicant_Address__c');
String message = 'Hi ' + customerName +', We’re pleased to confirm the registration of your unit with '+ projectName + '/'+ unitName +'. To complete the process,'+'' +
'kindly provide the following documents: 1. Aadhaar Card (self-attested) 2. PAN Card (self-attested) 3. Proof of Address (Utility Bill/Passport/Driving License) 4. Photographs (2 Passport-sized) 5. Sale Agreement / Booking Confirmation 6. Payment Receipt (if applicable) 7. Identity Proof of co-owner'+ ''+
'(if any) Please share these documents at your earliest convenience to ensure a smooth registration process. If you need any assistance or have questions, feel free to reach out! Looking forward to finalizing everything for you. Best Regards,' + ownerName +' @ Avant Group';  
dataMap.put('TransactionId', '');
dataMap.put('countrycode', '91');
dataMap.put('number', phoneNumber);
dataMap.put('message', message);
dataMap.put('url', '');
dataList.add(dataMap);
payload.put('templateid', System.label.templatebooking);

}
}
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
System.debug('req: '+req);
for (SObject record : records) {
SObject updateRecord = record.clone(false, true, false);
if(isLeadFound){
updateRecord.put('Id',record.Id);
}
if(isBookingFound){
updateRecord.put('Id',record.Id);
}
if(isSVFound){
updateRecord.put('Id',record.Id);
}
updateRecord.put('Request_Body__c', jsonPayload);
if(res.getStatusCode() == 200){
updateRecord.put('Response_Body__c', res.getBody());
}
if (res.getStatusCode() != 200) {
updateRecord.put('Error_Body__c', 'Error: ' + res.getStatusCode() + ' - ' + res.getBody());
}
updateSobjectList.add(updateRecord);
}
} catch (Exception e) {
for (SObject record : records) {
SObject updateRecord = record.clone(false, true, false);
if(isLeadFound){
updateRecord.put('Id',record.Id);
}
if(isBookingFound){
updateRecord.put('Id',record.Id);
}
if(isSVFound){
updateRecord.put('Id',record.Id);
}
updateRecord.put('Request_Body__c', jsonPayload);
updateRecord.put('Error_Body__c', 'Exception: ' + e.getMessage());
updateSobjectList.add(updateRecord);
}
}
System.debug('updateSobjectList: '+updateSobjectList);
try{
if (!updateSobjectList.isEmpty() && updateSobjectList != null) {
update updateSobjectList;
}  
}Catch(Exception ex){
System.debug('Error In Updating updateSobjectList: '+ex.getMessage());
}
}

public static String getProjectName(String pId){
List<Project__c> getPList = [Select Id, Name from Project__c where Id =: pId];
return getPList[0].Name;
}

public static String getOwnerName(String owner){
List<User> u = [Select Id, Name, FirstName, LastName from User where Id =: owner];
return u[0].FirstName + ' '+u[0].LastName ;
}

public static String getunitName(String unitId){
List<Unit__c> unit = [Select Id, Name from Unit__c where Id =: unitId];
return unit[0].Name;
}*/
}