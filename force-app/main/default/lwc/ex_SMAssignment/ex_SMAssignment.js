import { LightningElement, api, track, wire } from 'lwc';
import getSVRecord from '@salesforce/apex/Ex_SMAssignmentController.getSVRecord';
import getAllSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getAllSalesManager';
import getAllSalesManagerTL from '@salesforce/apex/Ex_SMAssignmentController.getAllSalesManagerTL';
import checkUserAvailability from '@salesforce/apex/Ex_SMAssignmentController.checkUserAvailability';
import assignSalesManager from '@salesforce/apex/Ex_SMAssignmentController.assignSalesManager';
import reAssignSalesManager from '@salesforce/apex/Ex_SMAssignmentController.reAssignSalesManager';
import getPreferredSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getPreferredSalesManager';

export default class Ex_SMAssignment extends LightningElement {
    @api recordId;
    @track svRecord;
    @track getAllSMData = [];
    @track getAllSMTLData = [];
    @track getPreferredSMArray = [];
    @track userId = '';
    @track salesManager;
    @track isSMAssign;
    @track IsSMAlreadyAssign = false;
    @track IsSMTLReAssign = false;
    @track showMsg = '';
    @track noSMPresent = false;
    @track showPreferredSM = false;
    @track reAssignSM = false;
    @track showReAssignToggle = false;
    @track isSpinner = false;
    @track formData = {};
    @api navigateToList;

    @wire(getSVRecord, { recordId: '$recordId' })
    wiredSVRecord({ error, data }) {
        if (data) {
            this.svRecord = data;
            console.log('svRecord:', JSON.stringify(this.svRecord));

            this.IsSMAlreadyAssign = this.svRecord.SV_Count__c > 1 && this.svRecord.Sales_Manager__c;
            this.showReAssignToggle = this.IsSMAlreadyAssign;

            this.getALLSM();
            this.getPreferredSM();
        } else {
            this.error = error;
            console.error('Error fetching SV Record:', error);
        }
    }

    getALLSM() {
        getAllSalesManager({ svRecord: this.svRecord })
            .then((result) => {
                if (result) {
                    this.getAllSMData = result.map((user, index) => ({
                        ...user,
                        index: index + 1
                    }));

                    console.log('getAllSMData:', JSON.stringify(this.getAllSMData));
                }
            })
            .catch(error => {
                console.error('Error fetching Sales Managers:', error);
                this.showErrorMessage('error', error);
            });
    }

    handleSMReassign(event) {
        const { name, value, checked, type } = event.target;
        const isCheckbox = type === 'checkbox' || type === 'checkbox-button' || type === 'toggle';
        this.formData = { ...this.formData, [name]: isCheckbox ? checked : value };

        this.reAssignSM = checked;
        this.IsSMTLReAssign = checked;

        if (checked) {
            this.getALLSMTL();
        }
    }

    getALLSMTL() {
        getAllSalesManagerTL({ svRecord: this.svRecord })
            .then((result) => {
                if (result) {
                    this.getAllSMTLData = result.map((user, index) => ({
                        ...user,
                        index: index + 1
                    }));

                    console.log('getAllSMTLData:', JSON.stringify(this.getAllSMTLData));
                }
            })
            .catch(error => {
                console.error('Error fetching Sales Manager TL:', error);
                this.showErrorMessage('error', error);
            });
    }

    getTeamMemberUserAvailability() {
        checkUserAvailability({ userId: this.userId })
            .then((result) => {
                this.salesManager = result;
                console.log('Sales Manager Availability:', JSON.stringify(this.salesManager));

                this.reAssignSM ? this.reAssignSManager() : this.assignSM();
            })
            .catch(error => {
                console.error('Error checking user availability:', error);
                this.showErrorMessage('error', error);
            });
    }

    getPreferredSM() {
        getPreferredSalesManager({ svRecord: this.svRecord })
            .then((result) => {
                if (result) {
                    this.getPreferredSMArray = result.map((user, index) => ({
                        ...user,
                        index: index + 1
                    }));

                    this.showPreferredSM = this.getPreferredSMArray.length > 0;
                    console.log('getPreferredSMArray:', JSON.stringify(this.getPreferredSMArray));
                }
            })
            .catch(error => {
                console.error('Error fetching Preferred Sales Managers:', error);
                this.showErrorMessage('error', error);
            });
    }

    assignSM() {
        this.isSpinner = true;
        assignSalesManager({ svRecord: this.svRecord, salesManager: this.salesManager })
            .then((result) => {
                this.isSMAssign = result;
                console.log('Sales Manager Assigned:', result);

                this.handleAssignmentResult(result, 'Sales Manager Assigned Successfully.');
            })
            .catch(error => {
                console.error('Error assigning Sales Manager:', error);
                this.showErrorMessage('error', error);
                this.isSpinner = false;
            });
    }

    reAssignSManager() {
        this.isSpinner = true;
        reAssignSalesManager({ svRecord: this.svRecord, salesManager: this.salesManager, reAssign: this.reAssignSM })
            .then((result) => {
                this.isSMAssign = result;
                console.log('Sales TL Re-Assigned:', result);

                this.handleAssignmentResult(result, 'Sales TL Re-Assigned Successfully.');
            })
            .catch(error => {
                console.error('Error reassigning Sales Manager:', error);
                this.showErrorMessage('error', error);
                this.isSpinner = false;
            });
    }

    handleAssignmentResult(result, successMessage) {
        if (result) {
            this.showErrorMessage('success', successMessage);
            this.navigateToList('/' + this.recordId);
        } else {
            this.showErrorMessage('error', 'Something went wrong, please contact the System Administrator.');
        }
        this.isSpinner = false;
    }

    handleAssign(event) {
        this.userId = event.target.value;
        console.log('Selected User ID:', this.userId);
        this.getTeamMemberUserAvailability();
    }

    handleReAssign(event) {
        this.userId = event.target.value;
        console.log('Selected User ID for Reassignment:', this.userId);
        this.getTeamMemberUserAvailability();
    }

    handleCancel() {
        if (this.recordId) {
            this.navigateToList('/' + this.recordId);
        } else {
            console.error('Record ID is not defined');
        }
    }

    showErrorMessage(type, message) {
        this.isSpinner = false;
        this.template.querySelector('c-custom-toast').showToast(type, message, 'utility:warning', 10000);
    }
}