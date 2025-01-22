/* Ex_WhatsappTemplate to Save and Edit the Whatsapp Templates using LWC component	*/
public class Ex_WhatsappTemplate {
    
    @AuraEnabled
    public static Map<String,String> getObjectField(string obj){
        System.debug('getObjectField -- '+obj);
        List<String> fieldSelectOptions = new List<String>();
        Map<String,String> options = new Map<String,String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(obj).getDescribe().fields.getMap();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(dfield.isUpdateable() || dfield.isCustom()){
                //fieldSelectOptions.add(new SelectOption(dfield.getname(),dfield.getLabel()));
                fieldSelectOptions.add(dfield.getLabel());
                options.put(dfield.getLabel(),dfield.getname());
            }
        }
        // Sort the fieldSelectOptions list in ascending order
        fieldSelectOptions.sort();

        // Create a new map with sorted options
        Map<String, String> sortedOptions = new Map<String, String>();
        for(String label : fieldSelectOptions) {
            sortedOptions.put(label, options.get(label));
        }

        System.debug('Options -- ' + sortedOptions);
        return sortedOptions;
    }

    
    @AuraEnabled(cacheable=true)
    public static Whatsapp_Template__c getWhatsappTemplate(string tId){
        system.debug('getWhatsappTemplate tId -- '+tId);
        if(tId != null){
            List<Whatsapp_Template__c> whatsappTemplates = [SELECT Id,Name, Template__c,Type__c, Parameters__c,Template_Kind__c,Project__c, 
                                                            Template_Category__c, Object__c, Whatsapp_Template_Name__c 
                                                            FROM Whatsapp_Template__c where Id =: tId];
            system.debug('whatsappTemplates -- '+whatsappTemplates);
            if(whatsappTemplates.size() > 0)
            	return whatsappTemplates[0];
            else
                return null;
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getpara(string tId){
        //system.debug('getWhatsappTemplate tId -- '+tId);
        List<String> ParaList = new List<String>();
        if(tId != null){
            
            List<Whatsapp_Template__c> whatsappTemplates = [SELECT Id,Name, Template__c,Type__c, Parameters__c,Template_Kind__c,Project__c, 
                                                            Template_Category__c, Object__c, Whatsapp_Template_Name__c 
                                                            FROM Whatsapp_Template__c where Id =: tId];
            system.debug('whatsappTemplates -- '+whatsappTemplates);
            
            if(whatsappTemplates.size() > 0){
                
                ParaList = whatsappTemplates[0].Parameters__c.split(',');
                
            	if(!ParaList.isEmpty() && ParaList != null){
                    return ParaList;
                }
                else{
                    return null;
                }
                
            }
            else
                return null;
        }else{
            return null;
        }
    }



    @AuraEnabled
    public static Whatsapp_Template__c Save(String template, String name, String category, List<String> variableList, 
                                            String types, String objectName, String header, List<String> SampleText,
                                           List<Whatsapp_Template__c> wtList, String templateKind, String project){
        System.debug('template -- ' + template +' Name -- '+name);
        System.debug('SampleText .: ' + SampleText);
        System.debug('templateKind .: ' + templateKind); 
        System.debug('selectedproject .: ' + project);                                        
    	List<Whatsapp_Template__c> whatsappTemplates = new List<Whatsapp_Template__c>();
        
        Whatsapp_Template__c wt = new Whatsapp_Template__c();
        wt.Template_Category__c = category;
        wt.Template__c = template;
        wt.Whatsapp_Template_Name__c = name;
        wt.Object__c = objectName;
        wt.Header__c = header;
		wt.Template_Kind__c = templateKind;
		wt.Project__c = project;
        wt.Parameters__c = '';
        for (String st : variableList) {
            wt.Parameters__c += st + ',';
        }
        wt.Sample_Text__c = '';
        for(String st : SampleText){
            wt.Sample_Text__c += st+',';
        }
        wt.Type__c = types;
        if(types == 'IMAGE' || types == 'VIDEO'){
           wt.Contains_Media__c = true; 
        }else if(types == 'FILE'){
            wt.Contains_Document__c = true;
        }
        // Remove the trailing comma
        if (wt.Parameters__c.endsWith(',')) {
            wt.Parameters__c = wt.Parameters__c.removeEnd(',');
        }
        if (wt.Sample_Text__c.endsWith(',')) {
            wt.Sample_Text__c = wt.Sample_Text__c.removeEnd(',');
        }
        whatsappTemplates.add(wt);
		System.debug('Whatsapp Template .: '+wtList);
        System.debug('New List whatsappTemplates -- ' + whatsappTemplates);
                                              
        if(wtList != null){
            Insert wtList;
            if(templateKind!=null && templateKind == 'Specific'){
                wtList[0].Template_Kind__c = templateKind;
            } else{
                wtList[0].Template_Kind__c = 'General';
            }
            
            wtList[0].Project__c = project;
            update wtList[0];
            return wtList[0];
            
        }else{
            return null;
        } 
    }
    
    @AuraEnabled
    public static Whatsapp_Template__c QuickSave(String recordId, String template, String name, String category, List<String> variableList, String types, String header){
        System.debug('Id -- '+recordId+' -template -- ' + template+' -Name -- '+name);
    	List<Whatsapp_Template__c> newwhatsappTemplates = new List<Whatsapp_Template__c>();
        if(recordId != null){
            List<Whatsapp_Template__c> whatsappTemplates = [Select Id,Template__c, Name,  Template_Category__c, 
                                                            Object__c, Header__c, Contains_Media__c, Contains_Document__c,
                                                            Whatsapp_Template_Name__c
                                                            FROM Whatsapp_Template__c where id =: recordId];
            System.debug('whatsappTemplates -- '+whatsappTemplates);            
            if(name != null && name != 'undefined' && name != '')
				whatsappTemplates[0].Whatsapp_Template_Name__c = name;
            
            whatsappTemplates[0].Template__c = template;
            whatsappTemplates[0].Parameters__c = '';
            whatsappTemplates[0].Type__c = types;
            if(types == 'IMAGE' || types == 'VIDEO'){
                whatsappTemplates[0].Contains_Media__c = true; 
            }else if(types == 'FILE'){
                whatsappTemplates[0].Contains_Document__c = true;
            }
            whatsappTemplates[0].Template_Category__c = category;
            whatsappTemplates[0].Header__c = header;
            for (String st : variableList) {
                whatsappTemplates[0].Parameters__c += st + ',';
            }
            
            // Remove the trailing comma
            if (whatsappTemplates[0].Parameters__c.endsWith(',')) {
                whatsappTemplates[0].Parameters__c = whatsappTemplates[0].Parameters__c.removeEnd(',');
            }
            newwhatsappTemplates.add(whatsappTemplates[0]);
        }
		
        System.debug('newwhatsappTemplates -- ' + newwhatsappTemplates);
        if(newwhatsappTemplates != null){
            Update newwhatsappTemplates;
            return newwhatsappTemplates[0];
        }else{
            return null;
        } 
    }


    @AuraEnabled
    public static List<WA_API_Details_Gupshup__c> getApiDetails() {
    
        List<WA_API_Details_Gupshup__c> apiDetails = [SELECT Name__c, isActive__c, appId__c, Connection__c, EndPoint__c, token__c,
                                                      Channel__c, Source_Phone__c, src_name__c, HandleId_Endpoint__c 
                                                      FROM WA_API_Details_Gupshup__c
                                                      WHERE Name__c = 'SatyamDevelopersSFDC' AND IsActive__c = true LIMIT 1];
        
        if (!apiDetails.isEmpty() && apiDetails != null) {
           
            return apiDetails;
        }else{
            return null;
        }
    
    }
    

    

    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId, String i){
        System.debug('in upload file'+recordId);
        System.debug('i -- '+i);
        ContentVersion cv = createContentVersion(base64, filename, recordId, i);
        System.debug('ContentVersion is::'+cv);
        //ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null) { 
            return null; 
        }
        System.debug('CV Id -- '+cv.Id);
        return cv.Id;
    }
    /*private static ContentVersion createContentVersion(String base64, String filename,String recordId ) {
        System.debug('createContentVersion.recordId is::'+recordId);   
        ContentVersion cv = new ContentVersion();       
        cv.VersionData = EncodingUtil.base64Decode(base64);
        System.debug('cv.VersionData is -- '+cv.VersionData);
        cv.Title = filename;
        System.debug('cv.Title is -- '+cv.Title);
        cv.PathOnClient = filename;
        System.debug('cv.PathOnClient is -- '+cv.PathOnClient);
        //cv.IsMajorVersion = true;
        //cv.ContentLocation = 'L'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        //cv.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        try {
          insert cv;
          Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id AND isLatest =: true].ContentDocumentId;
          System.debug('conDocId is -- '+conDocId);
          System.debug('cv is -- '+cv.ContentDocumentId);
          ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdl.Visibility = 'AllUsers';

            insert cdl;

            /*SObject linkedObject = cdl.LinkedEntityId.getSObjectType().newSObject(cdl.LinkedEntityId);
            linkedObject.put('IsUploaded__c', true);
            update linkedObject;

            System.debug('returned cv is::'+cv.Title);
            return cv;
        }catch(DMLException e) {
            System.debug('Exception'+e);
            return null;
        }
    }*/
    
    private static ContentVersion createContentVersion(String base64, String filename, String recordId, String i) {
        System.debug('createContentVersion.recordId is::' + recordId);
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        System.debug('cv.VersionData is -- ' + cv.VersionData);
        cv.Title = filename;
        System.debug('cv.Title is -- ' + cv.Title);
        cv.PathOnClient = filename;
        System.debug('cv.PathOnClient is -- ' + cv.PathOnClient);
    
        try {
            insert cv;
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id AND isLatest = true].ContentDocumentId;
            System.debug('conDocId is -- ' + conDocId);
    
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdl.Visibility = 'AllUsers';
            insert cdl;
    
            // Generate the public link for the ContentVersion associated with the record
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId LIMIT 1];
            if (!cdlList.isEmpty()) {
                ContentDocumentLink link = cdlList[0];
                Id contentDocumentId = link.ContentDocumentId;
    
                ContentDistribution cd = new ContentDistribution();
                cd.ContentVersionId = cv.Id; // Associate with the ContentVersion, not ContentDocument
                cd.Name = 'My Public Link';
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                insert cd;
    
                cd = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1]; 
                String publicLink = cd.DistributionPublicUrl;
                System.debug('Public Link: ' + publicLink);
                /*Calling updateRecordWithPublicLink to add Public Link  */
                updateRecordWithPublicLink(recordId, publicLink, i);
                }
                System.debug('returned cv is::' + cv.Title);
                return cv;
            } catch (DMLException e) {
                System.debug('Exception' + e);
                return null;
            }
    }

 
	private static void updateRecordWithPublicLink(String recordId, String publicLink, String i) {
        Integer index = Integer.valueOf(i) + 1;
    	String fieldName = 'Public_Link_' + index + '__c';

        Whatsapp_Template__c obj = new Whatsapp_Template__c(Id = recordId);
        obj.put(fieldName, publicLink);
        obj.Contains_Media__c = true;
        System.debug('Obj -- ' + obj);
        try {
            update obj;
        } catch (DmlException e) {
            System.debug('Error updating record with public link: ' + e.getMessage());
        }
    }
    
    
}