import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityPath from '@salesforce/community/basePath';
import getProduct from '@salesforce/apex/Core_IPS_ProductDetailCtrl_LWC.getProduct';
import getCaseRecords from '@salesforce/apex/Core_IPS_ProductDetailCtrl_LWC.getCaseRecords';
import { loadStyle } from 'lightning/platformResourceLoader';
import COLORS from '@salesforce/resourceUrl/portalDataTableColors';
import Custom from '@salesforce/resourceUrl/CustomCSS_LWC';
import PortalSiteURL from '@salesforce/label/c.Core_IPS_PortalSiteURL_LWC';
import TIME_ZONE from '@salesforce/i18n/timeZone';
const timezone=TIME_ZONE;
const columns = [
{
    label: 'Case Number', fieldName: 'linkCase', type: 'url',sortable:'true',
    typeAttributes: {
        label: { fieldName: 'CaseNumber' },
        target: '_self'
    }
    
},
{ label: 'Contact', fieldName: 'Core_Contact_Name__c', type: 'text', sortable: 'true' },
{ label: 'Subject', fieldName: 'Subject', type: 'text',sortable:'true' },
{
    label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'date',sortable:'true', typeAttributes: {
        day: 'numeric', month: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true,timeZone: timezone

    }
},
{ label: 'Status', fieldName: 'Status', type: 'text',sortable:'true' }
];
export default class Core_IPS_ProductDetail_LWC extends NavigationMixin(LightningElement) {
isCssLoaded = false;
columns = columns;
data = [];
error;
totalNumberOfRows = 100;
offSetCount = 0;
loadMoreStatus;
targetDatatable;
@api recordId;
@api prodId;
@track productData;
@track productName;
@track productStatus;
@track showTable = false;
@track showNewCase = false;
@track isSpinner;
connectedCallback() {
    loadStyle(this, Custom);
    let testURL = window.location.href;
    let newURL = new URL(testURL).searchParams;
    this.prodId = newURL.get('recordId');
    this.getRecords();    
}
renderedCallback() {
    if (this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, COLORS).then(() => {        
    }).catch(error => {        
    })
}
@track totalCaseList = [];
getRecords() {
    let productId=this.prodId;
    sessionStorage.setItem("ProjectDetail", productId);
    sessionStorage.setItem("ProdDetail", 'Session');
    getCaseRecords({ offSetCount: this.offSetCount, assetId:this.prodId })
        .then(result => {            
            if (result.length > 0) {
                this.showTable = true;
                result = JSON.parse(JSON.stringify(result));
                result.forEach(record => {
                    record.linkCase = communityPath + '/case-detail?recordId=' + record.Id;
                });
                this.data = [...this.data, ...result];           
                this.error = undefined;
                this.loadMoreStatus = '';
                if (this.targetDatatable && this.data.length >= this.totalNumberOfRows) {
                    this.targetDatatable.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
                if (this.targetDatatable) this.targetDatatable.isLoading = false;                   
            }else{
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.data = undefined;            
        });
}
@track sortBy;
@track sortDirection;
handleSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(event.detail.fieldName, event.detail.sortDirection)
}
sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.totalCaseList));
    let keyValue = (a) => {
        return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1 : -1;
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : '';
        y = keyValue(y) ? keyValue(y) : '';

        return isReverse * ((x > y) - (y > x));
    });
    this.totalCaseList = parseData;    
    this.refreshPageination();  
}
handleLoadMore(event) {
    event.preventDefault();
    this.offSetCount = this.offSetCount + 5;
    event.target.isLoading = true;
    this.targetDatatable = event.target;
    this.loadMoreStatus = 'Loading';
    this.getRecords();
}
//back button navigation
handleNavigateBack() {
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
    sessionStorage.removeItem('ProdDetail');
}
handleNewCaseCreate(event) {
    sessionStorage.removeItem("techstack");   
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'new-case'
        },
        state: {
            assetId: this.productData.Id,
            assetName: this.productData.Name,
            premiersupprojrojId: this.productData.Core_IPS_Project__c,
            premiersupprojrojName: this.productData.Core_IPS_Project_Name__c,

            mode: 'create'
        }
    });
    sessionStorage.setItem("tech", "JavaScript");
}
//get the Product Data
@wire(getProduct, { productId: '$prodId' })
getProduct({ error, data }) {
    this.isSpinner=true;
    if (data) {
        this.isSpinner=false;
        let pData = JSON.parse(JSON.stringify(data));
        this.productData = pData;
        this.productName = pData.Name;
        this.productStatus = pData.Status;
        if(this.productStatus == 'Inactive'){
            this.showNewCase = false;
        }else{
            this.showNewCase = true;
        }
    } else if (error) {        
    }
}
@track applicationPageUrl;
@track isPrintClicked = false;
@track showProdDetails = true;
getPrintView() {
    this.isPrintClicked = true;
    this.showProdDetails = false;
    let baseURL = '/'+PortalSiteURL+'/apex';
    this.applicationPageUrl = this.generateIframeUrl(baseURL);   
}
closeModal(){
    this.isPrintClicked = false;
    this.showProdDetails = true;
}
generateIframeUrl(baseURL) {   
    let generatedUrl = '';
    let pageName = 'Core_IPS_ProductDetailPrint_Page';
    generatedUrl = baseURL + '/' + pageName +'?recordId='+this.prodId;
    return generatedUrl;
}
@track isrefreshPageination=false;
refreshPageination(){
    if(this.isrefreshPageination==false){
        this.isrefreshPageination = true;
    }
    else{
        this.isrefreshPageination = false;
    }
}
handleCasePaginationChange(event) {

    this.totalCaseList = event.detail;
}
}