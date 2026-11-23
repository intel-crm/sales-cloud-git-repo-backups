import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import getProductVariants from '@salesforce/apex/core_IPS_caseCreate_LEX.getProductVariants'
import getCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseCategories'
import getSubCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseSubCategories'
import getProdEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ";
import getSubCatEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCatProductEDQ";
import projectNote from '@salesforce/label/c.Core_IPS_Project_Note_Portal';
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import getLoggedInContacts from "@salesforce/apex/core_IPS_caseCreate_LEX.getContactDetails";
import getCustomSettingLogs from '@salesforce/apex/Core_IPS_CaseCreateMode_CTRL.getCustomSettingLogs'; //added by Anil as part of MOde SSLC
import getContactRecords from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getContactRecords";
import { loadStyle } from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/portalDataTableColors'

const contactColumns = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: 'true' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text', sortable: 'true' },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: 'true' },
];

export default class Core_IPS_CaseCreateForm1_LWC extends NavigationMixin(LightningElement) {
    communityCheck = true;
    fieldName;
    showVariants = false;
    showCategories = false;
    showSubCategories = false;
    showEDQsection = false;
    showProdEdqs = false;
    showSubCatEdqs = false;
    showEdqSection = false;
    projectRecords;
    productOptions = [];
    tempProductOptions = [];
    productVariantOptions = [];
    caseCategoryOptions = [];
    caseSubCategoryOptions = [];
    selectedProjectName = '';
    selectedProductName = '';
    selectedVariantName = '';
    prodEdqRecs;
    subCatRecEdqs;
    isProjSelected = false;
    projSelectByProd = false;
    isProdSelected = false;
    value = 'inProgress';
    label = { projectNote };

    //Anil start
    @api project;
    //@api projectId = "test";
    @api productvariant;
    @api product;
    @api subject;
    @api CaseCategory;
    @api Language;
    @api CaseSubCategory;
    @api casedata; // data comes from Parent cmp
    @api projectdata; // data comes from Parent cmp
    @api storecaseinfofromParent;
    @api CaseSubCategoryId;
    @api CaseSubCategoryName;
    @api CaseCategoryId;
    @api CaseCategoryName;
    //for product lookup
    @track lookupSearchFieldNameProduct = "Name";
    @track error;
    @track products = [];
    @api contactData;
    @api contactCountry;
    @api accountId;
    @api contactId;
    //Anil End
    //Anil Mode Start
    @api mode;
    @api createmode = false;
    @api sslcmode = false;
    value = this.contactCountry;
    get countryOptions() {
        return [
            { label: "Aruba", value: "ABW" },
            { label: "Afghanistan", value: "AFG" },
            { label: "Angola", value: "AGO" },
            { label: "Anguilla", value: "AIA" },
            { label: "Åland Islands", value: "ALA" },
            { label: "Albania", value: "ALB" },
            { label: "Andorra", value: "AND" },
            { label: "United Arab Emirates", value: "ARE" },
            { label: "Argentina", value: "ARG" },
            { label: "Armenia", value: "ARM" },
            { label: "American Samoa", value: "ASM" },
            { label: "Antarctica", value: "ATA" },
            { label: "French Southern Territories", value: "ATF" },
            { label: "Antigua and Barbuda", value: "ATG" },
            { label: "Australia", value: "AUS" },
            { label: "Austria", value: "AUT" },
            { label: "Azerbaijan", value: "AZE" },
            { label: "Burundi", value: "BDI" },
            { label: "Belgium", value: "BEL" },
            { label: "Benin", value: "BEN" },
            { label: "Bonaire, Sint Eustatius and Saba", value: "BES" },
            { label: "Burkina Faso", value: "BFA" },
            { label: "Bangladesh", value: "BGD" },
            { label: "Bulgaria", value: "BGR" },
            { label: "Bahrain", value: "BHR" },
            { label: "Bahamas", value: "BHS" },
            { label: "Bosnia and Herzegovina", value: "BIH" },
            { label: "Saint Barthélemy", value: "BLM" },
            { label: "Belarus", value: "BLR" },
            { label: "Belize", value: "BLZ" },
            { label: "Bermuda", value: "BMU" },
            { label: "Bolivia (Plurinational State of)", value: "BOL" },
            { label: "Brazil", value: "BRA" },
            { label: "Barbados", value: "BRB" },
            { label: "Brunei Darussalam", value: "BRN" },
            { label: "Bhutan", value: "BTN" },
            { label: "Bouvet Island", value: "BVT" },
            { label: "Botswana", value: "BWA" },
            { label: "Central African Republic", value: "CAF" },
            { label: "Canada", value: "CAN" },
            { label: "Cocos (Keeling) Islands", value: "CCK" },
            { label: "Switzerland", value: "CHE" },
            { label: "Chile", value: "CHL" },
            { label: "China", value: "CHN" },
            { label: "Côte d'Ivoire", value: "CIV" },
            { label: "Cameroon", value: "CMR" },
            { label: "Congo, Democratic Republic of the", value: "COD" },
            { label: "Congo", value: "COG" },
            { label: "Cook Islands", value: "COK" },
            { label: "Colombia", value: "COL" },
            { label: "Comoros", value: "COM" },
            { label: "Cabo Verde", value: "CPV" },
            { label: "Costa Rica", value: "CRI" },
            { label: "Cuba", value: "CUB" },
            { label: "Curaçao", value: "CUW" },
            { label: "Christmas Island", value: "CXR" },
            { label: "Cayman Islands", value: "CYM" },
            { label: "Cyprus", value: "CYP" },
            { label: "Czechia", value: "CZE" },
            { label: "Germany", value: "DEU" },
            { label: "Djibouti", value: "DJI" },
            { label: "Dominica", value: "DMA" },
            { label: "Denmark", value: "DNK" },
            { label: "Dominican Republic", value: "DOM" },
            { label: "Algeria", value: "DZA" },
            { label: "Ecuador", value: "ECU" },
            { label: "Egypt", value: "EGY" },
            { label: "Eritrea", value: "ERI" },
            { label: "Western Sahara", value: "ESH" },
            { label: "Spain", value: "ESP" },
            { label: "Estonia", value: "EST" },
            { label: "Ethiopia", value: "ETH" },
            { label: "Finland", value: "FIN" },
            { label: "Fiji", value: "FJI" },
            { label: "Falkland Islands (Malvinas)", value: "FLK" },
            { label: "France", value: "FRA" },
            { label: "Faroe Islands", value: "FRO" },
            { label: "Micronesia (Federated States of)", value: "FSM" },
            { label: "Gabon", value: "GAB" },
            { label: "United Kingdom of Great Britain and Northern Ireland", value: "GBR" },
            { label: "Georgia", value: "GEO" },
            { label: "Guernsey", value: "GGY" },
            { label: "Ghana", value: "GHA" },
            { label: "Gibraltar", value: "GIB" },
            { label: "Guinea", value: "GIN" },
            { label: "Guadeloupe", value: "GLP" },
            { label: "Gambia", value: "GMB" },
            { label: "Guinea-Bissau", value: "GNB" },
            { label: "Equatorial Guinea", value: "GNQ" },
            { label: "Greece", value: "GRC" },
            { label: "Grenada", value: "GRD" },
            { label: "Greenland", value: "GRL" },
            { label: "Guatemala", value: "GTM" },
            { label: "French Guiana", value: "GUF" },
            { label: "Guam", value: "GUM" },
            { label: "Guyana", value: "GUY" },
            { label: "Hong Kong", value: "HKG" },
            { label: "Heard Island and McDonald Islands", value: "HMD" },
            { label: "Honduras", value: "HND" },
            { label: "Croatia", value: "HRV" },
            { label: "Haiti", value: "HTI" },
            { label: "Hungary", value: "HUN" },
            { label: "Indonesia", value: "IDN" },
            { label: "Isle of Man", value: "IMN" },
            { label: "India", value: "IND" },
            { label: "British Indian Ocean Territory", value: "IOT" },
            { label: "Ireland", value: "IRL" },
            { label: "Iran (Islamic Republic of)", value: "IRN" },
            { label: "Iraq", value: "IRQ" },
            { label: "Iceland", value: "ISL" },
            { label: "Israel", value: "ISR" },
            { label: "Italy", value: "ITA" },
            { label: "Jamaica", value: "JAM" },
            { label: "Jersey", value: "JEY" },
            { label: "Jordan", value: "JOR" },
            { label: "Japan", value: "JPN" },
            { label: "Kazakhstan", value: "KAZ" },
            { label: "Kenya", value: "KEN" },
            { label: "Kyrgyzstan", value: "KGZ" },
            { label: "Cambodia", value: "KHM" },
            { label: "Kiribati", value: "KIR" },
            { label: "Saint Kitts and Nevis", value: "KNA" },
            { label: "Korea, Republic of", value: "KOR" },
            { label: "Kuwait", value: "KWT" },
            { label: "Lao People's Democratic Republic", value: "LAO" },
            { label: "Lebanon", value: "LBN" },
            { label: "Liberia", value: "LBR" },
            { label: "Libya", value: "LBY" },
            { label: "Saint Lucia", value: "LCA" },
            { label: "Liechtenstein", value: "LIE" },
            { label: "Sri Lanka", value: "LKA" },
            { label: "Lesotho", value: "LSO" },
            { label: "Lithuania", value: "LTU" },
            { label: "Luxembourg", value: "LUX" },
            { label: "Latvia", value: "LVA" },
            { label: "Macao", value: "MAC" },
            { label: "Saint Martin (French part)", value: "MAF" },
            { label: "Morocco", value: "MAR" },
            { label: "Monaco", value: "MCO" },
            { label: "Moldova, Republic of", value: "MDA" },
            { label: "Madagascar", value: "MDG" },
            { label: "Maldives", value: "MDV" },
            { label: "Mexico", value: "MEX" },
            { label: "Marshall Islands", value: "MHL" },
            { label: "North Macedonia", value: "MKD" },
            { label: "Mali", value: "MLI" },
            { label: "Malta", value: "MLT" },
            { label: "Myanmar", value: "MMR" },
            { label: "Montenegro", value: "MNE" },
            { label: "Mongolia", value: "MNG" },
            { label: "Northern Mariana Islands", value: "MNP" },
            { label: "Mozambique", value: "MOZ" },
            { label: "Mauritania", value: "MRT" },
            { label: "Montserrat", value: "MSR" },
            { label: "Martinique", value: "MTQ" },
            { label: "Mauritius", value: "MUS" },
            { label: "Malawi", value: "MWI" },
            { label: "Malaysia", value: "MYS" },
            { label: "Mayotte", value: "MYT" },
            { label: "Namibia", value: "NAM" },
            { label: "New Caledonia", value: "NCL" },
            { label: "Niger", value: "NER" },
            { label: "Norfolk Island", value: "NFK" },
            { label: "Nigeria", value: "NGA" },
            { label: "Nicaragua", value: "NIC" },
            { label: "Niue", value: "NIU" },
            { label: "Netherlands", value: "NLD" },
            { label: "Norway", value: "NOR" },
            { label: "Nepal", value: "NPL" },
            { label: "Nauru", value: "NRU" },
            { label: "New Zealand", value: "NZL" },
            { label: "Oman", value: "OMN" },
            { label: "Pakistan", value: "PAK" },
            { label: "Panama", value: "PAN" },
            { label: "Pitcairn", value: "PCN" },
            { label: "Peru", value: "PER" },
            { label: "Philippines", value: "PHL" },
            { label: "Palau", value: "PLW" },
            { label: "Papua New Guinea", value: "PNG" },
            { label: "Poland", value: "POL" },
            { label: "Puerto Rico", value: "PRI" },
            { label: "Korea (Democratic People's Republic of)", value: "PRK" },
            { label: "Portugal", value: "PRT" },
            { label: "Paraguay", value: "PRY" },
            { label: "Palestine, State of", value: "PSE" },
            { label: "French Polynesia", value: "PYF" },
            { label: "Qatar", value: "QAT" },
            { label: "Réunion", value: "REU" },
            { label: "Romania", value: "ROU" },
            { label: "Russian Federation", value: "RUS" },
            { label: "Rwanda", value: "RWA" },
            { label: "Saudi Arabia", value: "SAU" },
            { label: "Sudan", value: "SDN" },
            { label: "Senegal", value: "SEN" },
            { label: "Singapore", value: "SGP" },
            { label: "South Georgia and the South Sandwich Islands", value: "SGS" },
            { label: "Saint Helena, Ascension and Tristan da Cunha", value: "SHN" },
            { label: "Svalbard and Jan Mayen", value: "SJM" },
            { label: "Solomon Islands", value: "SLB" },
            { label: "Sierra Leone", value: "SLE" },
            { label: "El Salvador", value: "SLV" },
            { label: "San Marino", value: "SMR" },
            { label: "Somalia", value: "SOM" },
            { label: "Saint Pierre and Miquelon", value: "SPM" },
            { label: "Serbia", value: "SRB" },
            { label: "South Sudan", value: "SSD" },
            { label: "Sao Tome and Principe", value: "STP" },
            { label: "Suriname", value: "SUR" },
            { label: "Slovakia", value: "SVK" },
            { label: "Slovenia", value: "SVN" },
            { label: "Sweden", value: "SWE" },
            { label: "Eswatini", value: "SWZ" },
            { label: "Sint Maarten (Dutch part)", value: "SXM" },
            { label: "Seychelles", value: "SYC" },
            { label: "Syrian Arab Republic", value: "SYR" },
            { label: "Turks and Caicos Islands", value: "TCA" },
            { label: "Chad", value: "TCD" },
            { label: "Togo", value: "TGO" },
            { label: "Thailand", value: "THA" },
            { label: "Tajikistan", value: "TJK" },
            { label: "Tokelau", value: "TKL" },
            { label: "Turkmenistan", value: "TKM" },
            { label: "Timor-Leste", value: "TLS" },
            { label: "Tonga", value: "TON" },
            { label: "Trinidad and Tobago", value: "TTO" },
            { label: "Tunisia", value: "TUN" },
            { label: "Turkey", value: "TUR" },
            { label: "Tuvalu", value: "TUV" },
            { label: "Taiwan, Province of China", value: "TWN" },
            { label: "Tanzania, United Republic of", value: "TZA" },
            { label: "Uganda", value: "UGA" },
            { label: "Ukraine", value: "UKR" },
            { label: "United States Minor Outlying Islands", value: "UMI" },
            { label: "Uruguay", value: "URY" },
            { label: "United States of America", value: "USA" },
            { label: "Uzbekistan", value: "UZB" },
            { label: "Holy See", value: "VAT" },
            { label: "Saint Vincent and the Grenadines", value: "VCT" },
            { label: "Venezuela (Bolivarian Republic of)", value: "VEN" },
            { label: "Virgin Islands (British)", value: "VGB" },
            { label: "Virgin Islands (U.S.)", value: "VIR" },
            { label: "Viet Nam", value: "VNM" },
            { label: "Vanuatu", value: "VUT" },
            { label: "Wallis and Futuna", value: "WLF" },
            { label: "Samoa", value: "WSM" },
            { label: "Yemen", value: "YEM" },
            { label: "South Africa", value: "ZAF" },
            { label: "Zambia", value: "ZMB" },
            { label: "Zimbabwe", value: "ZWE" }
        ];
    }
    //Anil Mode End
    connectedCallback() {
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.mode = newURL.get('mode');
        console.log('mode--' + this.mode);

        if (this.mode === 'create') {
            console.log('mode if--' + this.mode);
            this.createmode = true;
            this.sslcmode = false;
            this.projectFieldSet = "name,Core_IPS_Project_ID__c,";
            this.formCaseProjectLookupQuery();
            this.formCaseProductLookupQuery();
            //this.getProjectData();
            //this.getProductData();
        } else if (this.mode === 'sslc') {
            console.log('mode if else--' + this.mode);
            this.createmode = false;
            this.sslcmode = true;
            this.handleLoad();
        }
        console.log('projectdata body-----', JSON.stringify(this.projectdata));
        //contact data start
        getLoggedInContacts({})
            .then((result) => {
                this.contactData = result;
                console.log("Contact data--->", this.contactData);
                console.log("Contact country-->", this.contactData[0].Core_Country_Region__c);
                this.contactCountry = this.contactData[0].Core_Country_Region__c;
                this.contactId = this.contactData[0].Id;
                this.accountId = this.contactData[0].AccountId;
            })
            .catch((error) => {
                console.log(error);
                this.error = error;
            });
        //contact data end
        this.getContacts();
    }
    isCssLoaded = false;
    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
            console.log("Loaded Successfully")
        }).catch(error => {
            console.error("Error in loading the colors")
        })
    }
    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    get productVariants() {
        return this.productVariantOptions;
    }

    get categories() {
        return this.caseCategoryOptions;
    }

    get subCategories() {
        return this.caseSubCategoryOptions;
    }
    /*
    getProjectData Method
    1.Gets called from connectedcallback with Null paramenters when serach happens directly from project Input field
    2.Gets called from handleChangeProd method with ProdId as parameters when user selects first products and then next selects Projects
    */
    getProjectData(prodId) {
        let tempVar;
        let searchQueryStr;
        if (prodId == null || prodId == undefined || prodId == '') {
            console.log('Anil Inside getProjectData Method  connected callback fired');
            this.fieldName = 'Name';
            console.log('ANil Inside prodId is Null means serach happened based on Project');
            searchQueryStr = 'select id, name,Core_IPS_Project_ID__c from core_ips_project__c where core_status__c=\'Active\'  ORDER BY Core_IPS_Project_ID__c  DESC limit 5';
        } else {
            console.log('Anil Inside getProjectData Method handleChangeProd fired');
            console.log('ANil Inside prodId is Not Null means when user selects first products and then next selects Projects');
            this.projSelectByProd = true;
            this.fieldName = 'Core_IPS_Project_Name__c';
            tempVar = prodId;
            searchQueryStr = 'select Id, Name, Core_IPS_Project_Name__c from asset where Id =\'' + tempVar + '\' limit 5';
        }
        getQueryResult({
            queryString: searchQueryStr
        })
            .then(data => {
                if (data) {
                    this.projectRecords = data;
                    console.log('Anil Project Data---' + JSON.stringify(this.projectRecords));
                } else {
                    console.log('some error in project method' + JSON.stringify(error));
                }
            })
            .catch(error => {
                console.log('error===>' + JSON.stringify(error));
            })
    }

    handleProjChange(event) {
        console.log('Anil handleProjChange event.detail ===>' + JSON.stringify(event.detail));
        let selectProj = event.detail.record;
        console.log('Anil handleProjChange  name ===>' + JSON.stringify(selectProj));
        if (selectProj == null || selectProj == undefined || selectProj == '') {
            this.selectedProjectName = '';
            //this.refreshSelectedProd();
            this.getProductData();
            this.refreshSelectedProd1();
        } else {
            this.isProjSelected = true;
            if (this.projSelectByProd) {
                this.selectedProjectName = selectProj.Core_IPS_Project_Name__c;
            } else {
                this.selectedProjectName = selectProj.Name;
            }
            //console.log('string value===>'+JSON.stringify(event.detail));
            if (!this.isProdSelected) {
                this.getProductData(event.detail.record.Id);
            }
        }
        //Anil
        this.project = event.detail.recordId;
        this.sendDataToParent(event);
    }
    /*
        getProjectData Method
        1.Gets called from connectedcallback with Null paramenters when serach happens directly from product Input field
        2.Gets called from handleProjChange method with ProjId as parameters when user selects first Projects and then next selects Products
        */
    getProductData(projId) {
        let tempVar;
        let searchQueryStr;
        if (projId == null || projId == undefined) {
            console.log('Anil Inside getProductData Method  connected callback fired');
            console.log('ANil Inside projId is Null means serach happened based on Product');
            searchQueryStr = 'select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c from asset where core_supported_product__r.Core_IPS_Is_Show_Variant__c = true and Core_IPS_Project__c != null limit 100';
        } else {
            console.log('Anil Inside getProductData Method  handleProjChange fired');
            console.log('ANil Inside projId is Not Null means when user selects first Projects and then next selects products');
            tempVar = projId;
            searchQueryStr = 'select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c from asset where core_supported_product__r.Core_IPS_Is_Show_Variant__c = true and Core_IPS_Project__c =\'' + tempVar + '\' limit 100';
        }
        getQueryResult({
            queryString: searchQueryStr
        })
            .then(data => {
                if (data) {
                    let options = [];
                    data.forEach(eachRecord => {
                        options.push({ value: eachRecord.Id, label: eachRecord.Name, supProdId: eachRecord.Core_Supported_Product__c });
                    });
                    this.productOptions = options;
                    this.tempProductOptions = options;
                    console.log('Anil productOptions---' + JSON.stringify(this.productOptions));
                    console.log('Anil tempProductOptions---' + JSON.stringify(this.tempProductOptions));
                }
            })
            .catch(error => {
                console.log('prod error===>' + JSON.stringify(error));
            })
    }

    /*  handleChangeProd(event) {
         let productId = event.detail.value;
         console.log('Anil handleChangeProd event.detail ===>' + JSON.stringify(event.detail));
         let supportedId;
         console.log('ANil handleChangeProd Productn Id here==>' + productId);
         if (productId == null || productId == undefined || productId == '') {
             this.refreshSelectedProd();
         } else {
             this.isProdSelected = true;
             this.tempProductOptions.forEach(option => {
                 if (option.value == productId) {
                     this.selectedProductName = option.label;
                     supportedId = option.supProdId;
                 }
             });
             if (!this.isProjSelected) {
                 this.getProjectData(productId);
             }
             this.getProdVariants(productId);
             this.getCatergories(supportedId);
             this.getProductEdqs(supportedId);
             //Anil
             this.product = productId;
             console.log('prod change===>' + this.product);
             this.sendDataToParent(event);
         }
     } */
    refreshSelectedProd1() {
        this.caseProjectId = null;
        this.selectedProductName = '';
        this.showProject = false;
        this.showProdVariants = false;
        this.productVariantOptions = [];
        this.showVariants = false;
        this.selectedVariantName = '';
        this.caseCategoryOptions = [];
        this.showCategories = false;
        this.caseSubCategoryOptions = [];
        this.showSubCategories = false;
        this.renderProductCategory = false;
        this.renderProductSubCategory = false;
        this.showEdqSection = false;
        

        //this.getProjectData();
        this.formCaseProjectLookupQuery();
        if (this.projSelectByProd) {
            this.template.querySelector("c-core-ips-custom-lookup").removeSelected();
            this.projSelectByProd = false;
        }
    }

    refreshSelectedProd() {
        this.selectedProductName = '';
        this.productVariantOptions = [];
        this.showVariants = false;
        this.showProdVariants = false;
        this.showProduct = false;
        this.selectedVariantName = '';
        this.caseCategoryOptions = [];
        this.showCategories = false;
        this.caseSubCategoryOptions = [];
        this.showSubCategories = false;
        this.renderProductCategory = false;
        this.renderProductSubCategory = false;
        this.showEdqSection = false;
        this.renderProductVariant = false;
        //this.getProjectData();
        this.formCaseProductLookupQuery();
        if (this.projSelectByProd) {
            this.template.querySelector("c-core-ips-custom-lookup").removeSelected();
            this.projSelectByProd = false;
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    prodSearchChangeHandler(event) {
        let tempVar = event.detail.value;
        console.log('Anil tempVar po ==>' + tempVar);
        let similarOptions = [];
        this.productOptions.forEach(product => {
            let index = product.label.toLowerCase().indexOf(tempVar.toLowerCase());
            if (index !== -1) {
                similarOptions.push({ value: product.value, label: product.label });
            }
        });
        this.tempProductOptions = similarOptions;
        console.log('Anil this.tempProductOptions==>' + JSON.stringify(this.tempProductOptions));

    }

    getProdVariants(prodIdStr) {
        console.log("getProdVariants called--> ", prodIdStr);
        let tempVar;
        /* if(prodIdStr != null) {
            //tempVar = JSON.stringify(prodIdStr);
            tempVar = prodIdStr;
        } else {
            tempVar = undefined;
        } */
        if (prodIdStr != null || prodIdStr != undefined) {
            //console.log("tempVar");
            getProductVariants({
                prodId: prodIdStr
            })
                .then(data => {
                    if (data) {
                        console.log("apex called");
                        this.renderProductVariant = true;
                        console.log('variants data==>' + JSON.stringify(data))
                        let options = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Name, value: eachRecord.Id });
                        });
                        this.productVariantOptions = options;
                    }
                })
                .catch(error => {
                    console.log('error in variants==>' + JSON.stringify(error))
                })
        }
    }

    handleVariantChange(event) {
        let selectedProdVariant = event.detail.value;
        this.productVariantOptions.forEach(option => {
            if (option.value == selectedProdVariant) {
                this.selectedVariantName = option.label;
                this.productvariant = option.value; //Anil
            }
        });
        //Anil
        this.sendDataToParent(event);
    }

    getCatergories(prodId) {
        //console.log('inside get categories and prodid===>'+prodId)
        let tempVar;
        if (prodId != null) {
            tempVar = prodId;
        } else {
            tempVar = undefined;
        }
        if (tempVar != null || tempVar != undefined) {
            getCategoryOptions({
                prodId: tempVar
            })
                .then(data => {
                    if (data) {
                        this.showCategories = true;
                        this.renderProductCategory = true;
                        //console.log('inside categories==>'+JSON.stringify(data));
                        let options = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Core_Issue_Category_Name__r.Name, value: eachRecord.Id });
                        });
                        this.caseCategoryOptions = options;
                        console.log('final categories==>' + JSON.stringify(this.caseCategoryOptions));
                    }
                })
                .catch(error => {
                    console.log('error in categories==>' + JSON.stringify(error));
                })
        }
    }

    /*  handleCategoryChange(event) {
         let categoryId = event.detail.value;
         //console.log('category Id here==>'+categoryId);
         if (categoryId != null || categoryId != undefined) {
             this.getSubcategories(categoryId);
         }
     } */

    getSubcategories(categoryId) {
        //console.log('selected variant is '+this.selectedVariant);
        let tempVar;
        if (categoryId != null) {
            tempVar = categoryId;
        } else {
            tempVar = undefined;
        }
        if (tempVar != null || tempVar != undefined) {
            getSubCategoryOptions({
                categoryId: tempVar
            })
                .then(data => {
                    if (data) {
                        this.showSubCategories = true;
                        console.log('inside sub categories all data==>' + JSON.stringify(data));
                        let options = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Core_Issue_Sub_Category_Name__r.Name, value: eachRecord.Id });
                        });
                        this.caseSubCategoryOptions = options;
                        console.log('final sub categories with name and Id==>' + JSON.stringify(this.caseSubCategoryOptions));
                        //Anil start
                        for (let i = 0; i < options.length; i++) {
                            if (options[i].value != undefined) {
                                console.log('Category value==>' + JSON.stringify(options[i].value));
                                this.CaseCategory = options[i].value;
                            }
                        }
                        //Anil end
                    }
                })
                .catch(error => {
                    console.log('some error occured in getting sub categoeis' + JSON.stringify(error));
                })
        }
    }

    /* handleSubCatChange(event) {
        let subCatId;
        let selectedSubCategory = event.detail.value;
        this.caseSubCategoryOptions.forEach(option => {
            if (option.value == selectedSubCategory) {
                subCatId = option.value;
            }
        });
        //console.log('sub cat selected==>'+subCatId);
        this.getSubCategoryEdqs(subCatId);
    } */

    getProductEdqs(supportedId) {
        let tempVar = supportedId;
        //console.log('inside prod edq method and id is==>'+tempVar);
        getProdEdq({
            supportedProductId: tempVar,
            subCategoryid: null,
            isAgent: null
        })
            .then(data => {
                if (data) {
                    this.prodEdqRecs = data;
                    if (this.prodEdqRecs.length > 0) {
                        this.showEdqSection = true;
                        this.showProdEdqs = true;
                    }
                    console.log('final prodEdqRecs data==>' + JSON.stringify(this.prodEdqRecs));
                }
            })
            .catch(error => {
                console.log('error in fetching product edqs==>' + JSON.stringify(error));
            })
    }
    getSubCategoryEdqs(subcategoryId) {
        let tempVar = subcategoryId;
        getSubCatEdq({
            supportedProductId: null,
            subCategoryid: tempVar,
            isAgent: null
        })
            .then(data => {
                let subCateboryEDQ = new Set();
                let eDQSet = new Set();
                let i;
                for (i = 0; i < data.length; i++) {
                    subCateboryEDQ.add(data[i].id);
                }
                for (i = 0; i < this.prodEdqRecs.length; i++) {
                    eDQSet.add(this.prodEdqRecs[i].id);
                }

                i = 0;
                let categoryEDQ = [];
                data.forEach(edq => {
                    if (eDQSet.has(edq.id)) { } else {
                        categoryEDQ.push(data[i]);
                    }
                    i++;
                });
                this.subCatRecEdqs = categoryEDQ;
                //Anil start
                //console.log('final sub subCateboryEDQ==>'+subCateboryEDQ);
                // console.log('final sub eDQSet==>'+eDQSet);
                console.log('final sub categoryEDQ==>' + JSON.stringify(this.subCatRecEdqs));
                for (let i = 0; i < categoryEDQ.length; i++) {
                    if (categoryEDQ[i].id != undefined) {
                        //console.log('Anil sub Category==>'+JSON.stringify(categoryEDQ[i].id)); 
                        this.CaseSubCategory = categoryEDQ[i].id;
                    }
                }
                //Anil end
                if (this.subCatRecEdqs.length > 0) {
                    this.showEdqSection = true;
                    this.showSubCatEdqs = true;
                }
                const childEvent = new CustomEvent('getcatrecedqs', {
                    detail: {
                        firstParam: this.subCatRecEdqs,
                        secondParam: this.showSubCatEdqs
                    }
                });
                this.dispatchEvent(childEvent);
            })
            .catch(error => {
                console.log('error in sub cat edq ' + error);
            })
    }
    handleNavigateBack() {
        console.log('inside home navigation');
        //sendcasesubject this.oldsubject
        /* this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        }); */
    }
    /*Anil start*/
    handlesubject(event) {
        this.subject = event.target.value;
        this.sendDataToParent(event);
    }
    handlelanguage(event) {
        this.Language = event.target.value;
        this.sendDataToParent(event);
    }
    //custom Event to pass data to the parent Component Core_IPS_caseCreation_Form
    sendDataToParent(event) {
        const sendEvent = new CustomEvent(
            'caseinfodata', {
            detail: {
                project: this.projectid,
                projectName: this.selectedProjectName,
                productvariant: this.productvariant,
                productvariantName: this.selectedVariantName,
                Product: this.product,
                ProductName: this.selectedProductName,
                CategoryId: this.CaseCategoryId,
                CategoryName: this.CaseCategoryName,
                SubCategoryId: this.CaseSubCategoryId,
                SubCategoryName: this.CaseSubCategoryName,
                subject: this.subject,
                language: this.Language,
                prodEdqRecs: this.prodEdqRecs,
                showProdEdqs: this.showProdEdqs,
                showEdqSection: this.showEdqSection,
                contactId: this.contactId,
                accountId: this.accountId
            }
        });
        this.dispatchEvent(sendEvent);
    }
    get sendcaseProject() {
        return this.casedata.projectName;
    }
    get sendcasesubject() {
        return this.casedata.Subject;
    }
    get sendcaselanguage() {
        return this.casedata.Language;
    }
    get sendcaseproducts() {
        return this.casedata.ProductName;
    }
    get sendcaseproductvariant() {
        return this.casedata.productvariantName;
    }
    /*Anil End*/
    /*Anil Start */
    //For Product and Project Lookup
    @track isSelectedProjectPresent = false;
    //for project
    @api showProject = false;
    @track lookupIconNameProject = "standard:account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track isLookupQueryPresentProject = false;
    @track lookupCountQueryStringProject;
    @api projectFieldSet;
    @api projectid;
    @api caseProjectId;
    @api showProdVariants = false;
    //FOR PRODUCT 
    @api showProduct = false;
    @track isLookupQueryPresentProduct = false;
    @api assetFieldSet;
    @track lookupSearchFieldNameProduct = "Name";
    @track lookupQueryStringProduct;
    @track lookupIconNameProduct = "standard:product";
    @track lookupCountQueryStringProduct;
    @api assetid;
    @api caseassetId;
    @track renderProductVariant = false;
    @api recordTypeName = 'IPS_Case_Create';
    @track productVariant = '';
    @api productVariantOptions = [];
    @track renderProductCategory = false;
    // @track renderProductCategory = false;
    //category
    @api caseCategory;
    @api caseCategoryOptions;
    @api productid;
    //Subcategory
    @api renderProductSubCategory;
    @api subcategoryoptions;
    @api error;
    @api caseSubCategory;
    formCaseProjectLookupQuery() {
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING core_ips_project__c ';
        let queryFieldsStr = this.projectFieldSet + ' Id ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Project_ID__c DESC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        this.lookupQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProject = true;
        //console.log('ANil lookupQueryStringProject-- ', this.lookupQueryStringProject);
        //console.log('ANil lookupCountQueryStringProject-- ', this.lookupCountQueryStringProject);
    }
    formCaseProductLookupQuery() {
        console.log('preparing');
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING Asset ';
        this.assetFieldSet = 'Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,Core_Supported_Product__c,';
        let queryFieldsStr = this.assetFieldSet + ' Id, Name ';
        let queryWhereClause1Str = '  WHERE Status!=\'Inactive\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        console.log('preparing 1', this.caseProjectId);
        if (this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') { //Project ID
            queryWhereClause1Str += ' AND core_ips_project__c = \'' + this.caseProjectId + '\' ';
        }
        this.lookupQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProduct = true;
        //console.log('ANil lookupQueryStringProduct-- ', this.lookupQueryStringProduct);
        //console.log('ANil isLookupQueryPresentProduct-- ', this.isLookupQueryPresentProduct);
    }
    handleChangeProject(event) {
        console.log('minhaj event invoked project');
       
        console.log('ANil recordidproject-- ', event.detail.recordId);
        console.log('ANil record project-- ', JSON.stringify(event.detail.record));
        this.projectid = event.detail.recordId;
        this.caseProjectId = event.detail.recordId;
        let selectProj = event.detail.record;
        if (selectProj == null || selectProj == undefined || selectProj == '') {
            this.selectedProjectName = '';
            
            this.refreshSelectedProd1();
        } else {
            this.selectedProjectName = selectProj.Name;
            this.showProject = true;
            console.log('ANil this.selectedProjectName-- ', this.selectedProjectName);
            this.formCaseProductLookupQuery();
        }
        this.sendDataToParent(event);
        this.caseProjectId = '';
    }
    handleChangeProduct(event) {
        console.log('minhaj event invoked product')
        console.log('ANil recordid prod assetId-- ', JSON.stringify(event.detail));
        console.log('ANil record asset-- ', JSON.stringify(event.detail.record));
        this.productid = event.detail.record;
        this.assetid = event.detail.recordId;
        this.caseassetId = event.detail.recordId;
        if (this.productid == null || this.productid == undefined || this.productid == '') {
            this.selectedProductName = '';
            this.caseProjectId = null;
            this.refreshSelectedProd();
        } else {
            this.showProduct = true;
            this.selectedProductName = this.productid.Name;
            this.formCaseProjectLookupQuery();
            for (let key in event.detail.record) {
                //console.log(`${key} workload ---> ${event.detail.record[key]}`);
            }
            /* this.displayProdVariant(this.assetid.Id, this.recordTypeName); */
            this.getProdVariants(this.assetid);
            console.log('ANil Core_Supported_Product-- ', this.productid.Core_Supported_Product__c);
            if (this.productid.Core_Supported_Product__c !== null) {
                this.getCatergories(this.productid.Core_Supported_Product__c);
                this.getProductEdqs(this.productid.Core_Supported_Product__c);
                this.sendDataToParent(event);
            }
            this.product = this.assetid;
            this.sendDataToParent(event);
        }
    }
    //on product variant change
    handleChangeProductVariant(event) {
        //console.log('ANil ProductVariant-- ',  JSON.stringify(event.detail));
        let selectedProdVariant = event.detail.value;
        this.productVariantOptions.forEach(option => {
            if (option.value == selectedProdVariant) {
                this.showProdVariants = true;
                this.selectedVariantName = option.label;
                this.productvariant = option.value;
            }
        });
        this.sendDataToParent(event);
    }
    //on  category change
    handleChangeSubCategory(event) {
        // for type head picklist
        this.caseCategory = event.target.value;
        console.log("category---->>>" + JSON.stringify(event.detail));
        //console.log("category:" + JSON.stringify(this.caseCategory));
        this.caseCategoryOptions.forEach(option => {
            if (option.value == this.caseCategory) {
                this.CaseCategoryId = option.value;
                this.CaseCategoryName = option.label;
                // console.log("category---->>>" + this.CaseCategoryId);
                //console.log("categoryName---->>>" + this.CaseCategoryName);
            }
        });
        if (this.caseCategory !== null) {
            this.showCaseSubCategory(this.caseCategory);
        }
        this.sendDataToParent(event);
    }
    showCaseSubCategory(caseCategory) {
        showsubCategory({
            categorySelected: caseCategory,
        }).then(result => {
            if (result !== undefined || result !== null) {
                console.log("this.subcategoryoptions" + JSON.stringify(result));
                this.subcategoryoptions = result;
                this.error = undefined;
                if (this.subcategoryoptions.length > 0) {
                    this.renderProductSubCategory = true;
                    this.showSubCategories = true;
                }
            }
        })
            .catch(error => {
                this.error = error;
                //  this.showToast('ERROR', error.body.message, 'error');
                // console.log("this.error" + JSON.stringify(this.error));
            });
    }
    handleChangeRenderSubCategoryedq(event) {
        //this.caseSubCategory = event.target.value;
        //  this.showSubCatEDQ = false;
        console.log('sub cat event.target==>' + JSON.stringify(event.detail));
        let subCatId;
        let selectedSubCategory = event.detail.value;
        this.subcategoryoptions.forEach(option => {
            if (option.value == selectedSubCategory) {
                subCatId = option.value;
                this.CaseSubCategoryId = option.value;
                this.CaseSubCategoryName = option.label;
                console.log('CaseSubCategoryId==>' + this.CaseSubCategoryId);
            }
        });
        console.log('sub cat selected==>' + subCatId);
        this.getSubCategoryEdqs(subCatId);
        this.sendDataToParent(event);
    }
    /*Anil End */
    /*Anil Start ## Bring Miliatry section from page3 to page1*/
    @api showboolean1;
    @api showboolean2;
    handleChangeMINDS(event) {
        console.log('handleChangeMINDS----', JSON.stringify(event.detail));
        if (event.target.name == "yeschecked") {
            this.showboolean1 = true;
            this.showboolean2 = false;
        }
        if (event.target.name == "nochecked") {
            this.showboolean1 = false;
            this.showboolean2 = true;
        }
    }
    /*Anil End*/
    caseTypevalue = "Question";
    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }
    severityValue = "Low";
    get caseSeverityoptions() {
        return [
            { label: "Low", value: "Low" },
            { label: "Medium", value: "Medium" },
            { label: "High", value: "High" },
            { label: "Critical", value: "Critical" },
        ];
    }
    @api communityCheck;
    @api subjectvaluesslc;
    @api descriptiondefault;
    @api Assetdefault;
    @api Projectdefault;

    @api CaseTypedefault;
    @api CaseSubcategorydefault;
    @api Supported_Productdefault;

    @api IssueSourcedefault;
    @api Case_Categorydefault;
    @api CaseSubcategoryDetaildefalut;
    @api defaultdatainfo;

    @api Supported_ProductdefaultID;
    handleLoad() {
        getCustomSettingLogs().then(result => {
            this.defaultdatainfo = result;
            //this.getdatafromCus = result[0];
            console.log('result stringfy--' + JSON.stringify(this.defaultdatainfo));
            for (let key in this.defaultdatainfo) {
                console.log(`${key} key---> ${this.defaultdatainfo[key]}`);
                console.log('result -- stringfy--' + JSON.stringify(this.defaultdatainfo[key]));
                for (let key1 in this.defaultdatainfo[key]) {
                    console.log(`${key1} key1---> ${this.defaultdatainfo[key][key1]}`);
                    console.log('result key===' + key);
                    if (key == 0 && key1 == "Core_IPS_Default_Data__c") {
                        this.descriptiondefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 1 && key1 == 'Core_IPS_Default_Data__c') {
                        this.Assetdefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 2 && key1 == 'Core_IPS_Default_Data__c') {
                        this.Projectdefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 3 && key1 == 'Core_IPS_Default_Data__c') {
                        this.CaseTypedefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 4 && key1 == 'Core_IPS_Default_Data__c') {
                        this.CaseSubcategorydefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 5 && key1 == 'Core_IPS_Default_Data__c') {
                        this.Supported_Productdefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 5 && key1 == 'Core_IPS_Default_data_Id__c') {
                        this.Supported_ProductdefaultID = this.defaultdatainfo[key][key1];
                        this.getCatergories(this.Supported_ProductdefaultID);
                        this.getProductEdqs(this.Supported_ProductdefaultID);
                    }
                    if (key == 6 && key1 == 'Core_IPS_Default_Data__c') {
                        this.IssueSourcedefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 7 && key1 == 'Core_IPS_Default_Data__c') {
                        this.Case_Categorydefault = this.defaultdatainfo[key][key1];
                    }
                    if (key == 8 && key1 == 'Core_IPS_Default_Data__c') {
                        this.CaseSubcategoryDetaildefalut = this.defaultdatainfo[key][key1];
                    }
                }
            }
            console.log('descriptiondefault--' + this.descriptiondefault);
            console.log('Assetdefault--' + this.Assetdefault);
            console.log('Projectdefault--' + this.Projectdefault);
            console.log('CaseTypedefault--' + this.CaseTypedefault);
            console.log('CaseSubcategorydefault--' + this.CaseSubcategorydefault);
            console.log('Supported_Productdefault--' + this.Supported_Productdefault);
            console.log('IssueSourcedefault--' + this.IssueSourcedefault);
            console.log('Case_Categorydefault--' + this.Case_Categorydefault);
            console.log('CaseSubcategoryDetaildefalut--' + this.CaseSubcategoryDetaildefalut);
            console.log('Supported_ProductdefaultID--' + this.Supported_ProductdefaultID);
        })
            .catch(error => { this.error = error; });
        const childEvent = new CustomEvent('getmode', {
            detail: {
                firstParam: this.sslcmode,
            }
        });
        this.dispatchEvent(childEvent);
    }


    //Show contact popup
    @track showContacts = true;
    @track isModalOpen = false;
    @track contactColumns = contactColumns;
    conData;
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    getContacts() {
        getContactRecords()
            .then(result => {
                if (result) {
                   console.log('CONTACT DATA ',result);
                   let cData = JSON.parse(JSON.stringify(result));
                   this.conData = cData;
                }

            })
            .catch(error => {
                
            });
    }
        
        checkValidity() {
            console.log('checking');
        let isRequired = false;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(inputField.checked) {
                isRequired = true;
                console.log('isRequired',isRequired);
               // this.template.querySelector('.validate').classList.add('showRequired');

            }
        });
        return isRequired;
    }

}