import { LightningElement, api, track, wire } from 'lwc';
import getSVRecord from '@salesforce/apex/Ex_SMAssignmentController.getSVRecord';
import getAllSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getAllSalesManager';
import checkUserAvailability from '@salesforce/apex/Ex_SMAssignmentController.checkUserAvailability';
import assignSalesManager from '@salesforce/apex/Ex_SMAssignmentController.assignSalesManager';
import getPreferredSalesManager from '@salesforce/apex/Ex_SMAssignmentController.getPreferredSalesManager';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSVWrapper from '@salesforce/apex/Ex_GREUpdateDetails.getSVWrapper';
import updateSiteVisit from '@salesforce/apex/Ex_GREUpdateDetails.updateSiteVisit';

export default class Ex_GREUpdateDetails extends NavigationMixin(LightningElement) {



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
            // this.getSVData();
            this.getSVWrapper();
            this.showSourcePage = true;
        }
    }

    getSVWrapper() {
        this.isSpinner = true;
        getSVWrapper({ svRecordId: this.recordId })
            .then((result) => {
                this.svWrapper = result;
                this.isSpinner = false;
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));
                this.checkSource();
            }).catch(error => {
                console.log('svWrapper error: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }

    // checkSource() {
    //     console.log('insideSource: ' + JSON.stringify(this.svWrapper));
    //     var getLastSVsourceDate = '';

    //     var today = new Date().toISOString().substring(0, 10);
    //     if(this.svWrapper.sv.Project__r.TAT_Days_for_Walkin__c){
    //         if(this.svWrapper.sv.Opportunity__r.Fist_SV_Date__c){
    //             var lastSVsourceDateObj = new Date(this.svWrapper.sv.Opportunity__r.Fist_SV_Date__c);
    //         lastSVsourceDateObj.setDate(lastSVsourceDateObj.getDate() + this.tatDays);
    //         getLastSVsourceDate = lastSVsourceDateObj.toISOString().substring(0, 10);
    //         console.log('getLastSVsourceDateWithTATDAYS: ' + getLastSVsourceDate);
    //         }
    //     }

    //     if (getLastSVsourceDate != null && getLastSVsourceDate != '' && getLastSVsourceDate >= today) {
    //         this.isSourceNotEditable = true;
    //     }
    //     if(this.svWrapper.sv.Is_Preregister_Visit__c || this.svWrapper.sv.Is_Preregister_Visit__c != undefined){
    //         this.isSourceNotEditable = true;
    //     }

    //     if (this.svWrapper.sv.Lead_Source__c === 'Channel Partner' && this.svWrapper.sv.Lead_Sub_Source__c === 'Channel Partner') {
    //        // this.searchPlaceholder = 'Search Channel Partner';
    //         this.showChannelPartner = true;
    //         this.showReferenceName = false;

    //     } else if (this.svWrapper.sv.Lead_Source__c === 'Reference' && this.svWrapper.sv.Lead_Sub_Source__c === 'Reference') {
    //        // this.svWrapper.sv.Channel_Partner__c = '';
    //         this.showReferenceName = true;
    //         this.showChannelPartner = false;
    //         // this.getSVWrapperList = {
    //         //     ...this.svWrapper.sv,
    //         //     [fieldName]: value
    //         // };
    //     } else {
    //         this.showChannelPartner = false;
    //         this.showReferenceName = false;
    //     }
    //     console.log('isSourceNotEditable: '+this.isSourceNotEditable);
    // }

    checkSource() {
    console.log('insideSource: ' + JSON.stringify(this.svWrapper));

    var getLastSVsourceDate = '';
    var today = new Date().toISOString().substring(0, 10); // Current date in YYYY-MM-DD format

    // Ensure tatDays is defined (TAT_Days_for_Walkin__c from Project)
    this.tatDays = this.svWrapper.sv.Project__r.TAT_Days_for_Walkin__c || 0;

    // Debugging logs
    console.log('TAT_Days_for_Walkin__c: ', this.tatDays);
    console.log('Fist_SV_Date__c: ', this.svWrapper.sv.Opportunity__r.Fist_SV_Date__c);

    // Calculate Last Source Date with TAT Days (First SV Date + TAT_Days_for_Walkin__c)
    if (this.tatDays > 0 && this.svWrapper.sv.Opportunity__r.Fist_SV_Date__c) {
        var firstSVDate = new Date(this.svWrapper.sv.Opportunity__r.Fist_SV_Date__c);
        firstSVDate.setDate(firstSVDate.getDate() + this.tatDays); // Add TAT days to the First SV Date
        getLastSVsourceDate = firstSVDate.toISOString().substring(0, 10); // Convert back to YYYY-MM-DD format
        console.log('Calculated getLastSVsourceDateWithTATDAYS: ' + getLastSVsourceDate);
    }

    console.log('Final getLastSVsourceDate: ' + getLastSVsourceDate);
    console.log('Today\'s Date: ' + today);

    // Make the source editable on the exact day
    if (getLastSVsourceDate && getLastSVsourceDate < today) { // Only lock if the last date is BEFORE today
        this.isSourceNotEditable = true;
    } else {
        this.isSourceNotEditable = false; // Editable on today or after getLastSVsourceDate
    }
    
    // Lock the source if it's a pre-registered visit
    if (this.svWrapper.sv.Is_Preregister_Visit__c === true) {
        this.isSourceNotEditable = true;
    }

    // Handle the visibility of Channel Partner or Reference fields
    if (this.svWrapper.sv.Lead_Source__c === 'Channel Partner' && this.svWrapper.sv.Lead_Sub_Source__c === 'Channel Partner') {
        this.showChannelPartner = true;
        this.showReferenceName = false;
    } else if (this.svWrapper.sv.Lead_Source__c === 'Reference' && this.svWrapper.sv.Lead_Sub_Source__c === 'Reference') {
        this.showReferenceName = true;
        this.showChannelPartner = false;
    } else {
        this.showChannelPartner = false;
        this.showReferenceName = false;
    }

    console.log('isSourceNotEditable: ' + this.isSourceNotEditable);
}






    handleChange(event) {
        if (event.target.name == "Address") {
            this.svWrapper.sv.City__c = event.target.city;
            this.svWrapper.sv.Street_1__c = event.target.street;
            this.svWrapper.sv.Country__c = event.target.country;
            this.svWrapper.sv.State__c = event.target.province;
            this.svWrapper.sv.Pincode__c = event.target.postalCode;
        } else {

            try {
                const fieldName = event.target ? event.target.fieldName : event.detail ? event.detail.fieldName : '';
                const value = event.target ? event.target.value : event.detail ? event.detail.value : '';

                this.getSVWrapperList = {
                    ...this.svWrapper.sv,
                    [fieldName]: value
                };
                this.svWrapper = { sv: this.getSVWrapperList };
                console.log('svWrapper: ' + JSON.stringify(this.svWrapper));

                if (this.svWrapper.sv.Lead_Source__c === 'Channel Partner' && this.svWrapper.sv.Lead_Sub_Source__c === 'Channel Partner') {
                    this.searchPlaceholder = 'Search Channel Partner';
                    this.showChannelPartner = true;
                    this.showReferenceName = false;

                } else if (this.svWrapper.sv.Lead_Source__c === 'Reference' && this.svWrapper.sv.Lead_Sub_Source__c === 'Reference') {
                    this.svWrapper.sv.Channel_Partner__c = '';
                    this.showReferenceName = true;
                    this.showChannelPartner = false;
                    this.getSVWrapperList = {
                        ...this.svWrapper.sv,
                        [fieldName]: value
                    };
                } else {
                    this.showChannelPartner = false;
                    this.showReferenceName = false;
                }


            } catch (error) {
                console.log('svWrapper error' + JSON.stringify(error));
                console.error('svWrapper error' + JSON.stringify(error));
            }
        }
        console.log('svWrapper: ' + JSON.stringify(this.svWrapper));

    }

    lookupRecord(event) {

        // Retrieve the selected record from the event detail
        const selectedRecord = event.detail.selectedRecord;
        const getObjectName = event.target.dataset.name;
        console.log('Selected Record:', JSON.stringify(selectedRecord));
        console.log('Object Name:', getObjectName);

        // Check if getObjectName and selectedRecord are defined
        if (getObjectName && selectedRecord) {
            if (getObjectName === 'Account' && selectedRecord.Id) {
                this.svWrapper.sv.Channel_Partner__c = selectedRecord.Id;
                this.searchName = selectedRecord.Name;
                alert('Selected Channel Partner ' + selectedRecord.Name);
                // this.callCPProject(this.svWrapper.sv.Channel_Partner__c, this.projectId);

                // Optionally set the display name for UI
                // this.showCP = selectedRecord.Name;
            } else if (getObjectName === 'User' && selectedRecord.Id) {
                this.svWrapper.sv.Sourcing_Manager__c = selectedRecord.Id;
                this.searchNameSourcing = selectedRecord.Name;
                alert('Selected Sourcing Name ' + selectedRecord.Name);
            }
        }
        if (getObjectName && selectedRecord === undefined) {
            if (getObjectName === 'Account') {
                this.svWrapper.sv.Channel_Partner__c = undefined;
                // alert('Selected Channel Partner ' + selectedRecord.Name);
                // Optionally set the display name for UI
                // this.showCP = selectedRecord.Name;
            } else if (getObjectName === 'User') {
                this.svWrapper.sv.Sourcing_Manager__c = undefined;
                // alert('Selected Sourcing Name ' + selectedRecord.Name);
            }

        }
        console.log('svWrapper:', JSON.stringify(this.svWrapper));
    }


    // Assignment Details Start
    // getSVData() {
    //     getSVRecord({ recordId: this.recordId })
    //         .then((data) => {
    //             if (data) {
    //                 this.svRecord = data;
    //                 console.log('svRecord: ' + JSON.stringify(this.svRecord));
    //                 // if (this.svRecord.Is_Sales_Manager_Assigned__c == true && (this.svRecord.Sales_Manager__c != null || this.svRecord.Sales_Manager__c != '')) {
    //                 //     this.IsSMAlreadyAssign = true;
    //                 // }
    //                 // if (this.svRecord != null) {
    //                 //     this.getALLSM();
    //                 //     this.getPreferredSM();
    //                 // }

    //                 this.error = undefined;
    //             } else {
    //                 this.error = error;
    //                 this.svRecord = undefined;
    //             }
    //         })
    // }

    // getALLSM() {
    //     getAllSalesManager({ svRecord: this.svRecord })
    //         .then((result) => {
    //             if (result != null) {
    //                 this.getAllSMData = result.map((user, index) => {
    //                     return {
    //                         ...user,
    //                         index: index + 1
    //                     }
    //                 });
    //                 if (this.getAllSMData.Availability__c == false) {
    //                     this.disabledAv = this.getAllSMData.Availability__c;
    //                 }

    //                 console.log('getAllSMData: ' + JSON.stringify(this.getAllSMData));
    //             }


    //         }).catch(error => {
    //             this.error = error;
    //             console.log('error getAllSMData: ' + JSON.stringify(this.error));
    //         })
    // }

    // getTeamMemberUserAvailability() {
    //     checkUserAvailability({ userId: this.userId })
    //         .then((result) => {
    //             this.salesManager = result;
    //             console.log('salesManager: ' + JSON.stringify(this.salesManager));
    //             this.assignSM();
    //         }).catch(error => {
    //             this.error = error;
    //             console.log('error salesManager: ' + JSON.stringify(this.error));
    //         })
    // }

    // getPreferredSM() {
    //     getPreferredSalesManager({ svRecord: this.svRecord })
    //         .then((result) => {
    //             if (result != null) {
    //                 this.getPreferredSMArray = result.map((user, index) => {
    //                     return {
    //                         ...user,
    //                         index: index + 1
    //                     }
    //                 });
    //                 if (this.getPreferredSMArray.length > 0) {
    //                     this.showPrefferedSM = true;
    //                     if (this.getPreferredSMArray.Availability__c == false) {
    //                         this.disabledAv = this.getPreferredSMArray.Availability__c;
    //                     }
    //                 }
    //                 console.log('getPreferredSMArray: ' + JSON.stringify(this.getPreferredSMArray));
    //             }


    //         }).catch(error => {
    //             this.error = error;
    //             console.log('error getPreferredSMArray: ' + JSON.stringify(this.error));
    //         })
    // }


    // assignSM() {
    //     this.isSpinner = true;
    //     assignSalesManager({ svRecord: this.svRecord, salesManager: this.salesManager })
    //         .then((result) => {
    //             this.isSMAssign = result;
    //             console.log('isSMAssign: ' + JSON.stringify(this.isSMAssign));
    //             if (this.isSMAssign == true) {
    //                 const toastEvent = new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Sales Manager Assigned Successfully',
    //                     variant: 'success'
    //                 });
    //                 this.dispatchEvent(toastEvent);
    //                 window.location.href = '/' + this.recordId;
    //                 this.isSpinner = false;
    //             } else {
    //                 const toastEvent = new ShowToastEvent({
    //                     title: 'error',
    //                     message: 'Something went wrong please contact System Administrator',
    //                     variant: 'error'
    //                 });
    //                 this.dispatchEvent(toastEvent);
    //             }
    //             return;
    //         }).catch(error => {
    //             this.error = error;
    //             console.log('error isSMAssign: ' + JSON.stringify(this.error));
    //         })
    // }

    // handleAssign(event) {
    //     this.userId = event.target.value;
    //     console.log('userId: ' + JSON.stringify(this.userId));
    //     if (this.userId != '') {
    //         this.disabledAssignButton = true;
    //     }
    // }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
  

    handleSourceSection() {
        this.showSourcePage = false;
    }


    handlesubmit() {
     this.callUpdateSV();
    }

    callUpdateSV() {
        console.log('svWrapper: '+ this.svWrapper);
        this.isSpinner = true;
        updateSiteVisit({ svWrapper: this.svWrapper })
            .then((result) => {
                console.log('result: ' + JSON.stringify(result));
                this.isSpinner = false;
                this.callRecordPage();
            })
    }

    callRecordPage(){
        const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Sources Details Updated Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    window.location.href = '/' + this.recordId;
                    this.isSpinner = false;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.svWrapper.sv.Id,
        //         actionName: 'view'
        //     }
        // });
    }

}