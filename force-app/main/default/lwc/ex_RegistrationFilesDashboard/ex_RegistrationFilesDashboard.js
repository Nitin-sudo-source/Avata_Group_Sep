/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 03-06-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, wire, track } from 'lwc';
import getProject from '@salesforce/apex/Ex_BulkRegistrationFileDashboard.getProject';
import getTower from '@salesforce/apex/Ex_BulkRegistrationFileDashboard.getTower';
import fetchFiles from '@salesforce/apex/Ex_BulkRegistrationFileDashboard.fetchFiles';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_RegistrationFilesDashboard extends NavigationMixin(LightningElement) {
    @track selectedFinalist = [];
    @track projectId = '';
    @track towerId = '';
    @track documentType = '';
    @track regData = [];
    @track showTable = false;
    @track isSpinner = false;
    @track selectedList = [];
    @track currentPage = 1;
    @track pageSize = 10;
    @track index = 0;
    @track checkboxesState = {};
    @track regId = '';
    @track mainList = [];
    @track selectAllcheckBox = false;
    @track finalurl = '';
    @track url = [];
    @track isError = false;
    @track errorMsg = '';
    @track filteredRecords = []; // Data after applying filters
    @track activeStatusFilter = ''; //
    @track sortDirection = 'ASC';
    @track sortedBy = '';

    @track sortIcons = {
        bookingNo: { icon: 'utility:arrowdown', text: 'ASC', variant: 'success', size: 'small' },
        bookingStatus: { icon: 'utility:arrowdown', text: 'ASC', variant: 'success', size: 'small' },
        registrationDate: { icon: 'utility:arrowdown', text: 'ASC', variant: 'success', size: 'small' },
        UnitName: { icon: 'utility:arrowdown', text: 'ASC', variant: 'success', size: 'small' },
        fileType: { icon: 'utility:arrowdown', text: 'ASC', variant: 'success', size: 'small' }
    };

    @track documentArray = [
        { label: 'AFS', value: 'AFS', variant: 'brand', icon: 'utility:add' },
        { label: 'Index Page', value: 'INDEX', variant: 'brand', icon: 'utility:add' }
    ];

    // @track pageSizeOptions = [
    //     { label: '5', value: 5 },
    //     { label: '10', value: 10 },
    //     { label: '20', value: 20 },
    //     { label: '50', value: 50 }
    // ];

    @wire(getProject) getProjectData;
    @wire(getTower, { ProjectId: '$projectId' }) getTowerData;

    get projectOptions() {
        return this.getProjectData.data ? this.getProjectData.data.map(p => ({ label: p.Name, value: p.Id })) : [];
    }

    get towerOptions() {
        return this.getTowerData.data ? this.getTowerData.data.map(t => ({ label: t.Name, value: t.Id })) : [];
    }

    get documentOptions() {
        return this.documentArray ? this.documentArray.map(t => ({ label: t.label, value: t.value })) : [];
    }

    getSortIcon() {
        return this.sortDirection === 'ASC' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    getSortVariant() {
        return this.sortDirection === 'ASC' ? 'success' : 'error';
    }

    //Pagination Logic Start

    get totalPages() {
        return Math.ceil(this.regData.length / this.pageSize);
    }
    get startRecord() {
        return (this.currentPage - 1) * this.pageSize;
    }
    get endRecord() {
        return Math.min(this.startRecord + this.pageSize, this.regData.length);
    }
    get currentPageData() {
        if (!this.regData || this.regData.length === 0) {
            return [];
        }

        let data = [...this.regData];

        // Apply Sorting
        if (this.sortedBy !== '') {
            data.sort((a, b) => {
                let fieldA = a[this.sortedBy] || '';
                let fieldB = b[this.sortedBy] || '';

                if (this.sortedBy === 'registrationDate') {
                    return this.sortDirection === 'ASC'
                        ? new Date(fieldA) - new Date(fieldB)
                        : new Date(fieldB) - new Date(fieldA);
                }

                return this.sortDirection === 'ASC'
                    ? fieldA > fieldB ? 1 : -1
                    : fieldA < fieldB ? 1 : -1;
            });

            const currentPageData = data.slice(this.startRecord, this.endRecord);
            currentPageData.forEach((item, index) => {
                item.serialNumber = this.startRecord + index + 1;
            });

            return currentPageData;
        } else {

            return this.regData.slice(this.startRecord, this.endRecord);
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }
    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    //Pagination Logic End

    //Title to Show on Page Start

    get projectTitle() {
        return this.projectId ? 'Project Selected' : 'Please Select Project';
    }

    get towerTitle() {
        return this.towerId ? 'Tower Selected' : 'Please Select Tower';
    }

    get docTitle() {
        return this.documentType ? 'Document Selected' : 'Please Select Document';
    }
    // Title to Show on Page End

    //No of Records Selected
    get recordSelected() {
        const count = this.mainList.length > 0 ? this.mainList.length : 0;
        if (count > 0) {
            const message = count === 1 ? '1 File has been selected.' : `${count} Files have been selected.`;
            this.showToast('Records Selected', message, 'success');

        }
        // else if(count == 0){
        //     const message = count === 0 ? 'No File has been selected.' : '';
        //     this.showToast('Records Selected', message, 'warning');
        // }
        return count;
    }

    handleProjectChange(event) {
        this.projectId = event.target.value;
        //alert(this.projectId);
    }

    handleTowerChange(event) {
        this.towerId = event.target.value;
        //alert(this.towerId);
    }

    handleDocumentType(event) {
        console.log('event: ' + event);
        console.log('event: ' + event.target);
        console.log('event: ' + event.detail);
        console.log('Selected Value: ' + event.detail.value);
        this.documentType = event.detail.value;
        console.log('Selected this.documentType::  ' + this.documentType);
    }


    handleSort(event) {
        const fieldName = event.target.dataset.field;
        const isSameField = this.sortedBy === fieldName;
        this.sortDirection = isSameField && this.sortDirection === 'ASC' ? 'DESC' : 'ASC';
        this.sortedBy = fieldName;
        this.sortIcons = {
            ...this.sortIcons,
            [fieldName]: {
                icon: this.sortDirection === 'ASC' ? 'utility:arrowup' : 'utility:arrowdown',
                text: this.sortDirection === 'ASC' ? 'ASC' : 'DESC',
                variant: this.getSortVariant(),
                size: 'small'
            }
        };
    }


    fetchDocumentRecords() {
        if (this.projectId == null || this.projectId === '' || this.projectId == '') {
            this.showToast('Warning', 'Please select Project', 'warning');
            return;
        } else if (this.towerId == null || this.towerId === '' || this.towerId == '') {
            this.showToast('Warning', 'Please select Tower', 'warning');
            return;
        } else if (this.documentType == null || this.documentType === '' || this.documentType == '') {
            this.showToast('Warning', 'Please select Document Type', 'warning');
            return;
        }
        else {
            this.showTable = false;
            this.isSpinner = true;
            fetchFiles({ objectName: 'Registration__c', documentType: this.documentType, towerId: this.towerId, projectId: this.projectId })
                .then((result) => {

                    if (result != null) {
                        //console.log('fetch Files' + JSON.stringify(result));
                        this.regData = result.map((item, index) => ({
                            ...item,
                            // contentSizeKB: (item.contentSize / 1024).toFixed(2) + 'KB',
                            isSelected: false,
                            isDownloaded: item.isDownloaded,
                            "url": `/sfc/servlet.shepherd/document/download/${item.contentDocumentId}`,
                            "serialNumber": index + 1,
                            previewUrl: `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${item.contentVersionId}`

                        }));
                        this.showTable = true;
                        this.isSpinner = false;
                        console.log('regData: ' + JSON.stringify(this.regData));
                        this.selectedList = this.regData;
                        this.selectAllcheckBox = false;
                        this.mainList = [];
                        this.finalurl = '';
                        this.url = [];
                        //console.log('selectedList: ' + JSON.stringify(this.selectedList));

                    } else {
                        this.showToast('Warning', 'No Documents Found', 'warning');
                        this.showTable = false;
                        this.isSpinner = false;
                        this.selectAllcheckBox = false;
                        this.finalurl = '';
                        this.mainList = [];
                    }

                    if (this.regData.length === 0) {
                        this.showToast('Warning', 'No Documents Found', 'warning');
                        this.showTable = false;
                        this.isSpinner = false;
                        this.selectAllcheckBox = false;
                        this.finalurl = '';
                        this.mainList = [];
                    }


                })
                .catch((error) => {
                    console.error(error);
                    this.showToast('Warning', 'Something Went Wrong', 'warning');
                    this.showTable = false;
                    this.isSpinner = false;
                    this.selectAllcheckBox = false;
                    this.finalurl = '';
                    this.mainList = [];
                });
        }


    }


    handleAllSelected(event) {
        const checkboxes = this.template.querySelectorAll('[data-id^="checkbox-button"]');
        //console.log('checkboxes: ' + JSON.stringify(checkboxes));
        for (const ch of checkboxes) {
            ch.checked = event.target.checked;
            this.selectAllcheckBox = ch.checked;
        }
        this.handleChange(event);
    }


    handleChange(event) {
        const { name, checked } = event.target;
        this.checkboxesState = { ...this.checkboxesState, [name]: checked };
        this.regId = event.target.dataset.key;
        var valueset = event.target.checked;
        console.log('valueset: ' + valueset);
        var fieldName = event.currentTarget.name;
        //console.log('fieldName: ' + fieldName);
        var Name = event.target.dataset.name;
        //console.log('Name: ' + Name);
        // if (fieldName === undefined) {
        //     for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
        //         this.currentPageData[i].isSelected = false;
        //     }
        // } else 
        if (fieldName == 'SelectAll') {
            if (this.selectAllcheckBox == true) {
                for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
                    for (var i = 0; i < this.currentPageData.length; i++) {
                        const value = this.currentPageData[i].regId;
                        let isVerifiedByMIS = this.currentPageData[i].isverifiedBYMIS;
                        let isVerifiedBYRM = this.currentPageData[i].isverifiedBYRM;

                        console.log(' value: ' + value);
                        console.log('isVerifiedByMIS: ' + isVerifiedByMIS);
                        console.log('isVerifiedBYRM: ' + isVerifiedBYRM);

                        if (!this.mainList.includes(value) && isVerifiedByMIS == true && isVerifiedBYRM == true) {
                            this.currentPageData[i].isSelected = true;
                            this.mainList.push(value);
                            if (!this.url.includes(this.currentPageData[i].contentDocumentId)) {
                                this.url.push(this.currentPageData[i].contentDocumentId);
                            }
                        } else if (isVerifiedByMIS == false && isVerifiedBYRM == false) {
                            this.currentPageData[i].isSelected = false;
                            this.selectAllcheckBox = false;
                            this.showToast('Error', 'Please Verifiy with RM and MIS to Download', 'error');
                            //this.selectAllcheckBox = false;
                            //return;
                        }
                    }
                    break;
                }
            } else {
                //console.log('inside else ');
                for (var i = this.pageSize * this.currentPage - this.pageSize; i < this.pageSize * this.currentPage; i++) {
                    for (var j = 0; j < this.currentPageData.length; j++) {
                        const value = this.currentPageData[j].regId;
                        this.currentPageData[j].isSelected = false;
                        let isVerifiedByMIS = this.currentPageData[i].isverifiedBYMIS;
                        let isVerifiedBYRM = this.currentPageData[i].isverifiedBYRM;

                        if (this.mainList.includes(value) && isVerifiedByMIS == true && isVerifiedBYRM == true) {
                            const index = this.mainList.indexOf(value);
                            if (index !== -1) {
                                this.mainList.splice(index, 1);
                            }
                        }
                        if (this.url.includes(this.currentPageData[j].contentDocumentId) && isVerifiedByMIS == true && isVerifiedBYRM == true) {
                            const index = this.url.indexOf(this.currentPageData[j].contentDocumentId);
                            if (index !== -1) {
                                this.url.splice(index, 1);
                            }
                        }
                    }
                    break;
                }
            }
        } else {
            for (var i = 0; i < this.selectedList.length; i++) {
                const value = this.selectedList[i].regId;
                console.log(' value: ' + value);
                if (!this.selectedList[i].isDownloaded && this.currentPageData[i].isverifiedBYMIS && this.currentPageData[i].isverifiedBYRM) {
                    if (value == this.regId && valueset == true) {
                        this.mainList.push(value);
                        this.url.push(Name);
                    } else if (value == this.regId && valueset == false) {
                        this.mainList = this.mainList.filter(finalItem => finalItem !== this.regId);
                        this.url = this.url.filter(finalItem => finalItem !== Name);
                    }
                } 
            }
            for (var i = 0; i < this.currentPageData.length; i++) {
                if (this.currentPageData[i].regId == this.regId && valueset == true && this.currentPageData[i].isverifiedBYMIS && this.currentPageData[i].isverifiedBYRM) {
                    console.log('inside if 1 ' + this.currentPageData[i].isSelected);
                    this.currentPageData[i].isSelected = valueset;
                    break;
                } else if (this.currentPageData[i].regId == this.regId && valueset == false && this.currentPageData[i].isverifiedBYMIS && this.currentPageData[i].isverifiedBYRM) {
                    this.currentPageData[i].isSelected = valueset;
                    console.log('inside else if 2 ' + this.currentPageData[i].isSelected);
                    break;
                } if (this.currentPageData[i].regId == this.regId && valueset == true && !this.currentPageData[i].isverifiedBYMIS && !this.currentPageData[i].isverifiedBYRM) {
                    console.log('inside if 3 ' + this.currentPageData[i].isSelected);
                    this.currentPageData[i].isSelected = false;
                    this.showToast('Error', 'Please Verifiy with RM and MIS to Download', 'error');
                    event.target.checked = false;

                    break;
                } else if (this.currentPageData[i].regId == this.regId && valueset == false && !this.currentPageData[i].isverifiedBYMIS && !this.currentPageData[i].isverifiedBYRM) {
                    this.currentPageData[i].isSelected = valueset;
                    console.log('inside else if 4 ' + this.currentPageData[i].isSelected);
                    break;
                }
            }
        }
        //console.log('currentPageData: ' + JSON.stringify(this.currentPageData));
        console.log('FinalMainList: ' + JSON.stringify(this.mainList));
        //console.log('url ' + JSON.stringify(this.url));

        this.updateFinalUrl();

    }


    handleBulkDownload() {
        console.log('Final URL:', this.finalurl);

        if (!this.finalurl || this.mainList.length === 0) {
            this.showToast('Error', 'Please select files to download.', 'error');
            this.selectAllcheckBox = false;
            return;
        }
        window.open(this.finalurl, '_self');
        this.showToast('Success', 'Files are being downloaded. Please check your downloads folder.', 'success');
    }

    handledownloadcheck(event) {
        //console.log('inside handledownloadcheck');
        const dId = event.target.dataset.key;
        //console.log('dId' + dId);
        if (this.mainList.length === 0 || !this.mainList.includes(dId)) {
            this.showToast('Error !', 'Please Select File to Download', 'Error');
            return;
        } else if (this.mainList.includes(dId)) {
            //console.log('this.mainList Inside else' + JSON.stringify(this.mainList));
            this.selectedFinalist = this.currentPageData.filter(record => record.isSelected);
            this.selectedFinalist = this.selectedFinalist.filter(record => {
                if (record.regId === dId) {
                    record.isDownloaded = true;
                    if (this.mainList.includes(dId)) {
                        this.mainList.push(dId);
                        const index = this.mainList.indexOf(dId);
                        if (index !== -1) {
                            this.mainList.splice(index, 1);
                        }
                    }
                    return true;
                }
                return false;
            });
            this.handleBulkDownload();
        }
    }

    updateFinalUrl() {
        //console.log('url: ' + JSON.stringify(this.url));
        this.finalurl = '';
        // let allSelected = false;
        for (let i = 0; i < this.currentPageData.length; i++) {
            if (this.url.length != 0) {
                var idArray = this.url.join(',').split(',');
                this.finalurl = `/sfc/servlet.shepherd/document/download/${idArray.join('/')}`;
            }
        }
        const allSelected = this.currentPageData.every(record => record.isSelected && record.isDownloaded);
        console.log('allSelected : ' + allSelected);

        // Update selectAllcheckBox based on the current page's selection state
        this.selectAllcheckBox = allSelected;



        if (!this.finalurl || this.mainList.length === 0) {
            let allSelected = true;
            for (var i = 0; i < this.currentPageData.length; i++) {
                if (!this.currentPageData[i].isSelected) {
                    allSelected = false;
                    break;
                }
            }
            this.selectAllcheckBox = allSelected;
        }
        console.log('final : ' + this.finalurl);
    }


    openBooking(event) {
        var value = event.target.dataset.id;
        //console.log(value);
        window.open(`/${value}`, '_blank');
    }


    handlePreviousPage() {
        this.isSpinner = true;
        this.currentPage = Math.max(1, this.currentPage - 1);
        this.index = ((this.currentPage - 1) * this.pageSize);
        this.isSpinner = false;
        var allSelected = true;
        for (var i = 0; i < this.currentPageData.length; i++) {
            if (!this.currentPageData[i].isSelected) {
                allSelected = false;
                break;
            }
        }
        this.selectAllcheckBox = allSelected;
    }


    handleNextPage() {
        this.isSpinner = true;
        this.currentPage = Math.min(this.totalPages, this.currentPage + 1);
        this.index = ((this.currentPage - 1) * this.pageSize);
        this.isSpinner = false;
        var allSelected = true;
        for (var i = 0; i < this.currentPageData.length; i++) {
            if (!this.currentPageData[i].isSelected) {
                allSelected = false;
                break;
            }
        }
        this.selectAllcheckBox = allSelected;
    }

    handleReset() {
        setTimeout(() => {
            location.reload();
        }, 1000);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

}