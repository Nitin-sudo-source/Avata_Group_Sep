import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOppDetails from '@salesforce/apex/Ex_InventoryLWCController.getOppDetails';
import getProjectListDetails from '@salesforce/apex/Ex_InventoryLWCController.getProjectListDetails';
import getTowerListDetails from '@salesforce/apex/Ex_InventoryLWCController.getTowerListDetails';
import getUnitFloorMapDetails from '@salesforce/apex/Ex_InventoryLWCController.getUnitFloorMapDetails';
import getUnitConfigurationMapDetails from '@salesforce/apex/Ex_InventoryLWCController.getUnitConfigurationMapDetails';
import { NavigationMixin } from "lightning/navigation";
export default class inventoryComponent extends NavigationMixin(LightningElement) {
    @api oppId;
    @track isOppProject = false;
    @track selectedProjectId = null;
    @track selectedProjectName = null;
    @track selectedSubProjectName = null ;
    @track selectedSubProjectId = null ;
    @track selectedTowerId = null;
    @track selectedTowerName = null;
    @track projectList = [];
    @track towerList = [];
    @track originalUnitFloorMap = [];
    @track unitFloorMap = [];
    @track unitConfigurationMap = [];
    @track vacantCount = 0;
    @track bookedCount = 0;
    @track blockedCount = 0;
    @track notForSaleCount = 0;
    @track bookingInProcessCount = 0;
    @track refugeCount = 0;
    @track reservedCount = 0;
    @track selectedUnitId = null;

    connectedCallback() {
        console.log('oppId: ' + this.oppId);
        if (this.oppId) {
            getOppDetails({ oppId: this.oppId })
                .then(data => {
                    if (data) {
                        console.log('Opportunity: ' + JSON.stringify(data));
                        this.selectedProjectId = data.Project__c;

                        if (this.selectedProjectId) {
                            this.selectedProjectName = data.Project__r.Name;
                            this.isOppProject = true;
                            this.getTowerList();

                        } else {
                            this.getProjectList();
                        }
                    } else if (error) {
                        console.error('Error In getOppDetails: ', error);
                    }
                })
        }
    }

    getProjectList() {
        getProjectListDetails({})
            .then(data => {
                if (data) {
                    console.log('Project List: ' + JSON.stringify(data));
                    this.projectList = data;
                } else if (error) {
                    console.error('Error In getProjectListDetails: ', error);
                }
            })
    }

     getTowerList() {
        getTowerListDetails({ projectId: this.selectedProjectId })
            .then(data => {
                if (data) {
                    console.log('Tower List: ' + JSON.stringify(data));
                    this.towerList = data;
                } else if (error) {
                    console.error('Error In getTowerListDetails: ', error);
                }
            })
    }

    getUnitFloorMap() {
        this.unitFloorMap = [];
        this.vacantCount = 0;
        this.bookedCount = 0;
        this.blockedCount = 0;
        this.bookingInProcessCount = 0;
        this.refugeCount = 0;
        this.reservedCount = 0;
        this.notForSaleCount = 0 ;

        getUnitFloorMapDetails({ tId: this.selectedTowerId })
            .then(data => {
                if (data) {
                    //console.log('Unit Map: '+JSON.stringify(data));
                    this.originalUnitFloorMap = data;

                    for (let floor in data) {
                        //console.log('floor: '+floor);
                        const unitList = data[floor];
                        //console.log('unitList: '+unitList);

                        unitList.forEach(unit => {
                            //console.log('unit: '+unit);
                            if (unit.Sale_Status__c === 'Vacant') {
                                this.vacantCount = this.vacantCount + 1;
                            } else if (unit.Sale_Status__c === 'Booked') {
                                this.bookedCount = this.bookedCount + 1;
                            } else if (unit.Sale_Status__c === 'Blocked') {
                                this.blockedCount = this.blockedCount + 1;
                            } else if (unit.Sale_Status__c === 'Booking In-Progress') {
                                this.bookingInProcessCount = this.bookingInProcessCount + 1;
                            }
                            else if (unit.Sale_Status__c === 'Not for Sale') {
                                this.notForSaleCount = this.notForSaleCount + 1;
                            }
                        });
                        this.unitFloorMap.push({ key: floor, value: unitList });
                    }
                    console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
                } else if (error) {
                    console.error('Error In getUnitFloorMapDetails: ', error);
                }
            })
    }

    getUnitConfigurationMap() {
        this.unitConfigurationMap = [];
        getUnitConfigurationMapDetails({ tId: this.selectedTowerId })
            .then(data => {
                if (data) {
                    console.log('Unit Configuration Map: ' + JSON.stringify(data));

                    for (let config in data) {
                        this.unitConfigurationMap.push({ key: config, value: data[config] });
                    }
                    console.log('unitConfigurationMap: ' + JSON.stringify(this.unitConfigurationMap));
                } else if (error) {
                    console.error('Error In getUnitConfigurationMapDetails: ', error);
                }
            })
    }

    handleClick(event) {
        console.log('EventType: ' + event.currentTarget.dataset.name);
        console.log('EventValue: ' + event.currentTarget.dataset.value);

        var eventType = event.currentTarget.dataset.name;
        var eventValue = event.currentTarget.dataset.value;

        if (eventType === 'Project') {
            this.selectedProjectId = eventValue;
            this.selectedProjectName = this.projectList.find((project) => project.Id === eventValue).Name;
             this.getTowerList();
        } else if (eventType === 'Tower') {
            this.selectedTowerId = eventValue;
            this.selectedTowerName = this.towerList.find((tower) => tower.Id === eventValue).Name;
            this.getUnitFloorMap();
            this.getUnitConfigurationMap();
        } else if (eventType === 'Unit Status') {
            this.unitFloorMap = [];

            for (let floor in this.originalUnitFloorMap) {
                const unitList = this.originalUnitFloorMap[floor];
                const updatedUnitList = [];

                unitList.forEach(unit => {
                    if (unit.Sale_Status__c === eventValue) {
                        updatedUnitList.push({
                            ...unit
                        });
                    }
                });
                if (updatedUnitList.length !== 0) {
                    this.unitFloorMap.push({ key: floor, value: updatedUnitList });
                }
            }
            console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
        } else if (eventType === 'Unit Configuration') {
            this.unitFloorMap = [];

            for (let floor in this.originalUnitFloorMap) {
                const unitList = this.originalUnitFloorMap[floor];
                const updatedUnitList = [];

                unitList.forEach(unit => {
                    if (unit.Configuration__c === eventValue) {
                        updatedUnitList.push({
                            ...unit
                        });
                    }
                });
                if (updatedUnitList.length !== 0) {
                    this.unitFloorMap.push({ key: floor, value: updatedUnitList });
                }
            }
            console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
        } else if (eventType === 'Refresh') {
            this.unitFloorMap = [];

            for (let floor in this.originalUnitFloorMap) {
                this.unitFloorMap.push({ key: floor, value: this.originalUnitFloorMap[floor] });
            }
            console.log('unitFloorMap: ' + JSON.stringify(this.unitFloorMap));
        } else if (eventType === 'PreviousTower') {
            if (this.selectedTowerId) {
                this.selectedTowerId = null;
            } else if (this.selectedProjectId) {
                this.selectedProjectId = null;
                this.selectedTowerId = null;
                this.towerList = [];
            }
        }
    else if (eventType === 'PreviousSubProject') {
        if (this.selectedSubProjectId) {
            this.selectedSubProjectId = null;
        } else if (this.selectedProjectId) {
            this.selectedProjectId = null;
            this.selectedSubProjectId = null;
            this.SubProjectList = [];
        }
    }
    }

     handleQuotation(event){  
         this.selectedUnitId = event.currentTarget.dataset.value; 
      
        var link = document.createElement('a');
       
        if(this.selectedUnitId){
            const url = '/apex/Ex_CreateQuotationVF?uId=' + this.selectedUnitId + '&oppId=' + this.oppId;
            link.href = url;
            link.target = '_blank';
            link.click();
        }
    
    }
    handleBlock(event) {
          this.selectedUnitId = event.target.dataset.value;
        const compDefinition = {
            componentDef: "c:blockingDetailPage",
            attributes: {
                uniValue: this.selectedUnitId,
                projValue: this.selectedProjectId,
                oppvalue: this.oppId,
            },

        }
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        var url = "/one/one.app#" + encodedCompDef;
        var link = document.createElement('a');
        link.href = url;
        link.target = '_self';
        link.click();
        location.reload();
    }
}