public class Ex_ShowQRImage {
     @AuraEnabled(cacheable=false)
    public static Project__c getProject() {
        try {
            List<Project__c> pList = [SELECT Id, Name FROM Project__c];
            System.debug('Project List .: ' + pList);
            if (!pList.isEmpty()) {
                return pList[0];
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }

}