import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFieldDetails from '@salesforce/apex/Ex_WhatsappTemplate.getObjectField';
import getWhatsappTemplate from '@salesforce/apex/Ex_WhatsappTemplate.getWhatsappTemplate';
import getpara from '@salesforce/apex/Ex_WhatsappTemplate.getpara';
import Save from '@salesforce/apex/Ex_WhatsappTemplate.Save';
import QuickSave from '@salesforce/apex/Ex_WhatsappTemplate.QuickSave';
import uploadFile from '@salesforce/apex/Ex_WhatsappTemplate.uploadFile';
import getApiDetails from '@salesforce/apex/Ex_WhatsappTemplate.getApiDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import whatsappIcon from '@salesforce/resourceUrl/whatsappIcon';

const picklistValues = [
    { label: 'Lead', value: 'Lead__c' },
    { label: 'Opportunity', value: 'Opportunity__c' },
    { label: 'Booking', value: 'Booking__c' }
    //{ label: 'Channel Partner', value: 'Channel_Partner__c' }
    // { label: 'Site Visit', value: 'Site_Visit__c' },
    // { label: 'Quotation', value: 'Quotation__c' }
];

const category = [
    { label: 'UTILITY', value: 'UTILITY' },
    { label: 'MARKETING', value: 'MARKETING' }
    // { label: 'AUTHENTICATION', value: 'AUTHENTICATION' }
];

export default class WhatsappTemplate extends NavigationMixin(LightningElement) {
    @track picklistOptions = [];
    @track categorypicklist = [];
    @track selectedValue;
    @track selectedCat;
    @track mapObjFields;
    @track FieldsList = [];
    @track script;
    @track field;
    @track redirectid;
    @api recordId = null;
    @track temp;
    @track scriptstage;
    @track stage;
    @track leadfields = [];
    @track insert;
    @track folder = null;
    @track templatename = null;
    @track temperror;
    @track foldererror;
    @track nameerror;
    @track wholeerror;
    @track errorcontent;
    fileData = [];
    fileDataArray = [];
    @track type;
    @track typefile = false;
    @track variableList = [];
    @track actualvariableList = [];
    @track picklistValuesofCategory = [];
    @track categoryvalue;
    @track showspinner = false;
    @track header;
    @track sampleText = [];
    @track templatekind;
    @track specificKind;
    @track selectedproject;
    @track showprojecterror;
    @track CallToAction = {
        Template_Category__c : '',
        Template__c : '',
        Whatsapp_Template_Name__c : '',
        Object__c : '',
        Header__c : '',
        Parameters__c : '',
        Sample_Text__c : '',
        Type__c : '',
        Type_1__c : '',
        Title_1__c : '',
        Value_1__c : '',
        Type_2__c : '',
        Title_2__c : '',
        Value_2__c : '',
        Reply1__c : '',
        Reply2__c : '',
        Contains_Media__c : false,
        Contains_Document__c : false

    };
    @track newList = [];
    @track Type_1__c ;
    @track Title_1__c ;
    @track Value_1__c ;
    @track Type_2__c ;
    @track Title_2__c ;
    @track Value_2__c ;
    @track Reply1__c ;
    @track Reply2__c ;
    CTAOptions = [
        { label: 'Phone Number', value: 'PHONE_NUMBER' },
        { label: 'URL', value: 'URL' },
    ];
    @track showType2 = false;
    @track showCTA = false;
    @track showURL = false;
    @track showQR = false;
    @track ctaPhoneNumberFocus = false;
    @track ctaURLFocus = false;
    @track showSampleTextError = false;
    @track showMessageActionType = false;
    @track clientSideNameError = false;
    @track clientSideTypeError = false;
    @track clientSideCategoryError = false;
    @track clientSideObjectError = false;
    @track clientSideTemplateError = false;
    @track clientSideSampleError = false;
    singleSampleErrorList = [];

    whatsappIcon = whatsappIcon;
    
    @wire(getWhatsappTemplate,{tId: '$recordId'})getWhatsappTemplates({data,error}){
        if(data){
            this.insert = false;
            this.templatename = data.Whatsapp_Template_Name__c; 
            this.temp = data.Template__c;
            //this.folder = data.Folder__c;
            this.type = data.Type__c;
            this.selectedCat = data.Template_Category__c;
            this.selectedValue = data.Object__c;
            console.log(data.Parameters__c);

            getpara({tId: this.recordId})
            .then((result) => {
                console.log('result =' + JSON.stringify(result));
                this.variableList[this.variableList.length - 1].value = result[this.variableList.length - 1]
                for (let index = 0; index < (result.length - 1); index++) {
                    const i = this.variableList.length + 1;
                    const newEntry = {
                        'label': '{{'+i+'}}',
                        'value': result[this.variableList.length]
                    }
                    this.variableList.push(newEntry);  
                    console.log(JSON.stringify(newEntry));                  
                }
                console.log(JSON.stringify(this.variableList));
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            })

            console.log('data = '+ JSON.stringify(data));
            console.log(JSON.stringify('data = '+ data.Folder__c));

        }else if(error){
            console.log(JSON.stringify(error));
        }else if(data === null){
            this.insert = true;
        }
    }
    
    connectedCallback() {
        this.showCTA = true;
        this.picklistOptions = picklistValues;
        const i = 1;
        const newEntry = {
            'label': '{{'+i+'}}',
            'value': ''
        }
        this.variableList.push(newEntry);
        console.log(JSON.stringify(this.variableList));
        console.log(JSON.stringify(newEntry));
        console.log('CTA ',JSON.stringify(this.CallToAction));
        this.categorypicklist = category;
        console.log('Category Values .: ', this.categorypicklist);

    }

    handlefolder(evt){
        this.folder = evt.target.value;
        console.log('folder = ' + this.folder);
        if(this.folder != null && this.folder != ''){
            this.foldererror = false;
        }
    }

     // namePatternCheck() & validateName() functions are responsible for validation of Whatsapp Template Name.
     namePatternCheck(templateName) {
        var regex = /[^a-z_]/;
        return regex.test(templateName);
    }

    handlename(evt){
        this.templatename = evt.target.value;
        
        if(this.templatename != null && this.templatename != ''){
            this.nameerror = false;
        }
        
        this.clientSideNameError = this.namePatternCheck(this.templatename);

        this.CallToAction.Whatsapp_Template_Name__c = this.templatename;
        console.log('Name .: ', JSON.stringify(this.CallToAction));
    }

    handleheader(evt){
        this.header = evt.target.value;
    }

    handlePicklistChange(event) {
        this.selectedValue = event.detail.value;
        this.CallToAction.Object__c = this.selectedValue;
        if (this.selectedValue) {
            getFieldDetails({obj:this.selectedValue})
            .then(result =>{
                console.log('result: '+JSON.stringify(result));
                let tempArray = [];
                if(result){
                    for(let key in result){
                        tempArray.push({label:key,value:result[key]});
                    }
                    this.FieldsList = tempArray;
                    console.log(JSON.stringify(this.FieldsList));
                }
            })
        }
    }
/*-------------------- Creates API values --------------------*/
    handleCategoryChange(evt){
        let value = evt.target.value;
        console.log('Value .: ',value);
        this.selectedCat = value;

        this.CallToAction.Template_Category__c = this.selectedCat;
        console.log('Category .: ', JSON.stringify(this.CallToAction));

        if(this.selectedCat != 'UTILITY'){
            this.showMessageActionType = true;
        }else{
            this.showMessageActionType = false;
        }
    }


    handleFieldChange(evt){
        let value = evt.target.value;
        console.log(value);

        this.field = '{!'+this.selectedValue+'.'+value+'}';
        console.log(this.field);

        var key = parseInt(evt.target.dataset.key);
        console.log(key);

        // var value = evt.target.value;

        this.variableList[key].value = this.field;
        console.log('variableList = ' + JSON.stringify(this.variableList));

        // SHauryan Changes
        // this.clientSideSampleError[key] = true;
    }

    handlechange(evt){
        this.temp = evt.target.value;
        if(this.temp != null && this.temp != undefined && this.temp != '' ){
            this.temperror = false;
        }
        console.log(this.temp);

        this.CallToAction.Template__c = this.temp;
        console.log('Template .: ', JSON.stringify(this.CallToAction));
    }

    handletype(evt){
        this.type = evt.target.value;
        console.log('Value .:',this.type);
        
        if(this.type != 'TEXT'){
            this.typefile = true;
            if(this.type == 'IMAGE' || this.type == 'VIDEO'){
                this.image = true;
                this.CallToAction.Contains_Media__c = true; 
             }else if(this.type == 'DOCUMENT'){
                this.image = false;
                this.CallToAction.Contains_Document__c = true;
             }
        }
        else{
            this.typefile = false;
            this.image = false;
        }

        this.CallToAction.Type__c = this.type;
        console.log('Template .: ', JSON.stringify(this.CallToAction));
    }

    handlekind(evt){

        this.templatekind = evt.target.value;
        console.log('this.templatekind : '+this.templatekind);
        if(this.templatekind == 'Specific'){
            
            this.specificKind = true;

        }
        else{
            this.specificKind = false; 
           
        }
    }



    handleProject(event){
        this.selectedproject = event.target.value;
        console.log('this.selectedproject : '+this.selectedproject);

    }


    handleCallToAction(evt){
        var fieldName = evt.target.name;
        console.log('FieldName .:', fieldName);

        var value = evt.target.value;
        console.log('Value .:', value);

        this.CallToAction[fieldName] = value;
        console.log('Call To Action .: ',JSON.stringify(this.CallToAction));

        this.ctaPhoneNumberFocus = false;
        this.ctaURLFocus = false;
    }

    handleCTAPhoneNumberFocus(evt) {
        this.ctaPhoneNumberFocus = true;
    }

    handleCTAUrlFocus(evt){
        this.ctaURLFocus = true;
    }

    handleAdd(evt){
        var key = parseInt(evt.target.dataset.key);
        console.log('key .: ',key);
        console.log('length .: ',this.variableList.length);
        const i = parseInt(this.variableList.length) + 1;
        const newEntrys = {
            'label': '{{'+i+'}}',
            'value': ''
        }
        this.variableList.push(newEntrys);
        //this.clientSideSampleError.push(false);
        console.log('variableList = '+JSON.stringify(this.variableList));
    }

    handleremove(evt){
        var key = parseInt(evt.target.dataset.key);
        console.log(key);

        const indexToRemove = parseInt(key, 10);

        // Check if the index is within valid bounds
        if (indexToRemove >= 1 && indexToRemove < this.variableList.length) {
            // Remove the item at the specified index
            this.variableList.splice(indexToRemove, 1);
        }
        console.log('variableList = '+JSON.stringify(this.variableList));

        if (indexToRemove >= 1 && indexToRemove < this.sampleText.length) {
            // Remove the item at the specified index
            this.sampleText.splice(indexToRemove, 1);
        }
        console.log('sampleText = '+JSON.stringify(this.sampleText));
    }
    showCall(evt){
        //alert('CTA' ,evt);
        this.showCTA = true;
        this.showURL = false;
        this.showQR = false;
        // this.Type_1__c = 'PHONE_NUMBER';
        this.CallToAction.Reply1__c = '';
        this.Reply1__c = '';
        this.CallToAction.Reply2__c = '';
        this.Reply2__c = '';
        this.CallToAction.Type_2__c = '';
        this.CallToAction.Title_2__c = '';
        this.CallToAction.Value_2__c = '';
        this.Type_2__c = '';
        this.Title_2__c = '';
        this.Value_2__c = '';
        console.log('Call To Action .: ',JSON.stringify(this.CallToAction));
        console.log('Reply1__c .: ',this.Reply1__c);
        console.log('Reply1__c .: ',this.Reply2__c);
    }

    showURLtab(evt){
        this.showCTA = false;
        this.showURL = true;
        this.showQR = false;
        this.showType2 = false;
        this.CallToAction.Type_1__c = '';
        this.CallToAction.Title_1__c = '';
        this.CallToAction.Value_1__c = '';
        this.Type_1__c = 'URL';
        this.Title_1__c = '';
        this.Value_1__c = '';
        this.CallToAction.Reply1__c = '';
        this.Reply1__c = '';
        this.CallToAction.Reply2__c = '';
        this.Reply2__c = '';
        console.log('Call To Action .: ',JSON.stringify(this.CallToAction));
    }

    showQuickReplies(evt){
        this.showCTA = false;
        this.showURL = false;
        this.showQR = true;
        this.CallToAction.Type_1__c = '';
        this.CallToAction.Title_1__c = '';
        this.CallToAction.Value_1__c = '';
        this.CallToAction.Type_2__c = '';
        this.CallToAction.Title_2__c = '';
        this.CallToAction.Value_2__c = '';
        this.Type_1__c = '';
        this.Title_1__c = '';
        this.Value_1__c = '';
        this.Type_2__c = '';
        this.Title_2__c = '';
        this.Value_2__c = '';
        console.log('Call To Action .: ',JSON.stringify(this.CallToAction));
    }

    handleAddType2(){
        this.showType2 = true;
    }

    handleremoveType2(){
        this.showType2 = false;
        this.CallToAction.Type_2__c = '';
        this.CallToAction.Title_2__c = '';
        this.CallToAction.Value_2__c = '';
        this.Type_2__c = '';
        this.Title_2__c = '';
        this.Value_2__c = '';
        console.log('Call To Action .: ',JSON.stringify(this.CallToAction));
    }

    handlevariable(evt){
        var key = parseInt(evt.target.dataset.key);
        console.log(key);

        var value = evt.target.value;

        this.variableList[key].value = value;
        console.log('variableList = ' + JSON.stringify(this.variableList));
    }

    handleSampleText(evt){
        try{
            var key = parseInt(evt.target.dataset.key);
            console.log('Key .: ',key);
    
            var value = evt.target.value;
            console.log('Value .:',value);
    
            if(value !== '') { 
                this.sampleText[key] = value;
                // alert('If');

                // Shauryan Changes
                // this.clientSideSampleError[key] = false;
            }
            else {
                this.sampleText[key] = value;
                // this.clientSideSampleError[key] = true;
            }
            console.log('sampleText = ' + JSON.stringify(this.sampleText));
        }
        catch (err) {
            console.log(json.stringify(err));
        }
    }

/*------------------------Upload File for NEW------------------------*/

    @track apiDetails;
    @track file;
    @track Message;
    @track messageClass;
    

    handleFileUpload(event) {
        if (event.target && event.target.files && event.target.files.length > 0) {
            this.file = event.target.files[0];
            //console.log(this.file);

            const formData = new FormData();
            formData.append('file', this.file);
            formData.append('file_type', this.file.type); // Change file type accordingly
            //console.log(JSON.stringify(formData));
            
            getApiDetails()
            .then((result) => {
                if(result != null){
                    this.apiDetails = result;
                    //console.log(JSON.stringify(this.apiDetails));

                    fetch(this.apiDetails[0].HandleId_Endpoint__c + this.apiDetails[0].appId__c +'/upload/media', {
                        method: 'POST',
                        headers: {
                            'Authorization': this.apiDetails[0].token__c
                        },
                        body: formData
                    })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.json();
                    })
                    .then(data => {

                        if (data.handleId.message != null) {
                            this.responseMessage = data.handleId.message;
                            this.CallToAction.Media_HandleId__c = this.responseMessage;
                            
                            console.log(JSON.stringify(this.CallToAction));
                            this.Message = 'File Uploaded Sucessfully!';
                            this.messageClass = 'success-message';
                            //console.log(this.responseMessage);
                        }
                        
                    })
                    .catch(error => {
                        console.error('There was a problem with your fetch operation:', error);
                        this.Message = 'Error Occured Contact System Administrator!';
                        this.messageClass = 'error-message'; 
                    });
                }
                
                    })
            .catch((error) => {
                console.log(JSON.stringify(error));
            })

            
          
        } else {
            console.error('No file selected.');
            // Handle no file selected error
        }
    }

    // This Function Specifically Validates Input Values For All The Sample Text In Add Dynamic Values.
    validateSampleInputValues() {
        this.singleSampleErrorList = [];
        const dynamicSampleInputList = this.template.querySelectorAll('.dynamic-sample-input');

        // For Loop To Check If Any One Of The Rows Of Sample Text Has Error And Set The Sample Error Variable To {True}
        for(let i=0; i<dynamicSampleInputList.length; i++) {
            console.log("Sample Text at Index[", i, "]: ", this.sampleText[i]);
            if(this.sampleText[i] == '' || this.sampleText[i] == null || this.sampleText[i] == undefined) {
                this.clientSideSampleError = true;
                this.singleSampleErrorList.push(true);
            }
            else {
                this.singleSampleErrorList.push(false);
            }
        }

        console.log("Size of Dynamic Input List: ", dynamicSampleInputList.length);
        console.log("Size of Single Sample Error List: ", this.singleSampleErrorList.length);

        const dynamicSampleErrorList = this.template.querySelectorAll('.dynamic-sample-error');
        for(let i=0; i<this.singleSampleErrorList.length; i++) {
            /* if(this.singleSampleErrorList[i] === false) {
                dynamicSampleErrorList[i].classList.toggle('hide');
            } */
            // console.log("Single Sample Error List Value At Index[", i, "] :", this.singleSampleErrorList[i], " And The Value Of Sample Text: ", this.sampleText[i], " | Its Length: ", this.sampleText[i].length);
            console.log("Single Sample Error List Value At Index[", i, "] :", this.singleSampleErrorList[i], " And The Value Of Sample Text: ", this.sampleText[i]);
            if(this.singleSampleErrorList[i] == true) {
                if(dynamicSampleErrorList[i].classList.contains('hide')) {
                    console.log("This classList.remove('hide') Executed On Index: ", i);
                    dynamicSampleErrorList[i].classList.remove('hide');
                }
            }
            else {
                if(!dynamicSampleErrorList[i].classList.contains('hide')) {
                    console.log("This classList.add('hide') Executed On Index: ", i);
                    dynamicSampleErrorList[i].classList.add('hide');
                }
            }
            console.log("Class List At Index: ", i, " is: ", dynamicSampleErrorList[i].classList);
        }
    }

    // This Function is used for validating all the combobox & input box.
    validateInputs() {
        //this.validateSampleInputValues(); commented by pp

        const nameInput = this.template.querySelector('.name-input');
        const inputTypeField = this.template.querySelector('.type-input-field');
        const categoryCombobox = this.template.querySelector('.category-combobox');
        const objectCombobox = this.template.querySelector('.object-combobox');
        const templateInputField = this.template.querySelector('.template-input-field');
        const dynamicFieldNameCombobox = this.template.querySelector('.dynamic-field-name-combobox');
        const dynamicSampleInput = this.template.querySelector('.dynamic-sample-input');

        this.clientSideNameError = nameInput.value == undefined || nameInput.value == null || nameInput.value == '' ? true : this.clientSideNameError;
        this.clientSideTypeError = inputTypeField.value == undefined || inputTypeField.value == null || inputTypeField.value == '' ? true : false;
        this.clientSideCategoryError = categoryCombobox.value == undefined || categoryCombobox.value == null ? true : false;
        this.clientSideObjectError = objectCombobox.value == undefined || objectCombobox.value == null ? true : false;
        this.clientSideTemplateError = templateInputField.value == undefined || templateInputField.value == null || templateInputField.value == '' ? true : false;
        
        /* if(objectCombobox.value != undefined && objectCombobox.value != null) {
            if(objectCombobox.value != dynamicFieldNameCombobox.value) {
                if(dynamicSampleInput.value == undefined || dynamicSampleInput.value == null || dynamicSampleInput.value == '' ){
                    this.clientSideSampleError = true;
                } 
                else{
                    this.clientSideSampleError = false;
                }
            }
        } */

        return this.clientSideNameError || this.clientSideNameError || this.clientSideTypeError || 
               this.clientSideCategoryError || this.clientSideObjectError || this.clientSideTemplateError ||
               this.clientSideSampleError;
    }

    handlesave(){
        console.log('sampleText = ' + JSON.stringify(this.sampleText));
        //this.showspinner = true;
        if(!this.validateInputs()) {
            if (this.templatekind == 'Specific' && (this.selectedproject == null || this.selectedproject == '' || this.selectedproject == 'Undefined')) {
                console.log('Inprojecterror : ');
                this.showprojecterror = true;
                this.showSpinner = false;
                return;
            }

            
            this.showspinner = true;
            for(let key in this.variableList){
                this.actualvariableList.push(this.variableList[key].value);
            }
            console.log('actualvariableList' + JSON.stringify(this.actualvariableList));
    
            if(this.temp != null && this.temp != undefined && this.temp != '' && this.templatename != '' && this.templatename != null && //this.actualvariableList.length > 0 &&
                 this.type != null && this.type != '' /*&& this.actualvariableList.length == this.sampleText.length*/){
                this.temperror = false;
                this.nameerror = false;
                this.showSampleTextError = false;
                // this.foldererror = false;
                this.wholeerror = false;
                console.log('Size of .: ',this.actualvariableList.length);
                console.log('Size of sampleText.: ',this.sampleText.length);
                for (let st of this.actualvariableList) {
                    this.CallToAction.Parameters__c += st + ',';
                }
        
                for (let st of this.sampleText) {
                    this.CallToAction.Sample_Text__c += st + ',';
                }
        
                if (this.CallToAction.Parameters__c.endsWith(',')) {
                    this.CallToAction.Parameters__c = this.CallToAction.Parameters__c.slice(0, -1);
                }
        
                if (this.CallToAction.Sample_Text__c.endsWith(',')) {
                    this.CallToAction.Sample_Text__c = this.CallToAction.Sample_Text__c.slice(0, -1);
                }
    
                this.newList.push(this.CallToAction);
                console.log('New List .: '+this.newList);
                 console.log('this.selectedprojectsave : '+this.selectedproject);
                Save({template: this.temp, name: this.templatename, category: this.selectedCat ,variableList: this.actualvariableList,
                    types: this.type, objectName: this.selectedValue, header: this.header, SampleText: this.sampleText, wtList:this.newList, templateKind: this.templatekind, project: this.selectedproject })
                .then((result) => {
                    console.log(result);
                    this.showspinner = false;
                    this.redirectid = result.Id
                    if(result != null){
                        const event = new ShowToastEvent({
                            title: 'Success!',
                            message: 'Whatsapp Template Created Successfully',
                            variant: 'success',
                        });
                        if(this.fileDataArray != null)
                            this.savefile();
                        this.dispatchEvent(event);
                        setTimeout(() => {
                            location.replace('/'+this.redirectid);
                        }, 900);
                    }
                      this.showspinner = false;              
                })
                .catch((error) => {
                    console.log(error);
                    this.wholeerror = true;
                    console.log('Error .: ',error);
                    this.errorcontent = JSON.stringify(error);
                })
            }
            // else if(this.folder == null || this.folder == undefined){
            //     //this.foldererror = true;
            //     const event = new ShowToastEvent({
            //                 title: 'Error!',
            //                 message: 'Please Select Folder',
            //                 variant: 'error',
            //             });
            //     this.dispatchEvent(event);
            // }
            else if(this.templatename == null || this.templatename == '' ){
                //this.nameerror = true;
                const event = new ShowToastEvent({
                            title: 'Error!',
                            message: 'Template Name Can not be Empty',
                            variant: 'error',
                        });
                this.dispatchEvent(event);
            }
            else if(this.temp == null || this.temp == undefined || this.temp == ''){
                //this.temperror = true;
                const event = new ShowToastEvent({
                            title: 'Error!',
                            message: 'Template Can not be Empty',
                            variant: 'error',
                        });
                this.dispatchEvent(event);
            } 
            else if(this.actualvariableList.length != this.sampleText.length){
                this.showSampleTextError = true;
                const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Sample Text Cannot be Empty',
                        variant: 'error',
                    });
                this.dispatchEvent(event);
            }
        }
        else {
            console.log("Resolve Errors!");
            this.showspinner = false;
        }
    }

    savefile(){
        //alert('Uploading Files')
        const recordId = this.redirectid;
        console.log('Id -- ',recordId);
        for (let i = 0; i < this.fileDataArray.length; i++){
            const {base64, filename} = this.fileDataArray[i];
            console.log('index -- ',this.fileDataArray[i]);
            uploadFile({ base64, filename, recordId, i})
            .then(result=>{
                this.fileDataArray[i] = null
                let FileTitle = `${filename} uploaded successfully!!`
                alert(FileTitle);   
            })
            .catch((error)=>{
                console.log('Error',error);
            })
        }   
    }

    handlecancelsave(){
        //alert('Exit without Saving');
        location.replace('https://syngage.lightning.force.com/lightning/o/Whatsapp_Template__c/list?filterName=Recent');
    }

/*--------------------------Upload File for EDIT button--------------------------*/
    handleUploadFinished(event) {
            const documentId = event.target.dataset.targetId;
            const files = event.target.files;
            for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();

            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                const newFileData = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': documentId
                };

                // Append the file data to the fileDataArray
                this.fileDataArray.push(newFileData);
            };

            if (file) {
                reader.readAsDataURL(file);
                alert(file.name + ' Attached Successfully.');
            }
        }
    }

    handlequicksave(){

        for(let key in this.variableList){
            this.actualvariableList.push(this.variableList[key].value);
        }
        console.log('actualvariableList' + JSON.stringify(this.actualvariableList));
        if(this.temp != null && this.temp != undefined && this.temp != '' && this.actualvariableList.length > 0 && this.type != null && this.type != ''){
            this.wholeerror = false;
            QuickSave({recordId: this.recordId, template: this.temp, name: this.templatename, category: this.selectedCat,variableList: this.actualvariableList, types: this.type, header: this.header})
            .then((result) => {
                console.log(result);
                this.redirectid = result.Id
                if(result != null){
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Whatsapp Template Updated Successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.showspinner = true;
                    if (this.fileDataArray != null) {
                        this.quicksavefile();
                    }
                    setTimeout(() => {
                        location.replace('/'+this.redirectid);
                    }, 1000);
                }
               
                })
            .catch((error) => {
                console.log(error);
                this.wholeerror = true;
                this.errorcontent = JSON.stringify(error);
            })
        }
        // else if(this.folder == null || this.folder == undefined){
        //     this.foldererror = true;
        // }
        else if(this.templatename == null || this.templatename == '' ){
            this.nameerror = true;
        }
        else if(this.temp == null || this.temp == undefined || this.temp == ''){
            this.temperror = true;
        }
        
    }

    quicksavefile(){
        //alert('In')
        for (let i = 0; i < this.fileDataArray.length; i++){
            const {base64, filename, recordId} = this.fileDataArray[i];
            console.log('index -- ',this.fileDataArray[i]);
            uploadFile({ base64, filename, recordId, i})
            .then(result=>{
                this.fileDataArray[i] = null
                let FileTitle = `${filename} uploaded successfully!!`
                alert(FileTitle);   
            })
            .catch((error)=>{
                console.log('Error',error);
            })
        }
    }

    handlecancelqsave(){ 
        console.log('recordid',this.recordId);
        const url = 'https://syngage.lightning.force.com/lightning/r/Whatsapp_Template__c/'+this.recordId+'/view';
        console.log(url);
        location.replace(url);
    }
}