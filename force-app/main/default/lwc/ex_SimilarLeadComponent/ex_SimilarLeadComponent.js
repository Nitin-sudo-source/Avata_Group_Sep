import { LightningElement, wire, track,api } from 'lwc';
import getLeadData from '@salesforce/apex/Ex_ShowSimilarLeadController.getLeadData';

export default class Ex_SimilarLeadComponent extends LightningElement {
    @track getLeadInfo = [];
    @api recordId;
    @track showError = '';
    @track isShow = false;


    @wire(getLeadData , {recordId: '$recordId'}) 
    getLeadDataWired({ data, error }) {
        if (data != null) {
            this.getLeadInfo = data
            console.log('data: ' + JSON.stringify(this.getLeadInfo));
            if(this.getLeadInfo.length > 0){
                this.isShow = true;
            }else{
                this.isShow = false;
            }
        } else if (data == null || data == undefined || this.getLeadInfo.length == 0) {
            console.log('getLeadInfo: ' + JSON.stringify(this.getLeadInfo));
            this.showError = 'No Similar Lead Found ';
            this.isShow = false;
        }
        else if (error) {
            console.log('error: ' + JSON.stringify(error));
            this.showError = 'No Similar Lead Found ';

        }
    }
    
    viewRecord(event){   
        const viewRecord = event.currentTarget.dataset.id;
        console.log('viewRecord: '+viewRecord);
        
         var link = document.createElement('a');

        if(viewRecord) {
            const url = '/' + viewRecord;
            link.href = url;
            link.target = '_blank';
            link.click();
         }
    }
}