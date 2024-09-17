import { LightningElement, track, api, wire } from 'lwc';
import getSVRecord from '@salesforce/apex/Ex_SMAssignmentController.getSVRecord';
import getAllSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getAllSalesManager';
import checkUserAvailability from '@salesforce/apex/Ex_SMAssignmentController.checkUserAvailability';
import assignSalesManager from '@salesforce/apex/Ex_SMAssignmentController.assignSalesManager';
import getPreferredSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getPreferredSalesManager';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_SMAssignment extends NavigationMixin(LightningElement) {

    

    @track showSourcePage = false;
    @track showotherDetails = false;
    @track showAssignmentDetails = false;
    @track svWrapper = { sv: {} };
    @track getSVWrapperList = [];
    @track showChannelPartner = false;
    @track showReferenceName = false;
    @track isSourceNotEditable = false;


    //SM Assignment Variable
    @track disabledAssignButton = false;
    @api recordId;
    @track svRecord;
    @track getAllSMData = [];
    @track getPreferredSMArray = [];
    @track userId = '';
    @track salesManager;
    @track isSMAssign;
    @track IsSMAlreadyAssign = false;
    @track showMsg = '';
    @track noSMPresent = false;
    @track showPrefferedSM = false;
    @track isSpinner = false;


    connectedCallback() {
        const urlSearchParams = new URLSearchParams(window.location.search);
        this.recordId = urlSearchParams.get("recordId");
        if (this.recordId != null) {
            this.getSVData();
            //this.getSVWrapper();
            this.showAssignmentDetails = true;
        }
    }
    

    getSVData() {
        getSVRecord({ recordId: this.recordId })
            .then((data) => {
                if (data) {
                    this.svRecord = data;
                    console.log('svRecord: ' + JSON.stringify(this.svRecord));
                    if (this.svRecord.Is_Sales_Manager_Assigned__c == true && (this.svRecord.Sales_Manager__c != null || this.svRecord.Sales_Manager__c != '')) {
                        this.IsSMAlreadyAssign = true;
                    }
                    if (this.svRecord != null) {
                        this.getALLSM();
                        this.getPreferredSM();
                    }

                    this.error = undefined;
                } else {
                    this.error = error;
                    this.svRecord = undefined;
                }
            })
    }

    getALLSM() {
        getAllSalesManager({ svRecord: this.svRecord })
            .then((result) => {
                if (result != null) {
                    this.getAllSMData = result.map((user, index) => {
                        return {
                            ...user,
                            index: index + 1
                        }
                    });
                    if (this.getAllSMData.Availability__c == false) {
                        this.disabledAv = this.getAllSMData.Availability__c;
                    }

                    console.log('getAllSMData: ' + JSON.stringify(this.getAllSMData));
                }


            }).catch(error => {
                this.error = error;
                console.log('error getAllSMData: ' + JSON.stringify(this.error));
            })
    }

    getTeamMemberUserAvailability() {
        checkUserAvailability({ userId: this.userId })
            .then((result) => {
                this.salesManager = result;
                console.log('salesManager: ' + JSON.stringify(this.salesManager));
                this.assignSM();
            }).catch(error => {
                this.error = error;
                console.log('error salesManager: ' + JSON.stringify(this.error));
            })
    }

    getPreferredSM() {
        getPreferredSalesManager({ svRecord: this.svRecord })
            .then((result) => {
                if (result != null) {
                    this.getPreferredSMArray = result.map((user, index) => {
                        return {
                            ...user,
                            index: index + 1
                        }
                    });
                    if (this.getPreferredSMArray.length > 0) {
                        this.showPrefferedSM = true;
                        if (this.getPreferredSMArray.Availability__c == false) {
                            this.disabledAv = this.getPreferredSMArray.Availability__c;
                        }
                    }
                    console.log('getPreferredSMArray: ' + JSON.stringify(this.getPreferredSMArray));
                }


            }).catch(error => {
                this.error = error;
                console.log('error getPreferredSMArray: ' + JSON.stringify(this.error));
            })
    }


    assignSM() {
        this.isSpinner = true;
        assignSalesManager({ svRecord: this.svRecord, salesManager: this.salesManager })
            .then((result) => {
                this.isSMAssign = result;
                console.log('isSMAssign: ' + JSON.stringify(this.isSMAssign));
                if (this.isSMAssign == true) {
                    const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Sales Manager Assigned Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    window.location.href = '/' + this.recordId;
                    this.isSpinner = false;
                } else {
                    const toastEvent = new ShowToastEvent({
                        title: 'error',
                        message: 'Something went wrong please contact System Administrator',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                }
                return;
            }).catch(error => {
                this.error = error;
                console.log('error isSMAssign: ' + JSON.stringify(this.error));
            })
    }

    handleAssign(event) {
        this.userId = event.target.value;
        console.log('userId: ' + JSON.stringify(this.userId));
        this.getTeamMemberUserAvailability();

    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

    // callRecordPage(){
    //     const toastEvent = new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Sources Details Updated Successfully',
    //                     variant: 'success'
    //                 });
    //                 this.dispatchEvent(toastEvent);
    //                 window.location.href = '/' + this.recordId;
    //                 this.isSpinner = false;
        
    // }

}