import { LightningElement, api, track } from 'lwc';
import getOppDetails from '@salesforce/apex/Ex_InventoryMatrix.getOppDetails';
import getProjectList from '@salesforce/apex/Ex_InventoryMatrix.getProjectList';
import getTower from '@salesforce/apex/Ex_InventoryMatrix.getTower';
import getUnit from '@salesforce/apex/Ex_InventoryMatrix.getUnit';
import getUnitFloorMapDetails from '@salesforce/apex/Ex_InventoryMatrix.getUnitFloorMapDetails';
import getUnitConfigurationMapDetails from '@salesforce/apex/Ex_InventoryMatrix.getUnitConfigurationMapDetails';
export default class Ex_InventoryMatrix extends LightningElement {
    
    @api oppId;
    @track fetchOpp;
    @track isOppProject = false;
    @track showSpinner = false;

    @track projectList = [];
    @track towerList = [];
    @track unitList = [];

    @track storeTowerId = '';
    @track storeProjectId = '';
    @track selectedUnitId = '';

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

    @track vacantCount = 0;
    @track bookedCount = 0;
    @track blockedCount = 0;
    @track notForSaleCount = 0;
    @track bookingInProcessCount = 0;
    @track refugeCount = 0;
    @track reservedCount = 0;

    @track filterdata = false;
    @track filteredunitFloorMap = [];



    connectedCallback() {
        if(this.oppId == undefined){
        const urlSearchParams = new URLSearchParams(window.location.search);
        this.oppId = urlSearchParams.get("recordId");
        }
        //alert('oppId: ' + this.oppId);
        this.handleOppData();
    }

    handleOppData(){
        this.showSpinner = true;
        if(this.oppId !== undefined){
            getOppDetails({ oppId: this.oppId})
            .then(result => {
                console.log('result ',result);
                this.fetchOpp = result;
                this.error = undefined;
                if(this.fetchOpp.Project__c != undefined){
                    this.isOppProject = true;
                    this.storeProjectId = this.fetchOpp.Project__c;
                    this.handleProjectData();
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.fetchOpp = undefined;
            })
        }else{
            this.handleProjectData();
            this.showSpinner = false;
        }
       
        
    }

    handleProjectData(){
       
        let array = [];
        array.push(this.fetchOpp);
        this.projectList = array.map(pro => ({
            label: pro.Project__r.Name,
            value: pro.Project__r.Id
        }));
        if(this.projectList.length === 0){
            getProjectList({}).then(result=>{
                console.log('projectList result '+JSON.stringify(result));
                this.projectList = result.map(pro => ({
                    label: pro.Name,
                    value: pro.Id
                }));
            })
        }else{
            this.getTowers();
        }
        console.log('projectList: '+JSON.stringify(this.projectList));
    }

    handleProject(event) {
        this.storeProjectId = event.detail.value;
        console.log('storeProjectId: ', this.storeProjectId);
        this.getTowers();
    }

    getTowers() {
        this.showSpinner = true;
        getTower({ projId: this.storeProjectId })
            .then(data => {
                this.towerList = data.map(t => ({
                    label: t.Name,
                    value: t.Id
                }));
                console.log('Tower List:', JSON.stringify(this.towerList));
                this.showSpinner = false;
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                return Promise.reject(error);
            });
    }

    handleTower(event) {
        this.storeTowerId = event.detail.value;
        console.log('storeTowerId ', this.storeTowerId);
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
    }

    getUnits() {
        this.showSpinner = true;
        getUnit({ towerId: this.storeTowerId})
            .then(data => {
                this.unitList = data
                console.log('Unit List:', JSON.stringify(this.unitList));
                this.showSpinner = false;
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                return Promise.reject(error);
            });
    }

    handleUnit(event) {
        this.selectedUnitId = event.detail.value;
        console.log('selectedUnitId: ', this.selectedUnitId);
        
    }

    
    getUnitConfigurationMap() {
        this.showSpinner = true;
        this.unitConfigurationMap = [];
        getUnitConfigurationMapDetails({ towerId: this.storeTowerId })
            .then(data => {
                if (data != null) {
                    console.log('Unit Configuration Map: ' + JSON.stringify(data));
                    for (let config in data) {
                        this.unitConfigurationMap.push({key: config, value: data[config]});
                    }
                    this.showSpinner = false;
                } else if (error) {
                    console.error('Error In getUnitConfigurationMapDetails: ', error);
                }
            })
            console.log('unitConfigurationMap: ' + JSON.stringify(this.unitConfigurationMap));
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

        getUnitFloorMapDetails({ towerId: this.storeTowerId })
            .then(data => {
                if (data) {
                    console.log('Unit Map: '+JSON.stringify(data));
                    this.originalUnitFloorMap = data;
                    for (let floor in data) {
                        console.log('floor: '+floor);
                        this.unitList = data[floor];
                        this.unitList = this.unitList.map(item => ({ ...item}));


                        // this.unitList = data[floor].map(u => ({
                        //     ...u
                        //     // isBlockedOpp: u.Opportunity__c && u.Opportunity__c.slice(0, u.Opportunity__c.length - 3) === this.oppId && u.Sales_Status__c === 'Blocked'
                        // }));
                        console.log('unitList: ' + JSON.stringify(this.unitList));
                        this.unitList.forEach(unit => {
                            if (unit.Sales_Status__c === 'Vacant') {
                                this.vacantCount = this.vacantCount + 1;
                            } else if (unit.Sales_Status__c === 'Booked') {
                                this.bookedCount = this.bookedCount + 1;
                            } else if (unit.Sales_Status__c === 'Blocked') {
                                this.blockedCount = this.blockedCount + 1;
                            } else if (unit.Sales_Status__c === 'Booking-In-Process') {
                                this.bookingInProcessCount = this.bookingInProcessCount + 1;
                            }
                            else if (unit.Sales_Status__c === 'Not for Sale') {
                                this.notForSaleCount = this.notForSaleCount + 1;
                            }
                        });
                        this.unitFloorMap.push({ key: floor, value: this.unitList });
                        this.showSpinner = false;
                    }
                    this.unitCount = this.vacantCount + this.bookedCount + this.blockedCount + this.bookingInProcessCount + this.notForSaleCount;
                    console.log('Unit Count: ', this.unitCount);
                    console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
                    console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
                } else if (error) {
                    console.error('Error In getUnitFloorMapDetails: ', error);
                }
            })
    }
    

    handleAllCheckboxChange(event) {
        const isChecked = event.target.checked;
        this.isAllChecked = isChecked;
        if (isChecked) {
            this.defaultdata = true;
            this.filterdata = false;
            this.isDisabled = false;
        } else {
            this.defaultdata = false;
            this.filterdata = true;
        }
    }

    handleClick(event) {
        this.showSpinner = true;
        this.defaultdata = false;
        this.filterdata = true;
        this.isAllChecked = false;
        this.filteredunitFloorMap = [];
        const eventType = event.currentTarget.dataset.name;
        console.log('eventType .: ', eventType);
        const eventValue = event.currentTarget.dataset.value;
        console.log('eventValue .: ', eventValue);
        const isChecked = event.target.checked;

        if (eventValue === 'Vacant') {
            this.isDisabled1 = event.target.checked;
        } /*if (eventValue === 'Refuge') {
            this.statuscheckboxRefuge = event.target.checked;
        }*/ if (eventValue === 'Booked') {
            this.statuscheckboxBooked = event.target.checked;
        } if (eventValue === 'Blocked') {
            this.statuscheckboxBlocked = event.target.checked;
        } if (eventValue === 'Booking-In-Process') {
            this.statuscheckboxBookingInProcess = event.target.checked;
        } /*if (eventValue === 'Reserved') {
            this.statuscheckboxReserved = event.target.checked;
        }*/ if (eventValue === 'Not For Sale') {
            this.statuscheckboxNotForSale = event.target.checked;
        } else {
            // this.isDisabled = event.target.checked;
        }

        if (isChecked) {
            // Add the configuration to the selectedConfigurations array if checked
            this.selectedConfigurations.push(eventValue);
            console.log('this.selectedConfigurations' + this.selectedConfigurations);
        } else {
            // Remove the configuration from the selectedConfigurations array if unchecked
            const index = this.selectedConfigurations.indexOf(eventValue);
            if (index !== -1) {
                this.selectedConfigurations.splice(index, 1);
                console.log('this.selectedConfigurations12' + this.selectedConfigurations);

            }
        }

        const selectedConfigurations = this.selectedConfigurations;

        const sale_statusOptions = [
            'Vacant',
            'Blocked',
            'Booking In-Process',
            'Booked',
            // 'Refuge',
            // 'Reserved',
            'Not For Sale'
        ];

        const configDataValues = this.unitList.map(config => config.Configuration_Type__c);
        console.log('configDataValues .: ', JSON.stringify(configDataValues));

        const containsDesiredValues = selectedConfigurations.some(value => sale_statusOptions.includes(value));
        console.log('containsDesiredValues .: ', JSON.stringify(containsDesiredValues));

        const containsConfigDataValues = selectedConfigurations.some(value => configDataValues.includes(value));
        console.log('containsConfigDataValues .: ', JSON.stringify(containsConfigDataValues));

        if (containsDesiredValues && containsConfigDataValues) {
            console.log("The array contains at least one of the desired values and at least one configuration from configData.");
            for (let floor in this.originalUnitFloorMap) {
                this.unitList = this.originalUnitFloorMap[floor];
                const updatedUnitList = [];

                this.unitList.forEach(unit => {
                    if (
                        (this.selectedConfigurations.includes(unit.Configuration_Type__c) &&
                            this.selectedConfigurations.includes(unit.Sales_Status__c))) {
                        updatedUnitList.push({
                            ...unit
                        });
                    }
                });

                if (updatedUnitList.length !== 0) {
                    this.filteredunitFloorMap.push({ key: floor, value: updatedUnitList });
                }
            }
            console.log('unitFloorMap: ' + JSON.stringify(this.filteredunitFloorMap));
        } else {
            console.log("The array does not contain any of the desired values or any configuration from configData.");
            for (let floor in this.originalUnitFloorMap) {
                this.unitList = this.originalUnitFloorMap[floor];
                const updatedUnitList = [];

                this.unitList.forEach(unit => {
                    if (
                        (this.selectedConfigurations.includes(unit.Configuration_Type__c) ||
                            this.selectedConfigurations.includes(unit.Sales_Status__c))) {
                        updatedUnitList.push({
                            ...unit
                        });
                    }
                });

                if (updatedUnitList.length !== 0) {
                    this.filteredunitFloorMap.push({ key: floor, value: updatedUnitList });
                }
            }
            console.log('unitFloorMap: ' + JSON.stringify(this.filteredunitFloorMap));
        }

        console.log('unitFloorMapFinal: ' + JSON.stringify(this.filteredunitFloorMap));
        this.showSpinner = false;
    }

    handleQuotation(event) {
        this.selectedUnitId = event.currentTarget.dataset.value;
        var link = document.createElement('a');
        if (this.selectedUnitId) {
            const url = '/apex/Ex_GenerateQuotationVF?uId=' + this.selectedUnitId + '&oppId=' + this.oppId;
            link.href = url;
            link.target = '_blank';
            link.click();
        }
    }

    handleBlock(event) {
        console.log('oppId::: ',this.oppId);
        console.log('projValue::: ',this.storeProjectId);
    
        this.selectedUnitId = event.target.dataset.value;
        console.log('selectedUnitId:: ',this.selectedUnitId);
      const compDefinition = {
          componentDef: "c:blockingDetailPage",
          attributes: {
              uniValue: this.selectedUnitId,
              projValue: this.storeProjectId,
              oppvalue: this.oppId,
          },

      }
      var encodedCompDef = btoa(JSON.stringify(compDefinition));
      var url = "/one/one.app#" + encodedCompDef;
      var link = document.createElement('a');
      link.href = url;
      link.target = '_self';
      link.click();
      //location.reload();
  }

}