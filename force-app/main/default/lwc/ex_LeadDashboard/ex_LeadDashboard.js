import { LightningElement, api, track } from 'lwc';
import getFilteredLeads from '@salesforce/apex/Ex_LeadDashboard.getLeadsByDateAndProject';
//import getLeadsByDate from '@salesforce/apex/Ex_LeadDashboard.getLeadsByDate';
import updateLeadSendWhatsApp from '@salesforce/apex/Ex_LeadDashboard.updateLeadSendWhatsApp';
import { loadStyle } from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/colors'
import whatsappIMG from '@salesforce/resourceUrl/WhatsappIMG';
import whatsappIcon from '@salesforce/resourceUrl/whatsappIcon';
import getTemplate from '@salesforce/apex/Ex_LeadDashboard.getTemplate';
import getCategory from '@salesforce/apex/Ex_LeadDashboard.getCategory';
// import previewTemplate from '@salesforce/apex.Ex_LeadDashboard.previewTemplate';



const columns = [
    //{ label: 'Sr No.', fieldName: '' },
    { label: 'Name', fieldName: 'FullName' },
    //{ label: 'Mobile Phone', fieldName: 'Phone' },
    { label: 'Project', fieldName: 'projName' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Owner', fieldName: 'owner' },
    { label: 'CreatedDate', fieldName: 'createddate' }
];

// { type: 'checkbox', fieldName: 'selected', label: 'Select', typeAttributes: { isChecked: { fieldName: 'selected' }},initialWidth: 100 },

const CategoryValues = [
    { label: 'UTILITY', value: 'UTILITY' },
    { label: 'MARKETING', value: 'MARKETING' }
    
];

const ObjectValues = [
    { label: 'Lead', value: 'Lead__c' },
    //{ label: 'Booking', value: 'Booking__c' },
    //{ label: 'Account', value: 'Account' },
    //{ label: 'Site Visit', value: 'Site_Visit__c' },
    //{ label: 'Quotation', value: 'Quotation__c' },
    { label: 'Opportunity', value: 'Opportunity__c' },
    { label: 'Booking', value: 'Booking__c' }
];

export default class LeadFilter extends LightningElement {

    @track CategoryOptions = [];
    @track ObjectOptions = [];
    @track startDate;
    @track endDate;
    @track projectFilter;
    @track filteredLeads;
    @track viewtemplates;
    @track totalsize;
    @track selectedsize;
    columns = columns;
    @track selectedLeads = [];
    @track selectAll = false;
    @track showSuccessMessage = false;
    @track showStartDateError = false;
    @track showEndDateError = false;
    isCssLoaded = false;
    @track TemplateChoosen;
    @api helpText = 'Please wait while loading…';
    @api size = 'large';
    @api variant = 'base';
    @api hasRendered = false;
    @api showSpinner = false;
    @track viewdata = false;   // made true for time being 
    @track spinnerClass;
    @track sendbtn = false;
    @track leadSelected = [];
    @track showTemplate = false;
    @track showSampleRecord = false;
    @track SampleRecords;
    @track preview = '';

    imagePath = whatsappIMG;
    whatsappIcon = whatsappIcon;

    @track currentPage = 1;
    @track pageSize = 10;
    @track totalRecords = 100;
    @track disablePreviousButton = false;
    @track disableNextButton = false;

    @track object;
    @track categoryList = [];
    @track category;
    @track templatename;
    @track templateArray = [];
    @track samplePreview = '';
    @track Status = null;
    @track ownername;
    @track MasterSource;
    @track islead = false;
    @track isopp = false;
    @track isbooking = false;
    @track showtempcategory = false;

    // ... (existing methods)

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateButtonState();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateButtonState();
        }
    }

    handlePageChange(event) {
        this.currentPage = parseInt(event.detail.value, 10);
        this.updateButtonState();
    }

    updateButtonState() {
        this.disablePreviousButton = this.currentPage === 1;
        this.disableNextButton = this.currentPage === this.totalPages;
    }

    get pageOptions() {
        return Array.from({ length: this.totalPages }, (_, i) => ({
            label: `${i + 1}`,
            value: `${i + 1}`,
        }));
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get pagedLeads() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.filteredLeads.slice(start, end);
    }

    connectedCallback() {
        this.CategoryOptions = CategoryValues;
        this.ObjectOptions = ObjectValues;

        if (this.size == 'large') {

            this.spinnerClass = 'spinner-large';

        }
    }

    handleObject(event) {
        this.category = '';
        this.viewtemplates = false;
        this.object = event.target.value;
        console.log('VAlue .: ', this.object);


        if (this.object) {
            if (this.object === 'Lead__c') {
                this.islead = true;
                this.isopp = false;
                this.isbooking = false;
            } else if (this.object === 'Opportunity__c') {
                this.islead = false;
                this.isopp = true;
                this.isbooking = false;
            } else if (this.object === 'Booking__c') {
                this.islead = false;
                this.isopp = false;
                this.isbooking = true;
            }
           /* getCategory({ Objects: this.object, selectedproject: this.projectfilter })
                .then(result => {
                    console.log('result .: ', result);
                    let tempArray = [];
                    for (let key in result) {
                        tempArray.push({ label: result[key], value: result[key] });
                    }
                    this.categoryList = tempArray;
                    console.log('Category .: ', JSON.stringify(this.categoryList));
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                })*/
        }
    }

    handlecategory(evt) {
        this.templateList = [];
        //this.templateList = [];
        this.viewtemplates = false;
        console.log('this.templateList = ' + this.templateList);

        this.category = evt.target.value;
        console.log('Category .: ', this.category);

        if (this.category) {
            getTemplate({ category: this.category, Objects: this.object, selectedproject: this.projectFilter })
                .then((result) => {

                    console.log(JSON.stringify(result));
                    this.templateArray = result;
                    if (result.length > 0) {
                        this.viewtemplates = true
                        this.notemplates = false;
                        //this.viewdata = true;
                        let tempArray2 = [];

                        for (let key in result) {
                            tempArray2.push({ label: result[key].Whatsapp_Template_Name__c, value: result[key].Id });
                        }

                        this.templateList = tempArray2;
                        console.log('Template Array .: ', JSON.stringify(this.templateList));

                    } else {
                        this.viewtemplates = false;
                        this.notemplates = true;
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                })
        }
    }



    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.showStartDateError = false;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        console.log('End Date .: ' + endDate);
        this.showEndDateError = false;
    }

    handleProjectChange(event) {
        this.projectFilter = event.target.value;
        console.log("Project Selected::" + this.projectFilter);
        if(this.projectFilter){
            console.log('projectFilter : '+this.projectFilter);
            this.showtempcategory = true;
            getCategory({ Objects: this.object, selectedproject: this.projectfilter })
                .then(result => {
                    console.log('result .: ', result);
                    let tempArray = [];
                    for (let key in result) {
                        tempArray.push({ label: result[key], value: result[key] });
                    }
                    this.categoryList = tempArray;
                    console.log('Category .: ', JSON.stringify(this.categoryList));
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                })

        }else {
            this.showtempcategory = false;
            this.viewtemplates = false;
            this.category = '';

        }

        
    }

    handleStatus(event) {
        this.Status = event.target.value;
        console.log("Status Selected::" + this.Status);
    }

    handleownerchange(event) {
        this.ownername = event.target.value;
        console.log("ownername Selected::" + this.ownername);
    }

    handleMasterSource(event) {
        this.MasterSource = event.target.value;
        console.log("MasterSource Selected::" + this.MasterSource);
    }



    handleselectedtemplate(evt) {
        try {
            this.selectedtemplate = evt.target.value;
            console.log('Value of Template .: ', this.selectedtemplate);
            console.log(JSON.stringify(this.templateArray));
            const foundRecord = this.templateArray.find(record => record.Id === this.selectedtemplate);
            console.log(JSON.stringify(foundRecord));
            this.TemplateChoosen = foundRecord;
            console.log('TemplateChoosen = ' + JSON.stringify(this.TemplateChoosen));
            this.viewdata = true;
            console.log('this.TemplateChoosen.Sample_Text__c .: ', this.TemplateChoosen.Sample_Text__c);
            this.samplePreview = this.removeHtmlTags(this.TemplateChoosen.Template__c);
            if (this.TemplateChoosen.Sample_Text__c) {
                this.samplePreview = this.checkSampleText(this.TemplateChoosen.Sample_Text__c, this.samplePreview);
            }
            console.log('Sample Preview: ', this.samplePreview);
        } catch (error) {
            console.log('Error .: ', JSON.stringify(error));
        }


    }

    checkSampleText(parameters, template) {
        let parameterValues = parameters.split(',');
        // Replace placeholders in the template with values from parameters
        for (let i = 0; i < parameterValues.length; i++) {
            let placeholder = '{{' + (i + 1) + '}}';
            let parameterValue = parameterValues[i];
            template = template.replace(placeholder, '[' + parameterValue + ']');
        }
        return template;
    }

    removeHtmlTags(input) {
        // Replace any HTML tags with an empty string
        let replacetagswithn = input.replace(/<\/p>/g, '\n');
        return replacetagswithn.replace(/<[^>]+>/g, '');
    }


    applyFilter() {
        this.showSpinner = true;
        console.log('object:: : ' + this.object);
        //this.showStartDateError = !this.startDate;
        //this.showEndDateError = !this.endDate;

        /*if (!this.startDate || !this.endDate) {
            this.showSpinner = false;
            console.error('Please select both start date and end date.');
            return;
        }*/

        function formatDate(dateString) {
            const date = new Date(dateString);
            const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
            return new Intl.DateTimeFormat('en-GB', options).format(date);
        }

        //if (this.projectFilter) {
        getFilteredLeads({
            startDate: this.startDate, endDate: this.endDate, projectFilter: this.projectFilter, Objects: this.object,
            status: this.Status, ownername: this.ownername
        })
            .then(result => {
                console.log('Size is .: ', result.length);
                console.log('result is::' + JSON.stringify(result));
                if (this.object === 'Lead__c') {
                    console.log('OUTPUT clead : ');
                    this.filteredLeads = result.map(record => ({
                        ...record,
                        FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                        projName: record.Project_Name__c
                    }));
                    this.SampleRecords = result.map(record => ({
                        ...record,
                        FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                        Phone: record.Mobile__c,
                        projName: record.Project_Name__c,
                        status: record.Lead_Stage__c,
                        owner: record.Owner.Name,
                        createddate: formatDate(record.CreatedDate)
                    }));
                } else if (this.object === 'Opportunity__c') {
                    console.log('OUTPUT Opp : ');
                    this.filteredLeads = result.map(record => ({
                        ...record,
                        FullName: record.Name,
                        projName: record.Project__r.Name
                    }));
                    this.SampleRecords = result.map(record => ({
                        ...record,
                        FullName: record.Name,
                        Phone: record.Mobile__c,
                        projName: record.Project__r.Name,
                        status: record.Opportunity_Stage__c,
                        owner: record.Owner.Name,
                        createddate: formatDate(record.CreatedDate)
                    }));


                } else if (this.object === 'Booking__c') {
                    this.filteredLeads = result.map(record => ({
                        ...record,
                        FullName: record.Primary_Applicant_Name__c,
                        projName: record.Project__r.Name
                    }));
                    this.SampleRecords = result.map(record => ({
                        ...record,
                        FullName: record.Primary_Applicant_Name__c,
                        Phone: record.Mobile__c,
                        projName: record.Project__r.Name,
                        status: record.Booking_Stage__c,
                        owner: record.Owner.Name,
                        createddate: formatDate(record.CreatedDate)
                    }));

                }
                this.SampleRecords = this.SampleRecords.slice(0, 10);
                console.log("Result Json" + JSON.stringify(this.filteredLeads));
                this.showSpinner = false;
                this.sendbtn = true;
                this.totalsize = this.filteredLeads.length;
                console.log('Size of List .: ', this.totalsize);
                this.totalRecords = this.filteredLeads.length;
                this.updateButtonState();
                // this.showSampleRecord = true;

            })
            .catch(error => {
                console.error(error);
            });
        // } 
        /*else {
            getLeadsByDate({ startDate: this.startDate, endDate: this.endDate, Objects: this.object })
                .then(result => {
                    console.log('Size is .: ', result.length);
                    console.log('result is::' + JSON.stringify(result));

                    if (this.object === 'CLead__c') {
                        console.log('OUTPUT clead : ');
                        this.filteredLeads = result.map(record => ({
                            ...record,
                            FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                            projName: record.Project_Name__c 
                        }));
                        this.SampleRecords = result.map(record => ({
                            ...record,
                            FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                            Phone: record.X91_MobileNumber__c,
                            projName: record.Project_Name__c,
                            status:record.Lead_Status__c,
                            owner:record.Owner.Name
                        }));
                    } else if(this.object === 'Inquiry__c'){
                        console.log('OUTPUT Opp : ');
                        this.filteredLeads = result.map(record => ({
                            ...record,
                            FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                            projName: record.Project_Name__c 
                        }));
                        this.SampleRecords = result.map(record => ({
                            ...record,
                            FullName: record.First_Name__c + ' ' + record.Last_Name__c,
                            Phone: record.X91_plus_Mobile_Number__c,
                            projName: record.Project_Name__c,
                            status:record.Inq_pkl_Status__c,
                            owner:record.Owner.Name
                        }));


                    }
                    this.SampleRecords = this.SampleRecords.slice(0, 10);
                    console.log("Result Json" + JSON.stringify(this.filteredLeads));
                    this.showSpinner = false;
                    this.sendbtn = true;
                    this.totalsize = this.filteredLeads.length;
                    console.log('Size of List .: ', this.totalsize);
                    // this.showSampleRecord = true;
                })
                .catch(error => {
                    console.error(error);
                });

        }*/
    }

    showTemplateButton(event) {
        this.showTemplate = true;
    }

    handleCloseTemplate(event) {
        this.showTemplate = false;
    }

    showSampleRecordButton(event) {
        this.showSampleRecord = true;
    }

    handleCloseSampleRecord(event) {
        this.showSampleRecord = false;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.showStartDateError = false;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.showEndDateError = false;
    }

    handleRowSelection(event) {

        this.selectedLeads = event.detail.selectedRows;
        this.filteredLeads = this.filteredLeads.map(lead => ({
            ...lead,
            selected: this.selectedLeads.some(selectedLead => selectedLead.Id === lead.Id) ? '' : '',
        }));
        this.selectedsize = this.selectedLeads.length;
        console.log('Size of List .: ', this.selectedsize);
        console.log('selectedLeads .: ', JSON.stringify(this.selectedLeads));

        //    // Add the selected leads from filteredLeads to leadSelected if not already present
        //     const lead = this.filteredLeads.filter(lead =>
        //             lead.selected && !this.leadSelected.some(selectedLead => selectedLead.Id === lead.Id))

        //     console.log(lead);                
        //     // Remove deselected leads from leadSelected if present
        //     this.leadSelected = this.leadSelected.filter(selectedLead =>
        //         this.filteredLeads.some(lead => lead.Id === selectedLead.Id && !lead.selected)
        //     );

        //     // Log the updated this.leadSelected
        //     console.log('leadSelected: ', JSON.stringify(this.leadSelected));
    }
    handleSubmit() {
        this.showSpinner = true;
        console.log('Inside Submit::');
        const leadIds = this.filteredLeads.map(lead => lead.Id);
        console.log('Selected Lead Ids:', JSON.stringify(leadIds));
        console.log('Object .: ', this.object);
        if (leadIds.length > 0) {
            console.log('Size of Submit::', leadIds.length);
            console.log('Inside If::');

            updateLeadSendWhatsApp({ Ids: leadIds, Template: this.selectedtemplate, Objects: this.object })
                .then(result => {
                    if (result === 'Success') {
                        this.showSuccessMessage = true;
                        this.showSpinner = false;
                        this.selectedLeads.forEach(lead => {
                            lead.Send_Whatsapp__c = true;
                        });
                        //this.applyFilter();
                        console.log('Successfully updated checkbox::', JSON.stringify(leadIds));
                        setTimeout(function () {
                            // Reload the page
                            window.location.reload();
                        }, 2000);
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }

    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
            console.log("Loaded Successfully")
        }).catch(error => {
            console.error("Error in loading the colors")
        })
    }

}


            // If no project is selected, fetch all leads
            // getLeadsByDate({ startDate: this.startDate, endDate: this.endDate, Objects: this.object})
            //     .then(result => {
            //         console.log('Size is .: ',result.length);
            //         console.log('result is::'+JSON.stringify(result));
            //         this.filteredLeads = result.map(lead => ({
            //             ...lead,
            //             FullName: lead.FirstName + ' ' + lead.LastName,
            //             projName: lead.Project__r ? lead.Project__r.Name : ' ',
            //         }));
            //         console.log("Result Json" + JSON.stringify(this.filteredLeads));
            //         this.showSpinner = false;
            //         this.sendbtn = true;
            //         this.totalsize = this.filteredLeads.length;
            //         console.log('Size of List .: ',this.totalsize);
            //     })
            //     .catch(error => {
            //         console.error(error);
            //     });