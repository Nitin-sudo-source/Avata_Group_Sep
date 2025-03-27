import { LightningElement, api, track, wire } from 'lwc';
import getQuotationDetails from '@salesforce/apex/Ex_BookingFormController.getQuotationDetails';
import getBookingWrapper from '@salesforce/apex/Ex_BookingFormController.getBookingWrapper';
// import getReceiptWrapper from '@salesforce/apex/Ex_BookingFormController.getReceiptWrapper';
import ApplicantdocumentDetails from '@salesforce/apex/Ex_BookingFormController.ApplicantdocumentDetails';
import createBookingRecord from '@salesforce/apex/Ex_BookingFormController.createBookingRecord';
import getReceipts from '@salesforce/apex/Ex_BookingFormController.getReceipts';
import getLegalEntityDetails from '@salesforce/apex/Ex_BookingFormController.getLegalEntityDetails';

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
                console.log('result: ' + JSON.stringify(result));
                if (result != null) {
                    this.getLegalData = result;
                    console.log('Detail-1' + JSON.stringify(this.getLegalData));
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




    getApplicantDoc() {
        var fieldValue;
        ApplicantdocumentDetails({ fieldValue: fieldValue, oppId: this.oppId, tabKey: 'Applicant 1' })
            .then(result => {
                this.getApplicantData = result.map((item, index) => ({
                    key: `Applicant ${index + 1}`,
                    ap: item.ap,
                    documents: item.documents,
                }));
                console.log('getApplicantData ', JSON.stringify(this.getApplicantData));
            });
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
                console.log('result: ' + JSON.stringify(result));
                this.quote = result;
                if (this.quote.Opportunity__c !== undefined) {
                    this.oppId = this.quote.Opportunity__c;
                }
                this.getApplicantDoc();
                this.handleBookingWrapper();
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
                console.log('data: ' + JSON.stringify(this.bkWrapper));
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
        console.log('Active tab value:', this.activeTabValue);
        const newReceipt = {
            key: `Receipt ${this.getReceiptData.length + 1}`,
            rc: {}
        };
        this.getReceiptData.push(newReceipt);
        this.getReceiptData = [...this.getReceiptData];
    }
    removeTabReceipt(event) {

        const tabIndexToRemove = parseInt(event.target.dataset.index, 10);
        console.log('TAB INDEX:', tabIndexToRemove);
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
                    console.log(JSON.stringify(this.getReceiptData));
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
        console.log('getReceiptData: ' + JSON.stringify(this.getReceiptData));
    }

    handleBookingInfo(event) {
        const fieldName = event.target.fieldName;
        const value = event.target.value;
        this.getBookingWrapperList = {
            ...this.bkWrapper.bk,
            [fieldName]: value
        };

        this.bkWrapper = { bk: this.getBookingWrapperList };
        console.log('bkWrapper: ' + JSON.stringify(this.bkWrapper));
        if (fieldName == 'Mode_of_Funding__c') {
            if (this.bkWrapper.bk.Mode_of_Funding__c == 'Loan') {
                this.showBankDetails = true;
            } else {
                this.showBankDetails = false;
            }
        }
    }

    addApplicant() {
        console.log('Active tab value:', this.activeTabValue);
        const newApplicant = {
            key: `Applicant ${this.getApplicantData.length + 1}`,
            ap: {},
            documents: [],
        };
        this.getApplicantData.push(newApplicant);
        this.getApplicantData = [...this.getApplicantData];
    }
    removeTab(event) {
        const tabIndexToRemove = parseInt(event.target.dataset.index, 10);
        console.log('TAB INDEX:', tabIndexToRemove);
        const key = event.currentTarget.dataset.tabvalue;

        if (key === 'Applicant 1') {
            alert('Applicant 1 Cannot be Removed.');
        } else {
            const indexToRemove = this.getApplicantData.findIndex(applicant => applicant.key === key);
            if (indexToRemove !== -1) {
                this.getApplicantData.splice(indexToRemove, 1);
                this.getApplicantData.forEach((applicant, index) => {
                    console.log(`Applicant ${index + 1}`);
                    applicant.key = `Applicant ${index + 1}`;
                });
                this.getApplicantData = [...this.getApplicantData];
                console.log(JSON.stringify(this.getApplicantData));
            } else {
                console.log('Applicant not found:', key);
            }
        }
    }

    callDocument(tabKey, fieldValue, nationality) {
        ApplicantdocumentDetails({ fieldValue: fieldValue, nationality: nationality, oppId: this.quote.Opportunity__c, tabKey: this.tabKey })
            .then(result => {
                console.log('result', JSON.stringify(result));

                this.getApplicantData = this.getApplicantData.map((item, index) => {
                    console.log('item', JSON.stringify(item));
                    if (item.key === tabKey) {
                        if (result[index] && result[index].ap) {
                            item.ap = { ...item.ap, ...result[index].ap };
                        }

                    }
                    return item;
                });
                this.documentsArray = [];

                result.forEach((docItem, docIndex) => {
                    console.log('docItem', JSON.stringify(docItem.documents));

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

                console.log('getApplicantDataBeforeDocument: ', JSON.stringify(this.getApplicantData));
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

            //  console.log('fieldApiName::'+fieldApiName +' fieldValue:: '+ fieldValue);
            const applicantIndex = this.getApplicantData.findIndex(item => item.key === tabKey);
            if (applicantIndex !== -1) {
                const updatedApplicant = { ...this.getApplicantData[applicantIndex] };
                updatedApplicant.ap = { ...updatedApplicant.ap, [fieldApiName]: fieldValue };
                console.log('updatedApplicant::' + JSON.stringify(updatedApplicant));
                if (updatedApplicant.ap.Mailing_Address_Same_as_PermanentAddress__c === true) {

                    updatedApplicant.ap.Mailing_Address__c = updatedApplicant.ap.Permanent_Address__c;
                    updatedApplicant.ap.Mailing_Country__c = updatedApplicant.ap.Country__c;
                    updatedApplicant.ap.Mailing_State__c = updatedApplicant.ap.State__c;
                    updatedApplicant.ap.Mailing_City__c = updatedApplicant.ap.City__c;
                    updatedApplicant.ap.Mailing_Pincode__c = updatedApplicant.ap.PIN__c;
                }
                if (updatedApplicant.ap.Document_Upload_Required__c === 'Yes' && updatedApplicant.ap.Nationality__c === 'Indian') {
                    this.callDocument(tabKey, updatedApplicant.ap.Document_Upload_Required__c, updatedApplicant.ap.Nationality__c);
                } else if (updatedApplicant.ap.Document_Upload_Required__c === 'Yes' && updatedApplicant.ap.Nationality__c === 'NRI') {
                    this.callDocument(tabKey, updatedApplicant.ap.Document_Upload_Required__c, updatedApplicant.ap.Nationality__c);
                } else if (updatedApplicant.ap.Document_Upload_Required__c === 'No' && updatedApplicant.ap.Nationality__c === 'NRI') {
                    this.callDocument(tabKey, updatedApplicant.ap.Document_Upload_Required__c, updatedApplicant.ap.Nationality__c);
                }else if (updatedApplicant.ap.Document_Upload_Required__c === 'No' && updatedApplicant.ap.Nationality__c === 'Indian') {
                    this.callDocument(tabKey, updatedApplicant.ap.Document_Upload_Required__c, updatedApplicant.ap.Nationality__c);
                } else if (fieldApiName === 'PAN_Number__c') {
                    //alert('textt');
                    const panNumber = event.detail.value;
                    console.log('Inside Pan:::' + panNumber);
                    const isValidPan = this.sValidPanCardNo(panNumber);
                    console.log('isValidPan: ' + isValidPan);
    
                    if (isValidPan === 'false') {
                        this.showErrorPan = true;
                        this.showMsg = 'Please Enter Valid PAN Number ';
                    } else {
                        this.showErrorPan = false;
                    }
                } else if (fieldApiName === 'Aadhar_Number__c') {
                    const aadharNumber = event.detail.value;
                    const isValidAadhar = this.validateAadharNumber(aadharNumber);
    
                    if (!isValidAadhar) {
                        this.showError = true;
                        this.showMsg = 'Please Enter Valid Aadhar Number ';
                    } else {
                        this.showError = false;
                    }
                } else if (fieldApiName === 'PIN__c') {
                    const pinNumber = event.detail.value;
                    const isValidPIN = this.validPINNumber(pinNumber);
    
                    if (!isValidPIN) {
                        this.showErrorPIN = true;
                        this.showPINMsg = 'Please Enter Valid PIN Code';
                    } else {
                        this.showErrorPIN = false;
                    }
                } else if (fieldApiName === 'Mailing_Pincode__c') {
                    const MailingPinNumber = event.detail.value;
                    const isValidMailingPIN = this.validMailingPINNumber(MailingPinNumber);
    
                    if (!isValidMailingPIN) {
                        this.showErrorMailingPIN = true;
                        this.showMailingPINMsg = 'Please Enter Valid Mailing PIN Code';
                    } else {
                        this.showErrorMailingPIN = false;
                    }
                }
                this.getApplicantData.splice(applicantIndex, 1, updatedApplicant);
            }
            console.log('Applicant Data::' + JSON.stringify(this.getApplicantData));
           

        } catch (error) {
            console.error(error.message)
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
            console.log(this.bookingDate);
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

            console.log('filesize: ' + getSize);

            let index = event.target.dataset.id ? parseInt(event.target.dataset.id) : null;
            let applicantkey = event.target.dataset.applicantkey;

            if (index === null || !applicantkey) {
                console.error('Missing data attributes.');
                return;
            }

            console.log('applicantkey', applicantkey);
            let fieldName = event.target.name;
            let value = event.target.value;
            console.log('Selected value:', value);

            for (let i = 0; i < this.getApplicantData.length; i++) {
                var documentsArray = this.getApplicantData[i].documents;
                for (let j = 0; j < documentsArray.length; j++) {
                    if (documentsArray[j].key === applicantkey) {
                        console.log('documentsArraykey', JSON.stringify(documentsArray[j].key));
                        const matchingDocument = documentsArray.find(doc => doc.index === index);
                        if (matchingDocument) {
                            matchingDocument[fieldName] = value;
                            if (getSize > 3145728) {
                                alert('File size exceeds 3 MB. Please choose a smaller file.');
                                return;
                            }
                            var reader = new FileReader();
                            reader.onload = () => {
                                try {
                                    if (!reader.result) {
                                        throw new Error('FileReader result is null or undefined.');
                                    }
                                    var result = reader.result;
                                    // Ensure result is a valid data URL
                                    if (typeof result === 'string' && result.includes(',')) {
                                        var base64 = result.split(",")[1]; // Check if split result is correct
                                        matchingDocument.filename = file.name;
                                        matchingDocument.base64 = base64;
                                        console.log('File read successfully:', matchingDocument);

                                        // Update the documents array with the modified document
                                        this.getApplicantData[i].documents = documentsArray;
                                    } else {
                                        throw new Error('Unexpected FileReader result format: ' + result);
                                    }

                                } catch (error) {
                                    console.log('Error processing file:', JSON.stringify(error));
                                }
                            };
                            reader.onerror = () => {
                                console.error('Error reading file:', reader.error);
                            };
                            reader.readAsDataURL(file);
                        }
                    }
                }
            }
        } catch (error) {
            console.error('An error occurred:', error);
        }
        console.log('Updated Documents:', JSON.stringify(this.getApplicantData));

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
                    console.log('Booking: ', result);
                    this.showCustomToast('success', 'Booking Created Successfully');
                    this.isSpinner = false;
                    location.replace('/' + result);

                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showCustomToast('error', 'Error Occured Please Contact System Administrator');
                    console.log('error is::' + JSON.stringify(error));
                })
        }
    }
}