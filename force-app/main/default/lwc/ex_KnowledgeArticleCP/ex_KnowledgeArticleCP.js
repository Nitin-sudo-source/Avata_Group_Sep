import { LightningElement,track, wire } from 'lwc';
import KnowledgeAirticleIcon1 from "@salesforce/resourceUrl/KnowledgeAirticleIcon";
import KnowledgeAirticleIcon2 from "@salesforce/resourceUrl/KnowledgeAirticleIcon2";
import getQuestionsAnswers from '@salesforce/apex/Ex_KnowledgeArticleController.getQuestionsAnswers';


export default class Ex_KnowledgeArticleCP extends LightningElement {
    KnowledgeAirticleIcon1 = KnowledgeAirticleIcon1 + '/greaterthanicon.png'
    KnowledgeAirticleIcon2 = KnowledgeAirticleIcon2 + '/subtract-26.png'
    @track qNo = 'que';
    @track hreflink = '#que';

    @track getQuestionAnswerWrapper = [];

    @wire(getQuestionsAnswers)
    getQuestionsAnswerswiredData({ error, data }) {
      if (data) {
        console.log('getQuestionsAnswers:',JSON.stringify(data));
        this.getQuestionAnswerWrapper = data;
        } else if (error) {
        console.error('Error:', error);
      }
    }

    @track isOpen = false;
    @track openIndex = -1;

    toggleAccordion(event) {
        alert('open: '+ event.target.dataset.qno);
        
    }

}