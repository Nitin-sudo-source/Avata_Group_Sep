public class Ex_CPProjectTriggerHandlerServices {
    public static void assignCPAccountId(Boolean isUpdateCP, List<CP_Project__c> cpProjectList){
        for(CP_Project__c cp:  cpProjectList){
            if(cp.Channel_Partner__c != null){
                cp.CP_Account_Id__c = cp.Channel_Partner__c;
                if(isUpdateCP){
                    cp.CP_Account_Id__c = cp.Channel_Partner__c;
                }
            }
        }
    }
}