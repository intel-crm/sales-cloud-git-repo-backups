/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, wire, track } from 'lwc';
import searchRecords from '@salesforce/apex/mysearchcontroller.searchRecords';

const ACCOUNT_COLS = [
    { label: 'Account Name', fieldName: 'Name'},
    { label: 'Type', fieldName: 'Type'},
    { label: 'Industry', fieldName: 'Industry'}
];

const PRODUCT_COLS = [
    { label: 'Product Name', fieldName: 'Name'},
    { label: 'Product Code', fieldName: 'ProductCode'}
];

const ACC_PRODUCT__COLS = [
    { label: 'Account Name', fieldName: 'Account Name'},
    { label: 'Type', fieldName: 'Type'},
    { label: 'Industry', fieldName: 'Industry'},
    { label: 'Product Name', fieldName: 'Product Name'},
    { label: 'Product Code', fieldName: 'ProductCode'}
];

//var acc_prev=0;
//var acc_next=1;
var page_start=0,page_end=0,page_itemsPerPage=10,page_totalItems=0,page=1;
var page_start2=0,page_end2=0,page_itemsPerPage2=10,page_totalItems2=0,page2=1;
export default class mysearch extends LightningElement {

    @track acc_columns = ACCOUNT_COLS;
    @track product_columns = PRODUCT_COLS;
    @track acc_product_columns = ACC_PRODUCT__COLS;
    @track selectedacc=[];
    @track selectedproducts=[];
    @track selectedaccproducts=[];
    @track searchtextacc;
    @track searchtextproducts;
    @track isLoadingAccounts=false;
    @track isLoadingProducts=false;
    @track myobject='account';
    @track myobject_fields='Id,Name,Type,Industry';
    @track mysearch_field='Name';
    @track myobject2='product2';
    @track myobject_fields2='Id,Name,ProductCode';
    @track mysearch_field2='Name';
    @track displayAccountsCard=true;
    @track displayProductsCard=false;
    @track displayAll=false;
    @track account_wire=[];
    @track account_wire_main=[];
    @track product_wire=[];
    @track product_wire_main=[];
    @track displayAccounts=false;
    @track displayProducts=false;
    @track displaySelectedAccounts=false;
    @track displaySelectedProducts=false;
    @track showWarning=false;
    @track isGoToProductsDisabled=true;
    @track isGoToAllDisabled=true;
    @track showWarningAccounts=false;
    @track showWarningProducts=false;
    @track showAccPrev=false;
    @track showAccNext=false;
    @track pagination_status='';
    @track pagination_status2='';
    @track isProdPrevDisabled=true;
    @track isProdNextDisabled=true;
    @track isAccPrevDisabled=true;
    @track isAccNextDisabled=true;


    @wire(searchRecords, { searchtext: '$searchtextacc' , myobject: '$myobject' , myobject_fields: '$myobject_fields', mysearch_field: '$mysearch_field'})
    wiredRecords({ data }) {
        this.isLoadingAccounts=true;

        if (data) {
            this.account_wire = data;
            this.account_wire_main = data;
            this.displayAccounts = true;
            
            if(this.account_wire.length>99){
                this.showWarningAccounts=true;
            }
            else{
                this.showWarningAccounts=false;
            }
            page_totalItems=this.account_wire.length;
            this.paginationAccounts();
        } else  {
            this.displayAccounts = false;
        }
        this.isLoadingAccounts=false;

        //console.log('Account wire = '+JSON.stringify(this.account_wire));
        
    }

    @wire(searchRecords, { searchtext: '$searchtextproducts' , myobject: '$myobject2' , myobject_fields: '$myobject_fields2', mysearch_field: '$mysearch_field2' })
    wiredRecords2({ data}) {
        this.isLoadingProducts=true;

        if (data) {
            this.product_wire = data;
            this.displayProducts = true;
            this.product_wire_main=data;
            
            if(this.product_wire.length>99){
                this.showWarningProducts=true;
                page_totalItems2=this.product_wire.length2;
            }
            else{
                this.showWarningProducts=false;
            }
            page_totalItems2=this.product_wire.length;
            this.paginationProducts();
        } else  {
            this.displayProducts = false;
        }
        this.isLoadingProducts=false;
    }

    handleKeyChange(event){
      this.searchtextacc = event.target.value;
      this.isLoadingAccounts=true;
    }

    handleKeyChange2(event){
        this.searchtextproducts = event.target.value;
        this.isLoadingProducts=true;
      }

    getSelectedAccounts(event) {
        var selectedRows = event.detail.selectedRows;  
        if(selectedRows.length > 0) {
            for(var i =0 ; i< selectedRows.length; i++) {
                var x={'Id':selectedRows[i].Id,'Name':selectedRows[i].Name,'Type':selectedRows[i].Type,'Industry':selectedRows[i].Industry};
                var isDuplicate=false;

                for(var j =0 ; j< this.selectedacc.length; j++){
                    
                    if(this.selectedacc[j].Id.includes(selectedRows[i].Id)){
                        isDuplicate=true;
                        break;
                    }
                }
                
                if(!isDuplicate)
                    this.selectedacc = [...this.selectedacc ,x ];

            } 
        }

        if(this.selectedacc.length>0){
            this.isGoToProductsDisabled=false;
        }
        else{
            this.isGoToProductsDisabled=true;
        }
    }

    getSelectedProducts(event) {
        var selectedRows = event.detail.selectedRows;

        if(selectedRows.length > 0) {
            for(var i =0 ; i< selectedRows.length; i++) {
                var x={'Id':selectedRows[i].Id,'Name':selectedRows[i].Name,'ProductCode':selectedRows[i].ProductCode};
                var isDuplicate=false;

                for(var j =0 ; j< this.selectedproducts.length; j++){
                    
                    if(this.selectedproducts[j].Id.includes(selectedRows[i].Id)){
                        isDuplicate=true;
                        break;
                    }
                }
                
                if(!isDuplicate)
                    this.selectedproducts = [...this.selectedproducts ,x ];
            } 
        }

        if(this.selectedproducts.length>0){
            this.isGoToAllDisabled=false;
        }
        else{
            this.isGoToAllDisabled=true;
        }

    }

    handleGotoProducts(){
        this.displayAccountsCard=false;
        this.displayProductsCard=true;
    }

    handleReviewSelections(){
        this.selectedaccproducts=[];

        if((this.selectedacc.length > 0)&&(this.selectedproducts.length > 0)) {
            for(var i =0 ; i< this.selectedacc.length; i++) {
                for(var j =0 ; j< this.selectedproducts.length; j++){
                var x={'Account Name':this.selectedacc[i].Name,
                      'Type':this.selectedacc[i].Type,
                      'Industry':this.selectedacc[i].Industry,
                      'Product Name':this.selectedproducts[j].Name,
                      'ProductCode':this.selectedproducts[j].ProductCode};
                this.selectedaccproducts = [...this.selectedaccproducts ,x ];
                 } 
            }
        }
        

        this.displayProductsCard=false;
        this.displayAll=true;
    }
    
    handleBacktoAccounts(){
        this.displayAccountsCard=true;
        this.displayProductsCard=false;
    }
    handleBacktoProducts(){
        this.displayAll=false;
        this.displayProductsCard=true;
    }

    paginationAccounts(){
        var temp=[];
        temp=this.account_wire_main;
        this.account_wire=[];

        page_start=(page-1)*page_itemsPerPage+1;
       
        page_end=temp.length;

        if(page_itemsPerPage<page_totalItems){
            page_end=page_itemsPerPage*page;

            if(page_end>page_totalItems){
                page_end=page_totalItems;
            }
        }


        for(var i=page_start-1; i<page_end;i++ ){
            var x={'Id':temp[i].Id,'Name':temp[i].Name,'Type':temp[i].Type,'Industry':temp[i].Industry};
            this.account_wire = [...this.account_wire ,x ];
        }

        this.pagination_status=page_start + '-' + page_end + ' of ' + page_totalItems;


        if(page_start===1){
            this.isAccPrevDisabled=true;
        }else{
            this.isAccPrevDisabled=false;
        }

        if(page_end===page_totalItems){
            this.isAccNextDisabled=true;
        }else{
            this.isAccNextDisabled=false;
        }

    }

    AccPrev(){
        page=page-1;
        this.paginationAccounts();
    }

    AccNext(){
        page=page+1;
        this.paginationAccounts();
    }

    paginationProducts(){
        var temp2=[];
        temp2=this.product_wire_main;
        this.product_wire=[];

        page_start2=(page2-1)*page_itemsPerPage2+1;
       
        page_end2=temp2.length;

        if(page_itemsPerPage2<page_totalItems2){
            page_end2=page_itemsPerPage2*page2;

            if(page_end2>page_totalItems2){
                page_end2=page_totalItems2;
            }
        }


        for(var i=page_start2-1; i<page_end2;i++ ){
            var x={'Id':temp2[i].Id,'Name':temp2[i].Name,'Type':temp2[i].Type,'Industry':temp2[i].Industry};
            this.product_wire = [...this.product_wire ,x ];
        }

        this.pagination_status2=page_start2 + '-' + page_end2 + ' of ' + page_totalItems2;

        if(page_start2===1){
            this.isProdPrevDisabled=true;
        }else{
            this.isProdPrevDisabled=false;
        }

        if(page_end2===page_totalItems2){
            this.isProdNextDisabled=true;
        }else{
            this.isProdNextDisabled=false;
        }
         
    }


    ProdPrev(){
        page2=page2-1;
        this.paginationProducts();
    }

    ProdNext(){
        page2=page2+1;
        this.paginationProducts();
    }
}