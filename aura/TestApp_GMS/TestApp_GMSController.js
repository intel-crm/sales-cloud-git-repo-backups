({
	doInit : function(component, event, helper) {
		const EXAMPLES_COLUMNS_DEFINITION_BASIC = [{
            type: 'text',
            fieldName: 'productName',
            label: 'Product Family',
            title: 'Product Family',
            initialWidth: 500,
        }];
        const DATA_BASIC = [
            {
                name: '0',
                productName: 'Chipsets',
                productFamily:'Chipsets',
                isChecked: true,
            },
            {
                name: '1',
                productName: 'Storage',
                productFamily:'Storage',
                isChecked:true,
                _children: [
                    {
                        name: '1-0',
                        productName: 'Memory 1',
                        productFamily:'Storage',
                        isChecked:true,
                    },
                    {
                        name: '1-1',
                        productName: 'Memory 2',
                        productFamily:'Storage',
                        isChecked:false,
                    },
                    {
                        name: '1-2',
                        productName: 'Memory 3',
                        productFamily: 'Storage',
                        isChecked:false,
                    },
                ],
            },
            {
                name: '2',
                productName: 'Server',
                productFamily: 'Server',
                isChecked:false,
            },
            {
                name: '3',
                productName: 'Laptop',
                productFamily: 'Laptop',
                isChecked:true,
                _children: [
                    {
                        name: '3-0',
                        productName: 'HP',
                        productFamily:'Laptop',
                        isChecked:false,
                    },
                    {
                        name: '3-1',
                        productName: 'Apple',
                        productFamily:'Laptop',
                        isChecked:true,
                    },
                    {
                        name: '3-2',
                        productName: 'Dell',
                        productFamily: 'Laptop',
                        isChecked:false,
                    },
                ],
            },
             {
                name: '4',
                productName: 'Mobile',
                productFamily: 'Mobile',
                isChecked:false,

            },
        ];
        component.set("v.showTable", true);
        component.set("v.columns", EXAMPLES_COLUMNS_DEFINITION_BASIC);
        component.set("v.data", DATA_BASIC);
	},
                    
                    getSelectedRecords : function(component, event, helper) {
                    
                    	console.log('In Aura '+ JSON.stringify(event.detail));
                    
                    }
})