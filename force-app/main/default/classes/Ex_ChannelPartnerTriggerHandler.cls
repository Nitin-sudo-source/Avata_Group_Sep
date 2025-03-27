public class Ex_ChannelPartnerTriggerHandler { 
    public static void afterInsert(List<Channel_Partner__c> cpList){
        List<Channel_Partner__c> newCpList = new List<Channel_Partner__c>();
        
        for(Channel_Partner__c cp: cpList) {
            newCpList.add(cp);
        }
        if(!newCpList.isEmpty() && newCpList != null )
            Ex_ChannelPartnerHandlerServices.insertDocument(newCpList);
        Ex_ChannelPartnerHandlerServices.duplicationCheckOnCP(newCpList);
    }
    
    public static void afterUpdate(Map<Id, Channel_Partner__c> oldMap, Map<Id, Channel_Partner__c> newMap) {
        List<Channel_Partner__c> cpList = new List<Channel_Partner__c>();
        
        for(Channel_Partner__c oldCPAccount: oldMap.values()) {
            Channel_Partner__c newCPAccount = newMap.get(oldCPAccount.Id);
            
            if((oldCPAccount.Mobile__c != newCPAccount.Mobile__c || oldCPAccount.PAN_No__c != newCPAccount.PAN_No__c || oldCPAccount.MahaRERA_Registration_No__c != newCPAccount.MahaRERA_Registration_No__c))
            {
                cpList.add(newCPAccount);
            }
            
            if(oldCPAccount.RERA_Available__c != newCPAccount.RERA_Available__c && newCPAccount.RERA_Available__c == 'Yes')
            { 
                cpList.add(newCPAccount);
            }                       
        }
        
        if(!cpList.isEmpty() && cpList != null){
            Ex_ChannelPartnerHandlerServices.updateDocument(cpList);
            Ex_ChannelPartnerHandlerServices.duplicationCheckOnCP(cpList);
        }
    }    
}