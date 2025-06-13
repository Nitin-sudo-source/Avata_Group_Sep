/**
 * @description       : 
 * @author            : nitinSFDC@exceller.SFDoc
 * @group             : 
 * @last modified on  : 26-03-2025
 * @last modified by  : nitinSFDC@exceller.SFDoc
**/
import { LightningElement, api, track, wire } from 'lwc';
import getProject from '@salesforce/apex/Ex_InventoryMatrix.getProject';
import getTower from '@salesforce/apex/Ex_InventoryMatrix.getTower';
import getUnit from '@salesforce/apex/Ex_InventoryMatrix.getUnit';
import getUnitConfigurationMapDetails from '@salesforce/apex/Ex_InventoryMatrix.getUnitConfigurationMapDetails';
import getUnitFloorMapDetails from '@salesforce/apex/Ex_InventoryMatrix.getUnitFloorMapDetails';
import handleblockunit from '@salesforce/apex/Ex_InventoryMatrix.handleblockunit';
import handleunblockunit from '@salesforce/apex/Ex_InventoryMatrix.handleunblockunit';
import USER_ID from '@salesforce/user/Id';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Unit__c from "@salesforce/schema/Unit__c"
import Sales_Status__c from "@salesforce/schema/Unit__c.Sales_Status__c";
import Configuration_Type__c from "@salesforce/schema/Unit__c.Configuration_Type__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ex_InventoryMatrix extends LightningElement {
    @api oppId;
    @api qType;
    @api bkId;
    @api unitTransfer;
    @track showSpinner = false;
    @track projList = [];
    @track selectedProj;
    @track selectedProjId;
    @track selectedProjId = '';
    @track projectdisbaled = false;
    @track towerList = [];
    @track selectedTower;
    @track noErrorInTower = false;
    @track unitList = [];
    @track selectedUnit;
    @track showunblockbutton = false;
    userId = USER_ID;
    iscurrentuser = false;
    filterTypeOptions = [Sales_Status__c, Configuration_Type__c];
    @track unitSalesStatusOptions = [];
    @track unitConfigurationTypeOptions = [];
    @track selectedSalesStatusFilters = [];
    @track selectedConfigurationTypeFilters = [];
    @track unitsFoundWithSelectedFilters = true;
    @track defaultdata = false;
    @track showpanel = false;
    @track isAllChecked = false;
    @track isDisabled1 = false;
    @track isDisabled = true;
    @track statuscheckboxBooked = false;
    @track statuscheckboxBookingInProcess = false;
    @track statuscheckboxNotForSale = false;
    @track unitConfigurationMap = [];
    @track originalUnitFloorMap = [];
    @track selectedConfigurations = [];
    @track unitSalesStatusList = [];
    @track unitSalesStatusMap = {};
    @track vacantCount = 0;
    @track bookedCount = 0;
    @track blockedCount = 0;
    @track notForSaleCount = 0;
    @track bookingInProcessCount = 0;
    @track refugeCount = 0;
    @track reservedCount = 0;
    @track possessionDoneCount = 0;
    @track holdByManagementCount = 0;
    @track filterdata = false;
    @track filteredunitFloorMap = [];
    @track storeProjectName = '';

    // Get Unit Sales Status values
    @wire(getObjectInfo, { objectApiName: Unit__c })
    unitInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$unitInfo.data.defaultRecordTypeId',
        fieldApiName: Sales_Status__c
    })
    handlePicklistValues({ error, data }) {

        // Handle Sales Status values for filter
        if (data) {

            this.unitSalesStatusOptions = data.values.map((picklistValue, index) => {
                return {
                    'id': index + 1,
                    'filterType': Sales_Status__c.fieldApiName,
                    'salesStatus': picklistValue.value,
                    'unitCount': 0,
                    'checkBoxStatus': false,
                    'isAll': false
                }
            })

            // Add "All" filter 
            this.unitSalesStatusOptions = [
                {
                    'id': 0,
                    'filterType': Sales_Status__c.fieldApiName,
                    'salesStatus': 'All',
                    'unitCount': 0,
                    'checkBoxStatus': true,
                    'isAll': true
                },
                ...this.unitSalesStatusOptions
            ];
            this.selectedSalesStatusFilters = ['All'];
            //('Sales status values : ' + JSON.stringify(this.unitSalesStatusOptions));
        }
        // Handle Error
        else if (error) {
            //console.log("Error in retriving picklist values for Unit : 'Sales Status'");
            this.unitSalesStatusOptions = [];
        }
    }


    // Get Unit Configuration values
    @wire(getObjectInfo, { objectApiName: Unit__c })
    unitInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$unitInfo.data.defaultRecordTypeId',
        fieldApiName: Configuration_Type__c
    })
    handleUnitConfigurations({ error, data }) {

        // Handle Configuration Type values of Unit
        if (data) {

            this.unitConfigurationTypeOptions = data.values.map((picklistValue, index) => {
                return {
                    'id': index + 1,
                    'filterType': Configuration_Type__c.fieldApiName,
                    'configurationType': picklistValue.value,
                    'unitCount': 0,
                    'checkBoxStatus': false,
                    'isAll': false
                }
            })

            // Add "All" filter 
            this.unitConfigurationTypeOptions = [
                {
                    'id': 0,
                    'filterType': Configuration_Type__c.fieldApiName,
                    'configurationType': 'All',
                    'unitCount': 0,
                    'checkBoxStatus': true,
                    'isAll': true
                },
                ...this.unitConfigurationTypeOptions
            ];
            this.selectedConfigurationTypeFilters = ['All'];
            //('Configuration type values : ' + JSON.stringify(this.unitConfigurationTypeOptions));
        }
        // Handle Error
        else if (error) {
            //("Error in retriving picklist values for Unit : 'Configuration Type'");
            this.unitConfigurationTypeOptions = [];
        }
    }




    connectedCallback() {
        if (this.oppId == undefined) {
            const urlSearchParams = new URLSearchParams(window.location.search);
            this.oppId = urlSearchParams.get("recordId");
        }
        //alert('oppId: ' + this.oppId);
        this.getProjects();
    }


    getProjects() {
        getProject({ oppId: this.oppId })
            .then(data => {
                if (data) {
                    this.projList = data.map(pro => ({
                        label: pro.Name,
                        value: pro.Id
                    }));
                    this.selectedProj = this.projList[0].value;
                    this.selectedProjId = this.projList[0].value;
                    this.storeProjectName = this.projList[0].label;
                    if (this.selectedProj != null && this.selectedProj != undefined && this.selectedProj != '')
                        this.projectdisbaled = true;
                    else {
                        this.projectdisbaled = false;
                    }
                    this.getTowers();
                    //('Project List:', JSON.stringify(this.projList));
                } else {
                    //('No data');
                }
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                return Promise.reject(error);
            });
    }


    handleProject(event) {
        this.selectedProjId = event.detail.value;
        //('selectedProjId: ', this.selectedProjId);
        this.getTowers();
    }

    getTowers() {
        this.showSpinner = true;
        //('selectedProjId: ', this.selectedProjId);
        getTower({ projId: this.selectedProjId })
            .then(data => {
                this.towerList = data.map(t => ({
                    label: t.Name,
                    value: t.Id
                }));
                //('Tower List:', JSON.stringify(this.towerList));

                this.noErrorInTower = true;
                this.showSpinner = false;

            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                this.noErrorInTower = false;
                this.showSpinner = false;
                return Promise.reject(error);

            });
    }

    handleTower(event) {
        this.selectedTower = event.detail.value;
        //('Tower  : ', this.selectedTower);
        this.getUnits();
        this.getUnitConfigurationMap();
        this.getUnitFloorMap();
        this.defaultdata = true;
        this.showpanel = true;
        this.isAllChecked = true;
        this.isDisabled1 = false;
        this.statuscheckboxBooked = false;
        this.statuscheckboxBlocked = false;
        this.statuscheckboxBookingInProcess = false;
        this.statuscheckboxNotForSale = false;
        this.updateUnitCountForFilters();
    }

    getUnits() {
        getUnit({ towerId: this.selectedTower })
            .then(data => {
                this.unitList = data

                //('Unit List:', JSON.stringify(this.unitList));
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                return Promise.reject(error);
            });
    }

    getUnitConfigurationMap() {
        this.showSpinner = true;
        // alert('');
        this.unitConfigurationMap = [];
        getUnitConfigurationMapDetails({ towerId: this.selectedTower })
            .then(result => {
                for (let config in result) {
                    this.unitConfigurationMap.push({ key: config, value: result[config] })
                }
                this.showSpinner = false;
                //('unitConfigurationMap .: ', JSON.stringify(this.unitConfigurationMap));
            }).catch(error => {
                console.error("Error In getUnitConfigurationMapDetails: ", error);
                this.unitConfigurationMap = null;
            })
    }

    getUnitFloorMap() {
        this.showSpinner = true;
        this.unitFloorMap = [];
        this.vacantCount = 0;
        this.bookedCount = 0;
        this.blockedCount = 0;
        this.bookingInProcessCount = 0;
        this.refugeCount = 0;
        this.reservedCount = 0;
        this.notForSaleCount = 0;
        this.possessionDoneCount = 0;
        this.holdByManagementCount = 0;

        getUnitFloorMapDetails({ towerId: this.selectedTower })
            .then(data => {
                if (data) {
                    this.originalUnitFloorMap = data;
                    //('Unit Map: ' + JSON.stringify(this.originalUnitFloorMap));
                    this.updateUnitCountForFilters();

                    for (let floor in data) {
                        //('floor: ' + floor);
                        this.unitList = data[floor];
                        this.unitList = this.unitList.map(item => ({ ...item, BlockButton: false }));

                        //('unitList: ' + this.unitList);

                        this.unitList.forEach(unit => {
                            console.log('unit: ' + JSON.stringify(unit));


                            if (unit.Sales_Status__c === 'Vacant') {
                                this.vacantCount = this.vacantCount + 1;
                            } else if (String(unit.Sales_Status__c) === 'Booked') {
                                this.bookedCount = this.bookedCount + 1;
                            } else if (unit.Sales_Status__c === 'Blocked') {
                                this.blockedCount = this.blockedCount + 1;
                            } else if (unit.Sales_Status__c === 'Booking-In-Process') {
                                this.bookingInProcessCount = this.bookingInProcessCount + 1;
                            } else if (unit.Sales_Status__c === 'Refuge') {
                                this.refugeCount = this.refugeCount + 1;
                            } else if (unit.Sales_Status__c === 'Reserved') {
                                this.reservedCount = this.reservedCount + 1;
                            }
                            else if (unit.Sales_Status__c === 'Possession Done') {
                                this.possessionDoneCount = this.possessionDoneCount + 1;
                            }
                            else if (unit.Sales_Status__c === 'Hold By Management') {
                                this.holdByManagementCount = this.holdByManagementCount + 1;
                            }
                        });
                        this.unitFloorMap.push({ key: floor, value: this.unitList });
                        this.showSpinner = false;

                    }
                    this.unitCount = this.vacantCount + this.bookedCount + this.blockedCount + this.bookingInProcessCount + this.refugeCount + this.reservedCount + this.possessionDoneCount + this.holdByManagementCount;
                    //('Unit Count: ', this.unitCount);
                    console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
                } else if (error) {
                    console.error('Error In getUnitFloorMapDetails: ', error);
                    this.showSpinner = false;
                }
            })
    }

    handleFilterSelection(event) {

        var checkBoxStatus = event.target.checked;
        var filterType = event.target.dataset.filterType;
        var filterBy = event.target.dataset.filterBy;
        var isAll = event.target.dataset.isAll == 'true';

        //('checkBoxStatus : ' + checkBoxStatus);
        //('filterType : ' + filterType);
        //('filterBy : ' + filterBy);
        //('isAll : ' + isAll);


        // Handle Sales Status Filter
        if (filterType === Sales_Status__c.fieldApiName) {

            // If "All" is selected, clear existing filters and keep only "All"
            if (isAll === true) {
                if (checkBoxStatus === true) {
                    this.selectedSalesStatusFilters = [];
                    this.selectedSalesStatusFilters.push(filterBy);
                }
                else {
                    this.selectedSalesStatusFilters = [];
                }
            }
            else {
                if (checkBoxStatus === true && this.selectedSalesStatusFilters.indexOf(filterBy) == -1) {
                    this.selectedSalesStatusFilters.push(filterBy);
                }
                else if (!checkBoxStatus === true && this.selectedSalesStatusFilters.indexOf(filterBy) != -1) {
                    this.selectedSalesStatusFilters = this.selectedSalesStatusFilters.filter((salesStatus, index) => {
                        return this.selectedSalesStatusFilters.indexOf(filterBy) != index;
                    })
                }

                // Remove "All" if present 
                if (this.selectedSalesStatusFilters.indexOf("All") != -1) {
                    this.selectedSalesStatusFilters = this.selectedSalesStatusFilters.filter(salesStatus => {
                        return salesStatus != 'All';
                    })
                }

                // If applied filters are empty then add "All"
                if (this.selectedSalesStatusFilters.length == 0) {
                    this.selectedSalesStatusFilters.push('All');
                }

            }
        }

        // Handle Configuration Type Filter
        if (filterType === Configuration_Type__c.fieldApiName) {

            if (isAll === true) {
                if (checkBoxStatus === true) {
                    this.selectedConfigurationTypeFilters = [];
                    this.selectedConfigurationTypeFilters.push(filterBy);
                }
                else {
                    this.selectedConfigurationTypeFilters = [];
                }
            }
            else {
                if (checkBoxStatus === true && this.selectedConfigurationTypeFilters.indexOf(filterBy) == -1) {
                    this.selectedConfigurationTypeFilters.push(filterBy);

                }
                else if (!checkBoxStatus === true && this.selectedConfigurationTypeFilters.indexOf(filterBy) != -1) {
                    this.selectedConfigurationTypeFilters = this.selectedConfigurationTypeFilters.filter((salesStatus, index) => {
                        return this.selectedConfigurationTypeFilters.indexOf(filterBy) != index;
                    })
                }

                // Remove "All" if present
                if (this.selectedConfigurationTypeFilters.indexOf("All") != -1) {
                    this.selectedConfigurationTypeFilters = this.selectedConfigurationTypeFilters.filter(salesStatus => {
                        return salesStatus != 'All';
                    })
                }

                // If applied filters are empty then add "All"
                if (this.selectedConfigurationTypeFilters.length == 0) {
                    this.selectedConfigurationTypeFilters.push('All');
                }

            }
        }
        this.updateCheckboxUIStates();
    }
    // Update the checkbox state based on selections.
    updateCheckboxUIStates() {

        // Update Sales Status Checkbox states
        this.unitSalesStatusOptions = this.unitSalesStatusOptions.map(option => {
            var isOptionSelected = this.selectedSalesStatusFilters.indexOf(option.salesStatus) != -1;

            if (isOptionSelected) option.checkBoxStatus = true;
            else option.checkBoxStatus = false;

            return option;
        })


        // Update Sales Status Checkbox states
        this.unitConfigurationTypeOptions = this.unitConfigurationTypeOptions.map(option => {
            var isOptionSelected = this.selectedConfigurationTypeFilters.indexOf(option.configurationType) != -1;

            if (isOptionSelected) option.checkBoxStatus = true;
            else option.checkBoxStatus = false;

            return option;
        })

    }
    // Get all the Units with floors
    get getFloorWiseAllUnits() {

        var floorWiseAllUnitsFiltered = [];

        Object.keys(this.originalUnitFloorMap).map(floor => {
            var units = this.originalUnitFloorMap[floor];

            var filteredUnits1 = [];
            if (this.selectedSalesStatusFilters.includes('All')) {
                filteredUnits1 = units;
            }
            else {
                filteredUnits1 = units.filter(unit => {
                    return this.selectedSalesStatusFilters.includes(unit.Sales_Status__c);
                });
            }

            //('filteredUnits1 : ' + JSON.stringify(filteredUnits1));

            var filteredUnits2 = [];
            if (this.selectedConfigurationTypeFilters.includes('All')) {
                filteredUnits2 = filteredUnits1;
            }
            else {
                filteredUnits2 = filteredUnits1.filter(unit => {
                    return this.selectedConfigurationTypeFilters.includes(unit.Configuration_Type__c);
                });
            }

            filteredUnits2 = filteredUnits2.map(unit => {

                return {
                    ...unit,
                    isUnitBooked: unit.Sales_Status__c === 'Booked',
                    isUnitBlocked: unit.Sales_Status__c === 'Blocked',
                    isQuotationVisible: unit.Sales_Status__c === 'Vacant' || unit.Sales_Status__c ==='Resale',
                    isBlockVisible: unit.Sales_Status__c === 'Vacant' || unit.Sales_Status__c === 'Resale',
                    isUnblockVisible: (unit.Sales_Status__c === 'Blocked') &&
                        (unit.Opportunity__c && unit.Opportunity__c.slice(0, unit.Opportunity__c.length - 3) === this.oppId),
                    primaryApplicantName: unit.Sales_Status__c === 'Booked' && unit.Booking__r ? unit.Booking__r.Primary_Applicant_Name__c : ''




                }
            })

            console.log('filteredUnits2 : ' + JSON.stringify(filteredUnits2));

            if (filteredUnits2.length > 0) {
                floorWiseAllUnitsFiltered.push({
                    'key': floor,
                    'value': filteredUnits2
                });
            }

        })

        //('floorWiseAllUnitsFiltered : ' + JSON.stringify(floorWiseAllUnitsFiltered));

        return floorWiseAllUnitsFiltered;
    }


    // Update Unit counts as per filters
    updateUnitCountForFilters() {

        //('this.originalUnitFloorMap : ' + JSON.stringify(Object.keys(this.originalUnitFloorMap)));

        // Calculate the Unit Counts as per filters
        var unitCountBySalesStatus = { "All": 0 };
        var unitCountByConfigurationType = { "All": 0 };


        Object.keys(this.originalUnitFloorMap).map(floor => {
            //('FLOOR : ' + floor)
            var units = this.originalUnitFloorMap[floor];
            units.map(unit => {
                if (unitCountBySalesStatus[unit.Sales_Status__c] == undefined) {
                    unitCountBySalesStatus[unit.Sales_Status__c] = 0;
                }
                if (unitCountByConfigurationType[unit.Configuration_Type__c] == undefined) {
                    unitCountByConfigurationType[unit.Configuration_Type__c] = 0;
                }
                unitCountBySalesStatus[unit.Sales_Status__c] = unitCountBySalesStatus[unit.Sales_Status__c] + 1;
                unitCountByConfigurationType[unit.Configuration_Type__c] = unitCountByConfigurationType[unit.Configuration_Type__c] + 1;
            });
            unitCountBySalesStatus['All'] = unitCountBySalesStatus['All'] + units.length;
            unitCountByConfigurationType['All'] = unitCountByConfigurationType['All'] + units.length;
        });

        //('unitCountBySalesStatus : ' + JSON.stringify(unitCountBySalesStatus));
        //('unitCountByConfigurationType : ' + JSON.stringify(unitCountByConfigurationType));


        // Update the filter counts
        this.unitSalesStatusOptions = this.unitSalesStatusOptions.map(option => {
            if (unitCountBySalesStatus[option.salesStatus] != undefined) {
                option.unitCount = unitCountBySalesStatus[option.salesStatus];
            }
            else {
                option.unitCount = 0;
            }
            return option;
        })
        this.unitConfigurationTypeOptions = this.unitConfigurationTypeOptions.map(option => {
            if (unitCountByConfigurationType[option.configurationType] != undefined) {
                option.unitCount = unitCountByConfigurationType[option.configurationType];
            }
            else {
                option.unitCount = 0;
            }
            return option;
        })

    }


    handleQuotation(event) {
        this.selectedUnitId = event.currentTarget.dataset.value;
        //this.unitTransfer = event.currentTarget.dataset.value === 'true';
        var link = document.createElement('a');
        //('selectedUnitId .: ', this.selectedUnitId);
        //('unitTransfer:' + this.unitTransfer);

        if (this.unitTransfer) {
            const url = '/apex/Ex_GenerateQuotationVF?uId=' + this.selectedUnitId + '&oppId=' + this.oppId;
            // const url = '/apex/Ex_GenerateQuotationVF?uId=' + this.selectedUnitId + '&oppId=' + this.oppId + '&bkId=' + this.bkId + '&unitTransfer=true';
            //const url = '/apex/Ex_InventoryMatrixVF?oppId=' + this.oppId + '&unitTransfer=true';
            link.href = url;
        } else {
            const url = '/apex/Ex_GenerateQuotationVF?uId=' + this.selectedUnitId + '&oppId=' + this.oppId;
            link.href = url;
        }

        link.target = '_blank';
        link.click();
    }

    handleBlock(event) {
        this.selectedUnitId = event.currentTarget.dataset.value;
        //(' this.selectedUnitId : ' + this.selectedUnitId);
        if (this.selectedUnitId) {
            handleblockunit({ selectedunit: this.selectedUnitId, oppId: this.oppId })
                .then(result => {
                    //('Unit Blocked successfully:', result);
                    alert('Unit blocked for 24 hours.');

                    location.reload();
                })
                .catch(error => {
                    console.error('An error occurred:', error);
                    alert('An error occurred while blocking the unit.');
                });
        }

    }

    handleUnBlock(event) {
        this.selectedUnitId = event.currentTarget.dataset.value;
        //(' this.selectedUnitId : ' + this.selectedUnitId);
        if (this.selectedUnitId) {
            handleunblockunit({ selectedunit: this.selectedUnitId, oppId: this.oppId })
                .then(result => {
                    //('Unit UnBlocked successfully:', result);
                    alert('Unit Unblocked.');
                    location.reload();
                })
                .catch(error => {
                    console.error('An error occurred:', error);
                    alert('An error occurred while blocking the unit.');
                });
        }
    }
}