//-------------------------------------------//
//  Project: Unmanaged Package 
//  Created By: Priyanshu Agarkar
//  Created Date: 14-09-2024
//-------------------------------------------//
@isTest
public class TestEx_AccountHandlerServices {

    @isTest
    public static void testHandlerServices(){
        
        CP_Document__c cpd = new CP_Document__c();
        cpd.Name = 'Yes';
        cpd.Document_Required__c = 'PAN Card,RERA Competency Certificate,GST Registration Certificate,RERA Certificate';
        insert cpd;
        
        CP_Document__c cpd2 = new CP_Document__c();
        cpd2.Name = 'No';
        cpd2.Document_Required__c = 'PAN Card,RERA Competency Certificate';
        insert cpd2;
        String AccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc =  new Account();
        acc.Type = 'Analyst';
        acc.PersonMobilePhone = '9372082791';
        acc.RecordTypeId = AccountRecordTypeID;
        acc.LastName = 'Acc 1';
        insert acc;
        
        Account acc3 =  new Account();
        acc3.Type = 'Analyst';
        acc3.RecordTypeId = AccountRecordTypeID;
        acc3.PersonMobilePhone = '9372082791';
        acc3.LastName = 'Acc';
        insert acc3;

        Account acc2 =  new Account();
        acc2.Type = 'Analyst';
        acc2.Alternate_Mobile__c = '9090901212';
        acc2.RecordTypeId = AccountRecordTypeID;
        acc2.LastName = 'Cp acc 2';
        insert acc2;
        
       // update acc2;
        
        acc.Alternate_Email__c = 'newemail@gmail.com';
        update acc;
    }
}