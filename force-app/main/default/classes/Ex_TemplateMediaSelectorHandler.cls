public class Ex_TemplateMediaSelectorHandler {

    @AuraEnabled
    public static List<StaticResource> getStaticResources(){
        //try {
            List<StaticResource> StaticResourceList = [select Id, NamespacePrefix, Name, ContentType, BodyLength, Body, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CacheControl from StaticResource];
        
            if (!StaticResourceList.isEmpty() && StaticResourceList != null) {
                return StaticResourceList;
            }
            else {
                return null;
            }
        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }

    @AuraEnabled
    public static Boolean checkPublicURL(String tempId){
        //try {

            List<Whatsapp_Template__c> WhatsappTemplate = [Select Id, Public_Link_1__c from Whatsapp_Template__c where Id =: tempId];
            System.debug('WhatsappTemplate = ' + WhatsappTemplate);

            if(!WhatsappTemplate.isEmpty() && WhatsappTemplate != null){

                if (WhatsappTemplate[0].Public_Link_1__c == null) {
                    return false;
                }
                else {
                    return true;
                }

            }
            else {
                return false;
            }

        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }

    @AuraEnabled
    public static string UpdateTemplate(List<Whatsapp_Template__c> WhatsappTemplate){
        //try {
            
            if(!WhatsappTemplate.isEmpty() && WhatsappTemplate != null){
                Update WhatsappTemplate;
                return 'Success';
            }
            else{
                return null;
            }
       /* } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    
    @AuraEnabled
    public static List<Project__c> searchProjectRecord(String searchTerm){
        //try {
            List<Project__c> proj = new List<Project__c>();
            proj = [SELECT Id, Name FROM Project__c
                WHERE Name LIKE: ('%'+searchTerm+'%') ];

            if(!proj.isEmpty() && proj != null )
                return proj;
            else
                return null;
            
        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    
    @AuraEnabled
    public static List<StaticResource> getStaticResourcesforProject(){
        //try {
        List<StaticResource> StaticResourceList = [select Id, NamespacePrefix, Name, ContentType, BodyLength, 
                                                   Body, Description, CreatedDate, CreatedById, LastModifiedDate, 
                                                   LastModifiedById, SystemModstamp, CacheControl 
                                                   from StaticResource
                                                   WHERE ContentType = 'application/pdf'];
        
            if (!StaticResourceList.isEmpty() && StaticResourceList != null) {
                return StaticResourceList;
            }
            else {
                return null;
            }
       /* } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    
    @AuraEnabled
    public static Boolean checkPublicURLforProject(String tempId){
        //try {

            List<Project__c> Project = [Select Id, Public_Link__c from Project__c where Id =: tempId];
            System.debug('Project .: ' + Project);

            if(!Project.isEmpty() && Project != null){

                if (Project[0].Public_Link__c == null) {
                    return false;
                }
                else {
                    return true;
                }

            }
            else {
                return false;
            }

        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    
    @AuraEnabled
    public static string UpdateProject(List<Project__c> Project){
        //try {
            
            if(!Project.isEmpty() && Project != null){
                Update Project;
                return 'Success';
            }
            else{
                return null;
            }
        /*} catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }



    @AuraEnabled
    public static List<Whatsapp_Template__c> searchTemplateRecord(String searchTerm){
        try {
            List<Whatsapp_Template__c> wt = new List<Whatsapp_Template__c>();
            wt = [SELECT Id, Name, Whatsapp_Template_Name__c, Type__c 
                FROM Whatsapp_Template__c
                WHERE Whatsapp_Template_Name__c LIKE: ('%'+searchTerm+'%') AND Type__c != 'TEXT'];

            if(!wt.isEmpty() && wt != null )
                return wt;
            else
                return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}