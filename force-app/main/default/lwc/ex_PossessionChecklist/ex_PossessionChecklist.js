import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMasterPossession from '@salesforce/apex/Ex_PossessionchecklistController.getMasterPossession';
import getPossessionChecklist from '@salesforce/apex/Ex_PossessionchecklistController.getPossessionChecklist';
import getBookingDetails from '@salesforce/apex/Ex_PossessionchecklistController.getBookingDetails';
import savePossessionCheckList from '@salesforce/apex/Ex_PossessionchecklistController.savePossessionCheckList';
import updatePossessionChecklistStatusFromCRMHead from '@salesforce/apex/Ex_PossessionchecklistController.updatePossessionChecklistStatusFromCRMHead';
export default class Ex_PossessionChecklist extends LightningElement {
    @api recordId;
    @track booking = [];
    @track possessionChecklistMap = [];
    @track saveArray = [];
    @track possessionChecklistArray = [];
    @track isAccManager = false;
    @track isRMUser = false;
    @track isCRMHead = false;
    @track isGuestUser = false;
    @track alreadyCheckList = false;
    @track errorMsg = '';
    @track showData = false;
    @track accountData = [];
    @track accScuccess = false;
    @track accScuccessMessage = '';
    @track isSpinner = false;
    @track checklistData = [];
    @track showSubmitButton = false;

    get processedData() {
        return this.accountData.map((item, index) => ({
            ...item,
            serialNumber: index + 1
        }));
    }

    get recOption() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get ItemStatus() {
        return [
            { label: 'Completed', value: 'Completed' },
            { label: 'Pending', value: 'Pending' },
            { label: 'NA', value: 'NA' }
        ];
    }

    async connectedCallback() {
        const urlSearchParams = new URLSearchParams(window.location.search);

        this.recordId = urlSearchParams.get('recordId');
        if (this.recordId) {
            console.log('Found recordId:', this.recordId);
        } else {
            console.log('No recordId found in the URL.');
        }

        this.isRMUser = urlSearchParams.get('isRMUser') === 'true';
        console.log('isRMUser:', this.isRMUser);

        this.isAccManager = urlSearchParams.get('isAccManager') === 'true';
        console.log('Is Acc Manager:', this.isAccManager);

        this.isCRMHead = urlSearchParams.get('isCRMHead') === 'true';
        console.log('Is isCRMHead:', this.isCRMHead);

        if (this.isRMUser) {
            this.isCRMHead = true
            this.isAccManager = true;
        }

        await this.fetchData();
    }

    @wire(getBookingDetails, { bkId: '$recordId' })
    bookings({ error, data }) {
        if (data) {
            this.registration = data.booking.Registration_Done__c;
            console.log(' this.registration : ', JSON.stringify(this.registration));
            if (this.registration !== undefined && this.registration === true) {
                this.booking = data.booking;
                console.log(' this.booking : ', JSON.stringify(this.booking));
                this.isRMUser = data.isRMUser;
                if (this.isRMUser && this.booking.RM_Possession_Checklist__c) {
                    this.alreadyCheckList = true;
                    this.errorMsg = 'RM Checklist Already Done.';
                }
                else if (!this.isCRMHead && this.isAccManager && this.booking.Account_Possession_Checklist__c) {
                    this.alreadyCheckList = true;
                    this.errorMsg = 'FM Checklist Already Done.';
                }
                else if (this.isCRMHead && this.booking.Possession_Approved_By_CRM_Head__c) {
                    this.alreadyCheckList = true;
                    this.errorMsg = 'CRM Head Approval Already Done.';
                }

                if (!this.isRMUser && !this.isAccManager && !this.isCRMHead) {
                    this.errorMsg = 'You have no access for possession checklist.';
                    this.showData = false;
                } else {
                    this.showData = true;
                }
                this.showSubmitButton = true ;

                // this.showSubmitButton = !this.isCRMHead &&
                //     Array.isArray(this.possessionChecklistArray) &&
                //     this.possessionChecklistArray.length > 0;

                console.log('this.isRMUser. : ', JSON.stringify(this.isRMUser));
                console.log('this.isAccManager. : ', JSON.stringify(this.isAccManager));
                console.log('this.isCRMHead. : ', JSON.stringify(this.isCRMHead));
            } else {
                this.errorMsg = 'Registration not done yet.';
                this.showData = false;
            }
            this.fetchData();

        } else if (error) {
            console.error('Error fetching booking details:', error);
            this.booking = undefined;
            this.isCRMManager = false;
            this.isAccManager = false;
        }
    }

    async fetchData() {
        try {
            const [pcDetails, data] = await Promise.all([
                getPossessionChecklist({ bkId: this.recordId }),
                getMasterPossession({
                    bkId: this.recordId,
                    isCRMHead: this.isCRMHead,
                    isAccManager: this.isAccManager,
                    isRMUser: this.isRMUser,
                })
            ]);

            if (data) {
                let map = data.reduce((acc, item, index) => {
                    if (!acc[item.Section__c]) {
                        acc[item.Section__c] = [];
                    }

                    let remarksValue = '';
                    let rmstatusValue = '';
                    let fmStatusValue = '';

                    if (pcDetails) {
                        this.checklistData = pcDetails;
                        console.log('this.checklistData:', JSON.stringify(this.checklistData));
                        pcDetails.forEach(pc => {
                            if (pc.Section__c === item.Section__c && pc.Particulars__c === item.Particulars__c) {
                                remarksValue = pc.Remarks__c;
                                rmstatusValue = pc.RM_Status__c;
                                fmStatusValue = pc.FM_Status__c;
                                console.log('remarksValue:', remarksValue);
                                console.log('fmStatusValue:', fmStatusValue);
                            }
                        });
                    }

                    acc[item.Section__c].push({
                        ...item,
                        RM_Status__c: rmstatusValue || '',
                        Remarks__c: remarksValue || '',
                        FM_Status__c: fmStatusValue || '',
                        Index__c: index,
                        isHideRemark: item.Section__c === 'Documents handed over to customer',
                        isAccManager: item.Section__c === 'Documents received from customer'
                    });

                    return acc;
                }, {});

                this.possessionChecklistArray = Object.keys(map).map(section => ({
                    sectionName: section,
                    items: map[section],
                    isHideRemark: map[section][0].isHideRemark,
                    isAccManager: map[section][0].isAccManager
                }));

                console.log('possessionChecklistArray:', JSON.stringify(this.possessionChecklistArray));

                this.error = undefined;
            } else {
                this.possessionChecklistArray = [];
                console.error('No data returned from Apex method.');
            }

            console.log('this.accountData:', JSON.stringify(this.accountData));
        } catch (error) {
            this.error = error;
            this.possessionChecklistArray = [];
            console.error('Error fetching data:', error);
        }
    }


    handleAcceptAllRMChecklist(event) {
        const sectionIndex = parseInt(event.target.dataset.index, 10, 0);
        const acceptAllChecked = event.target.checked;

        this.possessionChecklistArray = this.possessionChecklistArray.map((section, index) => {
            console.log(index, sectionIndex, acceptAllChecked);

            if (index === sectionIndex) {
                section.items = section.items.map(item => ({
                    ...item,
                    RM_Status__c: acceptAllChecked ? 'Completed' : 'NA',
                }));
            }
            return section;
        });
        console.log('handleAcceptAllRMChecklist: ', JSON.stringify(this.possessionChecklistArray));

    }

    handleAcceptAllAccounthecklist(event) {
        const sectionIndex = event.target.dataset.index;
        const acceptAllChecked = event.target.checked;

        this.possessionChecklistArray = this.possessionChecklistArray.map((section, index) => {
            if (index === sectionIndex) {
                section.items = section.items.map(item => ({
                    ...item,
                    FM_Status__c: acceptAllChecked ? 'Completed' : 'NA',
                }));
            }
            return section;
        });
        console.log('handleAcceptAllChange: ', JSON.stringify(this.possessionChecklistArray));
    }

    handleChange(event) {
        let index = parseInt(event.target.dataset.index, 10, 0);
        let value = event.target.value;
        let name = event.target.name;
        console.log('index : ', index);
        console.log('value : ', value);
        console.log('name : ', name);

        this.possessionChecklistArray.forEach(section => {
            section.items = section.items.map(item => {
                if (item.Index__c === index) {
                    if (name === 'RM_Status__c') {
                        return { ...item, RM_Status__c: value };
                    }
                    if (name === 'FM_Status__c') {
                        return { ...item, FM_Status__c: value };
                    }
                    else if (name === 'remarks') {
                        return { ...item, Remarks__c: value };
                    }

                }
                return item;
            });
        });

        console.log('possessionChecklistArray :::' + JSON.stringify(this.possessionChecklistArray));
    }

    handleSubmit() {
        let checklistIdentifier = '';
        let recordsToSave = [];
        this.isSpinner = true;

        const validateChecklist = (key) => {
            return this.possessionChecklistArray.every(section => {
                return section.items.every(item => item[key] !== undefined && item[key] !== '');
            });
        };

        console.log('possessionChecklistArray :::' + JSON.stringify(this.possessionChecklistArray));

        if (this.isRMUser) {
            checklistIdentifier = 'RM User';
            if (!validateChecklist('RM_Status__c')) {
                this.showErrorMessage('error', 'Please select Status options for all items before saving.');
                this.isSpinner = false;
                return;
            }
        }
        else if (this.isAccManager) {
            checklistIdentifier = 'Account Manager';
            if (!validateChecklist('FM_Status__c')) {
                this.showErrorMessage('error', 'Please select FM Status options for all items before saving.');
                this.isSpinner = false;
                return;
            }
        }

        this.possessionChecklistArray.forEach(section => {
            section.items.forEach(item => {
                recordsToSave.push({
                    Particulars__c: item.Particulars__c,
                    RM_Status__c: item.RM_Status__c,
                    FM_Status__c: item.FM_Status__c,
                    Booking__c: this.recordId,
                    Remarks__c: item.Remarks__c,
                    Section__c: item.Section__c,
                    Checklist_Identifier__c: checklistIdentifier
                });
            });
        });

        savePossessionCheckList({ mpList: recordsToSave, bkId: this.recordId, isAccManager: this.isAccManager, isCRMHead: this.isCRMHead, isRMUser: this.isRMUser })
            .then(() => {
                let successMessage = 'Records upserted successfully.';
                if (this.isAccManager || this.isCRMHead) {
                    successMessage = 'Possession Checklist updated successfully.';
                    this.accScuccess = true;
                    this.accScuccessMessage = 'Your possession checklist has been updated successfully.';
                }

                if (this.isRMUser) {
                    location.replace('/' + this.recordId);
                }
                this.isSpinner = false;
            })
            .catch(error => {
                console.error('Error while saving records:', error);
                this.showErrorMessage('error', 'Error creating records: ' + error.body.message);
                this.isSpinner = false;
            });
    }

    handleCRMHeadApproval(event) {
        const _approvalStatus = event.target.dataset.approvalStatus;
        this.isSpinner = true;
        updatePossessionChecklistStatusFromCRMHead({ bookingId: this.recordId, approvalStatus: _approvalStatus })
            .then(data => {
                if (data === true) {
                    this.accScuccess = true;
                    this.isSpinner = false;

                    if (_approvalStatus === "Approved") {
                        this.accScuccessMessage = 'Checklist Approved Successfully. Thank you!';
                    }
                    else if (_approvalStatus === "Rejected") {
                        this.accScuccessMessage = 'Checklist Rejected. Please review and resubmit if necessary.';
                    }
                }
                else {
                    this.isSpinner = false;
                    this.showErrorMessage('error', 'Some internal error occurred !');

                }
            })
            .catch(error => {
                this.showErrorMessage('error', 'Some internal error occurred !');
            })
    }


    showErrorMessage(type, message) {
        this.isSpinner = false;
        this.template.querySelector('c-custom-toast').showToast(type, message, 'utility:error', 10000);
    }
    showSuccessMessage(type, message) {
        this.isSpinner = false;
        this.template.querySelector('c-custom-toast').showToast(type, message, 'utility:success', 10000);
    }
}