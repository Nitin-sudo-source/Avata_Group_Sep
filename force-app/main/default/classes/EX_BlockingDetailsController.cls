//-------------------------------------------//
//	Created By: Exceller Tech
//	Created Date: 27-09-2024
//-------------------------------------------//
public class EX_BlockingDetailsController {
    @AuraEnabled(cacheable=true)
    public static Blocking_Details__c getBlockDetails(string uniId)
    {
        try {
            Blocking_Details__c blockingDetailList = [select id,Name,Status__c,Blocked_with_token__c,Amount__c,Transaction_ID__c,
                                                      Blocking_Comments__c from Blocking_Details__c where Unit__c =:  uniId AND Status__c ='Blocked'];
            
            return blockingDetailList;
        } catch(QueryException e) {
            System.debug('Exception is : ' + e.getMessage()); 
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Unit__c> fetchUnits(string uniId)
    {
        List<Unit__c> unitList = [select id,Name,Tower__r.Name , Project__r.Name /*,Project__r.Blocking_Approvar__c */,Sales_Status__c from Unit__c where Id =:  uniId];
        return unitList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Opportunity__c> getOppName(string oppId){
        List<Opportunity__c> oppList = [SELECT Id , Name FROM Opportunity__c where Id =: oppId] ;
        return oppList ;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getModeOfFundingPicklist() {
        Map<String, List<String>> picklistValuesMap = new Map<String, List<String>>();
        Schema.DescribeFieldResult MOPFieldResult = Blocking_Details__c.Mode_of_Payment__c.getDescribe();
        List<Schema.PicklistEntry> ModeOfFundingPicklistEntries = MOPFieldResult.getPicklistValues();
        List<String> ModeOfFundingPicklist = new List<String>();
        for (Schema.PicklistEntry entry : ModeOfFundingPicklistEntries) {
            ModeOfFundingPicklist.add(entry.getValue());
        }
        
        picklistValuesMap.put('Mode_of_Payment__c', ModeOfFundingPicklist);
        system.debug('picklistValuesMap ' +picklistValuesMap);
        return picklistValuesMap;
    }
    @AuraEnabled
    public static Blocking_Details__c createBlockingRecord(Boolean blockByToken,Integer amount,String blockComment,String chequeNo,String unitName , string oppId ,string MOPpicklistValue)
    {
        System.debug('Inside CreateBlocking');
        Blocking_Details__c blockInfo=new Blocking_Details__c();
        blockInfo.Blocked_with_token__c=blockByToken;
        blockInfo.Amount__c=amount;
        blockInfo.Blocking_Comments__c=blockComment;
        blockInfo.Transaction_ID__c = chequeNo;
        blockInfo.Unit__c=unitName;
        blockInfo.Opportunity__c = oppId ;
        blockInfo.Blocking_Requested_By__c = UserInfo.getUserId();
        blockInfo.Mode_of_Payment__c = MOPpicklistValue ;
        try{
           // if((blockInfo.Blocked_by_token__c==true))
                insert blockInfo;
        }
        catch(exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
        blockInfo.Status__c='Blocked';
        
        Unit__c unit=[select id,Name,Sales_Status__c /*Project__r.Blocking_Approvar__c*/ from Unit__c where id =: unitName];
        
        unit.Sales_Status__c='Blocked';
        
     /*   if(unit.Project__r.Blocking_Approvar__c !=null)
        {
            unit.Block_Approvar__c= unit.Project__r.Blocking_Approvar__c;
        } */
        unit.Opportunity__c = oppId;  
        update blockInfo;
        update unit;
      
        return blockInfo;
    }
    @AuraEnabled
    public static Blocking_Details__c unblockLogic(String blockId,String unblockComment)
    {
        Blocking_Details__c unblock=[select id,Status__c,Unit__c from Blocking_Details__c where id=:blockId AND Status__c ='Blocked' limit 1];
        Unit__c unit=[select id,Name,Sales_Status__c,Blocking_Comments__c from Unit__c where Id=:unblock.Unit__c];
        unblock.Status__c='Released';
        unit.Sales_Status__c='Vacant';
        unit.Blocking_Comments__c = unblockComment;
        unit.Opportunity__c = null ;
        update unit;
        update unblock;
        return unblock;
    }
}