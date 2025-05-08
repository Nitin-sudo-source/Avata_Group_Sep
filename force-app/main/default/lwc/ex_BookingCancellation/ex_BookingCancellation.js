import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchBooking from '@salesforce/apex/Ex_BookingCancellationHandler.fetchBooking';

export default class Ex_BookingCancellation extends LightningElement {
    @api recordId;
    @track cancel = '';
    @track reason = '';
    @track amount = '';
    @track uploadedFiles = [];
    @track showfilename = '';
    @track isSpinner = false;
    @track hasValidationError = true;

    @track showCancelError = false;
    @track showAmountError = false;
    @track showReasonError = false;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    bookObject = { 'sObjectType': 'Booking__c' };

    connectedCallback() {
        this.validateForm(); // Ensure validation state is set on load
    }

    handleCancelChange(event) {
        this.cancel = event.detail.value;
        this.showCancelError = !this.cancel;
        this.validateForm();
    }

    handleReasonChange(event) {
        this.reason = event.detail.value;
        this.showReasonError = !this.reason;
        this.validateForm();
    }

    onchnageamount(event) {
        this.amount = event.detail.value;
        this.showAmountError = !this.amount || isNaN(this.amount);
        this.validateForm();
    }

    handleUploadFinished(event) {
        this.uploadedFiles = event.detail.files;
        this.showfilename = this.uploadedFiles.map(file => file.name).join(', ');
    }

    validateForm() {
        this.showCancelError = !this.cancel;
        this.showAmountError = !this.amount || isNaN(this.amount);
        this.showReasonError = !this.reason;

        this.hasValidationError = this.showCancelError || this.showAmountError || this.showReasonError;
        return !this.hasValidationError;
    }

    createBookData() {
        this.validateForm();

        if (this.hasValidationError) {
            if (this.showCancelError) {
                const cancelField = this.template.querySelector('lightning-input-field[field-name="Cancellation_Type__c"]');
                if (cancelField) cancelField.focus();
            } else if (this.showAmountError) {
                const amountField = this.template.querySelector('lightning-input[data-formfield="Refund_Amount__c"]');
                if (amountField) amountField.focus();
            } else if (this.showReasonError) {
                const reasonField = this.template.querySelector('lightning-input[data-formfield="Cancellation_Remark__c"]');
                if (reasonField) reasonField.focus();
            }

            this.showToast('Error', 'Please fill all required fields with valid values', 'error');
            return;
        }

        this.bookObject.Cancellation_Remark__c = this.reason;
        this.bookObject.Refund_Amount__c = this.amount;
        this.bookObject.Cancellation_Type__c = this.cancel;
        this.bookObject.Id = this.recordId;

        this.isSpinner = true;

        fetchBooking({
            dataVal: this.bookObject,
            ctype: this.cancel,
            amt: this.amount,
            remarks: this.reason
        })
        .then((result) => {
            if (result === 'success') {
                this.showToast('Success', 'Cancellation request submitted for approval', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
                setTimeout(() => {
                    window.location.href = '/' + this.recordId;
                }, 1000);
            } else {
                this.showToast('Error', result.startsWith('error:') ? result.substring(7) : result, 'error');
                this.isSpinner = false;
            }
        })
        .catch((error) => {
            console.error('Error:', error);
            this.showToast('Error', 'An error occurred while processing your request', 'error');
            this.isSpinner = false;
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        }));
    }
}