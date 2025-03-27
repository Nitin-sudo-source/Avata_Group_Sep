/**
 * @description       :
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
 **/
public with sharing class Ex_CPMeetingLocationTagging {
    public Ex_CPMeetingLocationTagging() {
        
    }
    @AuraEnabled
    public static String getRecordType(String objectApiName, String recordTypeName) {
        Id recordTypeId;
        try {
            recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = :objectApiName AND Name = :recordTypeName LIMIT 1].Id;
            System.debug('recordTypeId: ' + recordTypeId);
            return recordTypeId;
        } catch (Exception e) {
            System.debug('Record Type not found: ' + e.getMessage());
            return '';
        }
    }
    
    @AuraEnabled
    public static getTaskWrapper getWrapper(String recordId, String recordTypeId){
        getTaskWrapper t = new getTaskWrapper();
        t.t = new Task();
        if(t.t.WhatId == null && String.isNotBlank(recordId)){
            t.t.WhatId = recordId;
        }
        t.t.Call_Status__c = '';
        t.t.Meeting_Status__c = '';
        // t.t.Meeting_Type__c = '';
        // t.t.Purpose__c = '';
        t.t.Call_Date__c = null;
        // t.t.Next_Call_Action_Date__c = null;
        t.t.Description = '';
        t.t.Meeting_Status__c = '';
        // t.t.Meeting_Type__c = '';
        t.t.Purpose_of_the_Meeting__c = '';
        // t.t.Purpose__c = '';
        t.t.Meeting_Date__c = null;
        t.t.Next_Meeting_Date__c = null;
        if(String.isNotBlank(recordTypeId)){
            RecordType recordTypeName = [SELECT Id, Name FROM RecordType WHERE Id =: recordTypeId];
            System.debug('recordTypeName: ' + recordTypeName);
            
            
            if(String.isNotBlank(recordTypeName.Id)){
                t.t.recordTypeId = recordTypeName.Id;
            }
            if(String.isNotBlank(recordTypeName.Name)){
                t.t.Subject = recordTypeName.Name;
            }
            
        }
        
        
        System.debug('t: '+t);
        return t;
        
        
        
    }
    
    
    @AuraEnabled
    public static List<String> getPicklistValues(String objectApiName, String fieldName) {
        List<String> values = new List<String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectApiName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            values.add(pickListVal.getValue());
        }
        return values;
    }
    
    @AuraEnabled
    public static Task saveTask(getTaskWrapper t, Decimal latitude, Decimal longitude){
        Task newTask = t.t;
        System.debug('Meeting Start Time : '+newTask.Meeting_Start_Time__c);
        System.debug('Meeting End Time :    '+newTask.Meeting_End_Time__c);
        if(latitude != null && longitude != null){
            newTask.Location__latitude__s = latitude;
            newTask.Location__Longitude__s = longitude;
        }
        insert newTask;
        System.debug('newTask: '+newTask);
        
        Task task = [Select Id, Subject, WhoId, Geolocation__c, Location__c, Location__latitude__s, Location__Longitude__s 
                     from Task Where Id =: newTask.Id];
        System.debug('task: '+task);
        RecordType recordTypeName = [SELECT Id, Name FROM RecordType WHERE Id =: newTask.recordTypeId];
        System.debug('recordTypeName: ' + recordTypeName);
        
        
        // if(String.isNotBlank(recordTypeName.Id) && recordTypeName.Name.equalsIgnoreCase('CP Meeting')){
            trackGMap(task.Id, latitude, longitude);
        // }
        
        try{

            System.debug('newTask.Id: '+newTask.Id);
            return newTask;
        } catch(Exception e){
            System.debug('e: '+e);
            return newTask;
        }
       
    }
    
    
    
    public class getTaskWrapper{
        @AuraEnabled public Task t {get;set;}
        
        
        public getTaskWrapper(){
            t = new Task();
            t.Call_Date__c = null;
            
        }
    }
    
    @future(callout=true)
    public static void trackGMap(Id tsk, Decimal strlat, Decimal strlon)
    {
        system.debug('Task:: ' + tsk);
        Task tk = new Task();
        tk = [Select Id, WhoId, Geolocation__c, Location__c, Location__latitude__s, Location__Longitude__s 
              from Task
              where Id =: tsk];
        string address = strlat+'+'+strlon;
        system.debug('address::::'+address);
        string key = 'AIzaSyDIeqrVuALobFWDBVEvGa5IVSLM9k3luoI';
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        string endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+key;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        httpResponse response = new httpResponse();
        response = httpProtocol.send(request);
        system.debug('Response:::'+ response.getBody());
        Map<String,String> fieldValuesMap  = new Map<String,String>();
        EX_JSONGeoParser jResult = new EX_JSONGeoParser();
        jResult = EX_JSONGeoParser.parse(response.getBody());
        List<EX_JSONGeoParser.Results > lstJResult = new List<EX_JSONGeoParser.Results>();
        lstJResult = jResult.Results;
        system.debug(lstJResult);
        
        string stringArray = '';
        stringArray = string.valueOf(lstJResult[0].formatted_address);
        decimal cnt = 0;
        for(EX_JSONGeoParser.Results jr :lstJResult)
        {
            cnt=cnt+1;
            system.debug('formatted address:: '+ jr.formatted_address);
            stringArray = string.valueOf(jr.formatted_address);
            system.debug('String formatted Address:: '+ stringArray);
            if(cnt == 1)
                tk.Geolocation__c = stringArray;
            
        }
        system.debug('Formatted Address :: '+ stringArray);
        system.debug('address::::LIVEaddres'+tk.Geolocation__c);
        update tk;
    }
}