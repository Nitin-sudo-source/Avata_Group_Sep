import { LightningElement ,api} from 'lwc';

export default class BookingComponent extends LightningElement {
    @api recordId;

    handleSave(){
        location.replace('/',this.recordId);
    }
    
    
}