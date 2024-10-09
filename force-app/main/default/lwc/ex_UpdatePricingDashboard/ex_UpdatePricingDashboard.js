import { LightningElement,api,wire,track } from 'lwc';
import getAVDetails from '@salesforce/apex/Ex_UpdateAVDetails.getAVDetails'; //updateAVChangeDetails
import updateAVChangeDetails from '@salesforce/apex/Ex_UpdateAVDetails.updateAVChangeDetails';
import saveAV from '@salesforce/apex/Ex_UpdateAVDetails.saveAV';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Ex_UpdatePricingDashboard extends LightningElement {


    @api recordId;
    @track avDetails = [];
    @track isErrormsg = '';
    @track isError = false;
    @track getUpdatedValue;
    @track getUpdatedStampValue;
    @track getUpdatedGST;
    @track getRemarks;
    @track getModifiedData = [];


    @wire(getAVDetails , { recordId: '$recordId' })
    getAVDetails({ error, data }) {
        if (data) {
            this.avDetails  = data;
            console.log('getAVDetails : '+ JSON.stringify(this.avDetails))
        } else if (error) {
            this.error = error;
        }else if(this.avDetails == undefined){
            this.isError = true; 
            this.isErrormsg = 'Something Went Wrong Please Contact System Administrator';
        }
    }

    handleUpdatedAv(event){
        this.getUpdatedValue = event.detail.value;
        console.log('You selected an handleUpdatedAv: ' + this.getUpdatedValue);
        this.handlemodified();
    }
    handleUpdatedStamp(event){
        this.getUpdatedStampValue = event.detail.value;
        console.log('You selected an getUpdatedStampValue: ' + this.getUpdatedStampValue);
        this.handlemodified();
    }
    handleUpdatedGST(event){
        this.getUpdatedGST = event.detail.value;
        console.log('You selected an handleUpdatedAv: ' + this.getUpdatedGST);
        this.handlemodified();
    }
    handleRemarks(event){
        this.getRemarks = event.detail.value;
        console.log('You selected an getRemarks: ' + this.getRemarks);
    }

    handlemodified(){
        updateAVChangeDetails({recordId: this.recordId, updatedAVvalue: this.getUpdatedValue, getUpdatedStampValue: this.getUpdatedStampValue, getUpdatedGST: this.getUpdatedGST })
        .then((result) => {
            console.log('result: '+ JSON.stringify(result));
            if(result){
                this.getModifiedData = result;
                if(this.getModifiedData.errorMsg !== null && this.getModifiedData.errorMsg !== ''){
                    this.isError = true; 
                    this.isErrormsg = 'Please Check the default value for Stamp Duty & GST value on '+ this.avDetails.bookingName +' OR Please Contact System Administrator';        
                }else{
                  this.getModifiedData = result;
            } 
        }          
        })
        .catch((error) => {
          this.error = error;
        });
    }
    
    handleSave(){
    if(this.getRemarks == undefined){
        this.showToast('Error', 'Please Enter Remarks', 'error', 'dismissible');
    }else{
        saveAV({recordId: this.recordId, updatedAVvalue: this.getModifiedData.getAvvalue,
            gstValue: this.getUpdatedGST, stampValue: this.getUpdatedStampValue,
             remarks:  this.getRemarks })
        .then((result) => {
          console.log('result: '+ result);
          if(result == true){
            this.showToast('success', 'AV Changes Successfully', 'success', 'dismissible');
            window.location.href = '/'+this.recordId ;
          }else{
            this.showToast('Error', 'Something Went Wrong Please Contact System Administrator', 'error', 'sticky');
          }
        })
        .catch((error) => {
          this.error = error;
        });
    }
    }

    showToast(title,message,variant,mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}