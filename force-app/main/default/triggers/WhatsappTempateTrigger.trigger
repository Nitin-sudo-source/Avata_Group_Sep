trigger WhatsappTempateTrigger on Whatsapp_Template__c (after update) {
    List<Whatsapp_Template__c> templatesToUpdate = new List<Whatsapp_Template__c>();
    Set<String> existingNames = new Set<String>();
    List<Whatsapp_Template__c> approvedTemplates = new List<Whatsapp_Template__c>();
    
    
    if(trigger.isAfter && trigger.isUpdate){
        for(Whatsapp_Template__c er : [SELECT Name,Template_ID__c FROM Whatsapp_Template__c]){
            existingNames.add(er.Name.toLowerCase());
        }
        
        for(Whatsapp_Template__c oldTemplate : trigger.old){
            Whatsapp_Template__c newTemplate = trigger.newMap.get(oldTemplate.Id);
            if(oldTemplate.Submit_For_Approval__c != newTemplate.Submit_For_Approval__c && newTemplate.Submit_For_Approval__c == true){
                String newName = newTemplate.Name.toLowerCase();
                /*if(existingNames.contains(newName))
				System.debug('WhatsappTemplate with Similar Name exists');
				else*/
                templatesToUpdate.add(newTemplate);
            }
            if(oldTemplate.Check_Template_Status__c != newTemplate.Check_Template_Status__c && newTemplate.Check_Template_Status__c == true) {
                approvedTemplates.add(newTemplate);
            }
            
        }
        if(!templatesToUpdate.isEmpty() && templatesToUpdate != null)
        {
            Ex_WhatsappTemplateApproval.recordCreated(templatesToUpdate);  
        }
        if (!approvedTemplates.isEmpty() && approvedTemplates != null)  {
            Ex_WhatsappTemplateApproval.templateApprovalStatusUpdate(approvedTemplates[0].Id);
        }
        
    }
    
}