public without Sharing class Ex_CPAccountPartnerPortal {
    @AuraEnabled
    public static List<User> createPartnerUser(String accountId) {
        Set<String> oldConEmails = new Set<String>();
        List<User> userList = new List<User>();
        Contact c = new Contact();
        
        List<Account> accList = [SELECT Id,Partner_Enabled__c, Owner_Email__c, CP_Unique_Code__c, Name FROM Account WHERE Id = :accountId ];
        List<Contact> conList = [SELECT Email FROM Contact];
        
        for (Contact con : conList) {
            oldConEmails.add(con.Email);
        }
        
        try {
            for (Account acc : accList) {
                if(acc.Owner_Email__c == null){
                    throw new AuraException('You cannot create a Partner user without providing an email address.');
                }
                else if (oldConEmails.contains(acc.Owner_Email__c)) {
                    throw new AuraException('Duplicate Email Found: ' + acc.Owner_Email__c);
                } else {
                    oldConEmails.add(acc.Owner_Email__c);
                    if (acc.Owner_Email__c != null) {
                        try {
                            List<String> fullName = acc.Name.split(' ');
                            String firstName = '';
                            String lastName = '';
                            
                            if (fullName.size() >= 2) {
                                firstName = fullName[0];
                                lastName = fullName[1];
                            } else {
                                lastName = fullName[0];
                            }
                            
                            c.FirstName = firstName;
                            c.LastName = lastName;
                            c.Email = acc.Owner_Email__c;
                            c.AccountId = acc.Id;
                            insert c ;
                            
                            String ProfileName = System.Label.CP_Profile_Name;
                            Profile pf = [SELECT Id, Name FROM Profile WHERE Name = :ProfileName LIMIT 1];
                            System.debug('pf: '+pf);
                           // String pfId = pf.Id;
                           // System.debug('pfId: '+pfId);
                            
                            User u1 = new User();
                            u1.Email = acc.Owner_Email__c;
                            u1.ProfileId = pf.Id;
                            system.debug('uu: '+u1.ProfileId);
                            u1.UserName = acc.Owner_Email__c;
                            u1.Alias = acc.CP_Unique_Code__c;
                            u1.TimeZoneSidKey = 'Asia/Kolkata';
                            u1.LocaleSidKey = 'en_US';
                            u1.EmailEncodingKey = 'UTF-8';
                            u1.LanguageLocaleKey = 'en_US';
                            u1.ContactId = c.Id;
                            u1.FirstName = firstName;
                            u1.LastName = lastName;
                            u1.CommunityNickname = acc.CP_Unique_Code__c ;
                            insert u1;
                            System.debug('u1: '+u1);
                            userList.add(u1);
                            
                            if(u1 != null){
                                accList[0].Partner_Enabled__c = true ;
                                update accList;
                            }
                        }catch (Exception e) {
                            delete c;
                            String originalMessage = e.getMessage();
                            Integer exceptionIndex = originalMessage.indexOf('EXCEPTION,');
                            if (exceptionIndex != -1) {
                                String mainMessage = originalMessage.substring(exceptionIndex + 'EXCEPTION,'.length()).trim();
                                throw new AuraException('Error while Creating User and Contact : ' +mainMessage);
                            } else {
                                throw new AuraException('Error while Creating User and Contact : '+originalMessage);
                            }
                        }
                    }
                }
            }
        } catch (AuraException e) {
            return new List<User>{new User(Id = null, UserName = + e.getMessage())};
        }
        
        return userList;
    }
}