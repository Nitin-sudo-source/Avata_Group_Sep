import { LightningElement, api, track, wire } from 'lwc';
import getApplicants from '@salesforce/apex/Ex_WelcomeCallChecklistController.getApplicants';
import getApplicantDocuments from '@salesforce/apex/Ex_WelcomeCallChecklistController.getApplicantDocuments';
import getQuotationDetails from '@salesforce/apex/Ex_WelcomeCallChecklistController.getQuotationDetails';
import getTokenAmount from '@salesforce/apex/Ex_WelcomeCallChecklistController.getTokenAmount';
import getSourceDetails from '@salesforce/apex/Ex_WelcomeCallChecklistController.getSourceDetails';
import getRejectedChecklist from '@salesforce/apex/Ex_WelcomeCallChecklistController.getRejectedChecklist';
import updateChecklistAction from '@salesforce/apex/Ex_WelcomeCallChecklistController.updateChecklistAction';
import save from '@salesforce/apex/Ex_WelcomeCallChecklistController.save';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_WelcomeCallChecklist extends NavigationMixin(LightningElement) {
    @api recordId;
    @track applicants = [];
    @track rejectedChecklist = [];
    @track showRejectedChecklist = false;
    @track groupedRejectedChecklist = [];
    @api paymentScheme;
    @api tower;
    @api unit;
    @api agreementValue;
    @api unitValue;
    @track PSId = null;
    @api showChild = false;
    @api token;
    @api sourceDetails;
    @api showSource = false;
    @api showCP = false;
    @api showConflict = false;
    @api showReference = false;
    @api cp1;
    @api cp2;
    @api refer;
    @api isConflict;
    @track actionArray = [];
    @track aadharArray = [];
    @track panArray = [];
    @track mobileArray = [];
    @track emailArray = [];
    @track allArray = [];
    changes = {};

    @track agreementValue;
    @track agreementValueTax;
    @track agreementTotal; // New variable for the sum of amount and tax

    @track SDRValue;
    @track SDRTax;
    @track SDRTotal; // New variable for the sum of amount and tax

    @track OCValue;
    @track OCTax;
    @track OCTotal; 

    @track totalPrice = 0;
    @track totalPriceFormatted = '';
    @track isLoaded = false;

    
    



    // @api showError = false;

    @wire(getApplicants, { recId: '$recordId' })
    getApplicantData({ data, error }) {
        if (data) {
            this.applicants = data.map((applicant, index) => {
                return { ...applicant, displayIndex: index + 1 };
            });
            console.log('this.applicants::' + JSON.stringify(this.applicants));
        } else if (error) {
            this.error = error;
            console.log('this.error is::' + JSON.stringify(this.error));
        }
    }

    renderedCallback() {
        if (this.isLoaded)
            return;
        const STYLE = document.createElement("style");
        STYLE.innerText = `.uiModal--medium .modal-container{
width: 100% !important;
max-width: 95%;
min-width: 480px;
max-height:100%;
min-height:480px;
};`
        this.template.querySelector('lightning-card').appendChild(STYLE);
        this.isLoaded = true;
    }

    viewDocument(event) {
        const appId = event.target.dataset.id;
        const docType = event.target.dataset.docType;
    
        if (appId) {
            getApplicantDocuments({ appId: appId })
                .then((data) => {
                    this.docData = data;
                    const filteredDocs = this.docData.filter(docWrapper => docWrapper.documentType === docType);
                    console.log('filteredDocs: '+JSON.stringify(filteredDocs));
    
                    if (filteredDocs.length > 0) {
                        filteredDocs.forEach((docWrapper, index) => {
                            setTimeout(() => {
                                // Use the ContentVersion ID for download
                                // const encodedFileId = encodeURIComponent(docWrapper.fileId);
                                // // Use the correct download URL for ContentVersion
                                // const downloadUrl = `/sfc/servlet.shepherd/document/download/${encodedFileId}`;
                                console.log(`Opening download URL: ${docWrapper.documentViewLink}`);
                                window.open(docWrapper.documentViewLink, '_blank');
                            }, index * 500); // Optional delay between downloads
                        });
                    } else {
                        console.error('No attachments found for the document type');
                    }
                })
                .catch((error) => {
                    this.error = error;
                    console.log('Error retrieving documents:', JSON.stringify(this.error));
                });
        }
    }


    
    
    


    // @wire(getQuotationDetails, { recId: '$recordId' })
    // getQuotationData({ data, error }) {
    //     if (data) {
    //         console.log('data is::' + JSON.stringify(data));
    //         this.paymentScheme = data[0].Payment_Scheme__r.Name;
    //         this.paymentSchemeId = data[0].Payment_Scheme__c;
    //         this.tower = data[0].Tower__r.Name;
    //         this.unit = data[0].Unit__r.Name;

    //         if(String.isNotBlank(quote.Quotation_Status__c) && (quote.Quotation_Status__c.equalsIgnoreCase('Valid') || quote.Quotation_Status__c.equalsIgnoreCase('Approved'))) {
    //             for(Integer i = 1; i <= 3; i++) {
    //                 if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Agreement Value')) {
    //                     agreementValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
    //                     agreementValueTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
    //                 }
    //                 if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Statutory Charges')) {
    //                     SDRValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
    //                     SDRTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
    //                 }
    //                  if(String.isNotBlank((String)quote.get('Charge_Bucket_'+i+'__c')) && ((String)quote.get('Charge_Bucket_'+i+'__c')).equalsIgnoreCase('Other Charges')) {
    //                     OCValue = (Decimal)quote.get('Charge_Bucket_'+i+'_Amount__c');
    //                     OCTax = (Decimal)quote.get('Charge_Bucket_'+i+'_Total_Tax__c');
    //                 }
    //             }
    //         }

    //         this.agrValue1 = data[0].Agreement_Value1__c;
    //         if(this.agrValue1 != null || this.agrValue1 != undefined){
    //             this.agrValue = this.agrValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.sdrValue1 = data[0].SDR__c;
    //         if(this.sdrValue1 != null || this.sdrValue1 != undefined){
    //             this.sdrValue = this.sdrValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.otherCharges1 = data[0].Other_Charges__c;
    //         if(this.otherCharges1 != null || this.otherCharges1 != undefined){
    //             this.otherCharges = this.otherCharges1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.agrGstValue1 = data[0].GST_on_Agreement_Value__c;
    //         if(this.agrGstValue1 != null || this.agrGstValue1 != undefined){
    //             this.agrGstValue = this.agrGstValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.totalAgrValue1 = data[0].Total_Agreement_Value__c;
    //         if(this.totalAgrValue1 != null || this.totalAgrValue1 != undefined){
    //             this.totalAgrValue = this.totalAgrValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.otherGstValue1 = data[0].GST_on_Other_Charges__c;
    //         if(this.otherGstValue1 != null || this.otherGstValue1 != undefined){
    //             this.otherGstValue = this.otherGstValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.totalOtherValue1 = data[0].Total_Other_Charges__c;
    //         if(this.totalOtherValue1 != null || this.totalOtherValue1 != undefined){
    //             this.totalOtherValue = this.totalOtherValue1.toLocaleString('en-IN') + '/-';
    //         }

    //         this.carPark1 = data[0].Total_Car_Park_Amount__c;
    //         if(this.carPark1 != null || this.carPark1 != undefined){
    //             this.carPark = this.carPark1.toLocaleString('en-IN') + '/-';
    //         }


    //         this.deviation = data[0].Payment_Schedule_Deviation__c;
    //         this.carpet = data[0].Unit__r.Carpet_Area__c;
    //         this.saleable = data[0].Unit__r.Saleable_Area__c;
    //         console.log('this.unit is::' + this.unit);
    //         if (data[0].Total_Cost_of_Unit__c != null) {
    //             this.unitVal = data[0].Total_Cost_of_Unit__c;
    //             this.unitValue = this.unitVal.toLocaleString('en-IN') + '/-';
    //         } else {
    //             this.unitValue = 0;
    //         }
    //         console.log('this.unitValue is::' + this.unitValue);
    //         if (data[0].Booking__r.Agreement_Value__c != null) {
    //             this.agrVal = data[0].Booking__r.Agreement_Value__c;
    //             this.agreementValue = this.agrVal.toLocaleString('en-IN') + '/-';
    //         } else {
    //             this.agreementValue = 0;
    //         }
    //         console.log('this.agreementValue is::' + this.agreementValue);

    //     } else if (error) {
    //         this.error = error;
    //         console.log('this.error is::' + JSON.stringify(this.error));
    //     }
    // }

    @wire(getQuotationDetails, { recId: '$recordId' })
    getQuotationData({ data, error }) {
        if (data) {
            console.log('data is::' + JSON.stringify(data));
            this.paymentScheme = data[0].Payment_Scheme__r.Name;
            this.paymentSchemeId = data[0].Payment_Scheme__c;
            this.tower = data[0].Tower__r.Name;
            this.unit = data[0].Unit__r.Name;

           // Handle quotation status
if (data[0].Quotation_Status__c && 
    (data[0].Quotation_Status__c.toLowerCase() === 'valid' || 
    data[0].Quotation_Status__c.toLowerCase() === 'approved')) {
        this.totalPrice = 0;
    
    for (let i = 1; i <= 3; i++) {
        const chargeBucket = data[0][`Charge_Bucket_${i}__c`];
        const chargeAmount = data[0][`Charge_Bucket_${i}_Amount__c`];
        const totalTax = data[0][`Charge_Bucket_${i}_Total_Tax__c`];

        console.log(`Processing Charge_Bucket_${i}:`, chargeBucket);
        console.log(`Charge Amount for Charge_Bucket_${i}:`, chargeAmount);
        console.log(`Total Tax for Charge_Bucket_${i}:`, totalTax);

        if (chargeBucket) {
            if (chargeBucket.toLowerCase() === 'agreement value') {
                this.agreementValue = chargeAmount ? chargeAmount.toLocaleString('en-IN') + '/-' : '0/-';
                this.agreementValueTax = totalTax ? totalTax.toLocaleString('en-IN') + '/-' : '0/-';
                this.agreementTotal = chargeAmount ? 
                                      (chargeAmount + totalTax).toLocaleString('en-IN') + '/-' : '0/-';
                                      this.totalPrice += chargeAmount ? (chargeAmount + totalTax) : 0;

                console.log(`Formatted Agreement Value:`, this.agreementValue);
                console.log(`Formatted Agreement Value Tax:`, this.agreementValueTax);
                console.log(`Formatted Agreement Total:`, this.agreementTotal);
            } else if (chargeBucket.toLowerCase() === 'statutory charges') {
                this.SDRValue = chargeAmount ? chargeAmount.toLocaleString('en-IN') + '/-' : '0/-';
                this.SDRTax = totalTax ? totalTax.toLocaleString('en-IN') + '/-' : '0/-';
                this.SDRTotal = chargeAmount? 
                                (chargeAmount + totalTax).toLocaleString('en-IN') + '/-' : '0/-';
                                this.totalPrice += chargeAmount ? (chargeAmount + totalTax) : 0;

                console.log(`Formatted SDR Value:`, this.SDRValue);
                console.log(`Formatted SDR Tax:`, this.SDRTax);
                console.log(`Formatted SDR Total:`, this.SDRTotal);
            } else if (chargeBucket.toLowerCase() === 'other charges') {
                this.OCValue = chargeAmount ? chargeAmount.toLocaleString('en-IN') + '/-' : '0/-';
                this.OCTax = totalTax ? totalTax.toLocaleString('en-IN') + '/-' : '0/-';
                this.OCTotal = chargeAmount  ? 
                               (chargeAmount + totalTax).toLocaleString('en-IN') + '/-' : '0/-';
                               this.totalPrice += chargeAmount ? (chargeAmount + totalTax) : 0;

                console.log(`Formatted Other Charges Value:`, this.OCValue);
                console.log(`Formatted Other Charges Tax:`, this.OCTax);
                console.log(`Formatted Other Charges Total:`, this.OCTotal);
            }
        }
    }
}

this.totalPriceFormatted = this.totalPrice ? this.totalPrice.toLocaleString('en-IN') + '/-' : '0/-';
console.log(`Total Price of all Charges:`, this.totalPriceFormatted);


this.carPark1 = data[0].Car_Park_Required_Count__c;
        if(this.carPark1 != null || this.carPark1 != undefined){
            this.carPark = this.carPark1.toLocaleString('en-IN') + '/-';
        }





            //this.deviation = data[0].Payment_Schedule_Deviation__c;
            this.carpet = data[0].Unit__r.Total_carpet_Sq_Ft__c;
            this.saleable = data[0].Unit__r.Saleable_Area__c;

            console.log('this.unit is::' + this.unit);
            console.log('this.unitValue is::' + this.unitValue);
            console.log('this.agreementValue is::' + this.agreementValue);
        } else if (error) {
            this.error = error;
            console.log('this.error is::' + JSON.stringify(this.error));
        }
    }

    getFieldValue(data, field) {
        return field.split('.').reduce((o, key) => (o || {})[key], data);
    }


    @wire(getTokenAmount, ({ recId: '$recordId' })) getToken({ data, error }) {
        if (data) {
            console.log('receipt data : ', data);
            this.tkamt = data;
            this.token = this.tkamt.toLocaleString('en-IN') + '/-';
            console.log('this.token is::' + this.token);
        } else if (error) {
            this.error = error;
            console.log('this.error of receipt is::' + JSON.stringify(this.error));
        }
    }

    @wire(getSourceDetails, ({ recId: '$recordId' })) getSource({ data, error }) {
        if (data) {
            console.log('source data is::' + JSON.stringify(data));
            this.sourceDetails = data[0].Source__c;
            console.log('this.sourceDetails is::' + this.sourceDetails);
           // this.isConflict = data[0].Is_CP_Conflict__c;

            if (this.sourceDetails == 'Channel Partner') {
                if (data[0].First_CP__r.Name != null || data[0].First_CP__r.Name != undefined || data[0].First_CP__r.Name != '') {
                    this.cp1 = data[0].First_CP__r.Name;
                    console.log('this.cp1 is::' + this.cp1);
                }
                this.showCP = true;
                this.showConflict = false;
                this.showReference = false;
                this.showSource = false;
            } else if (this.sourceDetails == 'Channel Partner') {
                if (data[0].Is_CP_Conflict__c != null || data[0].Is_CP_Conflict__c != undefined || data[0].Is_CP_Conflict__c != '') {
                    this.isConflict = data[0].Is_CP_Conflict__c;
                    console.log('this.isConflict is::' + this.isConflict);
                }
                if (data[0].First_CP__r.Name != null || data[0].First_CP__r.Name != undefined || data[0].First_CP__r.Name != '') {
                    this.cp1 = data[0].First_CP__r.Name;
                    console.log('this.cp1 is::' + this.cp1);
                }
                // if (data[0].Second_CP__r.Name != null || data[0].Second_CP__r.Name != undefined || data[0].Second_CP__r.Name != '' ) {
                //     this.cp2 = data[0].Second_CP__r.Name;
                //     console.log('this.cp2 is::' + this.cp2);
                // }
                if (data[0].Second_CP__r && data[0].Second_CP__r.Name) {
                    this.cp2 = data[0].Second_CP__r.Name;
                    console.log('this.cp2 is::' + this.cp2);
                }
                this.showConflict = true;
                this.showCP = false;
                this.showReference = false;
                this.showSource = false;
            } else if (this.sourceDetails == 'Reference') {
                // if (data[0].Referrer_Name__r.Name != null || data[0].Referrer_Name__r.Name != undefined || data[0].Referrer_Name__r.Name != '')  {
                //     this.refer = data[0].Referrer_Name__r.Name;
                //     console.log('this.refer is::' + this.refer);
                // }
                if (data[0].Referrer_Name__r && data[0].Referrer_Name__r.Name) {
                    this.refer = data[0].Referrer_Name__r.Name;
                    console.log('this.cp2 is::' + this.cp2);
                }
                this.showReference = true;
                this.showCP = false;
                this.showConflict = false;
                this.showSource = false;
            } else {
                this.showSource = true;
                this.showReference = false;
                this.showCP = false;
                this.showConflict = false;
            }
        }
    }

    @wire(getRejectedChecklist, ({ recId: '$recordId' }))
    getRejectedChecklistData({ data, error }) {
        if (data) {
            console.log('getRejectedChecklist : ', JSON.stringify(data));
            if (data.length > 0) {
                // Group the checklist items by their sections
                const groupedData = {};
                data.forEach(item => {
                    if (!groupedData[item.Section__c]) {
                        groupedData[item.Section__c] = [];
                    }
                    groupedData[item.Section__c].push(item);
                });

                // Convert the grouped data to an array format
                this.groupedRejectedChecklist = Object.keys(groupedData).map(section => ({
                    sectionName: section,
                    items: groupedData[section]
                }));
                console.log('this.groupedRejectedChecklist : ', JSON.stringify(this.groupedRejectedChecklist));

                this.showRejectedChecklist = true;
                //this.showError = false; 
            } else {
                this.showRejectedChecklist = false;
                //this.showError = true;
            }
        } else if (error) {
            this.error = error;
            console.log('this.error is::' + JSON.stringify(this.error));
            this.showRejectedChecklist = false;
        }
    }


    @track newList = [];

    handleExistingAction(event) {
        const checklistId = event.target.dataset.id;
        // console.log('checklistId : ',checklistId);

        const actionValue = event.target.value;
        // console.log('actionValue : ',actionValue);

        const key = parseInt(event.target.dataset.key);
        // console.log('Key .: ',key);

        const ind = parseInt(event.target.dataset.index);
        // console.log('Index .: ',ind);

        const category = this.groupedRejectedChecklist[key];
        // console.log('category : ',JSON.stringify(category));

        const item = category.items[ind];
        // console.log('item : ',JSON.stringify(item));

        let record = this.newList.find(data => data.Id === checklistId);
        // console.log('record found .: ', JSON.stringify(record));

        if (record) {
            record.Action__c = actionValue;
        } else {
            this.newList.push({ ...item, Action__c: actionValue });
        }

        // console.log('newList : ',JSON.stringify(this.newList));


        this.changes[checklistId] = actionValue;
        console.log('OUTPUT : ', this.changes[checklistId]);
        console.log('this.changes : ', JSON.stringify(this.changes));

        // console.log('Updated groupedRejectedChecklist: ', JSON.stringify(this.groupedRejectedChecklist));
    }

    updateAccount() {
        // Check if all actions are either 'Accept' or 'Reject' within each section
        const allValidActions = this.newList.every(data => data.Action__c === 'Accept' || data.Action__c === 'Reject');
        // console.log('All records have valid actions:', allValidActions);

        if (!allValidActions) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'All actions should be either "Accept" or "Reject".',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }

        // Send the groupedRejectedChecklist to the Apex method
        updateChecklistAction({ bcList: this.newList })
            .then(() => {
                console.log('All records updated successfully');
                // Clear changes after saving
                this.newList = [];
                this.showRejectedChecklist = false;
                this.navigateToRecordPage();
            })
            .catch(error => {
                console.error('Error updating records: ', error);
            });
    }


    handleAction(evt) {

        let name = evt.target.name;
        console.log('name :::' + name);
        const index = evt.target.dataset.index;
        console.log('index is::' + index);
        const sectionDiv = evt.target.closest('.section-div');
        const sectionName = sectionDiv ? sectionDiv.getAttribute('data-section') : null;
        console.log('sectionName is::' + sectionName);

        const actionValue = evt.target.value;
        console.log('actionValue is::' + actionValue);

        let section, item;
        if (sectionName === 'section1') {
            section = this.template.querySelector(`h2[name='section1']`).innerText;
            item = this.template.querySelectorAll(`p[name='section1']`)[index].innerText;
        } else if (sectionName === 'section2') {
            section = this.template.querySelector(`h2[name='section2']`).innerText;
            item = this.template.querySelectorAll(`p[name='section2']`)[index].innerText;
        } else if (sectionName === 'section4') {
            section = this.template.querySelector(`h2[name='section4']`).innerText;
            item = this.template.querySelectorAll(`p[name='section4']`)[index].innerText;
        }
        else if (sectionName === 'section5') {
            section = this.template.querySelector(`h2[name='section5']`).innerText;
            item = this.template.querySelectorAll(`p[name='section5']`)[index].innerText;
        }
        else if (sectionName === 'section6') {
            section = this.template.querySelector(`h2[name='section6']`).innerText;
            item = this.template.querySelectorAll(`p[name='section6']`)[index].innerText;
        }
        else if (sectionName === 'section7') {
            section = this.template.querySelector(`h2[name='section7']`).innerText;
            item = this.template.querySelectorAll(`p[name='section7']`)[index].innerText;
        }
        else if (sectionName === 'section8') {
            section = this.template.querySelector(`h2[name='section8']`).innerText;
            item = this.template.querySelectorAll(`p[name='section8']`)[index].innerText;
        }
        else if (sectionName === 'section9') {
            section = this.template.querySelector(`h2[name='section9']`).innerText;
            item = this.template.querySelectorAll(`p[name='section9']`)[index].innerText;
        }



        if (name == "aadhar") {
            if (sectionName === 'section3') {
                section = this.template.querySelector(`h2[name='section3']`).innerText;
                let item1 = this.template.querySelectorAll(`p[name='section3']`)[index].innerText;
                let item2 = this.template.querySelectorAll(`p[name='section3a']`)[index].innerText;
                item = item1 + ' - ' + item2;
            }

            this.aadharArray = this.aadharArray ? [... this.aadharArray] : [];
            const duplicateIndex = this.aadharArray.findIndex(entry =>
                entry.Section__c === section &&
                entry.Item__c === item &&
                entry.Booking__c === this.recordId
            );

            if (duplicateIndex === -1) {
                this.aadharArray.push({
                    Section__c: section,
                    Item__c: item,
                    Action__c: actionValue,
                    Booking__c: this.recordId
                });

                console.log('Updated aadharArray:', JSON.stringify(this.aadharArray));
            } else {
                this.aadharArray[duplicateIndex].Action__c = actionValue;
                console.log('Action value updated in aadharArray:', JSON.stringify(this.aadharArray));
            }
        } else if (name == "pan") {
            if (sectionName === 'section3') {
                section = this.template.querySelector(`h2[name='section3']`).innerText;
                let item1 = this.template.querySelectorAll(`p[name='section3']`)[index].innerText;
                let item2 = this.template.querySelectorAll(`p[name='section3b']`)[index].innerText;
                item = item1 + ' - ' + item2;
            }
            this.panArray = this.panArray ? [...this.panArray] : [];
            const duplicateIndex = this.panArray.findIndex(entry =>
                entry.Section__c === section &&
                entry.Item__c === item &&
                entry.Booking__c === this.recordId
            );

            if (duplicateIndex === -1) {
                this.panArray.push({
                    Section__c: section,
                    Item__c: item,
                    Action__c: actionValue,
                    Booking__c: this.recordId
                });

                console.log('Updated panArray:', JSON.stringify(this.panArray));
            } else {
                this.panArray[duplicateIndex].Action__c = actionValue;
                console.log('Action value updated in panArray:', JSON.stringify(this.panArray));
            }
        } else if (name == "mobile") {
            if (sectionName === 'section4') {
                section = this.template.querySelector(`h2[name='section4']`).innerText;
                let item1 = this.template.querySelectorAll(`p[name='section4']`)[index].innerText;
                let item2 = this.template.querySelectorAll(`p[name='section4a']`)[index].innerText;
                item = item1 + ' - ' + item2;
            }
            this.mobileArray = this.mobileArray ? [...this.mobileArray] : [];
            const duplicateIndex = this.mobileArray.findIndex(entry =>
                entry.Section__c === section &&
                entry.Item__c === item &&
                entry.Booking__c === this.recordId
            );

            if (duplicateIndex === -1) {
                this.mobileArray.push({
                    Section__c: section,
                    Item__c: item,
                    Action__c: actionValue,
                    Booking__c: this.recordId
                });

                console.log('Updated mobileArray:', JSON.stringify(this.mobileArray));
            } else {
                this.mobileArray[duplicateIndex].Action__c = actionValue;
                console.log('Action value updated in mobileArray:', JSON.stringify(this.mobileArray));
            }
        }
        else if (name == "email") {
            if (sectionName === 'section4') {
                section = this.template.querySelector(`h2[name='section4']`).innerText;
                let item1 = this.template.querySelectorAll(`p[name='section4']`)[index].innerText;
                let item2 = this.template.querySelectorAll(`p[name='section4b']`)[index].innerText;
                item = item1 + ' - ' + item2;
            }
            this.emailArray = this.emailArray ? [...this.emailArray] : [];
            const duplicateIndex = this.emailArray.findIndex(entry =>
                entry.Section__c === section &&
                entry.Item__c === item &&
                entry.Booking__c === this.recordId
            );

            if (duplicateIndex === -1) {
                this.emailArray.push({
                    Section__c: section,
                    Item__c: item,
                    Action__c: actionValue,
                    Booking__c: this.recordId
                });

                console.log('Updated emailArray:', JSON.stringify(this.emailArray));
            } else {
                this.emailArray[duplicateIndex].Action__c = actionValue;
                console.log('Action value updated in emailArray:', JSON.stringify(this.emailArray));
            }
        } else {
            this.actionArray = this.actionArray ? [...this.actionArray] : [];
            const duplicateIndex = this.actionArray.findIndex(entry =>
                entry.Section__c === section &&
                entry.Item__c === item &&
                entry.Booking__c === this.recordId
            );

            if (duplicateIndex === -1) {
                this.actionArray.push({
                    Section__c: section,
                    Item__c: item,
                    Action__c: actionValue,
                    Booking__c: this.recordId
                });

                console.log('Updated actionArray:', JSON.stringify(this.actionArray));
            } else {
                this.actionArray[duplicateIndex].Action__c = actionValue;
                console.log('Action value updated in actionArray:', JSON.stringify(this.actionArray));
            }
        }
        this.allArray = [
            ...(this.actionArray || []),
            ...(this.aadharArray || []),
            ...(this.panArray || []),
            ...(this.mobileArray || []),
            ...(this.emailArray || [])
        ];
        console.log('Combined array:', JSON.stringify(this.allArray));

    }




    handlePayment(evt) {
        this.PSId = evt.currentTarget.dataset.id;
        console.log('this.PSId is::' + this.PSId);
        console.log('this.recordId is::' + this.recordId);
        if (this.PSId != null) {
            this.showChild = true;
        } else {
            this.showChild = false;
        }
    }


    handleSubmit() {
        let isValid = true;
        console.log('isValid', isValid);
        console.log('OUTPUT : ', isValid);
        let inputFields = this.template.querySelectorAll('.validate');
        console.log('OUTPUT : ', JSON.stringify(inputFields));

        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                //inputField.reportValidity();
                isValid = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in all required fields.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            }
        });
        if (isValid == true) {
            save({ bChecklist: this.allArray })
                .then(result => {
                    this.result = result;
                    console.log('result : ', JSON.stringify(this.result));
                    if (this.result == 'Record insert successfully') {
                        this.navigateToRecordPage();
                    }
                })
                .catch((error) => {
                    this.error = error;
                    console.log('this.error is::' + JSON.stringify(this.error));
                })
        }
        return isValid;
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });
        setTimeout(() => {
            window.location.reload();
        }, 1000);
    }
}