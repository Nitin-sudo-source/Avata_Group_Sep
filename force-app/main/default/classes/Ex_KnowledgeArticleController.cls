//-------------------------------------------//
//  Client: Satyam Developers
//  Created By: Exceller Consultancy
//  Created Date: 05-1-2024
//-------------------------------------------//

public with sharing class  Ex_KnowledgeArticleController {
    
    @AuraEnabled(cacheable=true)
    public static List<questionsAnswers> getQuestionsAnswers(){
        List<questionsAnswers> QAnsWrapperList = new List<questionsAnswers>();
        List<Knowledge_Articles__c> queansList = new List<Knowledge_Articles__c>();
        queansList = [Select Id,Article_Type__c,Question_No__c,Question_Text__c,Answer__c,hreflink__c from Knowledge_Articles__c order by Question_No__c ASC ];
        if(!queansList.isEmpty() && queansList != null){
            for(Knowledge_Articles__c q : queansList){
                QAnsWrapperList.add(new questionsAnswers(q.Question_No__c,q.Question_Text__c,q.Answer__c,q.hreflink__c)); 
            }
        }
        if(!QAnsWrapperList.isEmpty() && QAnsWrapperList != null){
            return QAnsWrapperList;
        }else{
            return null;
        }
        
    }
    
    public class questionsAnswers{
        @AuraEnabled
        public Decimal getQueno {get;set;}
        @AuraEnabled
        public String queName {get;set;}
        @AuraEnabled
        public String queAns {get;set;}
        @AuraEnabled
        public String href {get;set;}
        
        public questionsAnswers(Decimal getQueno,String queName,String queAns,String href){
            this.getQueno = getQueno;
            this.queName = queName;
            this.queAns = queAns;
            this.href = href;
            
        }
    }
    
}