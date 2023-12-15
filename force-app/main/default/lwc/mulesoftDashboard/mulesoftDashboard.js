import { LightningElement,track } from 'lwc';
import getMulesoftEnvData from '@salesforce/apex/MLD_MulesoftLogCallout.getMulesoftEnvData';
import getMulesoftAppData from '@salesforce/apex/MLD_MulesoftLogCallout.getMulesoftAppData';

export default class MulesoftDashboard extends LightningElement {
    spinner = true;
    envComboValue = '';
    appComboValue = '';
    appComboDisabled = true;
    startDate = '';
    endDate = '';
    last = '';
    filtersDisabled = true;
    statusComboValue = '';

    @track envComboList;
    @track appComboList;

    get statusComboList() {
        return [
            { label: 'Any', value: 'new' },
            { label: 'Success', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    columns = [
        { label: 'Label', fieldName: 'name' },
        { label: 'Website', fieldName: 'website', type: 'url' },
        { label: 'Phone', fieldName: 'phone', type: 'phone' },
        { label: 'Balance', fieldName: 'amount', type: 'currency' },
        { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
    ];

    data = [...Array(10)].map((_, index) => {
        return {
            name: `Name (${index})`,
            website: 'www.salesforce.com',
            amount: Math.floor(Math.random() * 100),
            phone: `${Math.floor(Math.random() * 9000000000) + 1000000000}`,
            closeAt: new Date(
                Date.now() + 86400000 * Math.ceil(Math.random() * 20)
            ),
        };
    });


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
            alert('Error in Fetching Environment Data from Mulesoft');
            this.spinner = false;
        })
    }


    envComboChange(event) {
        this.spinner = true;
        this.envComboValue = event.target.value;
        console.log(this.envComboValue);

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
            }

            this.appComboList = listName;
            this.appComboDisabled = false;
            this.spinner = false;
        })

        .catch(error => {
            alert('Error in Fetching Application Data from Mulesoft');
            this.spinner = false;
        })
    }


    appComboChange(event) {
        this.appComboValue = event.target.value;
        console.log(this.appComboValue);
        this.filtersDisabled = false;
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
        else if(event.target.name == 'last'){
            this.last = event.target.value;
        }
    }

    
    handleSearch(event) {
        console.log("Before Search:: "+this.startDate);
        console.log("Before Search:: "+this.endDate);
        console.log("Before Search:: "+this.last);

        //this.startDate = this.template.querySelector(".from").value;
        //this.endDate = this.template.querySelector(".to").value;
        //this.last = this.template.querySelector(".last").value;

        console.log("After Search:: "+this.startDate);
        console.log("After Search:: "+this.endDate);
        console.log("After Search:: "+this.last);
    }

    handleClear(event) {
        console.log("Before Clear:: "+this.startDate);
        console.log("Before Clear:: "+this.endDate);
        console.log("Before Clear:: "+this.last);

        this.startDate = '';
        this.endDate = '';
        this.last = '';

        console.log("After Clear:: "+this.startDate);
        console.log("After Clear:: "+this.endDate);
        console.log("After Clear:: "+this.last);
    }

}