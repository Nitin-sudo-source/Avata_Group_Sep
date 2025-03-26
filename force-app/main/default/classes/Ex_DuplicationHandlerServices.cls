//-------------------------------------------//
//  Project: Avant Infra 
//  Created By: Exceller Tech
//  Created Date: 29-08-2024
//  Author: Sarjerao Deshmukh
//-------------------------------------------//
public class Ex_DuplicationHandlerServices {
    public static Map<Lead__c, List<duplicateWrapper>> duplicationCheck(List<Lead__c> leadList) {
        Map<Lead__c, List<duplicateWrapper>> duplicateWrapperMap = new Map<Lead__c, List<duplicateWrapper>>();
        Map<Lead__c, List<Account>> accountDuplicateMapPrimaryMobile = new Map<Lead__c, List<Account>>();
        Map<Lead__c, List<Account>> accountDuplicateMapPrimaryEmail = new Map<Lead__c, List<Account>>();
        Map<Lead__c, List<Account>> accountDuplicateMapSecondaryMobile = new Map<Lead__c, List<Account>>();
        Map<Lead__c, List<Account>> accountDuplicateMapSecondaryEmail = new Map<Lead__c, List<Account>>();
        Map<Lead__c, List<Lead__c>> leadDuplicateMapPrimaryMobile = new Map<Lead__c, List<Lead__c>>();
        Map<Lead__c, List<Lead__c>> leadDuplicateMapPrimaryEmail = new Map<Lead__c, List<Lead__c>>();
        Map<Lead__c, List<Lead__c>> leadDuplicateMapSecondaryMobile = new Map<Lead__c, List<Lead__c>>();
        Map<Lead__c, List<Lead__c>> leadDuplicateMapSecondaryEmail = new Map<Lead__c, List<Lead__c>>();
        
        accountDuplicateMapPrimaryMobile = accountDuplicateCheckByPrimaryMobile(leadList);
        system.debug('accountDuplicateMapPrimaryMobile: '+accountDuplicateMapPrimaryMobile);
        
        if(!accountDuplicateMapPrimaryMobile.isEmpty() && accountDuplicateMapPrimaryMobile != null) {
            for(Lead__c l: accountDuplicateMapPrimaryMobile.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Account dupAccount: accountDuplicateMapPrimaryMobile.get(l)) {
                    dwList.add(new duplicateWrapper('Account', null, dupAccount));
                }
                duplicateWrapperMap.put(l, dwList);
            }
        } else {
            accountDuplicateMapPrimaryEmail = accountDuplicateCheckByPrimaryEmail(leadList);
            system.debug('accountDuplicateMapPrimaryEmail: '+accountDuplicateMapPrimaryEmail);
            
            if(!accountDuplicateMapPrimaryEmail.isEmpty() && accountDuplicateMapPrimaryEmail != null) {
                for(Lead__c l: accountDuplicateMapPrimaryEmail.keySet()) {
                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                    for(Account dupAccount: accountDuplicateMapPrimaryEmail.get(l)) {
                        dwList.add(new duplicateWrapper('Account', null, dupAccount));
                    }
                    duplicateWrapperMap.put(l, dwList);
                }
            } else {
                accountDuplicateMapSecondaryMobile = accountDuplicateCheckBySecondaryMobile(leadList);
                system.debug('accountDuplicateMapSecondaryMobile: '+accountDuplicateMapSecondaryMobile);
                
                if(!accountDuplicateMapSecondaryMobile.isEmpty() && accountDuplicateMapSecondaryMobile != null) {
                    for(Lead__c l: accountDuplicateMapSecondaryMobile.keySet()) {
                        List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                        for(Account dupAccount: accountDuplicateMapSecondaryMobile.get(l)) {
                            dwList.add(new duplicateWrapper('Account', null, dupAccount));
                        }
                        duplicateWrapperMap.put(l, dwList);
                    }
                } else {
                    accountDuplicateMapSecondaryEmail = accountDuplicateCheckBySecondaryEmail(leadList);
                    system.debug('accountDuplicateMapSecondaryEmail: '+accountDuplicateMapSecondaryEmail);
                    
                    if(!accountDuplicateMapSecondaryEmail.isEmpty() && accountDuplicateMapSecondaryEmail != null) {
                        for(Lead__c l: accountDuplicateMapSecondaryEmail.keySet()) {
                            List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                            for(Account dupAccount: accountDuplicateMapSecondaryEmail.get(l)) {
                                dwList.add(new duplicateWrapper('Account', null, dupAccount));
                            }
                            duplicateWrapperMap.put(l, dwList);
                        }
                    } else {
                        leadDuplicateMapPrimaryMobile = leadDuplicateCheckByPrimaryMobile(leadList);
                        system.debug('leadDuplicateMapPrimaryMobile: '+leadDuplicateMapPrimaryMobile);
                        
                        if(!leadDuplicateMapPrimaryMobile.isEmpty() && leadDuplicateMapPrimaryMobile != null) {
                            for(Lead__c l: leadDuplicateMapPrimaryMobile.keySet()) {
                                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                                for(Lead__c dupLead: leadDuplicateMapPrimaryMobile.get(l)) {
                                    dwList.add(new duplicateWrapper('Lead', dupLead, null));
                                }
                                duplicateWrapperMap.put(l, dwList);
                            }
                        } else {
                            leadDuplicateMapPrimaryEmail = leadDuplicateCheckByPrimaryEmail(leadList);
                            system.debug('leadDuplicateMapPrimaryEmail: '+leadDuplicateMapPrimaryEmail);
                            
                            if(!leadDuplicateMapPrimaryEmail.isEmpty() && leadDuplicateMapPrimaryEmail != null) {
                                for(Lead__c l: leadDuplicateMapPrimaryEmail.keySet()) {
                                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                                    for(Lead__c dupLead: leadDuplicateMapPrimaryEmail.get(l)) {
                                        dwList.add(new duplicateWrapper('Lead', dupLead, null));
                                    }
                                    duplicateWrapperMap.put(l, dwList);
                                }
                            } else {
                                leadDuplicateMapSecondaryMobile = leadDuplicateCheckBySecondaryMobile(leadList);
                                system.debug('leadDuplicateMapSecondaryMobile: '+leadDuplicateMapSecondaryMobile);
                                
                                if(!leadDuplicateMapSecondaryMobile.isEmpty() && leadDuplicateMapSecondaryMobile != null) {
                                    for(Lead__c l: leadDuplicateMapSecondaryMobile.keySet()) {
                                        List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                                        for(Lead__c dupLead: leadDuplicateMapSecondaryMobile.get(l)) {
                                            dwList.add(new duplicateWrapper('Lead', dupLead, null));
                                        }
                                        duplicateWrapperMap.put(l, dwList);
                                    }
                                } else {
                                    leadDuplicateMapSecondaryEmail = leadDuplicateCheckBySecondaryEmail(leadList);
                                    system.debug('leadDuplicateMapSecondaryEmail: '+leadDuplicateMapSecondaryEmail);
                                    
                                    if(!leadDuplicateMapSecondaryEmail.isEmpty() && leadDuplicateMapSecondaryEmail != null) {
                                        for(Lead__c l: leadDuplicateMapSecondaryEmail.keySet()) {
                                            List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                                            for(Lead__c dupLead: leadDuplicateMapSecondaryEmail.get(l)) {
                                                dwList.add(new duplicateWrapper('Lead', dupLead, null));
                                            }
                                            duplicateWrapperMap.put(l, dwList);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<Lead__c, List<Account>> accountDuplicateCheckByPrimaryMobile(List<Lead__c> leadList) {
        Map<Lead__c, List<Account>> accountDuplicateMapPrimaryMobile = new Map<Lead__c, List<Account>>();
        Map<String, List<Lead__c>> incomingLeadPrimaryMobileMap = new Map<String, List<Lead__c>>();
        Map<String, List<Account>> duplicateMapPrimaryMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingLeadPrimaryMobileMap = getIncomingLeadMap('Primary Mobile', leadList);
        incomingAccountIdSet = getAccountIdSet(leadList);
        
        if(!incomingLeadPrimaryMobileMap.isEmpty() && incomingLeadPrimaryMobileMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, OwnerId, Owner.Name, PersonContactId from Account 
                                    where PersonMobilePhone IN : incomingLeadPrimaryMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapPrimaryMobile.containsKey(dupAccount.PersonMobilePhone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapPrimaryMobile.put(dupAccount.PersonMobilePhone, newAccountList);
                    } else {
                        duplicateMapPrimaryMobile.get(dupAccount.PersonMobilePhone).add(dupAccount);
                    }
                }
            }
            
            for(String mobile: incomingLeadPrimaryMobileMap.keySet()) {
                if(duplicateMapPrimaryMobile.containsKey(mobile)) {
                    for(Lead__c l: incomingLeadPrimaryMobileMap.get(mobile)) {
                        accountDuplicateMapPrimaryMobile.put(l, duplicateMapPrimaryMobile.get(mobile));
                    }
                }
            }
        }
        return accountDuplicateMapPrimaryMobile;
    }
    
    public static Map<Lead__c, List<Account>> accountDuplicateCheckByPrimaryEmail(List<Lead__c> leadList) {
        Map<Lead__c, List<Account>> accountDuplicateMapPrimaryEmail = new Map<Lead__c, List<Account>>();
        Map<String, List<Lead__c>> incomingLeadPrimaryEmailMap = new Map<String, List<Lead__c>>();
        Map<String, List<Account>> duplicateMapPrimaryEmail = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingLeadPrimaryEmailMap = getIncomingLeadMap('Primary Email', leadList);
        incomingAccountIdSet = getAccountIdSet(leadList);
        
        if(!incomingLeadPrimaryEmailMap.isEmpty() && incomingLeadPrimaryEmailMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, OwnerId, Owner.Name, PersonContactId from Account 
                                    where PersonEmail IN: incomingLeadPrimaryEmailMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapPrimaryEmail.containsKey(dupAccount.PersonEmail)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapPrimaryEmail.put(dupAccount.PersonEmail, newAccountList);
                    } else {
                        duplicateMapPrimaryEmail.get(dupAccount.PersonEmail).add(dupAccount);
                    }
                }
            }
            
            for(String email: incomingLeadPrimaryEmailMap.keySet()) {
                if(duplicateMapPrimaryEmail.containsKey(email)) {
                    for(Lead__c l: incomingLeadPrimaryEmailMap.get(email)) {
                        accountDuplicateMapPrimaryEmail.put(l, duplicateMapPrimaryEmail.get(email));
                    }
                }
            }
        }
        return accountDuplicateMapPrimaryEmail;
    }
    
    public static Map<Lead__c, List<Account>> accountDuplicateCheckBySecondaryMobile(List<Lead__c> leadList) {
        Map<Lead__c, List<Account>> accountDuplicateMapSecondaryMobile = new Map<Lead__c, List<Account>>();
        Map<String, List<Lead__c>> incomingLeadSecondaryMobileMap = new Map<String, List<Lead__c>>();
        Map<String, List<Account>> duplicateMapSecondaryMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingLeadSecondaryMobileMap = getIncomingLeadMap('Secondary Mobile', leadList);
        incomingAccountIdSet = getAccountIdSet(leadList);
        
        if(!incomingLeadSecondaryMobileMap.isEmpty() && incomingLeadSecondaryMobileMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, OwnerId, Owner.Name, PersonContactId from Account 
                                    where Phone IN: incomingLeadSecondaryMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapSecondaryMobile.containsKey(dupAccount.Phone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapSecondaryMobile.put(dupAccount.Phone, newAccountList);
                    } else {
                        duplicateMapSecondaryMobile.get(dupAccount.Phone).add(dupAccount);
                    }
                }
            }
            
            for(String mobile: incomingLeadSecondaryMobileMap.keySet()) {
                if(duplicateMapSecondaryMobile.containsKey(mobile)) {
                    for(Lead__c l: incomingLeadSecondaryMobileMap.get(mobile)) {
                        accountDuplicateMapSecondaryMobile.put(l, duplicateMapSecondaryMobile.get(mobile));
                    }
                }
            }
        }
        return accountDuplicateMapSecondaryMobile;
    }
    
    public static Map<Lead__c, List<Account>> accountDuplicateCheckBySecondaryEmail(List<Lead__c> leadList) {
        Map<Lead__c, List<Account>> accountDuplicateMapSecondaryEmail = new Map<Lead__c, List<Account>>();
        Map<String, List<Lead__c>> incomingLeadSecondaryEmailMap = new Map<String, List<Lead__c>>();
        Map<String, List<Account>> duplicateMapSecondaryEmail = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingLeadSecondaryEmailMap = getIncomingLeadMap('Secondary Email', leadList);
        incomingAccountIdSet = getAccountIdSet(leadList);
        
        if(!incomingLeadSecondaryEmailMap.isEmpty() && incomingLeadSecondaryEmailMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, OwnerId, Owner.Name, PersonContactId from Account 
                                    where Alternate_Email__c IN: incomingLeadSecondaryEmailMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapSecondaryEmail.containsKey(dupAccount.Alternate_Email__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapSecondaryEmail.put(dupAccount.Alternate_Email__c, newAccountList);
                    } else {
                        duplicateMapSecondaryEmail.get(dupAccount.Alternate_Email__c).add(dupAccount);
                    }
                }
            }
            
            for(String email: incomingLeadSecondaryEmailMap.keySet()) {
                if(duplicateMapSecondaryEmail.containsKey(email)) {
                    for(Lead__c l: incomingLeadSecondaryEmailMap.get(email)) {
                        accountDuplicateMapSecondaryEmail.put(l, duplicateMapSecondaryEmail.get(email));
                    }
                }
            }
        }
        return accountDuplicateMapSecondaryEmail;
    }
    
    public static Map<Lead__c, List<Lead__c>> leadDuplicateCheckByPrimaryMobile(List<Lead__c> leadList) {
        Map<Lead__c, List<Lead__c>> leadDuplicateMapPrimaryMobile = new Map<Lead__c, List<Lead__c>>();
        Map<String, List<Lead__c>> incomingLeadPrimaryMobileMap = new Map<String, List<Lead__c>>();
        Map<String, List<Lead__c>> duplicateMapPrimaryMobile = new Map<String, List<Lead__c>>();
        List<Lead__c> duplicateLeadList = new List<Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadPrimaryMobileMap = getIncomingLeadMap('Primary Mobile', leadList);
        incomingLeadIdSet = getLeadIdSet(leadList);
        
        if(!incomingLeadPrimaryMobileMap.isEmpty() && incomingLeadPrimaryMobileMap != null) {
            duplicateLeadList = [Select Id, Full_Name__c, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, Email__c, Alternate_Email__c, OwnerId, Owner.Name from Lead__c
                                 where Mobile__c IN: incomingLeadPrimaryMobileMap.keySet() AND Id NOT IN: incomingLeadIdSet AND IsConverted__c = false];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(Lead__c dupLead: duplicateLeadList) {
                    if(!duplicateMapPrimaryMobile.containsKey(dupLead.Mobile__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(dupLead);
                        duplicateMapPrimaryMobile.put(dupLead.Mobile__c, newLeadList);
                    } else {
                        duplicateMapPrimaryMobile.get(dupLead.Mobile__c).add(dupLead);
                    }
                }
            }
            
            for(String mobile: incomingLeadPrimaryMobileMap.keySet()) {
                if(duplicateMapPrimaryMobile.containsKey(mobile)) {
                    for(Lead__c l: incomingLeadPrimaryMobileMap.get(mobile)) {
                        leadDuplicateMapPrimaryMobile.put(l, duplicateMapPrimaryMobile.get(mobile));
                    }
                }
            }
        }
        return leadDuplicateMapPrimaryMobile;
    }
    
    public static Map<Lead__c, List<Lead__c>> leadDuplicateCheckByPrimaryEmail(List<Lead__c> leadList) {
        Map<Lead__c, List<Lead__c>> leadDuplicateMapPrimaryEmail = new Map<Lead__c, List<Lead__c>>();
        Map<String, List<Lead__c>> incomingLeadPrimaryEmailMap = new Map<String, List<Lead__c>>();
        Map<String, List<Lead__c>> duplicateMapPrimaryEmail = new Map<String, List<Lead__c>>();
        List<Lead__c> duplicateLeadList = new List<Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadPrimaryEmailMap = getIncomingLeadMap('Primary Email', leadList);
        incomingLeadIdSet = getLeadIdSet(leadList);
        
        if(!incomingLeadPrimaryEmailMap.isEmpty() && incomingLeadPrimaryEmailMap != null) {
            duplicateLeadList = [Select Id, Full_Name__c, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, Email__c, Alternate_Email__c, OwnerId, Owner.Name from Lead__c
                                 where Email__c IN: incomingLeadPrimaryEmailMap.keySet() AND Id NOT IN: incomingLeadIdSet AND IsConverted__c = false];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(Lead__c dupLead: duplicateLeadList) {
                    if(!duplicateMapPrimaryEmail.containsKey(dupLead.Email__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(dupLead);
                        duplicateMapPrimaryEmail.put(dupLead.Email__c, newLeadList);
                    } else {
                        duplicateMapPrimaryEmail.get(dupLead.Email__c).add(dupLead);
                    }
                }
            }
            
            for(String email: incomingLeadPrimaryEmailMap.keySet()) {
                if(duplicateMapPrimaryEmail.containsKey(email)) {
                    for(Lead__c l: incomingLeadPrimaryEmailMap.get(email)) {
                        leadDuplicateMapPrimaryEmail.put(l, duplicateMapPrimaryEmail.get(email));
                    }
                }
            }
        }
        return leadDuplicateMapPrimaryEmail;
    }
    
    public static Map<Lead__c, List<Lead__c>> leadDuplicateCheckBySecondaryMobile(List<Lead__c> leadList) {
        Map<Lead__c, List<Lead__c>> leadDuplicateMapSecondaryMobile = new Map<Lead__c, List<Lead__c>>();
        Map<String, List<Lead__c>> incomingLeadSecondaryMobileMap = new Map<String, List<Lead__c>>();
        Map<String, List<Lead__c>> duplicateMapSecondaryMobile = new Map<String, List<Lead__c>>();
        List<Lead__c> duplicateLeadList = new List<Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadSecondaryMobileMap = getIncomingLeadMap('Secondary Mobile', leadList);
        incomingLeadIdSet = getLeadIdSet(leadList);
        
        if(!incomingLeadSecondaryMobileMap.isEmpty() && incomingLeadSecondaryMobileMap != null) {
            duplicateLeadList = [Select Id, Full_Name__c, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, Email__c, Alternate_Email__c, OwnerId, Owner.Name from Lead__c
                                 where Alternate_Mobile__c IN: incomingLeadSecondaryMobileMap.keySet() AND Id NOT IN: incomingLeadIdSet AND IsConverted__c = false];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(Lead__c dupLead: duplicateLeadList) {
                    if(!duplicateMapSecondaryMobile.containsKey(dupLead.Alternate_Mobile__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(dupLead);
                        duplicateMapSecondaryMobile.put(dupLead.Alternate_Mobile__c, newLeadList);
                    } else {
                        duplicateMapSecondaryMobile.get(dupLead.Alternate_Mobile__c).add(dupLead);
                    }
                }
            }
            
            for(String mobile: incomingLeadSecondaryMobileMap.keySet()) {
                if(duplicateMapSecondaryMobile.containsKey(mobile)) {
                    for(Lead__c l: incomingLeadSecondaryMobileMap.get(mobile)) {
                        leadDuplicateMapSecondaryMobile.put(l, duplicateMapSecondaryMobile.get(mobile));
                    }
                }
            }
        }
        return leadDuplicateMapSecondaryMobile;
    }
    
    public static Map<Lead__c, List<Lead__c>> leadDuplicateCheckBySecondaryEmail(List<Lead__c> leadList) {
        Map<Lead__c, List<Lead__c>> leadDuplicateMapSecondaryEmail = new Map<Lead__c, List<Lead__c>>();
        Map<String, List<Lead__c>> incomingLeadSecondaryEmailMap = new Map<String, List<Lead__c>>();
        Map<String, List<Lead__c>> duplicateMapSecondaryEmail = new Map<String, List<Lead__c>>();
        List<Lead__c> duplicateLeadList = new List<Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadSecondaryEmailMap = getIncomingLeadMap('Secondary Email', leadList);
        incomingLeadIdSet = getLeadIdSet(leadList);
        
        if(!incomingLeadSecondaryEmailMap.isEmpty() && incomingLeadSecondaryEmailMap != null) {
            duplicateLeadList = [Select Id, Full_Name__c, First_Name__c, Last_Name__c, Mobile__c, Alternate_Mobile__c, Email__c, Alternate_Email__c, OwnerId, Owner.Name from Lead__c
                                 where Alternate_Email__c IN: incomingLeadSecondaryEmailMap.keySet() AND Id NOT IN: incomingLeadIdSet AND IsConverted__c = false];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(Lead__c dupLead: duplicateLeadList) {
                    if(!duplicateMapSecondaryEmail.containsKey(dupLead.Alternate_Email__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(dupLead);
                        duplicateMapSecondaryEmail.put(dupLead.Alternate_Email__c, newLeadList);
                    } else {
                        duplicateMapSecondaryEmail.get(dupLead.Alternate_Email__c).add(dupLead);
                    }
                }
            }
            
            for(String email: incomingLeadSecondaryEmailMap.keySet()) {
                if(duplicateMapSecondaryEmail.containsKey(email)) {
                    for(Lead__c l: incomingLeadSecondaryEmailMap.get(email)) {
                        leadDuplicateMapSecondaryEmail.put(l, duplicateMapSecondaryEmail.get(email));
                    }
                }
            }
        }
        return leadDuplicateMapSecondaryEmail;
    }
    
    public static Map<Account, List<duplicateWrapper>> duplicationCheckAcccount(List<Account> accountList) {
        Map<Account, List<duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<duplicateWrapper>>();
        Map<Account, List<Account>> accountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<Account, List<Account>> accountDuplicateMapEmail = new Map<Account, List<Account>>();
        Map<Account, List<Account>> accountDuplicateMapPhone = new Map<Account, List<Account>>();
        Map<Account, List<Account>> accountDuplicateMapAlternateEmail = new Map<Account, List<Account>>();
        
        accountDuplicateMapMobile = accountDuplicateCheckByMobile(accountList);
        system.debug('accountDuplicateMapMobile: '+accountDuplicateMapMobile);
        
        if(!accountDuplicateMapMobile.isEmpty() && accountDuplicateMapMobile != null) {
            for(Account a: accountDuplicateMapMobile.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Account dupAccount: accountDuplicateMapMobile.get(a)) {
                    dwList.add(new duplicateWrapper('Account', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        } else {
            accountDuplicateMapEmail = accountDuplicateCheckByEmail(accountList);
            system.debug('accountDuplicateMapEmail: '+accountDuplicateMapEmail);
            
            if(!accountDuplicateMapEmail.isEmpty() && accountDuplicateMapEmail != null) {
                for(Account a: accountDuplicateMapEmail.keySet()) {
                    List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                    for(Account dupAccount: accountDuplicateMapEmail.get(a)) {
                        dwList.add(new duplicateWrapper('Account', dupAccount));
                    }
                    duplicateWrapperMap.put(a, dwList);
                }
            } else {
                accountDuplicateMapPhone = accountDuplicateCheckByPhone(accountList);
                system.debug('accountDuplicateMapPhone: '+accountDuplicateMapPhone);
                
                if(!accountDuplicateMapPhone.isEmpty() && accountDuplicateMapPhone != null) {
                    for(Account a: accountDuplicateMapPhone.keySet()) {
                        List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                        for(Account dupAccount: accountDuplicateMapPhone.get(a)) {
                            dwList.add(new duplicateWrapper('Account', dupAccount));
                        }
                        duplicateWrapperMap.put(a, dwList);
                    }
                } else {
                    accountDuplicateMapAlternateEmail = accountDuplicateCheckByAlternateEmail(accountList);
                    system.debug('accountDuplicateMapAlternateEmail: '+accountDuplicateMapAlternateEmail);
                    
                    if(!accountDuplicateMapAlternateEmail.isEmpty() && accountDuplicateMapAlternateEmail != null) {
                        for(Account a: accountDuplicateMapAlternateEmail.keySet()) {
                            List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                            for(Account dupAccount: accountDuplicateMapAlternateEmail.get(a)) {
                                dwList.add(new duplicateWrapper('Account', dupAccount));
                            }
                            duplicateWrapperMap.put(a, dwList);
                        }
                    }
                }
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<Account, List<Account>> accountDuplicateCheckByMobile(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountMobileMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountMobileMap = getIncomingAccountMap('Primary Mobile', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountMobileMap.isEmpty() && incomingAccountMobileMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, PersonContactId, OwnerId, Owner.Name from Account 
                                    where PersonMobilePhone IN: incomingAccountMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapMobile.containsKey(dupAccount.PersonMobilePhone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapMobile.put(dupAccount.PersonMobilePhone, newAccountList);
                    } else {
                        duplicateMapMobile.get(dupAccount.PersonMobilePhone).add(dupAccount);
                    }
                }
            }
            
            for(String mobile: incomingAccountMobileMap.keySet()) {
                if(duplicateMapMobile.containsKey(mobile)) {
                    for(Account a: incomingAccountMobileMap.get(mobile)) {
                        accountDuplicateMapMobile.put(a, duplicateMapMobile.get(mobile));
                    }
                }
            }
        }
        return accountDuplicateMapMobile;
    }
    
    public static Map<Account, List<Account>> accountDuplicateCheckByPhone(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapPhone = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountPhoneMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapPhone = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountPhoneMap = getIncomingAccountMap('Secondary Mobile', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountPhoneMap.isEmpty() && incomingAccountPhoneMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, PersonContactId, OwnerId, Owner.Name from Account 
                                    where Phone IN: incomingAccountPhoneMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapPhone.containsKey(dupAccount.Phone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapPhone.put(dupAccount.Phone, newAccountList);
                    } else {
                        duplicateMapPhone.get(dupAccount.Phone).add(dupAccount);
                    }
                }
            }
            
            for(String phone: incomingAccountPhoneMap.keySet()) {
                if(duplicateMapPhone.containsKey(phone)) {
                    for(Account a: incomingAccountPhoneMap.get(phone)) {
                        accountDuplicateMapPhone.put(a, duplicateMapPhone.get(phone));
                    }
                }
            }
        }
        return accountDuplicateMapPhone;
    }
    
    public static Map<Account, List<Account>> accountDuplicateCheckByEmail(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapEmail = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountEmailMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapEmail = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountEmailMap = getIncomingAccountMap('Primary Email', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountEmailMap.isEmpty() && incomingAccountEmailMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, PersonContactId, OwnerId, Owner.Name from Account 
                                    where PersonEmail IN: incomingAccountEmailMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapEmail.containsKey(dupAccount.PersonEmail)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapEmail.put(dupAccount.PersonEmail, newAccountList);
                    } else {
                        duplicateMapEmail.get(dupAccount.PersonEmail).add(dupAccount);
                    }
                }
            }
            
            for(String email: incomingAccountEmailMap.keySet()) {
                if(duplicateMapEmail.containsKey(email)) {
                    for(Account a: incomingAccountEmailMap.get(email)) {
                        accountDuplicateMapEmail.put(a, duplicateMapEmail.get(email));
                    }
                }
            }
        }
        return accountDuplicateMapEmail;
    }
    
    public static Map<Account, List<Account>> accountDuplicateCheckByAlternateEmail(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapAlternateEmail = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountAlternateEmailMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapAlternateEmail = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountAlternateEmailMap = getIncomingAccountMap('Secondary Email', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        if(!incomingAccountAlternateEmailMap.isEmpty() && incomingAccountAlternateEmailMap != null) {
            duplicateAccountList = [Select Id, Name, FirstName, LastName, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, PersonContactId, OwnerId, Owner.Name from Account 
                                    where Alternate_Email__c IN: incomingAccountAlternateEmailMap.keySet() AND Id NOT IN: incomingAccountIdSet AND IsPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapAlternateEmail.containsKey(dupAccount.Alternate_Email__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapAlternateEmail.put(dupAccount.Alternate_Email__c, newAccountList);
                    } else {
                        duplicateMapAlternateEmail.get(dupAccount.Alternate_Email__c).add(dupAccount);
                    }
                }
            }
            
            for(String alternateEmail: incomingAccountAlternateEmailMap.keySet()) {
                if(duplicateMapAlternateEmail.containsKey(alternateEmail)) {
                    for(Account a: incomingAccountAlternateEmailMap.get(alternateEmail)) {
                        accountDuplicateMapAlternateEmail.put(a, duplicateMapAlternateEmail.get(alternateEmail));
                    }
                }
            }
        }
        return accountDuplicateMapAlternateEmail;
    }
    
    /*-----------------------------------Master Method For CP Account Start--------------------------------------------*/
	// Changes Done by Nitin Choudhary    
    public static Map<Account, List<duplicateWrapper>> duplicationCheckCPAcccount(List<Account> accountList) {
        Map<Account, List<duplicateWrapper>> duplicateWrapperMap = new Map<Account, List<duplicateWrapper>>();
        Map<Account, List<Account>> CPaccountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<Account, List<Account>> CPaccountDuplicateMapPan = new Map<Account, List<Account>>();
        Map<Account, List<Account>> CPaccountDuplicateMapRera = new Map<Account, List<Account>>();


        
        CPaccountDuplicateMapMobile = CPaccountDuplicateCheckByMobile(accountList);
        CPaccountDuplicateMapPan = CPaccountDuplicateCheckByRera(accountList);
        CPaccountDuplicateMapRera = CPaccountDuplicateCheckByPan(accountList);
        
        system.debug('CPaccountDuplicateMapMobile: '+CPaccountDuplicateMapMobile);
        
        if(!CPaccountDuplicateMapMobile.isEmpty() && CPaccountDuplicateMapMobile != null) {
            for(Account a: CPaccountDuplicateMapMobile.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Account dupAccount: CPaccountDuplicateMapMobile.get(a)) {
                    dwList.add(new duplicateWrapper('Account', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        } 
        
         if(!CPaccountDuplicateMapPan.isEmpty() && CPaccountDuplicateMapPan != null) {
            for(Account a: CPaccountDuplicateMapPan.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Account dupAccount: CPaccountDuplicateMapPan.get(a)) {
                    dwList.add(new duplicateWrapper('Account', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        }
        
         if(!CPaccountDuplicateMapRera.isEmpty() && CPaccountDuplicateMapRera != null) {
            for(Account a: CPaccountDuplicateMapRera.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(Account dupAccount: CPaccountDuplicateMapRera.get(a)) {
                    dwList.add(new duplicateWrapper('Account', dupAccount));
                }
                duplicateWrapperMap.put(a, dwList);
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<Account, List<Account>> CPaccountDuplicateCheckByMobile(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountMobileMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountMobileMap = getIncomingCPAccountMap('CP Phone', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        RecordType rt = new RecordType();
        rt = [Select Id, DeveloperName, Name from RecordType where Name =: 'Channel Partner']; 
        System.debug('RecordType::'+rt);
        
        if(!incomingAccountMobileMap.isEmpty() && incomingAccountMobileMap != null) {
            duplicateAccountList = [Select Id, Name,FirstName, LastName, PAN_No__c, MahaRERA_Registration_No__c, Phone, PersonEmail,CP_Unique_Code__c,Owner.Name,PersonContactId from Account 
                                    where Phone IN: incomingAccountMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND RecordTypeId =: rt.id];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapMobile.containsKey(dupAccount.Phone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapMobile.put(dupAccount.Phone, newAccountList);
                    } else {
                        duplicateMapMobile.get(dupAccount.Phone).add(dupAccount);
                    }
                }
            }
            
            for(String phone: incomingAccountMobileMap.keySet()) {
                if(duplicateMapMobile.containsKey(phone)) {
                    for(Account a: incomingAccountMobileMap.get(phone)) {
                        accountDuplicateMapMobile.put(a, duplicateMapMobile.get(phone));
                    }
                }
            }
        }
        return accountDuplicateMapMobile;
    }
    
    public static Map<Account, List<Account>> CPaccountDuplicateCheckByRera(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountMobileMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountMobileMap = getIncomingCPAccountMap('CP RERA', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        RecordType rt = new RecordType();
        rt = [Select Id, DeveloperName, Name from RecordType where Name =: 'Channel Partner']; 
        System.debug('RecordType::'+rt);
        
        if(!incomingAccountMobileMap.isEmpty() && incomingAccountMobileMap != null) {
            duplicateAccountList = [Select Id, Name,FirstName, LastName, PAN_No__c, MahaRERA_Registration_No__c, Phone, PersonEmail,CP_Unique_Code__c,Owner.Name,PersonContactId from Account 
                                    where MahaRERA_Registration_No__c IN: incomingAccountMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND RecordTypeId =: rt.id];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapMobile.containsKey(dupAccount.MahaRERA_Registration_No__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapMobile.put(dupAccount.MahaRERA_Registration_No__c, newAccountList);
                    } else {
                        duplicateMapMobile.get(dupAccount.MahaRERA_Registration_No__c).add(dupAccount);
                    }
                }
            }
            
            for(String phone: incomingAccountMobileMap.keySet()) {
                if(duplicateMapMobile.containsKey(phone)) {
                    for(Account a: incomingAccountMobileMap.get(phone)) {
                        accountDuplicateMapMobile.put(a, duplicateMapMobile.get(phone));
                    }
                }
            }
        }
        return accountDuplicateMapMobile;
    }
    
    public static Map<Account, List<Account>> CPaccountDuplicateCheckByPan(List<Account> accountList) {
        Map<Account, List<Account>> accountDuplicateMapMobile = new Map<Account, List<Account>>();
        Map<String, List<Account>> incomingAccountMobileMap = new Map<String, List<Account>>();
        Map<String, List<Account>> duplicateMapMobile = new Map<String, List<Account>>();
        List<Account> duplicateAccountList = new List<Account>();
        Set<Id> incomingAccountIdSet = new Set<Id>();
        
        incomingAccountMobileMap = getIncomingCPAccountMap('CP PAN', accountList);
        incomingAccountIdSet = getAccountIdSet(accountList);
        
        RecordType rt = new RecordType();
        rt = [Select Id, DeveloperName, Name from RecordType where Name =: 'Channel Partner']; 
        System.debug('RecordType::'+rt);
        
        if(!incomingAccountMobileMap.isEmpty() && incomingAccountMobileMap != null) {
            duplicateAccountList = [Select Id, Name,FirstName, LastName, PAN_No__c, MahaRERA_Registration_No__c, Phone, PersonEmail,CP_Unique_Code__c,Owner.Name,PersonContactId from Account 
                                    where PAN_No__c IN: incomingAccountMobileMap.keySet() AND Id NOT IN: incomingAccountIdSet AND RecordTypeId =: rt.id];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(!duplicateAccountList.isEmpty() && duplicateAccountList != null) {
                for(Account dupAccount: duplicateAccountList) {
                    if(!duplicateMapMobile.containsKey(dupAccount.PAN_No__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(dupAccount);
                        duplicateMapMobile.put(dupAccount.PAN_No__c, newAccountList);
                    } else {
                        duplicateMapMobile.get(dupAccount.PAN_No__c).add(dupAccount);
                    }
                }
            }
            
            for(String phone: incomingAccountMobileMap.keySet()) {
                if(duplicateMapMobile.containsKey(phone)) {
                    for(Account a: incomingAccountMobileMap.get(phone)) {
                        accountDuplicateMapMobile.put(a, duplicateMapMobile.get(phone));
                    }
                }
            }
        }
        return accountDuplicateMapMobile;
    }
    
    public static Map<String, List<Account>> getIncomingCPAccountMap(String Type, List<Account> accountList) {
        Map<String, List<Account>> incomingAccountMap = new Map<String, List<Account>>();
        RecordType rt = new RecordType();
        rt = [Select Id, DeveloperName, Name from RecordType where Name =: 'Channel Partner']; 
        System.debug('RecordType::'+rt);
        
        if(Type.equalsIgnoreCase('CP Phone')) {
            for(Account a: accountList) {
                if(a.Phone != null && a.RecordTypeId == rt.id) {
                    if(!incomingAccountMap.containsKey(a.Phone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.Phone, newAccountList);
                    } else {
                        incomingAccountMap.get(a.Phone).add(a);
                        System.debug('RecordType::'+a.RecordTypeId);
                    }
                }
            }
        }
        if(Type.equalsIgnoreCase('CP PAN')) {
            for(Account a: accountList) {
                if(a.PAN_No__c != null && a.RecordTypeId == rt.id) {
                    if(!incomingAccountMap.containsKey(a.PAN_No__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.PAN_No__c, newAccountList);
                    } else {
                        incomingAccountMap.get(a.PAN_No__c).add(a);
                        System.debug('RecordType::'+a.RecordTypeId);
                    }
                }
            }
        }
        if(Type.equalsIgnoreCase('CP RERA')) {
            for(Account a: accountList) {
                if(a.MahaRERA_Registration_No__c != null && a.RecordTypeId == rt.id) {
                    if(!incomingAccountMap.containsKey(a.MahaRERA_Registration_No__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.MahaRERA_Registration_No__c, newAccountList);
                    } else {
                        incomingAccountMap.get(a.MahaRERA_Registration_No__c).add(a);
                        System.debug('RecordType::'+a.RecordTypeId);
                    }
                }
            }
        }
        return incomingAccountMap;
    }

    // Master Method for CP Lead Start
    public static Set<Id> getCPLeadIdSet(List<CP_Lead__c> leadList) {
        Set<Id> leadIdSet = new Set<Id>();
        
        for(CP_Lead__c l: leadList) {
            leadIdSet.add(l.Id);
        }
        return leadIdSet;
    }
    
    public static Map<CP_Lead__c, List<duplicateWrapper>> duplicationCheckCPLead(List<CP_Lead__c> cpList) {
        Map<CP_Lead__c, List<duplicateWrapper>> duplicateWrapperMap = new Map<CP_Lead__c, List<duplicateWrapper>>();
        Map<CP_Lead__c, List<CP_Lead__c>> cpleadDuplicateMapMobileWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<CP_Lead__c, List<CP_Lead__c>> cpleadDuplicateMapPhoneWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<CP_Lead__c, List<CP_Lead__c>> cpleadDuplicateMapEmailWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<CP_Lead__c, List<CP_Lead__c>> cpleadDuplicateMapAlternateEmailWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        
        cpleadDuplicateMapMobileWithProject = getCPleadDuplicateCheckByMobileWithProject(cpList);
        system.debug('cpleadDuplicateMapMobileWithProject: '+cpleadDuplicateMapMobileWithProject);
        
        cpleadDuplicateMapPhoneWithProject = getCPleadDuplicateCheckByPhoneWithProject(cpList);
        system.debug('cpleadDuplicateMapPhoneWithProject: '+cpleadDuplicateMapPhoneWithProject);
        
        cpleadDuplicateMapEmailWithProject = getCPleadDuplicateCheckByEmailWithProject(cpList);
        system.debug('cpleadDuplicateMapEmailWithProject: '+cpleadDuplicateMapEmailWithProject);
        
        cpleadDuplicateMapAlternateEmailWithProject = getCPleadDuplicateCheckByAlternateEmailWithProject(cpList);
        system.debug('cpleadDuplicateMapAlternateEmailWithProject: '+cpleadDuplicateMapAlternateEmailWithProject);
        
        if(!cpleadDuplicateMapMobileWithProject.isEmpty() && cpleadDuplicateMapMobileWithProject != null) {
            for(CP_Lead__c l: cpleadDuplicateMapMobileWithProject.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(CP_Lead__c dupCPLead: cpleadDuplicateMapMobileWithProject.get(l)) {
                    dwList.add(new duplicateWrapper('CP Lead', dupCPLead));
                }
                duplicateWrapperMap.put(l, dwList);
            }
        }
        if(!cpleadDuplicateMapPhoneWithProject.isEmpty() && cpleadDuplicateMapPhoneWithProject != null) {
            for(CP_Lead__c l: cpleadDuplicateMapPhoneWithProject.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(CP_Lead__c dupCPLead: cpleadDuplicateMapPhoneWithProject.get(l)) {
                    dwList.add(new duplicateWrapper('CP Lead', dupCPLead));
                }
                duplicateWrapperMap.put(l, dwList);
            }
        }
        if(!cpleadDuplicateMapEmailWithProject.isEmpty() && cpleadDuplicateMapEmailWithProject != null) {
            for(CP_Lead__c l: cpleadDuplicateMapEmailWithProject.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(CP_Lead__c dupCPLead: cpleadDuplicateMapEmailWithProject.get(l)) {
                    dwList.add(new duplicateWrapper('CP Lead', dupCPLead));
                }
                duplicateWrapperMap.put(l, dwList);
            }
        }
        if(!cpleadDuplicateMapAlternateEmailWithProject.isEmpty() && cpleadDuplicateMapAlternateEmailWithProject != null) {
            for(CP_Lead__c l: cpleadDuplicateMapAlternateEmailWithProject.keySet()) {
                List<duplicateWrapper> dwList = new List<duplicateWrapper>();
                for(CP_Lead__c dupCPLead: cpleadDuplicateMapAlternateEmailWithProject.get(l)) {
                    dwList.add(new duplicateWrapper('CP Lead', dupCPLead));
                }
                duplicateWrapperMap.put(l, dwList);
            }
        }
        return duplicateWrapperMap;
    }
    
    public static Map<CP_Lead__c, List<CP_Lead__c>> getCPleadDuplicateCheckByMobileWithProject(List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<CP_Lead__c>> leadDuplicateMapMobileWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadMobileMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadMobileWithProjectMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> duplicateMapMobileWithProject = new Map<String, List<CP_Lead__c>>();
        List<CP_Lead__c> duplicateLeadList = new List<CP_Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadMobileMap = getIncomingCPLeadMap('Mobile', leadList);
        incomingLeadMobileWithProjectMap = getIncomingCPLeadWithProjectMap('Mobile', leadList);
        incomingLeadIdSet = getCPLeadIdSet(leadList);
        
        if(!incomingLeadMobileMap.isEmpty() && incomingLeadMobileMap != null) {
            duplicateLeadList = [Select Id, CreatedDate, CP_Project__c, OwnerId, Owner.FirstName, Owner.LastName, Name, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Channel_Partner_Name__c from CP_Lead__c 
                                 where Mobile__c IN: incomingLeadMobileMap.keySet() AND Id NOT IN: incomingLeadIdSet];
                                
            system.debug('CPduplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(CP_Lead__c dupCPLead: duplicateLeadList) {
                    if(!duplicateMapMobileWithProject.containsKey(dupCPLead.Mobile__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(dupCPLead);
                        duplicateMapMobileWithProject.put(dupCPLead.Mobile__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c, newLeadList);
                    } else {
                        duplicateMapMobileWithProject.get(dupCPLead.Mobile__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c).add(dupCPLead);
                    }
                }
            }
            
            for(String mobileWithProject: incomingLeadMobileWithProjectMap.keySet()) {
                if(duplicateMapMobileWithProject.containsKey(mobileWithProject)) {
                    for(CP_Lead__c l: incomingLeadMobileWithProjectMap.get(mobileWithProject)) {
                        leadDuplicateMapMobileWithProject.put(l, duplicateMapMobileWithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return leadDuplicateMapMobileWithProject;
    }
    
    public static Map<CP_Lead__c, List<CP_Lead__c>> getCPleadDuplicateCheckByPhoneWithProject(List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<CP_Lead__c>> leadDuplicateMapPhoneWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadPhoneMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadPhoneWithProjectMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> duplicateMapPhoneWithProject = new Map<String, List<CP_Lead__c>>();
        List<CP_Lead__c> duplicateLeadList = new List<CP_Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadPhoneMap = getIncomingCPLeadMap('Phone', leadList);
        incomingLeadPhoneWithProjectMap = getIncomingCPLeadWithProjectMap('Phone', leadList);
        incomingLeadIdSet = getCPLeadIdSet(leadList);
        
        if(!incomingLeadPhoneMap.isEmpty() && incomingLeadPhoneMap != null) {
            duplicateLeadList = [Select Id, CreatedDate, CP_Project__c, OwnerId, Owner.FirstName, Owner.LastName, Name, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Channel_Partner_Name__c from CP_Lead__c 
                                 where Phone__c IN: incomingLeadPhoneMap.keySet() AND Id NOT IN: incomingLeadIdSet];
                                
            system.debug('CPduplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(CP_Lead__c dupCPLead: duplicateLeadList) {
                    if(!duplicateMapPhoneWithProject.containsKey(dupCPLead.Phone__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(dupCPLead);
                        duplicateMapPhoneWithProject.put(dupCPLead.Phone__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c, newLeadList);
                    } else {
                        duplicateMapPhoneWithProject.get(dupCPLead.Phone__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c).add(dupCPLead);
                    }
                }
            }
            
            for(String mobileWithProject: incomingLeadPhoneWithProjectMap.keySet()) {
                if(duplicateMapPhoneWithProject.containsKey(mobileWithProject)) {
                    for(CP_Lead__c l: incomingLeadPhoneWithProjectMap.get(mobileWithProject)) {
                        leadDuplicateMapPhoneWithProject.put(l, duplicateMapPhoneWithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return leadDuplicateMapPhoneWithProject;
    }
    
     public static Map<CP_Lead__c, List<CP_Lead__c>> getCPleadDuplicateCheckByEmailWithProject(List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<CP_Lead__c>> leadDuplicateMapEmailWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadEmailMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadEmailWithProjectMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> duplicateMapEmailWithProject = new Map<String, List<CP_Lead__c>>();
        List<CP_Lead__c> duplicateLeadList = new List<CP_Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadEmailMap = getIncomingCPLeadMap('Email', leadList);
        incomingLeadEmailWithProjectMap = getIncomingCPLeadWithProjectMap('Email', leadList);
        incomingLeadIdSet = getCPLeadIdSet(leadList);
        
        if(!incomingLeadEmailMap.isEmpty() && incomingLeadEmailMap != null) {
            duplicateLeadList = [Select Id, CreatedDate, CP_Project__c, OwnerId, Owner.FirstName, Owner.LastName, Name, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Channel_Partner_Name__c from CP_Lead__c 
                                 where Email__c IN: incomingLeadEmailMap.keySet() AND Id NOT IN: incomingLeadIdSet];
                                
            system.debug('CPduplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(CP_Lead__c dupCPLead: duplicateLeadList) {
                    if(!duplicateMapEmailWithProject.containsKey(dupCPLead.Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(dupCPLead);
                        duplicateMapEmailWithProject.put(dupCPLead.Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c, newLeadList);
                    } else {
                        duplicateMapEmailWithProject.get(dupCPLead.Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c).add(dupCPLead);
                    }
                }
            }
            
            for(String mobileWithProject: incomingLeadEmailWithProjectMap.keySet()) {
                if(duplicateMapEmailWithProject.containsKey(mobileWithProject)) {
                    for(CP_Lead__c l: incomingLeadEmailWithProjectMap.get(mobileWithProject)) {
                        leadDuplicateMapEmailWithProject.put(l, duplicateMapEmailWithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return leadDuplicateMapEmailWithProject;
    }
    
     public static Map<CP_Lead__c, List<CP_Lead__c>> getCPleadDuplicateCheckByAlternateEmailWithProject(List<CP_Lead__c> leadList) {
        Map<CP_Lead__c, List<CP_Lead__c>> leadDuplicateMapPhoneWithProject = new Map<CP_Lead__c, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadPhoneMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> incomingLeadPhoneWithProjectMap = new Map<String, List<CP_Lead__c>>();
        Map<String, List<CP_Lead__c>> duplicateMapPhoneWithProject = new Map<String, List<CP_Lead__c>>();
        List<CP_Lead__c> duplicateLeadList = new List<CP_Lead__c>();
        Set<Id> incomingLeadIdSet = new Set<Id>();
        
        incomingLeadPhoneMap = getIncomingCPLeadMap('Alternate Email', leadList);
        incomingLeadPhoneWithProjectMap = getIncomingCPLeadWithProjectMap('Alternate Email', leadList);
        incomingLeadIdSet = getCPLeadIdSet(leadList);
        
        if(!incomingLeadPhoneMap.isEmpty() && incomingLeadPhoneMap != null) {
            duplicateLeadList = [Select Id, CreatedDate, CP_Project__c, OwnerId, Owner.FirstName, Owner.LastName, Name, Mobile__c, Phone__c, Email__c, Alternate_Email__c, Channel_Partner_Name__c from CP_Lead__c 
                                 where Alternate_Email__c IN: incomingLeadPhoneMap.keySet() AND Id NOT IN: incomingLeadIdSet];
                                
            system.debug('CPduplicateLeadList: '+duplicateLeadList);
            
            if(!duplicateLeadList.isEmpty() && duplicateLeadList != null) {
                for(CP_Lead__c dupCPLead: duplicateLeadList) {
                    if(!duplicateMapPhoneWithProject.containsKey(dupCPLead.Alternate_Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(dupCPLead);
                        duplicateMapPhoneWithProject.put(dupCPLead.Alternate_Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c, newLeadList);
                    } else {
                        duplicateMapPhoneWithProject.get(dupCPLead.Alternate_Email__c+'-'+dupCPLead.Channel_Partner_Name__c+'-'+dupCPLead.CP_Project__c).add(dupCPLead);
                    }
                }
            }
            
            for(String mobileWithProject: incomingLeadPhoneWithProjectMap.keySet()) {
                if(duplicateMapPhoneWithProject.containsKey(mobileWithProject)) {
                    for(CP_Lead__c l: incomingLeadPhoneWithProjectMap.get(mobileWithProject)) {
                        leadDuplicateMapPhoneWithProject.put(l, duplicateMapPhoneWithProject.get(mobileWithProject));
                    }
                }
            }
        }
        return leadDuplicateMapPhoneWithProject;
    }
    
    public static Map<String, List<CP_Lead__c>> getIncomingCPLeadMap(String Type, List<CP_Lead__c> leadList) {
        Map<String, List<CP_Lead__c>> incomingLeadMap = new Map<String, List<CP_Lead__c>>();
        
        if(Type.equalsIgnoreCase('Mobile') || Type.equalsIgnoreCase('Phone')) {
            for(CP_Lead__c l: leadList) {
                if(l.Mobile__c != null) {
                    if(!incomingLeadMap.containsKey(l.Mobile__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Mobile__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Mobile__c).add(l);
                    }
                }
            
                if(l.Phone__c != null) {
                    if(!incomingLeadMap.containsKey(l.Phone__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Phone__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Phone__c).add(l);
                    }
                }
            }
        }  
        if(Type.equalsIgnoreCase('Email') || Type.equalsIgnoreCase('Alternate Email')) {
            for(CP_Lead__c l: leadList) {
                if(l.Email__c != null) {
                    if(!incomingLeadMap.containsKey(l.Email__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Email__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Email__c).add(l);
                    }
                }
            
                if(l.Alternate_Email__c != null) {
                    if(!incomingLeadMap.containsKey(l.Alternate_Email__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Alternate_Email__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Alternate_Email__c).add(l);
                    }
                }
            }
        }
        return incomingLeadMap;
    }

    public static Map<String, List<CP_Lead__c>> getIncomingCPLeadWithProjectMap(String Type, List<CP_Lead__c> leadList) {
        Map<String, List<CP_Lead__c>> incomingLeadWithProjectMap = new Map<String, List<CP_Lead__c>>();
        
        if(Type.equalsIgnoreCase('Mobile') || Type.equalsIgnoreCase('Phone')) {
            for(CP_Lead__c l: leadList) {
                if(l.Mobile__c != null) {
                    if(!incomingLeadWithProjectMap.containsKey(l.Mobile__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadWithProjectMap.put(l.Mobile__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c, newLeadList);
                    } else {
                        incomingLeadWithProjectMap.get(l.Mobile__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c).add(l);
                    }
                }
                if(l.Phone__c != null) {
                    if(!incomingLeadWithProjectMap.containsKey(l.Phone__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadWithProjectMap.put(l.Phone__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c, newLeadList);
                    } else {
                        incomingLeadWithProjectMap.get(l.Phone__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c).add(l);
                    }
                }
            }
        }
        if(Type.equalsIgnoreCase('Email') || Type.equalsIgnoreCase('Alternate Email')) {
            for(CP_Lead__c l: leadList) {
                if(l.Email__c != null) {
                    if(!incomingLeadWithProjectMap.containsKey(l.Email__c +'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadWithProjectMap.put(l.Email__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c, newLeadList);
                    } else {
                        incomingLeadWithProjectMap.get(l.Email__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c).add(l);
                    }
                }
                if(l.Alternate_Email__c != null) {
                    if(!incomingLeadWithProjectMap.containsKey(l.Alternate_Email__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c)) {
                        List<CP_Lead__c> newLeadList = new List<CP_Lead__c>();
                        newLeadList.add(l);
                        incomingLeadWithProjectMap.put(l.Alternate_Email__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c, newLeadList);
                    } else {
                        incomingLeadWithProjectMap.get(l.Alternate_Email__c+'-'+l.Channel_Partner_Name__c+'-'+l.CP_Project__c).add(l);
                    }
                }
            }
        }
        
        return incomingLeadWithProjectMap;
    }
    
    /*-----------------------------------Master Method For CP Account End--------------------------------------------*/

    
    public static Map<String, List<Lead__c>> getIncomingLeadMap(String Type, List<Lead__c> leadList) {
        Map<String, List<Lead__c>> incomingLeadMap = new Map<String, List<Lead__c>>();
        
        if(Type.equalsIgnoreCase('Primary Mobile') || Type.equalsIgnoreCase('Secondary Mobile')) {
            for(Lead__c l: leadList) {
                if(l.Mobile__c != null) {
                    if(!incomingLeadMap.containsKey(l.Mobile__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Mobile__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Mobile__c).add(l);
                    }
                }
                if(l.Alternate_Mobile__c != null) {
                    if(!incomingLeadMap.containsKey(l.Alternate_Mobile__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Alternate_Mobile__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Alternate_Mobile__c).add(l);
                    }
                }
            }
        } else if(Type.equalsIgnoreCase('Primary Email') || Type.equalsIgnoreCase('Secondary Email')) {
            for(Lead__c l: leadList) {
                if(l.Email__c != null) {
                    if(!incomingLeadMap.containsKey(l.Email__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Email__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Email__c).add(l);
                    }
                }
                if(l.Alternate_Email__c != null) {
                    if(!incomingLeadMap.containsKey(l.Alternate_Email__c)) {
                        List<Lead__c> newLeadList = new List<Lead__c>();
                        newLeadList.add(l);
                        incomingLeadMap.put(l.Alternate_Email__c, newLeadList);
                    } else {
                        incomingLeadMap.get(l.Alternate_Email__c).add(l);
                    }
                }
            }
        }
        return incomingLeadMap;
    }
    
    public static Map<String, List<Account>> getIncomingAccountMap(String Type, List<Account> accountList) {
        Map<String, List<Account>> incomingAccountMap = new Map<String, List<Account>>();
        
        if(Type.equalsIgnoreCase('Primary Mobile') || Type.equalsIgnoreCase('Secondary Mobile')) {
            for(Account a: accountList) {
                if(a.PersonMobilePhone != null) {
                    if(!incomingAccountMap.containsKey(a.PersonMobilePhone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.PersonMobilePhone, newAccountList);
                    } else {
                        incomingAccountMap.get(a.PersonMobilePhone).add(a);
                    }
                }
                if(a.Phone != null) {
                    if(!incomingAccountMap.containsKey(a.Phone)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.Phone, newAccountList);
                    } else {
                        incomingAccountMap.get(a.Phone).add(a);
                    }
                }
            }
        } else if(Type.equalsIgnoreCase('Primary Email') || Type.equalsIgnoreCase('Secondary Email')) {
            for(Account a: accountList) {
                if(a.PersonEmail != null) {
                    if(!incomingAccountMap.containsKey(a.PersonEmail)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.PersonEmail, newAccountList);
                    } else {
                        incomingAccountMap.get(a.PersonEmail).add(a);
                    }
                }
                if(a.Alternate_Email__c != null) {
                    if(!incomingAccountMap.containsKey(a.Alternate_Email__c)) {
                        List<Account> newAccountList = new List<Account>();
                        newAccountList.add(a);
                        incomingAccountMap.put(a.Alternate_Email__c, newAccountList);
                    } else {
                        incomingAccountMap.get(a.Alternate_Email__c).add(a);
                        
                    }
                }
            }
        } else {
            
        }
        return incomingAccountMap;
    }
    
    public static Map<Opportunity__c, List<Opportunity__c>> duplicationCheckOpportunity(List<Opportunity__c> opportunityList) {
        Map<Opportunity__c, List<Opportunity__c>> oppDuplicateMap = new Map<Opportunity__c, List<Opportunity__c>>();
        Map<String, List<Opportunity__c>> incomingOpportunityAccountMap = new Map<String, List<Opportunity__c>>();
        Map<String, List<Opportunity__c>> incomingOpportunityAccountWithProjectMap = new Map<String, List<Opportunity__c>>();
        Map<String, List<Opportunity__c>> duplicateMapOppotunityWithProject = new Map<String, List<Opportunity__c>>();
        List<Opportunity__c> duplicateOpportunityList = new List<Opportunity__c>();
        Set<Id> incomingOpportunityIdSet = new Set<Id>();
        
        for(Opportunity__c op: opportunityList) {
            if(!incomingOpportunityAccountMap.containsKey(op.Account__c)) {
                List<Opportunity__c> newOppList = new List<Opportunity__c>();
                newOppList.add(op);
                incomingOpportunityAccountMap.put(op.Account__c, newOppList);
            } else {
                incomingOpportunityAccountMap.get(op.Account__c).add(op);
            }
            if(!incomingOpportunityAccountWithProjectMap.containsKey(op.Account__c+'-'+op.Project__c)) {
                List<Opportunity__c> newOppList = new List<Opportunity__c>();
                newOppList.add(op);
                incomingOpportunityAccountWithProjectMap.put(op.Account__c+'-'+op.Project__c, newOppList);
            } else {
                incomingOpportunityAccountWithProjectMap.get(op.Account__c+'-'+op.Project__c).add(op);
            }
            if(op.Id != null)
                incomingOpportunityIdSet.add(op.Id);
        }
        
        if(!incomingOpportunityAccountMap.isEmpty() && incomingOpportunityAccountMap != null) {
            duplicateOpportunityList = [Select Id, Name,Stage__c, Account__c, Is_Active__c, Project__c, Project__r.Name, Is_Booked__c, OwnerId, Owner.Name from Opportunity__c
                                        where Account__c IN: incomingOpportunityAccountMap.keySet() AND Id NOT IN: incomingOpportunityIdSet AND Is_Booked__c = false];
            system.debug('duplicateOpportunityList: '+duplicateOpportunityList);
            
            if(!duplicateOpportunityList.isEmpty() && duplicateOpportunityList != null) {
                for(Opportunity__c dupOpp: duplicateOpportunityList) {
                    if(!duplicateMapOppotunityWithProject.containsKey(dupOpp.Account__c+'-'+dupOpp.Project__c)) {
                        List<Opportunity__c> newOppList = new List<Opportunity__c>();
                        newOppList.add(dupOpp);
                        duplicateMapOppotunityWithProject.put(dupOpp.Account__c+'-'+dupOpp.Project__c, newOppList);
                    } else {
                        duplicateMapOppotunityWithProject.get(dupOpp.Account__c+'-'+dupOpp.Project__c).add(dupOpp);
                    }
                }
            }
            
            for(String oppWithProject: incomingOpportunityAccountWithProjectMap.keySet()) {
                if(duplicateMapOppotunityWithProject.containsKey(oppWithProject)) {
                    for(Opportunity__c opp: incomingOpportunityAccountWithProjectMap.get(oppWithProject)) {
                        oppDuplicateMap.put(opp, duplicateMapOppotunityWithProject.get(oppWithProject));
                    }
                }
            }
        }
        return oppDuplicateMap;
    }
    
    public static Set<Id> getLeadIdSet(List<Lead__c> leadList) {
        Set<Id> leadIdSet = new Set<Id>();
        
        for(Lead__c l: leadList) {
            leadIdSet.add(l.Id);
        }
        return leadIdSet;
    }
    
    public static Set<Id> getAccountIdSet(List<Lead__c> leadList) {
        Set<Id> accountIdSet = new Set<Id>();
        
        for(Lead__c l: leadList) {
            if(l.IsConverted__c && l.Converted_Account__c != null) {
            	accountIdSet.add(l.Converted_Account__c);
            }
        }
        return accountIdSet;
    }
    
    public static Set<Id> getAccountIdSet(List<Account> accountList) {
        Set<Id> accountIdSet = new Set<Id>();
        
        for(Account a: accountList) {
            accountIdSet.add(a.Id);
        }
        return accountIdSet;
    }
    
    // Wrapper for duplicate details //
    public class duplicateWrapper {
        public String objectType {get;set;}
        public Lead__c dupLead {get;set;}
        public Account dupAccount {get;set;}
        public CP_Lead__c dupCPLead {get;set;}

        
        public duplicateWrapper(String type, Lead__c l, Account a) {
            this.objectType = type;
            this.dupLead = l;
            this.dupAccount = a;
        }
        public duplicateWrapper(String type, CP_Lead__c cp){
            this.objectType = type;
            this.dupCPLead = cp;
        }
        public duplicateWrapper(String type, Account acc) {
            this.objectType = type;
            this.dupAccount = acc;
        }
    }
}