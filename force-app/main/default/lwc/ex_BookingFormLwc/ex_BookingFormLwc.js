import { LightningElement, api, wire, track } from 'lwc';
import getQuotationDetails from '@salesforce/apex/Ex_BookingPageControllerLwc.getQuotationDetails';
//import getApplicants from '@salesforce/apex/Ex_BookingPageControllerLwc.getApplicants';
import createBookingRecord from '@salesforce/apex/Ex_BookingPageControllerLwc.createBookingRecord';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getReceipts from '@salesforce/apex/Ex_BookingPageControllerLwc.getReceipts';
import ApplicantdocumentDetails from '@salesforce/apex/Ex_BookingPageControllerLwc.ApplicantdocumentDetails';
import Insert_Receipt from '@salesforce/label/c.Insert_Receipt';
import getLegalEntityDetails from '@salesforce/apex/Ex_BookingPageControllerLwc.getLegalEntityDetails';
import getBookingWrapper from '@salesforce/apex/Ex_BookingPageControllerLwc.getBookingWrapper';
import getTermSheetWrapper from '@salesforce/apex/Ex_BookingPageControllerLwc.getTermSheetWrapper';
import projectImage from '@salesforce/apex/Ex_BookingPageControllerLwc.projectImage';





export default class Ex_BookingFormLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @track getQuotationDetails = [];
    @track getLegalEntityDetails = [];
    @track getApplicantData = [];
    @track SendApplicanttoApex = [];
    @track getReceiptData = [];
    @track applicantDocuments = [];
    @track fileList = [];
    @track listOfDocuments = [];
    @track values = [];
    @track saveList = [];
    showMailingAddressRow = true;
    error;
    fileData;
    @track filesize;
    @track testData = [];
    @api activeTabValue = 'defaultTabValue'; // Default value
    @track applicantCounter = 1;
    @track removeRender = false;
    showTable = false;
    @track documentsArray = [];
    isSpinner = false;
    showError = false;
    showErrorPan = false;
    showMsg = '';
    @track showErrormsg = '';
    @track isError = false;
    @track bkWrapper = { bk: {} };
    @track bkWrapperList = [];
    @track termSheetWrapper = { ts: {} };
    @track termSheetWrapperList = [];
    @track projectimage;


    handleChangeBooking(event) {
        try {
            // Extract fieldName from data-id or name
            const fieldName = event.target ? (event.target.dataset.id || event.target.name)
                : event.detail ? (event.detail.dataId || event.detail.name)
                    : '';
            const value = event.target ? event.target.value
                : event.detail ? event.detail.value
                    : '';

            // Update the bkWrapper.bk with new fieldName and value
            this.bkWrapper = {
                ...this.bkWrapper,
                bk: {
                    ...this.bkWrapper.bk,
                    [fieldName]: value
                }
            };

            // Log updated bkWrapper for debugging
            console.log('Updated bkWrapper:', JSON.stringify(this.bkWrapper));

        } catch (error) {
            // Handle errors and log for debugging
            console.log('bkWrapper error' + JSON.stringify(error));
            console.error('bkWrapper error' + JSON.stringify(error));
        }

        // Final log to ensure the bkWrapper is updated correctly
        console.log('bkWrapper (final): ' + JSON.stringify(this.bkWrapper));
    }



    handleChangeTermSheet(event) {
        try {
            const fieldName = event.target ? event.target.fieldName : event.detail ? event.detail.fieldName : '';
            const value = event.target ? event.target.value : event.detail ? event.detail.value : '';

            this.termSheetWrapperList = {
                ...this.termSheetWrapper.ts,
                [fieldName]: value
            };
            this.termSheetWrapper = { ts: this.termSheetWrapperList };
            console.log('termSheetWrapper: ' + JSON.stringify(this.termSheetWrapper));


        } catch (error) {
            console.log('termSheetWrapper error' + JSON.stringify(error));
            console.error('termSheetWrapper error' + JSON.stringify(error));
        }

        console.log('termSheetWrapper: ' + JSON.stringify(this.termSheetWrapper));

    }

    getBookingWrapperCall() {
        this.isSpinner = true;
        getBookingWrapper({})
            .then((result) => {
                this.bkWrapper = result;
                this.isSpinner = false;
                console.log('getBookingWrapper: ' + JSON.stringify(this.bkWrapper));
            }).catch(error => {
                console.log('getBookingWrapper error: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }

    getTermSheetWrapperCall() {
        this.isSpinner = true;
        getTermSheetWrapper({})
            .then((result) => {
                this.termSheetWrapper = result;
                this.isSpinner = false;
                console.log('termSheetWrapper: ' + JSON.stringify(this.termSheetWrapper));
            }).catch(error => {
                console.log('termSheetWrapper error: ' + JSON.stringify(error));
            }).catch(error => {
                console.error('An unexpected error occurred:', error);
            });
    }




    connectedCallback() {
        const insertReceiptLabel = Insert_Receipt;
        console.log('insertReceiptLabel: ' + insertReceiptLabel);
        if (/^yes$/i.test(insertReceiptLabel)) {
            this.showTable = true;
        }
        this.getBookingWrapperCall();
        this.getTermSheetWrapperCall();
        this.getApplicantCall();




    }

    getImage() {
        if (this.getQuotationDetails != [] && this.getQuotationDetails[0].Project__c !== undefined) {
            projectImage({ pid: this.getQuotationDetails[0].Project__c })
                .then((result) => {
                    console.log('Result: ' + JSON.stringify(result));
                    this.projectimage = result.Project_Logo__c;
                })
                .catch(error => {
                    console.log('error: ' + JSON.stringify(error));
                })
        }
    }

    getApplicantCall() {
        var fieldValue;
        ApplicantdocumentDetails({ fieldValue: fieldValue })
            .then(result => {
                this.getApplicantData = result.map((item, index) => ({
                    key: `Applicant ${index + 1}`,
                    ap: item.ap,
                    documents: item.documents,
                }));
                console.log('getApplicantData1 ', JSON.stringify(this.getApplicantData));
            });
    }

    //Show today Date by Default
    get dateValue() {
        if (this.dateval == undefined) {
            this.dateval = new Date().toISOString().substring(0, 10);
        }
        return this.dateval;
    }

    //Show Quotation Data
    @wire(getQuotationDetails, { qId: '$recordId' })
    getQuotationDetails({ error, data }) {
        if (data) {
            this.getQuotationDetails = data;
            if (this.getQuotationDetails[0].Quotation_Status__c == 'Valid' || this.getQuotationDetails[0].Quotation_Status__c == 'Approved') {
                this.showErrormsg = '';
                this.getImage();
            } else {
                this.showErrormsg = 'You can not procced further because you dont have valid or approved quotation';
                this.isError = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.getQuotationDetails = undefined;
        }
        console.log('Quotation: ' + JSON.stringify(this.getQuotationDetails));

    }
    //Show Legal Entity Data 
    @wire(getLegalEntityDetails, { qId: '$recordId' })
    getLegalEntityDetails({ error, data }) {
        if (data != null) {
            this.testData = data;
            console.log('Detail-1' + JSON.stringify(this.testData));
            this.error = undefined;

        } else {
            this.error = error;
            this.legalEntityData = undefined;
        }
    }

    //Show Documents Data
    handleFetchData() {
        getCustomSettingData()
            .then(result => {
                this.customSettingData = result;
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
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



    handleApplicant(event) {
        try {
            const tabKey = event.currentTarget.dataset.key;
            const fieldApiName = event.target.fieldName;
            const fieldValue = event.target.value;

            const applicantIndex = this.getApplicantData.findIndex(item => item.key === tabKey);
            if (applicantIndex !== -1) {
                const updatedApplicant = { ...this.getApplicantData[applicantIndex] };
                updatedApplicant.ap = { ...updatedApplicant.ap, [fieldApiName]: fieldValue };
                this.getApplicantData.splice(applicantIndex, 1, updatedApplicant);
            }
            if (fieldValue && fieldApiName === 'Residential_Status__c') {
                ApplicantdocumentDetails({ fieldValue: fieldValue })
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

                            if (docItem.documents) {
                                let mergedObject = {
                                    ...docItem.documents,
                                    key: tabKey,
                                    filename: null,
                                    base64: null,
                                    fileData: null,
                                    fileUploader: null,
                                    index: docIndex
                                };
                                this.documentsArray.push(mergedObject);
                            }
                        });

                        const applicantIndex = this.getApplicantData.findIndex(item => item.key === tabKey);
                        if (applicantIndex !== -1) {
                            this.getApplicantData[applicantIndex].documents = this.documentsArray;
                        }

                        console.log('getApplicantData1', JSON.stringify(this.getApplicantData));
                    })
                    .catch(error => {
                        console.error(error.message);
                    });
            }
            else if (fieldApiName === 'PAN_Number__c') {
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
            }
            else if (fieldApiName === 'Aadhar_Number__c') {
                const aadharNumber = event.detail.value;
                const isValidAadhar = this.validateAadharNumber(aadharNumber);

                if (!isValidAadhar) {
                    this.showError = true;
                    this.showMsg = 'Please Enter Valid Aadhar Number ';
                } else {
                    this.showError = false;
                }
            }

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
    //Applicant Logic End
    //Receipt Logic Start
    // @wire(getReceipts)
    // wiredReceipts({ error, data }) {
    //     if (data) {
    //         this.getReceiptData = data.map((item, index) => ({
    //             key: `Receipt ${index + 1}`,
    //             rc: item
    //         }));
    //     } else {
    //         console.error(error);
    //     }
    // }
    // addReceipt() {
    //     console.log('Active tab value:', this.activeTabValue);
    //     const newReceipt = {
    //         key: `Receipt ${this.getReceiptData.length + 1}`,
    //         rc: {}
    //     };
    //     this.getReceiptData.push(newReceipt);
    //     this.getReceiptData = [...this.getReceiptData];
    // }
    // removeTabReceipt(event) {
    //     const tabIndexToRemove = parseInt(event.target.dataset.index, 10);
    //     console.log('TAB INDEX:', tabIndexToRemove);
    //     const key = event.currentTarget.dataset.tabvalue;
    //     for (var i = 0; i < this.getReceiptData.length; i++) {
    //         if (this.getReceiptData[i].key == key) {
    //             //alert('FOund')
    //             this.getReceiptData.splice(tabIndexToRemove, 1);
    //             this.getReceiptData.forEach((receipt, index) => {
    //                 receipt.key = `Receipt ${index + 1}`;
    //                 receipt.rc = {}
    //             });
    //             this.getReceiptData = [...this.getReceiptData];
    //             console.log(JSON.stringify(this.getReceiptData));
    //         }
    //     }
    // }
    // handleReceipt(event) {
    //     const tabKey = event.currentTarget.dataset.key;
    //     const fieldApiName = event.target.fieldName;
    //     const fieldValue = event.target.value;
    //     this.getReceiptData = this.getReceiptData.map(item => {
    //         if (item.key === tabKey) {
    //             return { ...item, rc: { ...item.rc, [fieldApiName]: fieldValue } };
    //         }
    //         return item;
    //     });
    // }
    /* handleKeyPress(event) {
         const allowedKeys = [8];
         const numericKeys = /^[0-9]$/;
 
         if (!allowedKeys.includes(event.keyCode) && !numericKeys.test(event.key)) {
             event.preventDefault();
         }
     }*/
    // Receipt Logic End
    // changeBookingdate(event) {
    //     try {
    //         this.bookingDate = event.target.value;
    //         console.log(this.bookingDate);
    //     } catch (error) {

    //         console.error(error.message);
    //     }
    // }
    // changeTentativedate(event) {
    //     try {
    //         this.tentativeDate = event.target.value;
    //         console.log(this.tentativeDate);
    //     } catch (error) {
    //         console.error(error.message);
    //     }
    // }

    // handlemode() {
    //     let modeoffunding = this.template.querySelector("[data-id='Mode_of_Funding__c']");
    //     this.getmodeoffunding = modeoffunding ? modeoffunding.value : null;
    //     console.log(this.getmodeoffunding);
    // }
    // handleTypeofBooking() {
    //     let typeofBooking = this.template.querySelector("[data-id='Type_of_Booking__c']");
    //     this.getTypeofBooking = typeofBooking ? typeofBooking.value : null;
    //     console.log(this.getTypeofBooking);

    // }
    // handleOffers() {
    //     let offer = this.template.querySelector("[data-id='Any_other_offers__c']");
    //     this.getOfferValue = offer ? offer.value : null;
    //     console.log('this.getOfferValue: ' + this.getOfferValue);
    // }
    // handleRemarks() {
    //     let remarks = this.template.querySelector("[data-id='Remarks__c']");
    //     this.remarks = remarks ? remarks.value : null;
    //     console.log('Remarks: ' + this.remarks);
    // }
    // handlePayment() {
    //     let payementRemarks = this.template.querySelector("[data-id='Payment_Remarks__c']");
    //     this.getpayementRemarks = payementRemarks ? payementRemarks.value : null;
    // }

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
            const isValid = !!ap.Mobile_Number__c;
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

    isPermanentAddressValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Permanent_Address__c;
            //alert('isValid: ' + isValid);
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isCountryValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.Country__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isStateValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.State__c;
            if (!isValid) {
                allValid = false;
                break;
            }
        }
        return allValid;
    }
    isPincodeValid() {
        const allApplicants = this.getApplicantData;
        let allValid = true;
        for (const applicant of allApplicants) {
            const { ap } = applicant;
            const isValid = !!ap.PIN__c;
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
            const isValid = !!ap.Type_Of_Applicant__c;
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
    //check file size convertor
    /* handlebyteConverter(bytes, decimals, only) {
         const K_UNIT = 1024;
         const SIZES = ["Bytes", "KB", "MB", "GB", "TB", "PB"];
         if(bytes== 0) return "0 Byte";
         if(only==="MB") return (bytes / (K_UNIT*K_UNIT)).toFixed(decimals) + " MB" ;
         let i = Math.floor(Math.log(bytes) / Math.log(K_UNIT));
         let resp = parseFloat((bytes / Math.pow(K_UNIT, i)).toFixed(decimals)) + " " + SIZES[i];
         return resp;
     }*/

    /* handleDoctype(event){
         let index = parseInt(event.target.dataset.id);
         console.log('index: '+index);
         let applicantkey = event.target.dataset.applicantkey;
         console.log('applicantkey: '+applicantkey);
         let fieldName = event.target.name;
         console.log('fieldName: '+fieldName);
         let value = event.target.value;
         console.log('value: '+value);
         for (let i = 0; i < this.getApplicantData.length; i++) {
             var documentsArray = this.getApplicantData[i].documents;
             for (let j = 0; j < documentsArray.length; j++) {
                 if (documentsArray[j].key === applicantkey) {
                     console.log('documentsArraykey', JSON.stringify(documentsArray[j].key));
                     const matchingDocument = documentsArray.find(doc => doc.index === index);
                     if (matchingDocument) {
                         matchingDocument[fieldName] = value;
                     }
                 }
             }
             this.getApplicantData[i].documents = documentsArray;
         }
     }*/

    openfileUpload(event) {
        var getSize = event.target.files[0].size;
        // this.filesize = this.handlebyteConverter((event.target.files[0].size), 2);
        console.log('filesize: ' + this.filesize);
        let index = parseInt(event.target.dataset.id);
        let applicantkey = event.target.dataset.applicantkey;
        console.log('applicantkey', applicantkey);
        let fieldName = event.target.name;
        let value = event.target.value;
        console.log(value);

        for (let i = 0; i < this.getApplicantData.length; i++) {
            var documentsArray = this.getApplicantData[i].documents;
            for (let j = 0; j < documentsArray.length; j++) {
                if (documentsArray[j].key === applicantkey) {
                    console.log('documentsArraykey', JSON.stringify(documentsArray[j].key));
                    const matchingDocument = documentsArray.find(doc => doc.index === index);
                    if (matchingDocument) {
                        matchingDocument[fieldName] = value;
                        if (event.target.files.length > 0) {
                            const file = event.target.files[0];
                            var reader = new FileReader();
                            reader.onload = () => {
                                var base64 = reader.result.split(",")[1];
                                matchingDocument.filename = file.name;
                                matchingDocument.base64 = base64;
                                //matchingDocument.filesize = this.filesize;
                            };
                            if (getSize > 3145728) {
                                alert('File size exceeds 3 MB. Please choose a smaller file.');
                                return;
                            }
                            reader.readAsDataURL(file);
                        }
                        this.getApplicantData[i].documents = documentsArray;
                    }
                }
            }
        }
    }


    // handleselffundingpickList() {
    //     let selffunding = this.template.querySelector("[data-id='Self_funding__c']");
    //     this.getSelfFunding = selffunding ? selffunding.value : null;
    //     console.log('selffunding: ' + this.getSelfFunding);
    //     if (this.getSelfFunding == 'Yes') {
    //         this.showSelfAmount = true;
    //         this.showHomeLoanAmount = false;
    //     } else if (this.getSelfFunding == 'No') {
    //         this.showSelfAmount = false;
    //         this.showHomeLoanAmount = true;
    //     }
    // }
    // handlehomeLoanpickList() {
    //     let homeloan = this.template.querySelector("[data-id='Home_Loan__c']");
    //     this.getHomeLoanpick = homeloan ? homeloan.value : null;
    //     console.log('getHomeLoanpick: ' + this.getHomeLoanpick);
    //     if (this.getHomeLoanpick == 'Yes') {
    //         this.showHomeLoanAmount = true;
    //         this.showSelfAmount = false;
    //     } else if (this.getSelfFunding == 'No') {
    //         this.showSelfAmount = true;
    //         this.showHomeLoanAmount = false;
    //     }
    // }

    // handlemodeAmount() {
    //     let amount = this.template.querySelector("[data-id='Amount__c']");
    //     this.getAmount = amount ? amount.value : null;
    //     console.log('getAmount: ' + this.getAmount);

    // }
    // handleTokenAmount() {
    //     let tokenAmount = this.template.querySelector("[data-id='Token_Booking_Amount__c']");
    //     this.getTokenAmt = tokenAmount ? tokenAmount.value : null;
    //     console.log('getTokenAmt: ' + this.getTokenAmt);

    // }
    // handleTokenAmountDate() {
    //     let tokenAmountDate = this.template.querySelector("[data-id='Token_Booking_Amount_Date__c']");
    //     this.getTokenAmtDate = tokenAmountDate ? tokenAmountDate.value : null;
    //     console.log('handleTokenAmountDate: ' + this.getTokenAmtDate);

    // }
    // handleOwna() {
    //     let ownContributiona = this.template.querySelector("[data-id='Own_Contribution_a__c']");
    //     this.getownContributiona = ownContributiona ? ownContributiona.value : null;
    //     console.log('getownContributiona: ' + this.getownContributiona);

    // }
    // handleOwnDatea() {
    //     let ownContributionaDate = this.template.querySelector("[data-id='Own_Contribution_a_Date__c']");
    //     this.getownContributionaDate = ownContributionaDate ? ownContributionaDate.value : null;
    //     console.log('getownContributionaDate: ' + this.getownContributionaDate);

    // }
    // handleOwnb() {
    //     let ownContributionb = this.template.querySelector("[data-id='Own_Contribution_b__c']");
    //     this.getownContributionb = ownContributionb ? ownContributionb.value : null;
    //     console.log('getownContributionb: ' + this.getownContributionb);

    // }
    // handleOwnDateb() {
    //     let ownContributionbDate = this.template.querySelector("[data-id='Own_Contribution_b_Date__c']");
    //     this.getownContributionbDate = ownContributionbDate ? ownContributionbDate.value : null;
    //     console.log('getownContributionbDate: ' + this.getownContributionbDate);

    // }
    // handleOwnc() {
    //     let ownContributionb = this.template.querySelector("[data-id='Own_Contribution_c__c']");
    //     this.getownContributionc = ownContributionb ? ownContributionb.value : null;
    //     console.log('getownContributionb: ' + this.getownContributionb);

    // }
    // handleOwnDatec() {
    //     let ownContributionbDate = this.template.querySelector("[data-id='Own_Contribution_c_Date__c']");
    //     this.getownContributioncDate = ownContributionbDate ? ownContributionbDate.value : null;
    //     console.log('getownContributionbDate: ' + this.getownContributionbDate);

    // }
    // handleHomeLoan() {
    //     let HomeLoan = this.template.querySelector("[data-id='Home_Loan_Contribution_Self_Funding__c']");
    //     this.getHomeLoan = HomeLoan ? HomeLoan.value : null;
    //     console.log('getHomeLoan: ' + this.getHomeLoan);

    // }
    // handleHomeLoanDate() {
    //     let HomeLoanDate = this.template.querySelector("[data-id='Home_Loan_Date__c']");
    //     this.getHomeLoanDate = HomeLoanDate ? HomeLoanDate.value : null;
    //     console.log('getHomeLoanDate: ' + this.getHomeLoanDate);

    // }
    // handleGSTAmount() {
    //     let GSTAmount = this.template.querySelector("[data-id='GST_Amount__c']");
    //     this.getGSTAmount = GSTAmount ? GSTAmount.value : null;
    //     console.log('getGSTAmount: ' + this.getGSTAmount);

    // }
    // handleGSTAmountDate() {
    //     let GSTAmountDate = this.template.querySelector("[data-id='GST_Amount_Date__c']");
    //     this.getGSTAmountDate = GSTAmountDate ? GSTAmountDate.value : null;
    //     console.log('getGSTAmountDate: ' + this.getGSTAmountDate);

    // }
    // handleSDRAmount() {
    //     let SDRAmount = this.template.querySelector("[data-id='SDR_Amount__c']");
    //     this.getSDRAmount = SDRAmount ? SDRAmount.value : null;
    //     console.log('getSDRAmount: ' + this.getSDRAmount);

    // }
    // handleSDRAmountDate() {
    //     let SDRAmountDate = this.template.querySelector("[data-id='SDR_Amount_Date__c']");
    //     this.getSDRAmountDate = SDRAmountDate ? SDRAmountDate.value : null;
    //     console.log('getSDRAmountDate: ' + this.getSDRAmountDate);

    // }
    // handleselffundingAmount() {
    //     let selffundingAmount = this.template.querySelector("[data-id='Self_Funding_Amount__c']");
    //     this.getSelfFundingAmount = selffundingAmount ? selffundingAmount.value : null;
    //     console.log('getSelfFundingAmount: ' + this.getSelfFundingAmount);

    // }

    handleSave() {

        if (!this.isPrimaryApplicantDataValid()) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Salutation , Name and Applicant Number',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (!this.isPermanentAddressValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Permanent Address',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.isCountryValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Select Country',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (!this.isStateValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Select State',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.isPincodeValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter PinCode',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.ismobilenumberValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Mobile Number',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (!this.isDOBValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Date of Birth',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (!this.isTypeOfApplicantValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Type of Appliacant',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.isaadharValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Aadhar Number',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.isPanValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Pan Number',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (!this.isResidentialValid()) {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Residential Status',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (this.bkWrapper.bk.Payment_Remarks__c === undefined || this.bkWrapper.bk.Payment_Remarks__c === '') {
            const event = new ShowToastEvent({

                title: 'Error',
                message: 'Please Enter Payement Remarks',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.bkWrapper.bk.Mode_of_Funding__c === undefined || this.bkWrapper.bk.Mode_of_Funding__c === '') {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Funding Details',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Token_Booking_Amount__c === undefined || this.termSheetWrapper.ts.Token_Booking_Amount__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide a Token Booking Amount greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Own_Contribution_a__c === undefined || this.termSheetWrapper.ts.Own_Contribution_a__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Own Contribution (a) greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Own_Contribution_b__c === undefined || this.termSheetWrapper.ts.Own_Contribution_b__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Own Contribution (b) greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Own_Contribution_c__c === undefined || this.termSheetWrapper.ts.Own_Contribution_c__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Own Contribution (c) greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Own_Contribution_d__c === undefined || this.termSheetWrapper.ts.Own_Contribution_d__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Own Contribution (d) greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.Own_Contribution_e__c === undefined || this.termSheetWrapper.ts.Own_Contribution_e__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide Own Contribution (e) greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if (this.termSheetWrapper.ts.Home_Loan_Contribution_Self_Funding__c === undefined || this.termSheetWrapper.ts.Home_Loan_Contribution_Self_Funding__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide a Home Loan Contribution Amount greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.GST_Amount__c === undefined || this.termSheetWrapper.ts.GST_Amount__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide GST Amount greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else if (this.termSheetWrapper.ts.SDR_Amount__c === undefined || this.termSheetWrapper.ts.SDR_Amount__c <= 0) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Provide SDR Amount greater than zero',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }



        // else if (this.getSelfFunding == 'No' && this.getHomeLoanpick == 'No') {
        //     const event = new ShowToastEvent({
        //         title: 'Error',
        //         message: 'Please Provide Funding No',
        //         variant: 'error',
        //     });
        //     this.dispatchEvent(event);
        //     return;
        // }
        else {
            // alert('Save:');
            // alert('Applicant Data::' + JSON.stringify(this.getApplicantData));
            // alert('Quotation Details :: ' + JSON.stringify(this.getQuotationDetails));
            // alert('bkWrapper   ' + JSON.stringify(this.bkWrapper));
            // alert('termSheetWrapper: ' + JSON.stringify(this.termSheetWrapper));
            this.isSpinner = true;
            createBookingRecord({
                quotationDetails: this.getQuotationDetails,
                applicantData: JSON.stringify(this.getApplicantData),
                bookingAccount: this.testData,
                BookingWrapper: this.bkWrapper,
                termSheetWrapper: this.termSheetWrapper
            })
                .then(result => {
                    console.log('Applicant Data:', JSON.stringify(this.applicantData));
                    console.log('Booking record inserted successfully:', result);
                    this.isSpinner = false;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        }
                    });

                })
        }
    }
}