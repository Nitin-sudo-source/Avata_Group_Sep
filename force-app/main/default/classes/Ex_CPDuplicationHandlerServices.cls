public class Ex_CPDuplicationHandlerServices {
    public static Map<Channel_Partner__c, List<duplicateWrapper>> duplicationCheckCPAcccount(List<Channel_Partner__c> accountList) {
        Map<Channel_Partner__c, List<duplicateWrapper>> duplicateWrapperMap = new Map<Channel_Partner__c, List<duplicateWrapper>>();
        Map<Channel_Partner__c, List<Channel_Partner__c>> CPAccountDuplicateMapRERANo = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        Map<Channel_Partner__c, List<Channel_Partner__c>> CPAccountDuplicateMapMobile = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        Map<Channel_Partner__c, List<Channel_Partner__c>> CPAccountDuplicateMapPANNo = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        
        CPAccountDuplicateMapRERANo = CPaccountDuplicateCheckByRERANo(accountList);
        system.debug('CPAccountDuplicateMapRERANo: '+CPAccountDuplicateMapRERANo);
        
        if(!CPAccountDuplicateMapRERANo.isEmpty() && CPAccountDuplicateMapRERANo != null) {
            for(Channel_Partner__c a: CPAccountDuplicateMapRERANo.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Channel_Partner__c dupAccount: CPAccountDuplicateMapRERANo.get(a)) {
                    dwList.add(new duplicateWrapper('Account', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        } else {
            CPAccountDuplicateMapMobile = CPaccountDuplicateCheckByMobile(accountList);
            system.debug('CPAccountDuplicateMapMobile: '+CPAccountDuplicateMapMobile);
            
            if(!CPAccountDuplicateMapMobile.isEmpty() && CPAccountDuplicateMapMobile != null) {
                for(Channel_Partner__c a: CPAccountDuplicateMapMobile.keySet()) {
                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                    for(Channel_Partner__c dupAccount: CPAccountDuplicateMapMobile.get(a)) {
                        dwList.add(new duplicateWrapper('Account', dupAccount));
                    }
                    duplicateWrapperMap.put(a, dwList);
                }
            } else {
                CPAccountDuplicateMapPANNo = CPaccountDuplicateCheckByPANNo(accountList);
                system.debug('CPAccountDuplicateMapPANNo: '+CPAccountDuplicateMapPANNo);
                
                if(!CPAccountDuplicateMapPANNo.isEmpty() && CPAccountDuplicateMapPANNo != null) {
                    for(Channel_Partner__c a: CPAccountDuplicateMapPANNo.keySet()) {
                        List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                        for(Channel_Partner__c dupAccount: CPAccountDuplicateMapPANNo.get(a)) {
                            dwList.add(new duplicateWrapper('Account', dupAccount));
                        }
                        duplicateWrapperMap.put(a, dwList);
                    }
                }
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<Channel_Partner__c, List<Channel_Partner__c>> CPaccountDuplicateCheckByRERANo(List<Channel_Partner__c> accountList) {
        Map<Channel_Partner__c, List<Channel_Partner__c>> accountDuplicateMapRERANo = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> incomingAccountRERANoMap = new Map<String, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> duplicateMapRERANo = new Map<String, List<Channel_Partner__c>>();
        List<Channel_Partner__c> duplicateAccountList = new List<Channel_Partner__c>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountRERANoMap = getIncomingAccountMap('CP RERA No', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountRERANoMap.isEmpty() && incomingAccountRERANoMap != null) {
            duplicateAccountList = [Select Id, Name, MahaRERA_Registration_No__c, Mobile__c, PAN_No__c from Channel_Partner__c 
                                    where MahaRERA_Registration_No__c IN: incomingAccountRERANoMap.keySet() AND Id NOT IN: incomingAccountIdSet];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Channel_Partner__c dupAccount: duplicateAccountList) {
                    if(!duplicateMapRERANo.containsKey(dupAccount.MahaRERA_Registration_No__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(dupAccount);
                        duplicateMapRERANo.put(dupAccount.MahaRERA_Registration_No__c, newAccountList);
                    } else {
                        duplicateMapRERANo.get(dupAccount.MahaRERA_Registration_No__c).add(dupAccount);
                    }
                }
            }
            
            for(String RERANo: incomingAccountRERANoMap.keySet()) {
                if(duplicateMapRERANo.containsKey(RERANo)) {
                    for(Channel_Partner__c a: incomingAccountRERANoMap.get(RERANo)) {
                        accountDuplicateMapRERANo.put(a, duplicateMapRERANo.get(RERANo));
                    }
                }
            }
        }
        return accountDuplicateMapRERANo;
    }
    
    public static Map<Channel_Partner__c, List<Channel_Partner__c>> CPaccountDuplicateCheckByMobile(List<Channel_Partner__c> accountList) {
        Map<Channel_Partner__c, List<Channel_Partner__c>> accountDuplicateMapMobile = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> incomingAccountMobileMap = new Map<String, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> duplicateMapMobile = new Map<String, List<Channel_Partner__c>>();
        List<Channel_Partner__c> duplicateAccountList = new List<Channel_Partner__c>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountMobileMap = getIncomingAccountMap('CP Mobile', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountMobileMap.isEmpty() && incomingAccountMobileMap != null) {
            duplicateAccountList = [Select Id, Name, MahaRERA_Registration_No__c, Mobile__c, PAN_No__c from Channel_Partner__c 
                                    where Mobile__c IN: incomingAccountMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Channel_Partner__c dupAccount: duplicateAccountList) {
                    if(!duplicateMapMobile.containsKey(dupAccount.Mobile__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(dupAccount);
                        duplicateMapMobile.put(dupAccount.Mobile__c, newAccountList);
                    } else {
                        duplicateMapMobile.get(dupAccount.Mobile__c).add(dupAccount);
                    }
                }
            }
            
            for(String mobile: incomingAccountMobileMap.keySet()) {
                if(duplicateMapMobile.containsKey(mobile)) {
                    for(Channel_Partner__c a: incomingAccountMobileMap.get(mobile)) {
                        accountDuplicateMapMobile.put(a, duplicateMapMobile.get(mobile));
                    }
                }
            }
        }
        return accountDuplicateMapMobile;
    }
    
    public static Map<Channel_Partner__c, List<Channel_Partner__c>> CPaccountDuplicateCheckByPANNo(List<Channel_Partner__c> accountList) {
        Map<Channel_Partner__c, List<Channel_Partner__c>> accountDuplicateMapPANNo = new Map<Channel_Partner__c, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> incomingAccountPANNoMap = new Map<String, List<Channel_Partner__c>>();
        Map<String, List<Channel_Partner__c>> duplicateMapPANNo = new Map<String, List<Channel_Partner__c>>();
        List<Channel_Partner__c> duplicateAccountList = new List<Channel_Partner__c>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountPANNoMap = getIncomingAccountMap('CP PAN', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountPANNoMap.isEmpty() && incomingAccountPANNoMap != null) {
            duplicateAccountList = [Select Id, Name, MahaRERA_Registration_No__c, Mobile__c, PAN_No__c from Channel_Partner__c 
                                    where PAN_No__c IN: incomingAccountPANNoMap.keySet() AND Id NOT IN: incomingAccountIdSet];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Channel_Partner__c dupAccount: duplicateAccountList) {
                    if(!duplicateMapPANNo.containsKey(dupAccount.PAN_No__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(dupAccount);
                        duplicateMapPANNo.put(dupAccount.PAN_No__c, newAccountList);
                    } else {
                        duplicateMapPANNo.get(dupAccount.PAN_No__c).add(dupAccount);
                    }
                }
            }
            
            for(String PANNo: incomingAccountPANNoMap.keySet()) {
                if(duplicateMapPANNo.containsKey(PANNo)) {
                    for(Channel_Partner__c a: incomingAccountPANNoMap.get(PANNo)) {
                        accountDuplicateMapPANNo.put(a, duplicateMapPANNo.get(PANNo));
                    }
                }
            }
        }
        return accountDuplicateMapPANNo;
    }
    
    public static Map<String, List<Channel_Partner__c>> getIncomingAccountMap(String Type, List<Channel_Partner__c> accountList) {
        Map<String, List<Channel_Partner__c>> incomingAccountMap = new Map<String, List<Channel_Partner__c>>();
        
        if(Type.equalsIgnoreCase('CP RERA No')) {
            for(Channel_Partner__c cp: accountList) {
                if(cp.MahaRERA_Registration_No__c != null) {
                    if(!incomingAccountMap.containsKey(cp.MahaRERA_Registration_No__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(cp);
                        incomingAccountMap.put(cp.MahaRERA_Registration_No__c, newAccountList);
                    } else {
                        incomingAccountMap.get(cp.MahaRERA_Registration_No__c).add(cp);
                    }
                }
            }
        } else if(Type.equalsIgnoreCase('CP Mobile')) {
            for(Channel_Partner__c cp: accountList) {
                if(cp.Mobile__c != null) {
                    if(!incomingAccountMap.containsKey(cp.Mobile__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(cp);
                        incomingAccountMap.put(cp.Mobile__c, newAccountList);
                    } else {
                        incomingAccountMap.get(cp.Mobile__c).add(cp);
                    }
                }
            }
        } else if(Type.equalsIgnoreCase('CP PAN')) {
            for(Channel_Partner__c cp: accountList) {
                if(cp.PAN_No__c != null) {
                    if(!incomingAccountMap.containsKey(cp.PAN_No__c)) {
                        List<Channel_Partner__c> newAccountList = new List<Channel_Partner__c>();
                        newAccountList.add(cp);
                        incomingAccountMap.put(cp.PAN_No__c, newAccountList);
                    } else {
                        incomingAccountMap.get(cp.PAN_No__c).add(cp);
                    }
                }
            }
        } else {
            
        }
        return incomingAccountMap;
    }
    
    public static Set<Id> getAccountIdSet(List<Channel_Partner__c> accountList) {
        Set<Id> accountIdSet = new Set<Id>();
        
        for(Channel_Partner__c cp: accountList) {
            accountIdSet.add(cp.Id);
        }
        return accountIdSet;
    }
    
    // Wrapper for duplicate details //
    public class duplicateWrapper {
        public String objectType {get;set;}
        public Channel_Partner__c dupAccount {get;set;}
        
        
        public duplicateWrapper(String type, Channel_Partner__c acc) {
            this.objectType = type;
            this.dupAccount = acc;
        }
    }
    
}