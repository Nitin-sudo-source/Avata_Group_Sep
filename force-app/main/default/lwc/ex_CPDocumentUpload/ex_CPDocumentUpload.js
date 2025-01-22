import { LightningElement , api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CPDocument_Uploads from '@salesforce/apex/Ex_CPDocumentUploadServices.CPAccountDocument_Uploads';
import Uploads from '@salesforce/apex/Ex_CPDocumentUploadServices.Uploads';
import myResource from '@salesforce/resourceUrl/logo';


export default class Ex_CPDocumentUpload extends LightningElement {
    @track name;
    @api recordId;
    @track doid;
    Logo = myResource;
    @track allDocumentsUploaded = false; // Variable to track the upload status

    connectedCallback() {
        this.loadDocuments();
    }

    loadDocuments() {
        CPDocument_Uploads({ id: this.recordId })
            .then(data => {
                if (data) {
                    this.name = data;
                    this.checkAllDocumentsUploaded(); // Check if all documents are uploaded on initial load
                }
            })
            .catch(error => {
                console.error('Error fetching documents:', error);
            });
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.contentversionId = uploadedFiles[0].contentVersionId;
        Uploads({ did: this.contentversionId })
            .then(result => {
                console.log('Uploads Apex response:', result);
            })
            .catch(error => {
                console.error('Error in Uploads Apex method:', error);
            });

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Files uploaded Successfully',
                variant: 'success',
            }),
        );

        location.reload();
    }

    get acceptedFormats() {
        return ['.pdf','.png','.jpg'];
    }

    checkAllDocumentsUploaded() {
        // Check if all documents in the 'name' array are uploaded
        this.allDocumentsUploaded = this.name.every(doc => doc.Uploaded__c);
        console.log('All Documents Uploaded:', this.allDocumentsUploaded);
    }
    

}