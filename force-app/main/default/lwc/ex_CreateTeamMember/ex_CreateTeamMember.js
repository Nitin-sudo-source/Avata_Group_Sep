import { LightningElement, wire, track, api } from 'lwc';
import getPicklistValues from '@salesforce/apex/Ex_CreateTeamMemberController.getPicklistValues';
import getPojectDetails from '@salesforce/apex/Ex_CreateTeamMemberController.getPojectDetails';
import getUserDetails from '@salesforce/apex/Ex_CreateTeamMemberController.getUserDetails';
import saveData from '@salesforce/apex/Ex_CreateTeamMemberController.saveData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_CreateTeamMember extends LightningElement {
    @track teamTypepicklistOptions = [];
    @track selectedTeamType = '';
    @track userList = [];
    @track updateUserList = [];
    @track showTable = false;
    @track allCheckbox = false;
    @api recordId;
    @track tmList = [];
    @track isSpinner = false;
    @track isSave = false;
    @track tmDuplicateList;
    @track projectName = '';
    @track isDuplicateSequenceNumber = false;

    @wire(getPicklistValues)
    pickListValue({ data, error }) {
        if (data) {
            this.teamTypepicklistOptions = data.map(teamType => ({ label: teamType, value: teamType }));
        } else if (error) {
            console.error('Error retrieving picklist values:', error.message);
        }
    }

    @wire(getPojectDetails, { projectId: '$recordId' })
    project({ data, error }) {
        if (data) {
            this.projectName = data.Name;
        } else if (error) {
            console.error('Error retrieving :', error.message);
        }
    }

    handleChange = async (event) => {
        try {
            const { name, index } = event.target.dataset;
            let value;
            if (name === 'Team_Type__c') {
                value = event.target.value;
                this.selectedTeamType = value;
                const data = await getUserDetails({ selectedTeamType: value, projectId: this.recordId });
                if (data && Array.isArray(data)) {
                    const userDetails = data[0];
                    this.tmDuplicateList = userDetails.tmList.map(tm => ({ ...tm })) || [];
                    this.userList = userDetails.userList.map(user => ({
                        ...user,
                        singleCheckbox: this.tmDuplicateList.some(tm => user.Id === tm.User__c),
                        styleClass: this.tmDuplicateList.some(tm => user.Id === tm.User__c) ? 'dupClass' : null,
                        isDupTeam: this.tmDuplicateList.some(tm => user.Id === tm.User__c),
                        Availability__c: this.tmDuplicateList.some(tm => user.Id === tm.User__c) ? this.tmDuplicateList.find(tm => user.Id === tm.User__c).Availability__c : false,
                        Sequence_Number__c: this.tmDuplicateList.some(tm => user.Id === tm.User__c) ? this.tmDuplicateList.find(tm => user.Id === tm.User__c).Sequence_Number__c : null,
                    })) || [];
                    this.showTable = this.userList.length > 0;
                } else {
                    this.showTable = false;
                    this.showToast('Error', 'Data not available.', 'error');
                }
            } else if (name === 'singleCheckbox' || name === 'Availability__c') {
                value = event.target.checked;
            } else if (name === 'allCheckbox') {
                value = event.target.checked;
                this.userList.forEach(user => {
                    if (!this.tmDuplicateList.some(tm => user.Id === tm.User__c)) {
                        user.singleCheckbox = value;
                    }
                });
            } else {
                value = event.target.value;
            }

            const updatedUser = { ...this.userList[index], [name]: value };
            this.userList[index] = updatedUser;
            this.allCheckbox = this.userList.every(user => user.singleCheckbox === true);
            this.updateUserList = this.userList.filter(user => user.singleCheckbox);
        } catch (error) {
            console.error('Error in handleChange:', error.message);
        }
    };


    handleSave = async () => {
        try {
            this.isSpinner = true;
            const isAnyCheckboxChecked = this.updateUserList.some(user => user.singleCheckbox);
            if (!isAnyCheckboxChecked) {
                this.showToast('Error', 'Please Select at least one User to proceed.', 'error');
                this.isSave = false;
            } else {
                this.isSave = true;
                const seenNumbers = new Set();
                for (let i = 0; i < this.updateUserList.length; i++) {
                    const sequenceNumber = parseInt(this.updateUserList[i].Sequence_Number__c);
                    if (this.updateUserList[i].Sequence_Number__c == null || this.updateUserList[i].Sequence_Number__c === '') {
                        this.showToast('Error', `Sequence Number required for ${this.updateUserList[i].Name}`, 'error');
                        this.isSave = false;
                        break;
                    }
                    else if (seenNumbers.has(sequenceNumber)) {
                        this.showToast('Error', `Duplicate Sequence Number for ${this.updateUserList[i].Name}. Please ensure unique Sequence Numbers.`, 'error');
                        this.isSave = false;
                        break;
                    }
                    seenNumbers.add(sequenceNumber);
                }
                if (this.isSave) {
                    const result = await saveData({
                        tmList: this.updateUserList,
                        projectId: this.recordId,
                        selectedTeamType: this.selectedTeamType
                    });

                    this.tmList = result || [];
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: this.tmList.length > 0 ? 'Record inserted successfully.' : 'No records inserted.',
                        variant: this.tmList.length > 0 ? 'success' : 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    if (this.tmList.length > 0) {
                        location.replace('/' + this.recordId);
                    }
                }
            }
        } catch (error) {
            this.showToast('Error', 'Error saving data: ' + error.message, 'error');
        } finally {
            this.isSpinner = false;
        }
    };
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            })
        );
    }


}