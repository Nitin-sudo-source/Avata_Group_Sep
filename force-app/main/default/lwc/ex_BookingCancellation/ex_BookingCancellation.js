import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchBooking from '@salesforce/apex/Ex_BookingCancellationHandler.fetchBooking';


export default class Ex_BookingCancellation extends LightningElement {
    @api recordId;
    @track cancel;
    @track reason;
    @track amount;
    @track totalAmount;
    @track password;
    @track uploadedFiles;
    @track showfilename = '';
    @api fileName;
    @track isSpinner = false;
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    bookObject = {'sObjectType' : 'Booking__c'}
    
    handleCancelChange(event){
        this.cancel = event.detail.value;
    }
    
    handleReasonChange(event){
        this.reason = event.detail.value;
    }

    onchnageamount(event){
        this.amount = event.detail.value;

    }
    onchnagepassword(event){
        this.passchange = event.detail.value;
    }

    handleUploadFinished(event) {
        this.uploadedFiles = event.detail.files;
        console.log('this.uploadedFiles: '+this.uploadedFiles);
        this.uploadedFiles.forEach(file => {
            console.log('File Name: ' + file.name);
            this.showfilename = file.name;
        });
    
    }
    

    createBookData(){
        if (!this.template.querySelector('lightning-input[data-formfield="Cancellation_Remark__c"]').value) {
            // Show error message
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Cancellation Remark',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }
        // if(this.uploadedFiles == null){
        //     const evt = new ShowToastEvent({
        //         title: 'Error',
        //         message: 'Please upload Cancellation document signed by Sales Head, CFO & CEO',
        //         variant: 'error',
        //     });
        //     this.dispatchEvent(evt);
        //     return;
        // }
        
        this.bookObject.Cancellation_Remark__c = this.template.querySelector('lightning-input[data-formfield="Cancellation_Remark__c"]').value;
        this.bookObject.Refund_Amount__c = this.template.querySelector('lightning-input[data-formfield="Refund_Amount__c"]').value;
        this.bookObject.Cancellation_Type__c = this.cancel;
        this.bookObject.Id = this.recordId;
        this.isSpinner = true;
        fetchBooking({dataVal : this.bookObject,ctype : this.cancel ,amt :this.amount ,remarks :this.reason})
        .then((result)=>{
            console.log(result);
            if (result !== null && !isNaN(result)) {
                this.bookObject.Refund_Amount__c = result;
            }
            this.dispatchEvent(new CloseActionScreenEvent());
            window.location.href = '/' + this.recordId;

           // this.navigateToViewBookingPage();
           
            // location.replace('https://data-dream-8698--agahallsb.sandbox.lightning.force.com/lightning/r/Booking__c/'+this.recordId+'/view');
        })
        .catch((error)=>{
            console.log(error)
        });
                   
    }
   /* navigateToViewBookingPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Booking__c',
                actionName: 'view'
            },
        });
    }*/

}