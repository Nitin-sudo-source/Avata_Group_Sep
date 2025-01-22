@isTest
public class TestEx_KnowledgeArticleController {
    @isTest
    static void testGetQuestionsAnswers() {
        Knowledge_Articles__c testArticle = new Knowledge_Articles__c(
            Article_Type__c = 'CP Portal',
            Question_No__c = 1,
            Question_Text__c = 'Test Question',
            Answer__c = 'Test Answer'
        );
        insert testArticle;
        
        Test.startTest();
        List<Ex_KnowledgeArticleController.questionsAnswers> result = Ex_KnowledgeArticleController.getQuestionsAnswers();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        Ex_KnowledgeArticleController.questionsAnswers wrapper = result[0];
        System.assertEquals(1, wrapper.getQueno);
        System.assertEquals('Test Question', wrapper.queName);
        System.assertEquals('Test Answer', wrapper.queAns);
    }
}