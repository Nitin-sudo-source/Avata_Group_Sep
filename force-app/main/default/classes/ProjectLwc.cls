public class ProjectLwc {
@AuraEnabled (cacheable=true)
    public static list<Project__c> searchpro(){
        List<Project__c> getProject =[SELECT Id , Name FROM Project__c];
        return getProject;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<ContentDocumentLink> notes(string ProId){
       List<ContentDocumentLink>  getNotes =[SELECT LinkedEntity.Name,ContentDocument.Title ,ContentDocument.Description FROM 
           ContentDocumentLink where LinkedEntityId =: ProId] ;
        system.debug('getNotes='+getNotes);
        return getNotes;
    }
}