import { LightningElement,wire,api,track } from 'lwc';
import getEvalutionProductList from '@salesforce/apex/Sales_CreateLicenseController.getProductList';
import productoption from '@salesforce/apex/Sales_FreeLicenseProvider.getProductOptions';
import { NavigationMixin } from 'lightning/navigation';
import Sales_Path1TextLabel from '@salesforce/label/c.Sales_Path1TextLabel';
import Sales_Path2TextLabel from '@salesforce/label/c.Sales_Path2TextLabel';
import Sales_Numberofseatstest2 from '@salesforce/label/c.Sales_Numberofseatstest2';
import Sales_NumberOfSeatsMax from '@salesforce/label/c.Sales_NumberOfSeatsMax';
import Sales_WebDescriptionProductPage from '@salesforce/label/c.Sales_WebDescriptionProductPage';
import Sales_MaintainanceExpirationProductPage from '@salesforce/label/c.Sales_MaintainanceExpirationProductPage';
import Sales_LicenseExpirationProductPage from '@salesforce/label/c.Sales_LicenseExpirationProductPage';
import Sales_SelectOptionalProductsProductPage from '@salesforce/label/c.Sales_SelectOptionalProductsProductPage';
import Sales_NextProductPage from '@salesforce/label/c.Sales_NextProductPage';
import Sales_SelectAllOptions from '@salesforce/label/c.Sales_SelectAllOptions';
import Sales_MaintenanceExpirationProductPagetooltip from '@salesforce/label/c.Sales_MaintenanceExpirationProductPagetooltip';
import Sales_LicenseExpirationProductPageTooltip from '@salesforce/label/c.Sales_LicenseExpirationProductPageTooltip';

export default class sales_FreeLicenseProductPage extends NavigationMixin(LightningElement) {

   // @api flexipageRegionInfo  = 'CLASSIC'; // default to classic. If its lightning, framework will set the value - Soumy added

    label = {
        Sales_Path1TextLabel,
        Sales_Path2TextLabel,
        Sales_Numberofseatstest2,
        Sales_NumberOfSeatsMax,
        Sales_WebDescriptionProductPage,
        Sales_MaintainanceExpirationProductPage,
        Sales_LicenseExpirationProductPage,
        Sales_SelectOptionalProductsProductPage,
        Sales_NextProductPage,
        Sales_SelectAllOptions,
        Sales_MaintenanceExpirationProductPagetooltip,
        Sales_LicenseExpirationProductPageTooltip
    };
    @track buttonClicked=false;
    @track result;
    error;
    isload =false;
    @track productOptionsResult;
    dataAvailable;
    @api checkradio=false;
    @api termandcondition=false;
    @api productId;
    @api productOption;
    @api seats;
    //columnsList=columns;
    @track productOptionsData = {};
    selectedRows =[];
    changedNoSeats2=[];
    draftValues = [];
    selectedProd = [];
    //T&C logic
    termsAccepted=false;
    @api termsCondition;
    licenseType='Evalution';
    @track selectedProductOptions = [];
    productWrapper =[];
    @api isChecked = false;
    selectedCheckboxes=[];
    @api uniqueId = 'radio-' + Math.random().toString(36).substring(7);
    @track showTable = false;
    @track isNextButtonDisabled = 'false';
    @track noOfSeats;
    @track showseats= false;
    @track defaultValue=1;
    @track inputDisable = true;
    @track pid;
    @track selectedproduct;
    productSet = false;
    toolLicenseType;
    @api isOptionSelect;
    selectAllCheck;
    handleChange(event) {
        const productId = event.currentTarget.getAttribute('data-product-id');
        this.showTable=false;
        this.defaultValue=1;
        this.inputDisable=true;
        this.pid=productId;
        this.productId=productId;
        this.loadProductOptions(this.productId);
    }

    connectedCallback(){
        console.log('In connected callback');
        console.log('Seats ' + this.seats);
        console.log('isOptionSelect in product ' + this.isOptionSelect);
        if(this.seats != undefined){
            console.log('hiii');
            this.productSet = true;
            this.defaultValue = this.seats;
          //  this.noOfSeats = this.defaultValue;
          //this.nextSectionElement = this.template.querySelector('[data-next-section]');
        }

    }
    
    loadProductOptions(productId) {
        productoption({ prodId: productId })
        .then(result => {
            /*
            console.log(JSON.stringify(result));
            for(let key in result){
                console.log(JSON.stringify(key));
                console.log(JSON.stringify(result[key]));
                
                //Changes by Bishal Singh
                this.selectedProductOptions = result[key].map(optionProduct => ({
                    ...optionProduct,
                    checked: false // Initialize checked status to false
                }));*/
                /******* Vinita Changes for web description   *******/
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
            this.toolLicenseType = selectedProduct.licType;
            console.log(selectedProduct.licType)
            if (selectedProduct.licType != 'FIXED') {
                console.log('float');
                
                this.inputDisable = false; // Disable the input field for "# of Seats"
            }
            else if (selectedProduct.licType === 'FIXED') {
                console.log('fix Log');
                this.defaultValue = 1;
          
            }
            console.log('this.selectedproduct ' +this.selectedproduct);
            if(this.productSet == true){
             /*   if(this.selectedproduct != this.productId){
                    
                    console.log('Inside our logic');
                
                    this.isOptionSelect = false;
        
                    this.selectedProductOptions.forEach(element =>{
                            element.checked = false;
                    })
                    this.selectedProductOptions = [];
                    this.selectedCheckboxes = [];
                }*/
               
                if(this.productOption != undefined){
                    if(this.selectedproduct != this.productId){
                    
                        console.log('Inside our logic');
                    
                        this.isOptionSelect = false;
            
                        this.selectedProductOptions.forEach(element =>{
                                element.checked = false;
                        })
                        /*
                        this.selectedProductOptions = [];
                        this.selectedCheckboxes = [];
                        this.productOption = [];*/
                    }
                    console.log('isOptionSelect value ' +this.productOption.length);
                    console.log('In side condition ' + this.selectedCheckboxes.length);
                    console.log('productOptionnnn outside ' + this.selectedProductOptions.length);
                    //We need to make this.productOption as an array, to get multiple selectedlist.
                    //Run this.productOPtion in Loop to check it with selectedProductOptions list element.
                    // LOGIC:: if(this.productOption.includes(element.SBQQ__OptionalSKU__c){
                    //    element.checked = true;
                    //})
                    console.log('productOptionnnn ' + this.productOption);
                    if(this.isOptionSelect == true){
                        this.selectedProductOptions = this.selectedProductOptions.map(option => ({
                            ...option,
                            checked: true
                        }));
        
                        this.selectedProductOptions.forEach(element =>{
                            if(!this.selectedCheckboxes.includes(element.Id)){
                                this.selectedCheckboxes.push(element.Id);
                            }
                        })
                        
                    }
                    else{
                    this.selectedProductOptions.forEach(element =>{
                        console.log('element:: ' + JSON.stringify(element));
                        this.productOption.forEach(elm =>{
                            console.log('inside foreach ' +elm);
                            if(element.Id == elm){
                                console.log('Last foreach');
                                //element.checked = true; soumy
                                element.checked = false;
                                if(!this.selectedCheckboxes.includes(elm)){
                                    this.selectedCheckboxes.push(elm);
                                }
                            }
                        })
                       
                    })
                console.log('Selected Checkboxes:', this.selectedCheckboxes);
                    }
            }  
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

handleRowClick(event) {
    const productId = event.currentTarget.dataset.productId;
    this.result = this.result.map(product => ({

        ...product,

        checked: product.prodId === productId  // Set checked status for the clicked product

    }));
    this.handleClick(productId);
  
/*
    // Find the associated radio button based on the data attribute
    const radioButton = this.template.querySelector('input[data-radio-id="${productId}"]');
    //const radioButton = this.result('input[data-product-id="${productId}"]');
    console.log(radioButton);
    console.log(productId);
    if (radioButton) {
        // Set the radio button to checked
        radioButton.checked = true;

        // Handle the click event for the radio button (if needed)
        this.handleClick();
    }
    */
}
    handleClick(productId) {
       if(this.selectAllCheck){
        this.isOptionSelect = false;
       }
       // const pid = event.target.value;
       const pid=productId;
        this.selectedproduct = pid;
        for (let i = 0; i < this.productWrapper.length; i++){
            if(pid == this.productWrapper[i].prodId){
                this.termsCondition=this.productWrapper[i].TandC;
            }
        }
        console.log('termsCondition ' +this.termsCondition);
        console.log('selected product ' +this.selectedproduct);
        this.result = this.result.map(product => ({
            ...product,
            checked: product.prodId === pid // Set checked status for the clicked product
        }));

        //const productId = event.target.value;
        this.loadProductOptions(pid);
    }

    selectAllOptions(event) {
        const isChecked = event.target.checked;
        this.selectAllCheck = isChecked;
        console.log('selectAllCheck ' +this.selectAllCheck);
        this.selectedProductOptions = this.selectedProductOptions.map(option => ({
            ...option,
            checked: isChecked
        }));
        if(isChecked){
            this.isOptionSelect = true;
            this.selectedProductOptions.forEach(element =>{
                if(!this.selectedCheckboxes.includes(element.Id)){
                    this.selectedCheckboxes.push(element.Id);
                }
            })
        }
        else if(!isChecked){
            this.isOptionSelect = false;
            this.selectedCheckboxes=[];
        }
       
        console.log('selectedCheckboxesss in All select' + this.selectedCheckboxes);
          
    }

    handleCheckboxChange(event) {
        const checkboxId = event.target.dataset.id; 
        const checkboxOptionId = event.target.dataset.optionid;
        const isChecked = event.target.checked;
        console.log('checkboxOptionId ' + checkboxOptionId);
        console.log('selectedCheckboxesss ' + this.selectedCheckboxes);
        if (isChecked) {
            if(!this.selectedCheckboxes.includes(checkboxId)){
             console.log('Inside handleCheckboxChange');
                this.selectedCheckboxes.push(checkboxId);
                if (this.selectedCheckboxes.length === this.selectedProductOptions.length) {
                    this.isOptionSelect = true;
                    this.selectedProductOptions.forEach(element =>{
                        element.checked = true;
                    })
                }
            }
        }
        else { console.log('in unchecked');
            const index = this.selectedCheckboxes.indexOf(checkboxId); 
        if (index > -1){ 
            if(this.isOptionSelect==true){
                    this.isOptionSelect = false;
            }
                this.selectedCheckboxes.splice(index, 1);
          //      this.isOptionSelect = true;
                this.selectedProductOptions.forEach(element =>{
                    
                if(element.Id ===checkboxId && !isChecked){
                  element.checked = false;
                  
                }})
            } 
        } 
        console.log('Selected Checkboxes:' + this.selectedCheckboxes.length);
        console.log('HandleCheckbox:: CheckForCommnets ' +this.selectedProductOptions.length);
        let allCheckbox=false;
        this.selectedProductOptions.forEach(element =>{
                    
            if(element.checked == true){
              
                allCheckbox=true;
            }
            else{
                allCheckbox=false;

            }
            
        })
        console.log(allCheckbox);
        if(allCheckbox==true){
            this.isOptionSelect=true;
        }
            
        
     


       /* if (this.selectedCheckboxes.length === this.selectedProductOptions.length) {
            this.isOptionSelect = true;
            this.selectedProductOptions.forEach(element =>{
                element.checked = true;
            })
        }else {
            console.log('in else condition');
            this.isOptionSelect = false;
            this.selectedProductOptions.forEach(element =>{
                if(element.Id ===checkboxId && !isChecked){
                    element.checked = false;
                }
            })
        }*/
    }

    handleNextButtonClick() {
    console.log('Default Value ' +this.defaultValue);    
   // console.log('Seatsss ' +this.noOfSeats);
    var selectedEvent = new CustomEvent('productpage', { detail:{"comp2" : true, "comp1" : false, "productId" : this.selectedproduct, "Seats" :  this.defaultValue, "termsCondition" : this.termsCondition, "productOptions" : this.selectedCheckboxes,"toolLicenseType" : this.toolLicenseType, "isOptionSelect" : this.isOptionSelect}});

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);

    //this.nextSectionElement.scrollIntoView({ behavior: 'smooth' });
   }
           
    handleSeatsInputChange(event) {
        this.defaultValue = parseInt(event.target.value);
      //  this.defaultValue =  this.noOfSeats;
        console.log('Seat change to ' +  this.defaultValue);
         // Parse the input value as an integer
        if (this.defaultValue >= 1 && this.defaultValue <= 9999) {

            this.isNextButtonDisabled = false; // Enable the Next button only if the radio button is checked
            this.template.querySelector(".input-field1").style.border="none";
            
        } else {
            this.isNextButtonDisabled = true; // Disable the Next button if the input value is outside of the range
          this.template.querySelector(".input-field1").style.border="3px solid red";
         // this.template.querySelector(".input-field1").style.border="red";

         
            
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
                this.productWrapper = data;
                console.log('productWrapper ' + this.productWrapper);
                console.log('errors>>>'+JSON.stringify(data))
                this.result = data.map(product => ({
                    ...product,
                    checked: false // Initialize checked status to false
                }));
                
                if(this.result.length>0){
                    
                this.dataAvailable=true;
                this.isload=false;
                        if(this.productSet == true){
                            const pid = this.productId;
                            this.selectedproduct = pid;
                            console.log('selected product ' +this.selectedproduct);
                            this.result = this.result.map(product => ({
                                ...product,
                                checked: product.prodId === pid // Set checked status for the clicked product
                            }));
                        
                        
                        //const productId = event.target.value;
                        this.loadProductOptions(pid);
                        }

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
    
    /*
    connectedCallback() {
        const resizableColumns = this.template.querySelectorAll('.resizable-column');

        let startX;
        let startWidth;

        resizableColumns.forEach(column => {
            const resizer = document.createElement('div');
            resizer.className = 'resizer';
            column.appendChild(resizer);

            resizer.addEventListener('mousedown', function (e) {
                startX = e.pageX;
                startWidth = parseInt(
                    document.defaultView.getComputedStyle(column).width,
                    10
                );
                document.addEventListener('mousemove', onMouseMove);
                document.addEventListener('mouseup', onMouseUp);
            });

            function onMouseMove(e) {
                const newWidth = startWidth + (e.pageX - startX);
                column.style.width = newWidth + 'px';
            }

            function onMouseUp() {
                document.removeEventListener('mousemove', onMouseMove);
                document.removeEventListener('mouseup', onMouseUp);
            }
        });
    }*/

    // ...
}