import { LightningElement, track, wire } from 'lwc';
import whatsappIcon from '@salesforce/resourceUrl/whatsappIcon';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCallBackURL from '@salesforce/apex/Ex_SetWebhookURL.getCallBackURL';
import updateURL from '@salesforce/apex/Ex_SetWebhookURL.updateURL';

export default class SetWebhoolURL extends LightningElement {

    whatsappIcon = whatsappIcon;
    @track callbackURLList = [];
    @track visible;
    @track project;

    @wire(getCallBackURL)
    wiredCallbackURL({data, error}) {
        if(data) {
            this.callbackURLList = data;
            this.visible  = true;
            console.log(data);
        } else if(error) {
            console.error('Error Occurred:', error);
        }else{
            this.visible = false;
            console.log('null');
        }
    }

    handleURLChange(evt){

        this.callbackURL = evt.target.value;
        console.log(this.callbackURL);

    }

    handleProject(evt){

        this.project = evt.target.value;
        console.log(this.project);

    }

    handleSetURL(evt){
        console.log(evt);
        if(evt.detail == 1 && this.project != undefined && this.project != '' && this.project != null){
            updateURL({URL : this.callbackURL, projectId: this.project})
            .then(result => {
                console.log(result);
                this.callbackURL = '';
                const evt = new ShowToastEvent({
                    title: 'URL Updated',
                    message: 'URL has been updated',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                setTimeout(function() {
                    // Reload the page
                    window.location.reload();
                }, 2000); // 3000 milliseconds = 3 seconds
                
                
            }).catch(error => {
                console.error(JSON.stringify(error));
                this.callbackURL = '';
            });
        }
        else if(this.project != undefined && this.project != '' && this.project != null){

            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select a Project',
                variant: 'error',
            });
            this.dispatchEvent(evt);

        }

    }
}