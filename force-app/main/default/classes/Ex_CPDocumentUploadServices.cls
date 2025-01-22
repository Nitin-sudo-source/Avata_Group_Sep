//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 03-11-2023
//-------------------------------------------//
public class Ex_CPDocumentUploadServices {
     @AuraEnabled
    public static List<Document__c> CPAccountDocument_Uploads(string id ){
        List<Document__c> sList = new List<Document__c>(); 

        List<Document__c> dhList = [SELECT ID,Name,Document_Type__c,CP_Account__C,Uploaded__c FROM Document__c where CP_Account__r.Id=:id];
        
        for(Document__c doc:dhList){
            if(doc.Uploaded__c == false){
                sList.add(doc);
            }
        }   
        System.debug(slist.size());
        return sList;
    }
     
   @AuraEnabled()
    public static void Uploads(string did ){ 
        System.debug('did = '+ did);
        List<Document__c> dList = new List<Document__c>(); 
        List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionList= new List<ContentVersion>();
        
        contentVersionList = [Select Id,ContentDocumentId from ContentVersion where id =:did];
        System.debug('ContentDocumentId = '+ contentVersionList[0].ContentDocumentId);
        
        cdlist = [SELECT LinkedEntityId FROM ContentDocumentLink  WHERE ContentDocumentId  =:contentVersionList[0].ContentDocumentId AND LinkedEntityId in (SELECT Id FROM Document__c) and LinkedEntity.Type=:'Document__c' ];
        System.debug('LinkedEntityId = '+ cdlist[0].LinkedEntityId);
        
        List<Document__c> dhList = [SELECT ID, Name, Document_Type__c, CP_Account__c, Uploaded__c FROM Document__c where Id=:cdlist[0].LinkedEntityId];
        
        for(Document__c docnew : dhList){
            System.debug('docnew' + docnew);
            docnew.Uploaded__c = true;
            dList.add(docnew);
        }   
        
        System.debug(dlist);
        Update dList[0];
        
    }


}