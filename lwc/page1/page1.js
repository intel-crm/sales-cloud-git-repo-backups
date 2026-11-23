import { LightningElement,wire,api,track } from 'lwc';
import getEvalutionProductList from '@salesforce/apex/Sales_CreateLicenseController.getProductList';
import productoption from '@salesforce/apex/OptionProductController.getProductOptions'
import { NavigationMixin } from 'lightning/navigation';

export default class Page1 extends NavigationMixin(LightningElement) {

    @track buttonClicked=false;
   @track result;
    error;
   isload =false;
   @track roductOptionsResult
    dataAvailable;
    @api checkradio=false;
    termandcondition=false;
    //@api productId;
    //columnsList=columns;
    @track productOptionsData = {};
    selectedRows =[];
    changedNoSeats2=[];
    draftValues = [];
    selectedProd = [];
    //T&C logic
    termsAccepted=false;
    termsCondition;
    licenseType='Evalution';
    @track selectedProductOptions = [];
    
    
   
    
    @api isChecked = false;
    
    
    @api uniqueId = 'radio-' + Math.random().toString(36).substring(7);
    @track showTable = false;
    @track isNextButtonDisabled = 'false';
    @track noOfSeats = 1;
    @track showseats= false;
    @track defaultValue=1;
    @track inputDisable = true;
    @track pid;

    handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
        this.showTable=false;
        this.inputDisable=true;
        this.pid=productId;
        this.loadProductOptions(productId);
        
        
    }
    
    loadProductOptions(productId) {
        
       
    
        /*
        if(this.result[productId]==='FIXED'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='true';

        }
        else if(this.productId.licType==='FLOAT'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='false';
        }*/
        /*productoption({ prodId: productId })
            .then(result => {
                this.selectedProductOptions = result;
                this.showTable = true; // Show the table when options are available
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error loading product options:', error);
                this.selectedProductOptions = [];
                this.showTable = false; // Hide the table when options are not available
                this.error = 'Error loading product options';
            });*/

        productoption({ prodId: productId })
        .then(result => {
            console.log(JSON.stringify(result));
            for(let key in result){
                console.log(JSON.stringify(key));
                console.log(JSON.stringify(result[key]));
                let resultCleanUp = [];

               
                for(const e of result[key]){
                    var test = {};
                    
                
                    let ty=e.split("%");
                    test.Id = ty[1];
                    test.WebDesc =ty[0];
                    test.checked=false;
                    resultCleanUp.push(test);

                }
                console.log(resultCleanUp);
                this.selectedProductOptions=resultCleanUp;
                //Changes by Bishal Singh
           /*     this.selectedProductOptions = result[key].map(optionProduct => ({
                   ...optionProduct,
                  // const parts = optionProduct.split('%');

                    checked: false // Initialize checked status to false
                    
                }));*/

                


            }
            
            console.log('this.selectedProductOptions' + this.selectedProductOptions);
            this.inputDisable=true;
       
            
            if(this.selectedProductOptions.length>0){
                console.log(this.selectedProductOptions.length);
                this.showTable = true;
                this.showseats=true;
                this.isNextButtonDisabled=false;

            }
            else{
                this.showTable= true;
                this.showseats=false;
                this.isNextButtonDisabled=false;

                
            }
            
            const selectedProduct = this.result.find(product => product.prodId === productId);
            console.log(selectedProduct.licType)
            if (selectedProduct.licType !== 'FIXED') {
                console.log('float');
                
                this.inputDisable = false; // Disable the input field for "# of Seats"
            } 
            
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions = [];
        });
        
    }
    
    loadSeats(productId){
        console.log(productId);
        const selectedProduct = this.result.find(product => product.prodId === productId);
        console.log(selectedProduct);
            if (selectedProduct) {
                if (selectedProduct.licType !== 'FIXED') {
                    console.log('float');
                    
                    this.inputDisable = false; // Disable the input field for "# of Seats"
                } 
    }
    this.loadProductOptions(productId);
}

   /* handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
    this.result = this.result.map(product => ({
        ...product,
        checked: product.Id === productId
    }));
    this.showTable = event.target.checked;

    if (event.target.checked) {
        this.loadProductOptions(productId); // Load product options if the radio button is checked
    } else {
        // Update the condition to check if productOptionsData[productId] is defined
        if (this.productOptionsData[productId]) {
            this.productOptionsData[productId] = undefined;
        }
    
    }
}
loadProductOptions(productId) {
    productoption({ prodId: productId })
        .then(result => {
            this.selectedProductOptions[productId] = result;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions[productId] = undefined;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        });
}*/
    /*@wire(productoption, { prodId: '$selectedProductId' })
handleProductOptions({ error, data }) {
    if (data) {
        this.productOptionsData = {
            ...this.productOptionsData,
            [this.selectedProductId]: data
        };
    } else if (error) {
        console.log('Error fetching product options:', error);
    }
}*/
    /*selectedProductOptnAvailable;
    productOptionsData;
    async loadProductOptions(productId) {
        try{
        const productOptions = await productoption({ prodId: productId });

        // Update the result array with the retrieved product options
        this.result = this.result.map(product => {
            if (product.Id === productId) {
                product.productOptions = productOptions;
            }
            return product;
        });

        // Toggle the visibility of the options table
        this.showTable = productOptions && productOptions.length > 0;
    } catch (error) {
        console.error('Error loading product options:', error);
    }
}*/


    
    
    

    handleClick(event) {
        const pid = event.target.value;

    this.result = this.result.map(product => ({
        ...product,
        checked: product.prodId === pid // Set checked status for the clicked product
    }));
    
    
    //const productId = event.target.value;
    this.loadProductOptions(pid);
    }
    @track selectedCheckboxes=[];
    handleCheckboxChange(event) {
        
            const checkboxId = event.target.dataset.id;
            const isChecked = event.target.checked;
    
            if (isChecked) {
                this.selectedCheckboxes.push(checkboxId);
            } else {
                const index = this.selectedCheckboxes.indexOf(checkboxId);
                if (index > -1) {
                    this.selectedCheckboxes.splice(index, 1);
                }
            }
    
            console.log('Selected Checkboxes:', this.selectedCheckboxes);
        }
        
    
    handleNextButtonClick() {
    /*this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'c__page2'
        },
        state: {
            c__counter: '5'
        }
    });
    console.log('Next button clicked!');*/
    var selectedEvent = new CustomEvent('productpage', { detail:{"comp2" : true, "comp1" : false}});
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
   }
        
        
    
    handleSeatsInputChange(event) {
        this.noOfSeats = parseInt(event.target.value, 10);
         // Parse the input value as an integer
        if (this.noOfSeats >= 1 && this.noOfSeats <= 9999) {
            this.isNextButtonDisabled = true; // Enable the Next button only if the radio button is checked
        } else {
            this.isNextButtonDisabled = false; // Disable the Next button if the input value is outside of the range
        }
         // Call a function to enable/disable the Next button
    }
    handleNextButtonState() {
        // Enable the Next button only when the radio button is checked and the number of seats is greater than 0
      
    }
    /**end */

    /********************************************
        Function      : wire method to get list of products
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/

        @wire(getEvalutionProductList,{licenseType:'$licenseType'})
        getEvalutionProductList({ error, data }) {
            if (data) {
                console.log('errors>>>'+JSON.stringify(data))
                this.result = data.map(product => ({
                    ...product,
                    checked: false // Initialize checked status to false
                }));
                
                if(this.result.length>0){
                    
                this.dataAvailable=true;
                this.isload=false;
                }
                else{
                    this.isload= true;
                    this.dataAvailable=false;
                }
                 ///show error in the UI if no records
                this.error = undefined;
            } else if (error) {
                console.log('errors>>>'+JSON.stringify(error));
                this.error = error;
                this.result = undefined;
                this.dataAvailable=false;
                this.isload=true;
    
            }
        }
        /********************************************
        Function      : handle the selected row data
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
    getSelectedRow(event){
        this.selectedRows = event.detail.selectedRows; 
        console.log('selectedRows>>'+JSON.stringify(this.selectedRows));
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedProd=[];
            this.termsCondition=this.selectedRows[i].TandC;
            console.log('termsCondition>>>'+this.termsCondition);
            this.selectedProd.push({
                licExp:this.selectedRows[i].licExp,
                licType:this.selectedRows[i].licType,
                maintenenceExp:this.selectedRows[i].maintenenceExp,
                noSeats:this.selectedRows[i].noSeats,
               // displayEditIcon:selectedRows[i].displayEditIcon,
                prodExtId:this.selectedRows[i].prodExtId,
                prodId:this.selectedRows[i].prodId,
                prodName:this.selectedRows[i].prodName,
                maxRehost:this.selectedRows[i].maxRehost,
                prodExtTempLicAllowed:this.selectedRows[i].prodExtTempLicAllowed,
                optnAvailable:this.selectedRows[i].optnAvailable,
                optin:false,
                isEmployee:false
                
            });
        }
        console.log('selectedProd value after row select>>'+JSON.stringify(this.selectedProd)); 
        this.termandcondition=true;
    }
}
/*import { LightningElement,wire,api,track } from 'lwc';
import getEvalutionProductList from '@salesforce/apex/Sales_CreateLicenseController.getProductList';
import productoption from '@salesforce/apex/OptionProductController.getProductOptions'
import { NavigationMixin } from 'lightning/navigation';

export default class Page1 extends NavigationMixin(LightningElement) {

    @track buttonClicked=false;
   @track result;
    error;
   isload =false;
   @track roductOptionsResult
    dataAvailable;
    @api checkradio=false;
    termandcondition=false;
    //columnsList=columns;
    @track productOptionsData = {};
    selectedRows =[];
    changedNoSeats2=[];
    draftValues = [];
    selectedProd = [];
    //T&C logic
    termsAccepted=false;
    termsCondition;
    licenseType='Evalution';
    @track selectedProductOptions = [];
    
    
   
    
    @api isChecked = false;
    
    
    @api uniqueId = 'radio-' + Math.random().toString(36).substring(7);
    @track showTable = false;
    @track isNextButtonDisabled = 'false';
    @track noOfSeats = 1;
    @track showseats= false;
    @track defaultValue=1;
    @track inputDisable = 'false';

    handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
        this.loadProductOptions(productId);
    }
    loadProductOptions(productId) {
        
       
    
        /*
        if(this.result[productId]==='FIXED'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='true';

        }
        else if(this.productId.licType==='FLOAT'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='false';
        }*/
        /*productoption({ prodId: productId })
            .then(result => {
                this.selectedProductOptions = result;
                this.showTable = true; // Show the table when options are available
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error loading product options:', error);
                this.selectedProductOptions = [];
                this.showTable = false; // Hide the table when options are not available
                this.error = 'Error loading product options';
            });*//*
        productoption({ prodId: productId })
        .then(result => {
            this.selectedProductOptions = result;
            
            if(this.selectedProductOptions.length>0){
                console.log(this.selectedProductOptions.length);
                this.showTable = true;
                this.showseats=true;

            }
            else{
                this.showTable= false;
                this.showseats=true;
            }
            
            
            
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions = [];
        });
    }
*/
   /* handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
    this.result = this.result.map(product => ({
        ...product,
        checked: product.Id === productId
    }));
    this.showTable = event.target.checked;

    if (event.target.checked) {
        this.loadProductOptions(productId); // Load product options if the radio button is checked
    } else {
        // Update the condition to check if productOptionsData[productId] is defined
        if (this.productOptionsData[productId]) {
            this.productOptionsData[productId] = undefined;
        }
    
    }
}
loadProductOptions(productId) {
    productoption({ prodId: productId })
        .then(result => {
            this.selectedProductOptions[productId] = result;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions[productId] = undefined;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        });
}*/
    /*@wire(productoption, { prodId: '$selectedProductId' })
handleProductOptions({ error, data }) {
    if (data) {
        this.productOptionsData = {
            ...this.productOptionsData,
            [this.selectedProductId]: data
        };
    } else if (error) {
        console.log('Error fetching product options:', error);
    }
}*/
    /*selectedProductOptnAvailable;
    productOptionsData;
    async loadProductOptions(productId) {
        try{
        const productOptions = await productoption({ prodId: productId });

        // Update the result array with the retrieved product options
        this.result = this.result.map(product => {
            if (product.Id === productId) {
                product.productOptions = productOptions;
            }
            return product;
        });

        // Toggle the visibility of the options table
        this.showTable = productOptions && productOptions.length > 0;
    } catch (error) {
        console.error('Error loading product options:', error);
    }
}*/

    
    /*loadProductOptions(productId) {
        
        const presult=this.result;
    
        /*
        if(this.result[productId]==='FIXED'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='true';

        }
        else if(this.productId.licType==='FLOAT'){
            this.showseats=true;
            this.defaultValue=1;
            this.inputDisable='false';
        }*/
        /*productoption({ prodId: productId })
            .then(result => {
                this.selectedProductOptions = result;
                this.showTable = true; // Show the table when options are available
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error loading product options:', error);
                this.selectedProductOptions = [];
                this.showTable = false; // Hide the table when options are not available
                this.error = 'Error loading product options';
            });*/
            /*loadProductOptions(productId){
                productoption({ prodId: productId })
                    .then(result => {
                        this.selectedProductOptions = result;
            const selectedProduct = this.result.find(product => product.prodId === productId);
            if (selectedProduct) {
                if (selectedProduct.licType === 'FIXED') {
                    this.showseats = true;
                    this.defaultValue = 1;
                    this.inputDisable = true;
                } else {
                    this.showseats = true;
                    this.defaultValue = 1;
                    this.inputDisable = false;
                }
            }
            if (this.selectedProductOptions.length > 0) {
                this.showTable = true;
            } else {
                this.showTable = false;
            }
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions = [];
            this.showTable = false;
        });
    }*/

      /*productoption({ prodId: productId })
        .then(result => {
            this.selectedProductOptions = result;
        this.selectedProductOptions = result;

            // Check the license type of the selected product
            const selectedProduct = presult.find(product => product.prodId === productId);
            if (selectedProduct) {
                if (selectedProduct.licType === 'FIXED') {
                    
                    this.defaultValue = 1;
                    this.inputDisable = true; // Disable the input field for "# of Seats"
                } else {
                    
                    this.defaultValue = 1;
                    this.inputDisable = false; // Enable the input field for "# of Seats"
                }
            }

            if (this.selectedProductOptions.length > 0) {
                this.showTable = true;
                this.showseats = true;
            } else {
                this.showTable = false;
                this.showseats = true;
            }
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions = [];
            this.showTable = false;
        });
}*/
       /* .then(result => {
            this.selectedProductOptions = result;
            
            if(this.selectedProductOptions.length>0){
                console.log(this.selectedProductOptions.length);
                this.showTable = true;
                this.showseats=false;

            }
            else{
                this.showTable= false;
                this.showseats=false;
            }
            
            const selectedProduct = presult.find(product => product.prodId === productId);
            if (selectedProduct) {
                if (selectedProduct.licType === 'FIXED') {
                    this.showseats = true;
                    this.defaultValue = 1;
                    this.inputDisable = 'false';
                } else if (selectedProduct.licType === 'FLOAT') {
                    this.showseats = true;
                    this.defaultValue = 1;
                    this.inputDisable = 'true';
                }
                }
            
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions = [];
        });
    }*/

   /* handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
    this.result = this.result.map(product => ({
        ...product,
        checked: product.Id === productId
    }));
    this.showTable = event.target.checked;

    if (event.target.checked) {
        this.loadProductOptions(productId); // Load product options if the radio button is checked
    } else {
        // Update the condition to check if productOptionsData[productId] is defined
        if (this.productOptionsData[productId]) {
            this.productOptionsData[productId] = undefined;
        }
    
    }
}
loadProductOptions(productId) {
    productoption({ prodId: productId })
        .then(result => {
            this.selectedProductOptions[productId] = result;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        })
        .catch(error => {
            console.error('Error loading product options:', error);
            this.selectedProductOptions[productId] = undefined;
            this.result = [...this.result]; // Trigger reactivity to update the UI
        });
}*/
    /*@wire(productoption, { prodId: '$selectedProductId' })
handleProductOptions({ error, data }) {
    if (data) {
        this.productOptionsData = {
            ...this.productOptionsData,
            [this.selectedProductId]: data
        };
    } else if (error) {
        console.log('Error fetching product options:', error);
    }
}*/
    /*selectedProductOptnAvailable;
    productOptionsData;
    async loadProductOptions(productId) {
        try{
        const productOptions = await productoption({ prodId: productId });

        // Update the result array with the retrieved product options
        this.result = this.result.map(product => {
            if (product.Id === productId) {
                product.productOptions = productOptions;
            }
            return product;
        });

        // Toggle the visibility of the options table
        this.showTable = productOptions && productOptions.length > 0;
    } catch (error) {
        console.error('Error loading product options:', error);
    }
}*/
/*

    
    
    

    handleClick(event) {
        const pid = event.target.value;

    this.result = this.result.map(product => ({
        ...product,
        checked: product.prodId === pid // Set checked status for the clicked product
    }));
    
    
    //const productId = event.target.value;
    this.loadProductOptions(pid);
    }

    handleCheckboxChange(event) {
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
        this.isChecked = event.target.checked;
        
        
    }
    handleNextButtonClick() {
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'c__page2'
        },
        state: {
            c__counter: '5'
        }
    });
    console.log('Next button clicked!');
   }
        
        
    
    handleSeatsInputChange(event) {
        this.noOfSeats = parseInt(event.target.value, 10);
         // Parse the input value as an integer
        if (this.noOfSeats >= 1 && this.noOfSeats <= 9999) {
            this.isNextButtonDisabled = !this.checked; // Enable the Next button only if the radio button is checked
        } else {
            this.isNextButtonDisabled = true; // Disable the Next button if the input value is outside of the range
        }
         // Call a function to enable/disable the Next button
    }
    handleNextButtonState() {
        // Enable the Next button only when the radio button is checked and the number of seats is greater than 0
        this.isNextButtonDisabled = !(this.checked && this.noOfSeats > 0 && !this.inputDisable);
    }*/
    /**end */

    /********************************************
        Function      : wire method to get list of products
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
/*
        @wire(getEvalutionProductList,{licenseType:'$licenseType'})
        getEvalutionProductList({ error, data }) {
            if (data) {
                console.log('errors>>>'+JSON.stringify(data))
                this.result = data.map(product => ({
                    ...product,
                    checked: false // Initialize checked status to false
                }));
                
                if(this.result.length>0){
                    
                this.dataAvailable=true;
                this.isload=false;
                }
                else{
                    this.isload= true;
                    this.dataAvailable=false;
                }
                 ///show error in the UI if no records
                this.error = undefined;
            } else if (error) {
                console.log('errors>>>'+JSON.stringify(error));
                this.error = error;
                this.result = undefined;
                this.dataAvailable=false;
                this.isload=true;
    
            }
        }*/
        /********************************************
        Function      : handle the selected row data
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
   /* getSelectedRow(event){
        this.selectedRows = event.detail.selectedRows; 
        console.log('selectedRows>>'+JSON.stringify(this.selectedRows));
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedProd=[];
            this.termsCondition=this.selectedRows[i].TandC;
            console.log('termsCondition>>>'+this.termsCondition);
            this.selectedProd.push({
                licExp:this.selectedRows[i].licExp,
                licType:this.selectedRows[i].licType,
                maintenenceExp:this.selectedRows[i].maintenenceExp,
                noSeats:this.selectedRows[i].noSeats,
               // displayEditIcon:selectedRows[i].displayEditIcon,
                prodExtId:this.selectedRows[i].prodExtId,
                prodId:this.selectedRows[i].prodId,
                prodName:this.selectedRows[i].prodName,
                maxRehost:this.selectedRows[i].maxRehost,
                prodExtTempLicAllowed:this.selectedRows[i].prodExtTempLicAllowed,
                optnAvailable:this.selectedRows[i].optnAvailable,
                optin:false,
                isEmployee:false
                
            });
        }
        console.log('selectedProd value after row select>>'+JSON.stringify(this.selectedProd)); 
        this.termandcondition=true;
    }
}*/