import { LightningElement, track } from 'lwc';
import getStaticResources from '@salesforce/apex/Ex_TemplateMediaSelectorHandler.getStaticResourcesforProject';
import checkPublicURLforProject from '@salesforce/apex/Ex_TemplateMediaSelectorHandler.checkPublicURLforProject';
import Submit from '@salesforce/apex/Ex_TemplateMediaSelectorHandler.UpdateProject';
import searchProjectRecord from '@salesforce/apex/Ex_TemplateMediaSelectorHandler.searchProjectRecord';
import LightningConfirm from 'lightning/confirm';


export default class ProjectMediaSelector extends LightningElement {

    @track StaticResourceList = [];
    @track execute;
    @track projectList = [];
    @track modalClass = 'slds-modal'; // Class to show/hide the modal
    @track backdropClass = 'slds-backdrop'; // Class to show/hide the backdrop
    @track resourceName = '';
    @track errors = '';
    @track showProjectError = false;
    @track searchTemplate;
    @track searchProjectResult = [];
    @track showProjectResult = false;
    @track indexkey ;

    connectedCallback(){
        this.StaticResource();
    }


    handleAdd() {
        // Open the modal
        this.modalClass = 'slds-modal slds-fade-in-open';
        this.backdropClass = 'slds-backdrop slds-backdrop_open';
    }

    handleCancel() {
        // Close the modal
        this.modalClass = 'slds-modal';
        this.backdropClass = 'slds-backdrop';
        this.clearInputFields();
    }

    handleCreate() {
        // Handle the StaticResource creation logic here
        console.log('Creating StaticResource:', this.resourceName);

        // Call the appropriate Apex method to create the StaticResource
        // ...

        // Close the modal after creating the StaticResource
        this.handleCancel();
    }

    handleInputChange(event) {
        this.resourceName = event.target.value;
    }

    handleFileUpload(event) {
        // Handle file upload logic if needed
        console.log('File uploaded:', event.detail);
    }

    clearInputFields() {
        // Reset input fields
        this.resourceName = '';
    }


    StaticResource(){
        getStaticResources()
        .then((result) => {
            // Modify the result to include the "Extension" field
            const modifiedResult = result.map(record => {
                const contentTypeParts = record.ContentType.split('/');
                const extension = contentTypeParts.length === 2 ? contentTypeParts[1] : '';
                return { ...record, Extension: extension, project__c: '',showProjectError :false,showProjectResult : false };
            });

            console.log(JSON.stringify(modifiedResult));
            this.StaticResourceList = modifiedResult;

            for (const key in this.StaticResourceList) {
                //this.StaticResourceList[key].Name = this.StaticResourceList[key].Name + '.' + this.StaticResourceList[key].Extension;
            }
        })
        .catch((error) => {
            console.error('Error fetching static resources: ', error);
        });
    }

    viewRecord(evt){
        const key = evt.target.dataset.index;
        console.log(key);

        window.open('https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/ResourceLink/resource/'+ this.StaticResourceList[key].Name);
    }

    handleTemplate(event){
        const fieldValue = event.currentTarget.value;
        console.log(fieldValue);

        const name = event.currentTarget.name;
        console.log(name);

        this.indexkey = event.currentTarget.dataset.index;
        console.log(this.indexkey);

        if(name === 'Project_Name__c'){
            this.searchTemplate = fieldValue;
            if (fieldValue == '') {
                this.searchProjectResult = [];
                this.showProjectResult = false;
                this.showProjectError = true; 

                const new_addobj = { ...this.StaticResourceList[this.indexkey], 'showProjectResult': false, 'showProjectError': true}
                console.log('new_addobj = '+ JSON.stringify(new_addobj));

                this.StaticResourceList[this.indexkey] = new_addobj;
                console.log('StaticResourceList: ' + JSON.stringify(this.StaticResourceList));

                return;
            }
            else{
                this.showProjectError = false;
                this.searchProjectRecords();


            }
        }
    }

    searchProjectRecords(){
        searchProjectRecord({searchTerm: this.searchTemplate})
        .then((result) => {
            this.searchProjectResult = result;
            this.showProjectResult = true;

            const new_addobj = { ...this.StaticResourceList[this.indexkey], 'showProjectResult': true, 'showProjectError': false}
            console.log('new_addobj = '+ JSON.stringify(new_addobj));

            this.StaticResourceList[this.indexkey] = new_addobj;
            console.log('StaticResourceList: ' + JSON.stringify(this.StaticResourceList));
            console.log('Search Result .: ', JSON.stringify(this.searchProjectResult));
        }).catch(error => {
            console.error('Error fetching search results', error);
        });
    }
    handlechange(evt){
        alert('');
        const projId = evt.currentTarget.dataset.id;
        console.log('Id .: ',projId);

        const key = evt.currentTarget.dataset.index;
        console.log(key);

        const name = evt.currentTarget.dataset.name;
        console.log(name);

        const new_addobj = { ...this.StaticResourceList[key], 'project__c': name, 'showProjectResult': false, 'Id': projId}
        console.log('new_addobj = '+ JSON.stringify(new_addobj));

        this.StaticResourceList[key] = new_addobj;
        console.log('StaticResourceList: ' + JSON.stringify(this.StaticResourceList));

        checkPublicURLforProject({tempId: projId})
        .then((result) => {
            console.log(JSON.stringify(result));
            if(result){
                this.execute = this.handleConfirmClick(key,projId, name);
                console.log(this.execute);
            }
        })
        .catch((error) => {
            console.log('Error = '+JSON.stringify(error));
        })
    }

    async handleConfirmClick(key,projId, name) {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to overide the existing media',
            variant: 'headerless',
            
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        console.log(result);
        
        if(result){
            this.StaticResourceList[key].project__c = name;
            console.log('StaticResourceList = ' + JSON.stringify(this.StaticResourceList));
        }else{
            this.StaticResourceList[key].project__c = null;
            console.log('StaticResourceList = ' + JSON.stringify(this.StaticResourceList));
        }
    }

    handleSubmit(){

        for (const key in this.StaticResourceList) {

            console.log(this.StaticResourceList[key].project__c);

            if (this.StaticResourceList[key].project__c != null && this.StaticResourceList[key].project__c != undefined && this.StaticResourceList[key].project__c != '') {
                
                const element = {
                    'Id': this.StaticResourceList[key].Id,
                    'Public_Link__c': 'https://customization-velocity-7183--satyamsb.sandbox.my.salesforce-sites.com/ResourceLink/resource/'+ this.StaticResourceList[key].Name
                };

                this.projectList.push(element);
                
            }
        }

        Submit({Project: this.projectList})
        .then((result) => {
            //console.log(result);

            if(result == 'Success'){
                location.reload();
            }else{
                this.errors = 'An Error Occured. Please contact your System Administrator';
            }
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
            this.errors = 'Error Occured: ' + error;
        })

        console.log('projectList .: ' + JSON.stringify(this.projectList));
    }
}