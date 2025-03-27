import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCPDocumentDetails from '@salesforce/apex/Ex_CPDocumentUploadController.getCPDocumentDetails';
import uploadFile from '@salesforce/apex/Ex_CPDocumentUploadController.uploadFile';
import myResource from '@salesforce/resourceUrl/ExcellerLogo';

export default class CpDocumentUpload extends LightningElement {

    @track name;
    @api recordId;
    @track doid;
    Logo = myResource;
    @track allDocumentsUploaded = false;
    @track isPanCardUploaded = false;
    @track isAadharCardUploaded = false;
    @track isGSTCertificateUploaded = false;
    @track isRERACertificateUploaded = false;
    @track cpDocList = [];
    @track allUploadedTrue = false;
    isSpinner = false;
    connectedCallback() {
        this.loadDocuments();
    }

    loadDocuments() {
        getCPDocumentDetails({ id: this.recordId })
            .then(data => {
                if (data) {
                    this.cpDocList = data.map(document => {
                        return {
                            ...document,
                            isUploadedFalse: document.Uploaded__c == false,
                            isUploadedTrue: document.Uploaded__c == true,
                            filename: null,
                            base64: null,
                            fileData: null,
                            fileUploader: null,
                        }
                    });
                    this.allUploadedTrue = this.cpDocList.every(document => document.Uploaded__c == true);

                    console.log('allUploadedTrue', JSON.stringify(allUploadedTrue));
                }
            })
            .catch(error => {
                console.error('Error fetching documents:', error);
            });
    }


    openFileUpload(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        let index = event.target.dataset.index;
        console.log(`Index: ${index}, FieldName: ${fieldName}, Value: ${value}`);

        this.cpDocList[index][fieldName] = value;
        this.cpDocList[index]['Uploaded__c'] = true;
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            var reader = new FileReader();
            reader.onload = () => {
                var base64 = reader.result.split(",")[1];
                this.cpDocList[index].filename = file.name;
                this.cpDocList[index].base64 = base64;
            };
            reader.readAsDataURL(file);
        }

        console.log('Updated this.cpDocList:', JSON.stringify(this.cpDocList));
    }


    uploadData() {
        this.isSpinner = true;
        const filteredFiles = this.cpDocList.filter(file => file.Uploaded__c === true && file.isUploadedTrue === false);
        console.log('Filtered Files:', JSON.stringify(filteredFiles));
    
        if (filteredFiles.length === 0) {
            this.isSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload at least one file',
                    variant: 'error',
                }),
            );
            return;
        }
    
        uploadFile({ cpDocumentList: JSON.stringify(filteredFiles) })
            .then(result => {
                this.isSpinner = false;
                console.log('Uploads Apex response:', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Files uploaded Successfully',
                        variant: 'success',
                    }),
                );
    
                location.reload();
            })
            .catch(error => {
                this.isSpinner = false;
                console.error('Error in Uploads Apex method:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while uploading files',
                        variant: 'error',
                    }),
                );
            });
    }

}