import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class InventoryComponentAction extends NavigationMixin(LightningElement) {
    @api recordId ;

    connectedCallback() {
        var urlParams = new URLSearchParams(window.location.search);
        this.recordId = urlParams.get('recordId');
        console.log("Record ID:", this.recordId);
    
        var compDefinition = {
            componentDef: "c:ex_InventoryComponent",
            attributes: {
                oppId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        
        var url = "/one/one.app#" + encodedCompDef;
        console.log(url);
        
        var link = document.createElement('a');
        link.href = url;
       // link.target = '_blank';
        link.click();
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
     }
}