//-------------------------------------------//
//  Project: Nandi Vardhan Constructioin 
//  Created By: Exceller Consultancy
//  Created Date: 17-5-2023
//-------------------------------------------//
public class SearchPageController {
    public String strProjectId {get;set;}
    public List<SelectOption> lstProjectList {get;set;}
    public Lead__c l {get;set;}
    public List<Account> accList {get;set;}
    public List<Opportunity__c> oppList {get;set;}
    public List<Lead__c> leadList {get;set;}
    public boolean isAccount {get;set;}
    public boolean isLead {get;set;}
    public boolean isOpp {get;set;}
    public boolean isSearch {get;set;}
    public string QRProject {get;set;}
    public boolean flagQR {get;set;}
    
    public SearchPageController() {
        strProjectId = '';
        flagQR = false;
        l = new Lead__c();
        lstProjectList = new List<SelectOption >();
        QRProject = ApexPages.currentPage().getParameters().get('project');
        system.debug('project: '+ QRProject);
        List <Project__c> listPr = new List <Project__c>();
        List <User> listUr = [Select Id, Name/*Project_Name__c*/ from User where ID =: userInfo.getUserId()];
        if(QRProject != '' && QRProject != null)
        {
            listPr = [Select Id, Name from Project__c Where Id =: QRProject];
            flagQR = true;
        }
        else
        	listPr = [Select Id, Name from Project__c /*Where Name =:listUr[0].Project_Name__c*/];
        System.debug('Project ::' + listPr);
     	lstProjectList.add(new SelectOption('', '---Please Select Project---'));
        if (listPr != null && listPr.size() > 0) {
            for (Project__c Pr: listPr) {
                lstProjectList.add(new SelectOption(Pr.id, pr.name));
            }
        }         
        accList = new List<Account>();
        oppList = new List<Opportunity__c>();
        leadList = new List<Lead__c>();
        isSearch = false;
        isAccount = false;
        isLead = false;
        isOpp = false; 
    }
    
    public void search() {
        isAccount = false;
        isLead = false;
        isOpp = false; 
    
        if(l.Mobile__c != Null && l.Mobile__c != '') {
            accList = [Select Id, Name, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Owner.Name from Account 
                       where (PersonMobilePhone =: l.Mobile__c OR Phone =: l.Mobile__c) AND IsPersonAccount = true];
            system.debug('accList: '+accList);
            
            if(!accList.isEmpty()) {
                isAccount = true;
                
                oppList = [Select Id, Name, Project__c, Project__r.Name, Account__r.PersonMobilePhone, Account__r.PersonEmail, Owner.Name from Opportunity__c
                           where Account__c =: accList[0].Id AND Project__c =: strProjectId AND Is_Active__c = true];
                system.debug('oppList: '+oppList);
                
                if(!oppList.isEmpty()) {
                    isOpp = true;
                }
            } else {
                if(l.Email__c != Null && l.Email__c != '') {
                    accList = [Select Id, Name, PersonMobilePhone, Phone, PersonEmail, Alternate_Email__c, Owner.Name from Account 
                               where (PersonEmail =: l.Email__c OR Alternate_Email__c =: l.Email__c) AND IsPersonAccount = true];
                    system.debug('accList: '+accList);
                    
                    if(!accList.isEmpty()) {
                        isAccount = true;
                
                        oppList = [Select Id, Name, Project__c, Project__r.Name, Account__r.PersonMobilePhone, Account__r.PersonEmail, Owner.Name from Opportunity__c
                                   where Account__c =: accList[0].Id AND Project__c =: strProjectId AND Is_Active__c = true];
                        system.debug('oppList: '+oppList);
                        
                        if(!oppList.isEmpty()) {
                            isOpp = true;
                        }
                    }
                } 
            }
            
            if(oppList.isEmpty()) {
                leadList = [Select Id, Name, Mobile__c, Phone__c,Salutation__c, Email__c, Alternate_Email_Id__c, Project__c, Project__r.Name,Stage__c, Sub_Stage__c, Substage_Reason__c,
                                    Master_Source__c, Sub_Source__c, Sub_Source_Details__c, Lead_Source__c, Owner.Name from Lead__c
                            where (Mobile__c =: l.Mobile__c OR Phone__c =: l.Mobile__c) AND Project__c =: strProjectId AND IsConverted__c = false];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty()) {
                    isLead = true;
                } else {
                    if(l.Email__c != Null && l.Email__c != '') {
                        leadList = [Select Id, Name, Mobile__c, Phone__c,Salutation__c, Email__c, Alternate_Email_Id__c, Project__c, Project__r.Name,Stage__c, Sub_Stage__c, Substage_Reason__c,
                                    Master_Source__c, Sub_Source__c, Sub_Source_Details__c, Lead_Source__c, Owner.Name from Lead__c
                                    where (Email__c =: l.Email__c OR Alternate_Email_Id__c =: l.Email__c) AND Project__c =: strProjectId AND IsConverted__c = false];
                        system.debug('leadList: '+leadList);
                        
                        if(!leadList.isEmpty()) {
                            isLead = true;
                        }
                    }
                }
            }
        }
        isSearch = true;
    }
    
    public PageReference continueMethod() {
        if(l.Email__c == Null) {
            l.Email__c = '';
        }
        Pagereference objReference = new Pagereference('/apex/SiteVisitForm?project=' + strProjectId +'&mobile='+l.Mobile__c+ '&email='+l.Email__c+'&QR='+flagQR);
        objReference.setRedirect(true);
        return objReference;
    }
    
    public PageReference cancel() {
        Pagereference objReference = new Pagereference('/lightning/page/home');
        objReference.setRedirect(true);
        return objReference;
    }
}