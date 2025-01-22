import { LightningElement, track, api } from 'lwc';
import createPartnerUser from '@salesforce/apex/Ex_CPAccountPartnerPortal.createPartnerUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_CPAccountPartnerPortal extends LightningElement {
    @track isModalOpen = true;
    @api recordId;
    closeModal() {
        location.replace('/' + this.recordId);
    }
    handleCreatePartnerUser() {
        createPartnerUser({ accountId: this.recordId })
            .then(result => {
                console.log(JSON.stringify(result));
                if (Array.isArray(result) && result.length > 0 && result[0].Id) {
                    this.showToast('Success', 'Partner user created successfully', 'success');
                    location.replace('/' + this.recordId);
                } else {
                    const errorMessage = result[0].Username;
                    this.showToast('Error', errorMessage, 'error');
                }
            })
            .catch(error => {
                console.error(error.message);
            });
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}