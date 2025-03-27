/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 27-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, track, wire } from 'lwc';
import getQuotationDetails from '@salesforce/apex/Ex_BookingFormController.getQuotationDetails';
import getBookingWrapper from '@salesforce/apex/Ex_BookingFormController.getBookingWrapper';
// import getReceiptWrapper from '@salesforce/apex/Ex_BookingFormController.getReceiptWrapper';
import ApplicantdocumentDetails from '@salesforce/apex/Ex_BookingFormController.ApplicantdocumentDetails';
import createBookingRecord from '@salesforce/apex/Ex_BookingFormController.createBookingRecord';
import getReceipts from '@salesforce/apex/Ex_BookingFormController.getReceipts';
import getLegalEntityDetails from '@salesforce/apex/Ex_BookingFormController.getLegalEntityDetails';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import APPLICANT_FIELD from '@salesforce/schema/Applicant__c.Applicant_Number__c';

export default class Ex_BookingForm extends LightningElement {


    @track getReceiptData = [];
    @track getLegalData = [];

    @api uId;
    @api oppId;
    @api qId;
    @track isSpinner = false;
    @track quote;
    @track showToast = false;
    @track toastMessage = '';
    @track toastVariant = ''; // success, warning, error
    @track showBankDetails = false;

    @track bkWrapper = { bk: {} };
    @track getBookingWrapperList = [];

    @track rcWrapper = { rc: {} };
    @track getReceiptWrapper = [];

    showPINMsg = '';
    showErrorMailingPIN = '';
    showMailingPINMsg = '';

    @track getApplicantData = [];
    @track applicantDocuments = [];
    @api activeTabValue = 'defaultTabValue'; // Default value
    @track applicantCounter = 1;
    @track documentsArray = [];


    @track applicantObj;
    @track applicantTab;
    accountRecordTypeId;

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    results({ error, data }) {
      if (data) {
        this.accountRecordTypeId = data.defaultRecordTypeId;
        this.error = undefined;
      } else if (error) {
        this.error = error;
        this.accountRecordTypeId = undefined;
      }
    }
  
    @wire(getPicklistValues, { recordTypeId: "$accountRecordTypeId", fieldApiName: APPLICANT_FIELD })
    picklistResults({ error, data }) {
        //console.log('Before Data:', JSON.stringify(data));
        if (data) {
            //console.log('After Data:', JSON.stringify(data));
            this.applicantTab = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            //console.log('Picklist Values:', JSON.stringify(this.applicantTab));
        } else if (error) {
            this.error = error;
            console.error('Error fetching picklist values:', JSON.stringify(error));
        }
    }

    
    // getApplicantDoc() {
    //     var fieldValue;
    //     ApplicantdocumentDetails({ fieldValue: fieldValue, oppId: this.oppId, tabKey: 'Applicant 1' })
    //         .then(result => {
    //             this.getApplicantData = result.map((item, index) => ({
    //                 key: `Applicant ${index + 1}`,
    //                 ap: item.ap,
    //                 documents: item.documents,
    //             }));
    //             //console.log('getApplicantData ', JSON.stringify(this.getApplicantData));
    //         });
    // }

   
    
  
   

  

    connectedCallback() {
        const urlSearchParams = new URLSearchParams(window.location.search);
        this.qId = urlSearchParams.get("recordId");
        this.getQuotationDetailsCall();
        this.getLegalEntityDetails();
        this.getReceiptWrapperMethod();

        //this.showCustomToast('success', 'This is a success message!', 5000000); // Shows for 5 seconds\
    }

    getLegalEntityDetails() {
        getLegalEntityDetails({ qId: this.qId })
            .then(result => {
                //console.log('result: ' + JSON.stringify(result));
                if (result != null) {
                    this.getLegalData = result;
                    //console.log('Detail-1' + JSON.stringify(this.getLegalData));
                    this.error = undefined;
                } else {
                    this.error = error;
                    this.getLegalEntityDetails = undefined;
                }
            })
            .catch(error => {
                this.error = error;
                this.quote = undefined;
            })
    }






    get getToastClass() {
        return `slds-notify slds-notify_toast slds-theme_${this.toastVariant}`;
    }

    get iconName() {
        switch (this.toastVariant) {
            case 'success':
                return 'utility:success';
            case 'error':
                return 'utility:error';
            case 'warning':
                return 'utility:warning';
            case 'info':
                return 'utility:info';
            default:
                return 'utility:info'; // Default icon
        }
    }

    get toastTextColor() {
        switch (this.toastVariant) {
            case 'success':
                return 'success'; // Or another suitable color for success
            case 'error':
                return 'error';
            case 'warning':
                return 'warning';
            case 'info':
                return 'info';
            default:
                return 'black'; // Default color
        }
    }

    showCustomToast(type, message, timeout = 5000) { // Timeout in milliseconds
        this.toastVariant = type;
        this.toastMessage = message;
        this.showToast = true;
        setTimeout(() => {
            this.showToast = false;
        }, timeout);
    }

    closeToast() {
        this.showToast = false;
    }

    getQuotationDetailsCall() {
        // this.showSpinner = true;
        getQuotationDetails({ qId: this.qId })
            .then(result => {
                //console.log('result: ' + JSON.stringify(result));
                this.quote = result;
                if (this.quote.Opportunity__c !== undefined) {
                    this.oppId = this.quote.Opportunity__c;
                }
                setTimeout(() => {
                    this.getApplicantDoc();
                    this.handleBookingWrapper();
                }, 2000
                )
                //this.getBookingWrapper();
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.quote = undefined;
            })
    }

    handleBookingWrapper() {
        getBookingWrapper({ oppId: this.oppId })
            .then((result) => {
                this.bkWrapper = result;
                //console.log('data: ' + JSON.stringify(this.bkWrapper));
            })
            .catch((error) => {
                this.error = error;
                this.bkWrapper = undefined;
            });
    }

    getReceiptWrapperMethod() {
        getReceipts({})
            .then((result) => {
                if (result && result.length > 0) {
                    this.getReceiptData = result.map((item, index) => ({
                        key: `Receipt ${index + 1}`,  // Unique key for each receipt
                        rc: item                      // The receipt data from the result
                    }));
                }
            })
            .catch((error) => {
                console.error('Error fetching receipt data: ', error);
            });
    }

    //    @wire(getReceipts)
    //     wiredReceipts({ error, data }) {

    //     }
    addReceipt() {
        //console.log('Active tab value:', this.activeTabValue);
        const newReceipt = {
            key: `Receipt ${this.getReceiptData.length + 1}`,
            rc: {}
        };
        this.getReceiptData.push(newReceipt);
        this.getReceiptData = [...this.getReceiptData];
    }
    removeTabReceipt(event) {

        const tabIndexToRemove = parseInt(event.target.dataset.index, 10);
        //console.log('TAB INDEX:', tabIndexToRemove);
        const key = event.currentTarget.dataset.tabvalue;

        if (key === 'Receipt 1') {
            alert('Receipt 1 Cannot be Removed.');
            return;
        } else {
            for (var i = 0; i < this.getReceiptData.length; i++) {
                if (this.getReceiptData[i].key == key) {
                    //alert('FOund')
                    this.getReceiptData.splice(tabIndexToRemove, 1);
                    this.getReceiptData.forEach((receipt, index) => {
                        receipt.key = `Receipt ${index + 1}`;
                        receipt.rc = {}
                    });
                    this.getReceiptData = [...this.getReceiptData];
                    //console.log(JSON.stringify(this.getReceiptData));
                }
            }

        }

    }

    handleReceiptInfo(event) {
        const tabKey = event.currentTarget.dataset.key;
        const fieldApiName = event.target.fieldName;
        const fieldValue = event.target.value;
        this.getReceiptData = this.getReceiptData.map(item => {
            if (item.key === tabKey) {
                return { ...item, rc: { ...item.rc, [fieldApiName]: fieldValue } };
            }
            return item;
        });
        //console.log('getReceiptData: ' + JSON.stringify(this.getReceiptData));
    }

    handleBookingInfo(event) {
        const fieldName = event.target.fieldName;
        const value = event.target.value;
        this.getBookingWrapperList = {
            ...this.bkWrapper.bk,
            [fieldName]: value
        };

        this.bkWrapper = { bk: this.getBookingWrapperList };
        //console.log('bkWrapper: ' + JSON.stringify(this.bkWrapper));
        if (fieldName == 'Mode_of_Funding__c') {
            if (this.bkWrapper.bk.Mode_of_Funding__c == 'Loan') {
                this.showBankDetails = true;
            } else {
                this.showBankDetails = false;
            }
        }
    }


    @track isLoadedFull = false;

    renderedCallback() {
        try {
            if (this.isLoadedFull)
                return;
            const STYLE = document.createElement("style");
            STYLE.innerText = '.uiModal--medium .modal-container' +
                '{' +
                'width: 90% !important;min-width: 90% !important;max-width: 90% !important;' +
                'min-height:420px !important;' +
                '}';
            //console.log('STYLE::' + STYLE);
            this.template.querySelector('modern-form-container').appendChild(STYLE);
            this.isLoadedFull = true;
        } catch (error) {
            //console.log('## error in renderedCallback: ' + JSON.stringify(error));
            //this.showToast("Error", "Error in renderedCallback", "error");
        }
    }

    getApplicantDoc() {
        if (!this.applicantTab || this.applicantTab.length === 0) {
            this.showCustomToast('error', 'No Applicant Tab Present!', 1000);
            console.error('No applicant tabs available.');
            return;
        }
    
        // Filter only "Primary Applicant" for initial load
        const primaryApplicant = this.applicantTab.find(tab => tab.label === "Primary Applicant");
        if (!primaryApplicant) {
            this.showCustomToast('error', 'Primary Applicant is required!', 1000);
            return;
        }
    
        ApplicantdocumentDetails({ fieldValue: null, nationality: '', oppId: this.oppId, tabKey: primaryApplicant.value })
            .then(result => {
                setTimeout(() => { // 2-second delay before setting data
                    this.getApplicantData = result.map(item => ({
                        key: primaryApplicant.label, // Only Primary Applicant at first
                        ap: { ...item.ap, Applicant_Number__c: primaryApplicant.label },
                        documents: item.documents,
                    }));
                    //console.log('getApplicantData:', JSON.stringify(this.getApplicantData));
                }, 2000); // 2-second delay
            })
            .catch(error => {
                console.error('Error fetching Primary Applicant documents:', JSON.stringify(error));
            });
    }
    
    
    addApplicant() {
        //console.log('Active tab value:', this.activeTabValue);
        //this.showCustomToast('success', this.activeTabValue + ' Added', 1000); 
    
        if (!this.applicantTab || this.getApplicantData.length >= this.applicantTab.length) {
            alert('Cannot add more applicants than available applicant');
            return;
        }
    
        const nextApplicant = this.applicantTab[this.getApplicantData.length]; // Pick next available tab
        const newApplicant = {
            key: nextApplicant.label, // Use picklist value instead of numbering
            ap: { Applicant_Number__c: nextApplicant.label }, // Set Applicant Number
            documents: [],
        };
    
        this.getApplicantData.push(newApplicant);
        this.getApplicantData = [...this.getApplicantData];
        this.showCustomToast('success', nextApplicant.label + ' Added', 1000); 
        //console.log('Updated Applicants:', JSON.stringify(this.getApplicantData));
    }
    
    removeTab(event) {
        const key = event.currentTarget.dataset.tabvalue;
        //console.log('Removing tab:', key);

    
        if (key === this.applicantTab[0].label) { 
            this.showCustomToast(
                            'error',
                            ` ${key} Cannot be Removed.`,
                            1000
                        ); 
                        //alert(`${)
           // alert(`${key} cannot be removed.`);
            return;
        }
    
        const indexToRemove = this.getApplicantData.findIndex(applicant => applicant.key === key);
        if (indexToRemove !== -1) {
            this.getApplicantData.splice(indexToRemove, 1);
            this.getApplicantData = [...this.getApplicantData];
            //console.log('Updated Applicants after removal:', JSON.stringify(this.getApplicantData));
        } else {
            //console.log('Applicant not found:', key);
        }
    }
    
    

    callDocument(tabKey, fieldValue, nationality) {
        ApplicantdocumentDetails({ fieldValue: fieldValue, nationality: nationality, oppId: this.quote.Opportunity__c, tabKey: this.tabKey })
            .then(result => {
                //console.log('result', JSON.stringify(result));

                this.getApplicantData = this.getApplicantData.map((item, index) => {
                    //console.log('item', JSON.stringify(item));
                    if (item.key === tabKey) {
                        if (result[index] && result[index].ap) {
                            item.ap = { ...item.ap, ...result[index].ap };
                        }

                    }
                    return item;
                });
                this.documentsArray = [];

                result.forEach((docItem, docIndex) => {
                    //console.log('docItem', JSON.stringify(docItem.documents));

                    if (docItem.documents != undefined && docItem.documents) {
                        let mergedObject = {
                            ...docItem.documents,
                            key: tabKey,
                            filename: null,
                            base64: null,
                            fileData: null,
                            fileUploader: null,
                            type: docItem.documents.Name,
                            index: docIndex
                        };
                        this.documentsArray.push(mergedObject);
                    }
                });

                const applicantIndex = this.getApplicantData.findIndex(item => item.key === tabKey);
                if (applicantIndex !== -1) {
                    this.getApplicantData[applicantIndex].documents = this.documentsArray;
                }

                //console.log('getApplicantDataBeforeDocument: ', JSON.stringify(this.getApplicantData));
            })
            .catch(error => {
                console.error(error.message);
            });
    }

    handleApplicant(event) {
        try {
            const tabKey = event.currentTarget.dataset.key;
            const fieldApiName = event.target.fieldName;
            const fieldValue = event.target.value;
    
            const applicantIndex = this.getApplicantData.findIndex(item => item.key === tabKey);
            if (applicantIndex !== -1) {
                const updatedApplicant = { ...this.getApplicantData[applicantIndex] };
                updatedApplicant.ap = { ...updatedApplicant.ap, [fieldApiName]: fieldValue };
    
                //console.log('updatedApplicant::', JSON.stringify(updatedApplicant));
    
                // **Handling Mailing Address Copying**
                if (updatedApplicant.ap.Mailing_Address_Same_as_PermanentAddress__c === true) {
                    updatedApplicant.ap.Mailing_Address__c = updatedApplicant.ap.Permanent_Address__c;
                    updatedApplicant.ap.Mailing_Country__c = updatedApplicant.ap.Country__c;
                    updatedApplicant.ap.Mailing_State__c = updatedApplicant.ap.State__c;
                    updatedApplicant.ap.Mailing_City__c = updatedApplicant.ap.City__c;
                    updatedApplicant.ap.Mailing_Pincode__c = updatedApplicant.ap.PIN__c;
                }
    
                let nationality = updatedApplicant.ap.Nationality__c;
                let isDocumentUploaded = false;
    
                if (updatedApplicant.documents && updatedApplicant.documents.length > 0) {
                    updatedApplicant.documents.forEach(doc => {
                        //console.log('Checking document:', doc);
                        if (doc.filename && doc.base64) {
                            isDocumentUploaded = true;
                        }
                    });
                }
    
                //console.log('isDocumentUploaded:', isDocumentUploaded);
    
                // **Clear Documents if Upload is NOT Required**
                if (updatedApplicant.ap.Document_Upload_Required__c === 'No') {
                    if (updatedApplicant.documents && updatedApplicant.documents.length > 0) {
                        updatedApplicant.documents.forEach(doc => {
                            doc.filename = '';
                            doc.base64 = '';
                        });
                    }
                    updatedApplicant.documents = [];
                    //console.log('Documents cleared as upload is not required.');
                }
    
                // **Trigger Document Upload if Required and Not Uploaded**
                if (updatedApplicant.ap.Document_Upload_Required__c === 'Yes' && nationality && !isDocumentUploaded) {
                    this.callDocument(tabKey, updatedApplicant.ap.Document_Upload_Required__c, nationality);
                }
    
                // **PAN Validation**
                if (fieldApiName === 'PAN_Number__c') {
                    const panNumber = event.detail.value;
                    const isValidPan = this.sValidPanCardNo(panNumber);
                    this.showErrorPan = isValidPan === 'false';
                    this.showMsg = this.showErrorPan ? 'Please Enter Valid PAN Number' : '';
                }
    
                // **Aadhar Validation**
                else if (fieldApiName === 'Aadhar_Number__c') {
                    const aadharNumber = event.detail.value;
                    this.showError = !this.validateAadharNumber(aadharNumber);
                    this.showMsg = this.showError ? 'Please Enter Valid Aadhar Number' : '';
                }
    
                // **PIN Validation**
                else if (fieldApiName === 'PIN__c') {
                    const pinNumber = event.detail.value;
                    this.showErrorPIN = !this.validPINNumber(pinNumber);
                    this.showPINMsg = this.showErrorPIN ? 'Please Enter Valid PIN Code' : '';
                }
    
                // **Mailing PIN Validation**
                else if (fieldApiName === 'Mailing_Pincode__c') {
                    const MailingPinNumber = event.detail.value;
                    this.showErrorMailingPIN = !this.validMailingPINNumber(MailingPinNumber);
                    this.showMailingPINMsg = this.showErrorMailingPIN ? 'Please Enter Valid Mailing PIN Code' : '';
                }
    
                // **Update Applicant Data Efficiently**
                this.getApplicantData.splice(applicantIndex, 1, updatedApplicant);
            }
    
            //console.log('Applicant Data::', JSON.stringify(this.getApplicantData));
    
        } catch (error) {
            console.error(error.message);
        }
    }

    sValidPanCardNo(panNumber) {
        let regex = new RegExp(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/);
        if (panNumber == null) {
            return 'false';
        }
        if (regex.test(panNumber) == true) {
            return 'true';
        }
        else {
            return 'false';
        }
    }

    validateAadharNumber(aadharNumber) {
        const aadharRegex = /^\d{12}$/;
        return aadharRegex.test(aadharNumber);
    }

    validPINNumber(pinNumber) {
        const validCodeRgx = /^\d{6}$/;
        return validCodeRgx.test(pinNumber);

    }

    validMailingPINNumber(MailingPinNumber) {
        const validCodeRgx = /^\d{6}$/;
        return validCodeRgx.test(MailingPinNumber);

    }
    changeBookingdate(event) {
        try {
            this.bookingDate = event.target.value;
            //console.log(this.bookingDate);
        } catch (error) {

            console.error(error.message);
        }
    }

    isPrimaryApplicantDataValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Applicant_Title__c && !!ap.Name && !!ap.Applicant_Number__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    ismobilenumberValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Mobile__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isDOBValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.DOB__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }


    isTypeOfApplicantValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Type_of_Applicant__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isResidentialValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Residential_Status__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isaadharValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Aadhar_Number__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }

    isPanValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.PAN_Number__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }

    openfileUpload(event) {
        try {
            // Check if any file is selected
            if (!event.target.files || event.target.files.length === 0) {
                console.error('No files selected.');
                return; // Exit if no files are selected
            }

            var file = event.target.files[0];
            var getSize = file.size;

            if (getSize > 3145728) {
                alert('File size exceeds 3 MB. Please choose a smaller file.');
                return;
            }


            let index = event.target.dataset.id ? parseInt(event.target.dataset.id) : null;
            let applicantkey = event.target.dataset.applicantkey;

            if (index === null || !applicantkey) {
                console.error('Missing data attributes.');
                return;
            }

            //console.log('applicantkey', applicantkey);
            let fieldName = event.target.name;
            let value = event.target.value;
            //console.log('Selected value:', value);


            // --- Store Uploaded Files ---
            var selectedApplicantData = null;
            var selectedApplicantIndex = -1;
            for (let i = 0; i < this.getApplicantData.length; i++) {
                const applicantData = this.getApplicantData[i];
                if(applicantData['key'] === applicantkey){
                    selectedApplicantData = {...applicantData};
                    selectedApplicantIndex = i;
                    break;
                }
            }


            if(selectedApplicantData != null && selectedApplicantIndex != -1){
                var matchingDocument = selectedApplicantData?.documents?.find(doc => doc.index === index);
                var matchingDocIndex = selectedApplicantData?.documents?.find((doc, docIdx) => {
                    if(doc.index === index)  return docIdx;
                });

                var reader = new FileReader();
                reader.onload = () => {
                    var base64 = reader.result.split(",")[1];
                    matchingDocument.base64 = base64;
                    matchingDocument.filename = file.name;        

                    //console.log('matchingDocument ::: ' + JSON.stringify(matchingDocument));                    
                    
                    selectedApplicantData.documents[matchingDocIndex] = matchingDocument;
                    this.getApplicantData[selectedApplicantIndex] = selectedApplicantData;

                    //console.log('After Uploading File: ' + JSON.stringify(this.getApplicantData));
                    
                };
                reader.readAsDataURL(file);
            }

            // -----------

        } catch (error) {
            console.error('An error occurred:', error);
        }
        //console.log('Updated Documents:', JSON.stringify(this.getApplicantData));

    }





    handleSave() {
        // alert('bkWrapper: '+JSON.stringify(this.bkWrapper));
        // alert('applicantData: '+ JSON.stringify(this.getApplicantData))
        // alert('Quotation: '+ JSON.stringify(this.quote))
        // alert('LegalEntity: '+ JSON.stringify (this.getLegalData));
        // alert('getReceiptData: '+ JSON.stringify(this.getReceiptData));

        if (!this.isPrimaryApplicantDataValid()) {
            this.showCustomToast('error', 'Please Enter Salutation, Name, and Applicant Number');
            return;
        } else if (this.bkWrapper.bk.Mode_of_Funding__c == null || this.bkWrapper.bk.Mode_of_Funding__c == '') {
            this.showCustomToast('error', 'Please enter mode of funding details');
            return;
        } else if (!this.ismobilenumberValid()) {
            this.showCustomToast('error', 'Please Enter Mobile Number');
            return;
        } //else if (!this.isDOBValid()) {
        // this.showCustomToast('error', 'Please Enter Date of Birth');
        //return;
        //} 
        else if (!this.isTypeOfApplicantValid()) {
            this.showCustomToast('error', 'Please Enter Type of Applicant');
            return;
        } else if (!this.isaadharValid()) {
            this.showCustomToast('error', 'Please Enter Aadhar Number');
            return;
        } else if (!this.isPanValid()) {
            this.showCustomToast('error', 'Please Enter Pan Number');
            return;
        } else if (!this.isResidentialValid()) {
            this.showCustomToast('error', 'Please Enter Residential Status');
            return;
        } else if (this.bkWrapper.bk.Booking_Date__c == null) {
            this.showCustomToast('error', 'Please Enter Booking Date');
            return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Mode_Of_Payment__c == null) {
            //     this.showCustomToast('error', 'Please Select Payment Mode');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Payment_Type__c == null) {
            //     this.showCustomToast('error', 'Please Select Payment Type');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Payment_Status__c == null) {
            //     this.showCustomToast('error', 'Please Select Payment Status');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Receipt_Type__c == null) {
            //     this.showCustomToast('error', 'Please Select Receipt Type');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Transaction_ID__c == null) {
            //     this.showCustomToast('error', 'Please Enter Transaction ID');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Receipt_Date__c == null) {
            //     this.showCustomToast('error', 'Please Enter Receipt Date');
            //     return;
            // } else if (this.rcWrapper && this.rcWrapper.rc.Amount__c == null) {
            //     this.showCustomToast('error', 'Please Enter Receipt Amount');
            //     return;
        } else {
            this.isSpinner = true;
            createBookingRecord({
                bkWrapper: this.bkWrapper,
                applicantData: JSON.stringify(this.getApplicantData),
                quotationDetails: this.quote,
                receiptData: JSON.stringify(this.getReceiptData),
                bookingAccount: this.getLegalData,
            })
                .then(result => {
                    //console.log('Booking: ', result);
                    this.showCustomToast('success', 'Booking Created Successfully');
                    this.isSpinner = false;
                    location.replace('/' + result);

                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showCustomToast('error', 'Error Occured Please Contact System Administrator');
                    //console.log('error is::' + JSON.stringify(error));
                })
        }
    }
}