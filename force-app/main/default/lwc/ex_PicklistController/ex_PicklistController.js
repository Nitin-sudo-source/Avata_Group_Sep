import { LightningElement, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/PicklistValueController.getPicklistValues';

export default class Ex_PicklistController extends LightningElement {
    @track picklistValues = [];
    @track selectedValues = new Set();

    connectedCallback() {
        // Fetch the picklist values dynamically
        getPicklistValues({ objectName: 'Lead__c', fieldName: 'Age_Group__c' })
            .then((data) => {
                this.picklistValues = data;
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleButtonClick(event) {
        const value = event.target.dataset.value;
        if (this.selectedValues.has(value)) {
            this.selectedValues.delete(value);
            event.target.classList.remove('selected');
        } else {
            this.selectedValues.add(value);
            event.target.classList.add('selected');
        }
    }

    handleNext() {
        console.log('Selected Values:', Array.from(this.selectedValues));
    }

}