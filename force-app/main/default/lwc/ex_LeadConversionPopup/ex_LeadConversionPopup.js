import { LightningElement , track, api,wire} from 'lwc';
import object from '@salesforce/schema/Lead__c';
import isChecked from '@salesforce/apex/Ex_LeadConversionPopup.isChecked';

export default class Ex_LeadConversionPopup extends LightningElement {
    
    @api recordId;
    @track isCheck = false;
    object = object;
   
     @wire (isChecked,{ID:'$recordId'}) retrieveCheck({data,error}){
        let checkArray = [];
        if(data){
            for(let key in data){
                checkArray.push({label:data[key],value:key})
            }
            if(checkArray.length>0)
                this.isCheck = checkArray[0].label.IsConverted__c;
            //console.log(this.isCheck);
        }else if(error){
            this.result = undefined;
        }
    }


}