import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import DeleteTemplate from '@salesforce/apex/Ex_DeleteWhatsappTemplate.DeleteTemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_DeleteWhatsappTemplate extends NavigationMixin(LightningElement) {

    @track isModalOpen = true;
    @track loading = false;
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    connectedCallback() {
        this.openModal();
    }

    openModal() {
        document.body.classList.add('modal-open'); // Add class to body to prevent scrolling
    }

    closeModal() {
        setTimeout(() => {
            this.navigateToListView();
        }, 500);
    }

    handleConfirm() {
        this.loading = true;
        DeleteTemplate({recId: this._recordId})
        .then((result) => {
            console.log('OUTPUT : ',result);
            this.loading = false;
            if(result == 'success'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Whatsapp Template Deleted successfully.',
                        variant: 'success'
                    })
                );

                this.closeModal();

            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occured Please Contact System Administrator.',
                        variant: 'error'
                    })
                );
                this.closeModal();
            }
        })
        .catch((error) => {
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Occured.',
                    variant: 'error'
                })
            );
            console.log('OUTPUT : ',error);
            console.log('OUTPUT : ',JSON.stringify(error));
        })
    }

    handleCancel(){
        Location.replace('/'+ this._recordId)
    }

    navigateToListView() {
        // Define the list view ID of the WhatsApp Template object

        // Navigate to the list view
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'WhatsApp_Template__c',
                actionName: 'list'
            }
        });
    }

}