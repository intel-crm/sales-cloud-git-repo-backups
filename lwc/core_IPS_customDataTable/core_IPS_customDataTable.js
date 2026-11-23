import { LightningElement } from 'lwc';

export default class Core_IPS_customDataTable extends LightningElement {
    data = [];

    connectedCallback() {
        this.columns = [
            { label: 'Name', fieldName: 'Name'},
            { label: 'Account Number', fieldName: 'AccountNumber'},
            { label: 'Phone', fieldName: 'phone', type: 'phone'},
            {
                label: 'Members', fieldName: 'Members', type: 'picklist', typeAttributes: {
                    placeholder: 'Member Type', options: [
                        { label: 'Selective', value: 'Selective' },
                        { label: 'All', value: 'All' },
                    ]  
                    , value: { fieldName: 'Members' }  
                    , context: { fieldName: 'Id' }
                }
            }
        ];
        this.data = [{ 'Id': '12345', 'Name': 'Acme', 'AccountNumber': 'CD355119-A', 'Members': 'Selective', phone: 12537 },
         { 'Id': '34567', 'Name': 'Mace', 'AccountNumber': 'CD355120-A', 'Members': 'Selective', phone: 1978234 }]

    }

    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Rating: dataRecieved.value };
    }
}