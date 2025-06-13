import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitForApproval from '@salesforce/apex/Ex_ResaleBookingApproval.submitForApproval';

export default class Ex_ResaleBookingApproval extends LightningElement {
    @api recordId;
    @track comments    = '';
    @track commentError = false;
    @track isSpinner   = false;

    handleCommentChange(e) {
        this.comments     = e.target.value;
        this.commentError = false;
    }

    handleClick() {
        this.isSpinner = true;
        if (!this.comments.trim()) {
            this.commentError = true;
            this.isSpinner    = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title:   'Validation Error',
                    message: 'Please enter comments before submitting.',
                    variant: 'error'
                })
            );
            return;
        }

        submitForApproval({ recordId: this.recordId, comment: this.comments })
            .then((resp) => {
                this.isSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:   resp.success ? 'Success' : 'Error',
                        message: resp.message,
                        variant: resp.success ? 'success' : 'error'
                    })
                );
                if (resp.success) {
                    this.comments = '';
                    window.location.replace(`/${this.recordId}`);
                }
            })
            .catch((err) => {
                this.isSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:   'Error',
                        message: 'An unexpected error occurred.',
                        variant: 'error'
                    })
                );
                console.error(err);
            });
    }

    handleCancel() {
        window.location.replace(`/${this.recordId}`);
    }

    get commentClass() {
        return this.commentError ? 'textarea-error' : '';
    }
}