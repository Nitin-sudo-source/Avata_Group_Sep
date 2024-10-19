import { LightningElement, api, track, wire } from 'lwc';
import object from '@salesforce/schema/CP_Lead__c';
import isChecked from '@salesforce/apex/Ex_LeadConversionPopup.isCPLeadChecked';

export default class Ex_CPLeadVisitDonePopup extends LightningElement {

    @api recordId;
    @track isCheck = false;
    object = object;
   
     @wire (isChecked,{ID:'$recordId'}) 
     retrieveCheck({data,error}){
        let checkArray = [];
        if(data){
            for(let key in data){
                checkArray.push({label:data[key],value:key})
            }
            if(checkArray.length>0)
                this.isCheck = checkArray[0].label.CP_Lead_Stage__c;
                console.log(this.isCheck);
        }else if(error){
            console.log('error: '+error);
            this.result = undefined;
        }
    }
}