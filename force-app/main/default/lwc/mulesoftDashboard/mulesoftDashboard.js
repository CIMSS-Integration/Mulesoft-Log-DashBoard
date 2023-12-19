import { LightningElement,track } from 'lwc';
import getMulesoftEnvData from '@salesforce/apex/MLD_MulesoftLogCallout.getMulesoftEnvData';
import getMulesoftAppData from '@salesforce/apex/MLD_MulesoftLogCallout.getMulesoftAppData';
import getMulesoftLogs from '@salesforce/apex/MLD_MulesoftLogCallout.getMulesoftLogs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MulesoftDashboard extends LightningElement {
    spinner = true;
    envComboValue = '';
    envComboValueLabel = '';
    appComboValue = '';
    appComboDisabled = true;
    startDate = '';
    endDate = '';
    filtersDisabled = true;
    statusComboValue = 'Any';

    @track envComboList;
    @track appComboList;
    @track logData;

    get statusComboList() {
        return [
            { label: 'Any', value: 'Any' },
            { label: 'Success', value: 'Success' },
            { label: 'Error', value: 'Error' },
        ];
    }

    logColumns = [
        { label: 'Name', fieldName: 'NameURL', type: 'url', typeAttributes: {
            label: {
                fieldName: 'Name'
            }
          } 
        },
        { label: 'Logger Name', fieldName: 'Logger_Name__c' },
        { label: 'Time Stamp', fieldName: 'Time_Stamp__c' },
        { label: 'Log Level', fieldName: 'Log_Level__c' },
        { label: 'Message', fieldName: 'Message__c', wrapText: true },
    ];


    connectedCallback() {
        getMulesoftEnvData()
        .then(data => {
            let listName = [];

            for (var key in data) {
                listName.push({ label: key, value: data[key] });
            }

            this.envComboList = listName;
            this.spinner = false;
        })

        .catch(error => {
            this.showToast('Error in Fetching Environment Data from Mulesoft!','error');
            this.spinner = false;
        })
    }


    envComboChange(event) {
        this.spinner = true;
        this.envComboValue = event.target.value;
        this.envComboValueLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        console.log(this.envComboValue);
        console.log(this.envComboValueLabel);

        getMulesoftAppData({ envId:this.envComboValue })
        .then(data => {
            let listName = [];

            if(data.length > 0){
                for (var key in data) {
                    listName.push({ label: data[key], value: data[key] });
                }
            }
            else{
                listName.push({ label: '-- No Application Deployed --', value: '-- No Application Deployed --' });
                this.filtersDisabled = true;
            }

            this.appComboList = listName;
            this.appComboValue = '';
            this.appComboDisabled = false;
            this.startDate = '';
            this.endDate = '';
            this.statusComboValue = 'Any';
            this.spinner = false;
        })

        .catch(error => {
            this.showToast('Error in Fetching Application Data from Mulesoft!','error');
            this.spinner = false;
        })
    }


    appComboChange(event) {
        if(event.target.value != '-- No Application Deployed --'){
            this.appComboValue = event.target.value;
            console.log(this.appComboValue);
            this.filtersDisabled = false;
        }
    }


    statusComboChange(event) {
        this.statusComboValue = event.target.value;
        console.log(this.statusComboValue);
    }


    handleInput(event) {
        if(event.target.name == 'startDate'){
            this.startDate = event.target.value;
        }
        else if(event.target.name == 'endDate'){
            this.endDate = event.target.value;
        }
    }

    
    handleSearch(event) {
        if(this.startDate == ''){
            this.showToast('Please select a Start Date!','warning');
        }
        else if(this.endDate == ''){
            this.showToast('Please select an End Date!','warning');
        }
        else if(this.startDate > this.endDate){
            this.showToast('Start Date cannot be after End Date!','warning');
        }
        else{
            this.spinner = true;

            getMulesoftLogs({ 
                orgName:'MIMIT', 
                envId:this.envComboValue,
                envName:this.envComboValueLabel, 
                appName:this.appComboValue, 
                endDate:this.endDate, 
                startDate:this.startDate, 
                logStatus:this.statusComboValue})
            .then(data => {
                console.log('LOGS DATA -->' + data);
                if(data.length > 0){
                    this.logData = data;
                    if(this.logData){
                        this.logData.forEach(item => item['NameURL'] = '/lightning/r/Integration_Log__c/' +item['Id'] +'/view');
                        
                    }
                    this.showToast('Logs fetched successfully!','success');
                }
                else{
                    this.showToast('No Logs found in the selected date range!','error');
                    this.logData = [];
                }
                this.spinner = false;
            })

            .catch(error => {
                this.showToast('Error in Fetching Logs Data from Mulesoft!','error');
                this.spinner = false;
            })
        }
    }


    handleClear(event) {
        this.startDate = '';
        this.endDate = '';
        this.statusComboValue = 'Any';
    }


    showToast(m,v) {
        const event = new ShowToastEvent({
            message: m,
            variant: v,
        });
        this.dispatchEvent(event);
    }
}