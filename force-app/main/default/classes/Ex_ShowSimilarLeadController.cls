public class Ex_ShowSimilarLeadController {
	@AuraEnabled(Cacheable=true)
    public static List<Lead__c> getLeadData(Id recordId){
        List<Lead__c> leadlist = new List<Lead__c>();
        List<Lead__c> updateList = new List<Lead__c>();
        if(recordId != null){
            Lead__c ld = [Select Id, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Project__r.Name, Project__c,First_Name__c,Last_Name__c from Lead__c where Id =: recordId ];
            //System.debug('ld: '+ld);
            if(ld.Mobile__c != null){
                leadlist =  [Select Id, Mobile__c, Phone__c, Project__r.Name, Project__c,First_Name__c,Last_Name__c,Lead_Source__c,OwnerId, Owner.Name from Lead__c where Id !=: ld.Id AND(Mobile__c =: ld.Mobile__c OR Phone__c =: ld.Mobile__c)AND IsConverted__c = false ];
                //System.debug('Size of leadlist: ' + leadlist.size());
            }
            if(ld.Phone__c != null){
                leadlist =  [Select Id, Mobile__c, Phone__c, Project__r.Name, Project__c,First_Name__c,Last_Name__c,Lead_Source__c,OwnerId, Owner.Name from Lead__c where Id !=: ld.Id AND(Phone__c =: ld.Phone__c OR Phone__c =: ld.Mobile__c)AND IsConverted__c = false ];
                //System.debug('Size of leadlist: ' + leadlist.size());
            }
            if(ld.Email__c != null){
                leadlist =  [Select Id, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Project__r.Name, Project__c,First_Name__c,Last_Name__c,Lead_Source__c,OwnerId, Owner.Name from Lead__c where Id !=: ld.Id AND(Email__c =: ld.Email__c OR Alternate_Email__c =: ld.Email__c) AND IsConverted__c = false ];
                //System.debug('Size of leadlist: ' + leadlist.size());
            }
            if(ld.Alternate_Email__c != null){
                leadlist =  [Select Id, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Project__r.Name, Project__c,First_Name__c,Last_Name__c,Lead_Source__c,OwnerId, Owner.Name from Lead__c where Id !=: ld.Id AND(Alternate_Email__c =: ld.Alternate_Email__c OR Alternate_Email__c =: ld.Email__c) AND IsConverted__c = false ];
                //System.debug('Size of leadlist: ' + leadlist.size());
            }
            if(!leadlist.isEmpty() && leadlist != null){
                updateList.addAll(leadlist);
            }
        }
        System.debug('updateList: '+updateList.size());
        if(!updateList.isEmpty() && updateList != null && updateList.size() > 0){
            return updateList;
        }else{
            return null;
        }
    }
}