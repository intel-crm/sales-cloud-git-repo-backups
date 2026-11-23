import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProduct from '@salesforce/apex/Product_HierarchyDataClone.getProducts';
import loadRelatedData from "@salesforce/apex/Product_HierarchyDataClone.getProductHistory";
import getObjectFields from '@salesforce/apex/Product_HierarchyDataClone.getObjectFields';
import getRecordsByIds from '@salesforce/apex/Product_HierarchyDataClone.getRecordsByIds'

export default class TreeHier  extends NavigationMixin(LightningElement)  {
    async=true;
    @track availableFields = [];
    @track selectedFields = [];
    @track searchKeyword = '';
    @track idsList=[];
    @track bShowModal = false;
    @track combinedData = [];
    @track inputText = '';
    @track found =true;
    @track checked=false;
    @track
    data1=[];
    @track
    data2=[];
    @track
    data=[];
    @track
    items=[];
    @track
    tempitems=[];
    @track
    productList=[];
    @track
    epmIdtoNameMap={};
    @track
    prodIdtoEpmMap={};
    @track
    filterFieldValue=null;
    @track
    filterCreatedByNameValue=null;
    @track
    filterOldValue=null;
    @track
    filterNewValue=null;
    @track 
    dataLength=0;
    @track
    dataRelated = [];
    @track 
    copydataRelated = [];
    @track 
    fieldFilterOptions={};
    @track 
    searchInputs = [];

    resultsfound = false;
    toggleIconName = 'utility:preview';
    toggleIconLevel = 'utility:preview';
    toggleIconSize ='utility:preview';
    toggleIconExcoll='utility:preview';
    toggleButtonLabelName = 'Reveal EPM Id';
    toggleButtonLabelLevel = 'Reveal Level';
    toggleExLevelLabel = 'Expand Level';
    recordCount = '20';
    HierarchyValue='43';
    activeValue= "true";
    recordIndex=0; 
    totalRecountCount = 0;
    nameVisible = false;
    levelVisible= false;
    expColl=false;
    loadMoreToggle=true;    
    isLoading=true;
    isLoading2=false;
    isLoading3=false;
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'button', typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' ,  rowActions: [
            { label: 'Open', name: 'openRecord', disabled: false },
            ]},  
        },
        { label: 'Id', fieldName: 'recordLink', type: 'url' ,typeAttributes: {label: { fieldName: 'Id' },tooltip:{ fieldName: 'Name' }, target: 'blank'}},
        { label: 'Unique Id', fieldName: 'Core_Unique_ID__c', type: 'text' },
        { label: 'Active', fieldName: 'IsActive', type: 'text'},
        { label: 'OPN', fieldName: 'Core_OPN__c', type: 'text' },
        { label: 'Sales Visible Flag', fieldName: 'Core_Sales_Visible_Flag__c', type: 'text' }
    ];
    columnsRelated=[
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Field', fieldName: 'Field', type: 'text' },
        { label: 'OldValue', fieldName: 'OldValue', type: 'text' },
        { label: 'NewValue', fieldName: 'NewValue', type: 'text' },
        { label: 'Created By', fieldName: 'CreatedByName', type: 'text' },
    ];
    HierarchyOptions=[{ label: 'Valid Product Hierarchy', value:'43' },{ label: 'Valid Platform CodeName Hierarchy', value: '59' }];
    recordCountOptions = [{ label: '20', value:'20' },{ label: '40', value:'40' },{ label: '50', value:'50' },{ label: '75', value:'75' },{ label: '100', value:'100' }];
    activeOptions = [{ label: 'True', value:'true'},{ label: 'False', value: 'false' },{ label: 'Both', value: 'both' }];
    SearchTypeOptions=[{label:'EPM Id',value:'EPM Id'},{label:'Name',value:'Name'},{label:'Salesforce Id',value:'Salesforce Id'}];
    
    tableData=[];
    tableDatatemp=[];
    addSearchName=[];
    searchOutputError='';
    searchValue='';

    selectedItemValue;
    recordId;
    recordName;
    table;
    isSelected='EPM Id';
    error;


    addSearchInput() {
      const newSearchInput = {
        id: this.searchInputs.length,
        value: '',
        searchOutputError:''
      };
      this.searchInputs = [...this.searchInputs, newSearchInput];
    }
    handleRemoveSearchInput(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.searchInputs.splice(index, 1);
        this.filterData();
      }

    connectedCallback(){
        this.productData(this.HierarchyValue,'true');
        this.productData(this.HierarchyValue,'false');    
    }

     loadRelatedData(ProductId,event){
        loadRelatedData({ ProductId: ProductId})
        .then(result => {
            if (result) {
                this.dataRelated = JSON.parse(JSON.stringify(result));
                for(let i=0;i<this.dataRelated.length;i++){
                    this.dataRelated[i].CreatedByName = this.dataRelated[i].CreatedBy.Name;
                }
                  this.dataLength = result.length;
                  this.copydataRelated=this.dataRelated;
                  this.mapProductHisory(this.dataRelated);
                  this.isLoading2=false;
              }
        })
        .catch(error => {
            this.error = error;
            this.isLoading2=false;
            console.log(this.error);
        });
    }

     activeChange(event){
        try{
            this.resultsfound=false;
            this.inputText='';
            this.checked=false;
            this.isLoading=true;
            if(event.target.value=="true"){
                this.activeValue="true";
                this.items =  this.buildTreeWithChildren(this.data1);
                this.table=false;
            }
            else if(event.target.value=="false"){
                this.activeValue="false";
                this.items =  this.buildTreeWithChildren(this.data2);
                this.table=false;
            }
            else{
                this.activeValue="both";
                this.data = this.data1.concat(this.data2);
                this.items =  this.buildTreeWithChildren(this.data);
                this.table=false;
            }
            this.isLoading=false;
        }
        catch(error){
            this.error=error;
            this.isLoading=false;
            console.log(this.error);
        }
     }
     HierarchyChange(event){
        this.inputText='';
        this.resultsfound=false;
        this.isLoading=true;
        this.checked=false;
        this.epmIdtoNameMap ={};
        this.prodIdtoEpmMap={};
        if(event.target.value=="43"){
            this.HierarchyValue="43";
            this.activeValue='true';
        }
        else if(event.target.value=="59"){
            this.HierarchyValue="59";
            this.activeValue='true';
        }
        this.productData(this.HierarchyValue,'true');
        this.productData(this.HierarchyValue,'false');    
     }
     mapProductHisory(productHistory) {
        const CreatedByNames = new Set();
        const CreatedDates = new Set();
        const Fields = new Set();
        const NewValues = new Set();
        const OldValues = new Set();
        productHistory.forEach((ph) => {
            const { Id, CreatedById, CreatedDate, DataType, Field, NewValue, OldValue, Product2Id, CreatedBy, CreatedByName } = ph;
            CreatedByNames.add(CreatedByName );
            CreatedDates.add(CreatedDate);
            Fields.add(Field);
            if(Field!='created'){
                NewValues.add(NewValue);
            }
            if(Field!='created'){
                OldValues.add(OldValue);
            }
        });
        
        this.fieldFilterOptions = {
            CreatedByNames:Array.from(CreatedByNames).map((value) => ({ label: value, value: value })),
            CreatedDates:Array.from(CreatedDates).map((value) => ({ label: value, value: value })),
            Fields:Array.from(Fields).map((value) => ({ label: value, value: value })),
            NewValues:Array.from(NewValues).map((value) => ({ label: value+'', value: value+'' })),
            OldValues:Array.from(OldValues).map((value) => ({ label: value+'', value: value+'' }))
        };
    }  
    handleFilterChange(event) {
        if(event.target.name=='Field'){
            this.filterFieldValue=event.detail.value;
        }
        if(event.target.name=='CreatedByName'){
             this.filterCreatedByNameValue=event.detail.value;
        }
        if(event.target.name=='NewValue'){
           this.filterNewValue=event.detail.value;
        }
        if(event.target.name=='OldValue'){
            this.filterOldValue=event.detail.value;
        }
        this.dataRelated = this.dataRelated.filter((dataRel) => (''+event.detail.value!=''||''+event.detail.value!=null) && dataRel[event.target.name]+'' == ''+event.detail.value);
        this.mapProductHisory(this.dataRelated);
    }  

    clear(event){
        if(event.target.name=='FieldClose'){
            this.filterFieldValue=null;
        }
        if(event.target.name=='CreatedByNameClose'){
            this.filterCreatedByNameValue=null;
        }
        if(event.target.name=='NewValueClose'){
           this.filterNewValue=null;
        }
        if(event.target.name=='OldValueClose'){
            this.filterOldValue=null;
        }

        this.dataRelated=this.copydataRelated;
        
        if(this.filterFieldValue!=null){
            this.dataRelated = this.dataRelated.filter((dataRel) => dataRel['Field']+"" == this.filterFieldValue);
       }
        if(this.filterCreatedByNameValue!=null){
            this.dataRelated = this.dataRelated.filter((dataRel) => dataRel['CreatedByName']+"" == this.filterCreatedByNameValue);
         }
        if(this.filterNewValue!=null){
            this.dataRelated = this.dataRelated.filter((dataRel) => dataRel['NewValue']+"" == this.filterNewValue);
        }
        if(this.filterOldValue!=null){
            this.dataRelated = this.dataRelated.filter((dataRel) => dataRel['OldValue']+"" == this.filterOldValue);
        }
        this.mapProductHisory(this.dataRelated);
    }

    handleActive(event) {
        if(event.target.value=="EPM Id"){
            this.isSelected = "EPM Id";
        }
        else if(event.target.value=="Name"){
            this.isSelected = "Name";
        }
        else if(event.target.value=="Salesforce Id"){
            this.isSelected ="Salesforce Id";
        }
    }
    handleDataActive(event) {
        if(event.target.value=="2"){
            this.isLoading2=true;
            this.loadRelatedData(this.recordId,event);
        }
    }
    
    handleNoofRows(event){
       this.recordCount = event.target.value;
       this.sliceLength=this.totalRecountCount<parseInt(this.recordCount)?this.totalRecountCount:parseInt(this.recordCount);
       if(this.sliceLength == this.totalRecountCount){
        this.loadMoreToggle=false;
        }
       this.tableData = this.productList.slice(0,this.sliceLength);
    }
   

    handleItemClick(event) {
        try{
            this.isLoading3=true;
            this.selectedItemValue =event.detail.selectedKeys;
            this.searchValue='';
            this.searchInputs=[];
            this.filterFieldValue=null;
            this.filterCreatedByNameValue=null;
            this.filterNewValue=null;
            this.filterOldValue=null;
            let levelval = event.detail.level.toString();
            let lastlevel= event.detail.lastlevel;
            setTimeout(() => {
                this.getProdbyEpm(this.selectedItemValue,levelval,lastlevel);
             }, 0);
        }
        catch(error){
            this.error=error;
            console.log(this.error);
            this.isLoading3=false;
        }
    }

    getProdbyEpm(selectedItemValue,levelval,lastlevel){
        try{
            const levelsToSearch = selectedItemValue.split(';');
            const levelValList =levelval.split(';');
            if(this.isSelected!='Name'){
                for(let i=0;i<levelsToSearch.length;i++){
                    if(levelValList[i]=='0'){
                        levelsToSearch[i]='';
                    }
                    else if(levelValList[i]=='1'){
                        levelsToSearch[i]=';'+levelsToSearch[i];
                    }
                    else if(!lastlevel){
                        levelsToSearch[i]=';'+levelsToSearch[i]+';';
                    }
                    else{
                        levelsToSearch[i]=levelsToSearch[i]+';';
                    }
                }
            }
            else{
                for(let i=0;i<levelsToSearch.length;i++){
                    if(levelValList[i]=='0'){
                        levelsToSearch[i]='';
                    }
                    else if(levelValList[i]=='1'){
                        levelsToSearch[i]=';'+levelsToSearch[i];
                    }
                    else {
                        levelsToSearch[i]=levelsToSearch[i]+';';
                    }
                }
            }
        
        if(this.activeValue=='true'){
            this.productList= this.data1.filter(
                row=>{
                    if(levelval=='1'){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.endsWith(level))
                    }
                    else if(lastlevel){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.startsWith(level))
                    }
                    else{
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.includes(level))
                    }
                }
                );
        }
        else if(this.activeValue=='false'){
            this.productList= this.data2.filter(
                row=>{
                    if(levelval=='1'){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.endsWith(level))
                    }
                    else if(lastlevel){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.startsWith(level))
                    }
                    else{
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.includes(level))
                    }
                }
                );
        }
        else{
            this.productList= this.data1.concat(this.data2).filter(
                row=>{
                    if(levelval=='1'){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.endsWith(level))
                    }
                    else if(lastlevel){
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.startsWith(level))
                    }
                    else{
                        return levelsToSearch.some(level => row.Core_Unique_ID__c.includes(level))
                    }
                }
                );
        }
        
            this.table=false;
            this.loadMoreToggle=true;
            
            this.productList=this.productList.map((item) => ({
                ...item,
                recordLink: '/'+item.Id
                }));
            this.tableDatatemp = this.productList;
            this.totalRecountCount=this.productList.length;
            this.sliceLength=this.totalRecountCount<parseInt(this.recordCount)?this.totalRecountCount:parseInt(this.recordCount);
            this.tableData = this.productList.slice(0,this.sliceLength);
            this.table=true;
            this.recordId = '';
            if(this.sliceLength == this.totalRecountCount){
                this.loadMoreToggle=false;
            }
            
        this.isLoading3=false;
        }
        catch(error){
            this.error=error;
            console.log(this.error);
            this.isLoading3=false;
        }
    }
    handleLoadMore(productListt) {
        let prev=this.sliceLength;
        this.sliceLength = ((parseInt(this.recordCount) + parseInt(this.sliceLength))> this.totalRecountCount) ? this.totalRecountCount : (parseInt(this.recordCount) + parseInt(this.sliceLength)); 
        this.tableData = this.tableData.concat(productListt.slice(prev , this.sliceLength));
        if(this.sliceLength == this.totalRecountCount){
            this.loadMoreToggle=false;
        }
    }

    productData(HierarchyValue,activeValue){
        getProduct({ HierarchyValue: HierarchyValue,isActive:activeValue })
        .then(result => {
            if (result) {
                this.data = result.prodData;
                if(activeValue=='true'){
                    this.data1=this.data;
                    this.epmIdtoNameMap =  { ...this.epmIdtoNameMap, ...result.epmIdtoNameMap };
                    this.prodIdtoEpmMap =  { ...this.prodIdtoEpmMap, ...result.prodIdtoEpmMap };
                    this.items =  this.buildTreeWithChildren(this.data1); 
                }
                else if(activeValue=='false'){
                    this.data2=this.data; 
                    this.epmIdtoNameMap =  { ...this.epmIdtoNameMap, ...result.epmIdtoNameMap };
                    this.prodIdtoEpmMap =  { ...this.prodIdtoEpmMap, ...result.prodIdtoEpmMap };
                }
                this.isLoading = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log(this.error);
            this.isLoading = false;
        });
    }

       buildTreeWithChildren(data) {
        const root = { name: 'ROOT',
            id: 'Root',
            label: '',
            items: [],
            found: false,
            levelfound:false,
            level: 0,
            downlevelfound:false,
            active: true,
            expanded:true};
        const levelsData = data.map(item => {
            const elements = item.Core_Unique_ID__c.split(';');
            let endIndex = 0;
            for (let i = 1; i < elements.length; i++) {
            if (elements[i] !== elements[0]) {
                endIndex = i-1;
                break;
            }
            }
        
            const modifiedElements = elements.slice(endIndex);
            var leveltemp = modifiedElements.join(';');
          
            
            const levels = leveltemp.split(';').reverse(); 
            let uniqueLevel = [...new Set(levels)];
            return {name: '',
                itemList: uniqueLevel,
                items:[],
                level: uniqueLevel.length,
                active: item.IsActive
               }
          });

          
          levelsData.forEach(item => {
            let currentNode = root.items;
        
            item.itemList.forEach((level, index) => {
              let childNode = currentNode.find(node => node.label === level);
              if (!childNode) {
                childNode={ name: this.epmIdtoNameMap[level],
                    id: level,
                    label: level,
                    items: [],
                    found: false,
                    levelfound:false,
                    downlevelfound:false,
                    active:item.active,
                    level: index+1,
                    expanded:false};
               // currentNode.push(childNode);
                let insertIndex = 0;
                while (insertIndex < currentNode.length && currentNode[insertIndex].name < childNode.name) {
                  insertIndex++;
                }
                
                currentNode.splice(insertIndex, 0, childNode);
              }
              
              currentNode = childNode.items;
            });
          });
        
       let a=[];
          a.push(root);
        return a;
      }    
    isObject(item) {
        return item && typeof item === 'object' && !Array.isArray(item);
    }
    handleClick(event) {
        const clickedRecordId = event.currentTarget.dataset.id;

        // Open the Contact record in a new tab
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: clickedRecordId,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    }
    back(event){
        if(this.table==false){
            this.table=true;
            this.recordId='';
        }
    }
    handleRowAction(event) {
        
        const row = event.detail.row;
        this.table=false;
        this.recordId=row.Id;
        this.recordIndex = this.tableDatatemp.map(function(e) { return e.Id; }).indexOf(this.recordId);
        this.recordName=row.Name;
        this.filterFieldValue=null;
       this.filterCreatedByNameValue=null;
       this.filterNewValue=null;
      this.filterOldValue=null;        
    }

    searchLabelHierarchyRecords(data,search,event){
       this.tempitems =  this.searchLabelHierarchy(data, search,event);
       this.items = this.resetExpColl(JSON.parse(JSON.stringify(this.tempitems)));
        let epmjoin='';
        let leveljoin='';
        if(this.isSelected=='Name'){
            if(this.addSearchName.length>0){
                this.table=true;
                for(let i=0;i<this.addSearchName.length;i++){
                    if(epmjoin==''){
                            epmjoin=this.addSearchName[i].label;
                            leveljoin=this.addSearchName[i].level.toString();
                    }
                    else{
                            epmjoin=epmjoin+";"+this.addSearchName[i].label;
                            leveljoin= leveljoin+';'+this.addSearchName[i].level;
                    }  
                }
                this.isLoading3=true;
                setTimeout(() => {
                    this.getProdbyEpm(epmjoin,leveljoin,false);
                }, 0);
            }
        }
        this.found=true;
        this.isLoading=false;
    }
    searchLabelHierarchy(data, targetLabel,event) {
        for (let item of data) {
            if (item.items) {
                this.searchLabelHierarchy(item.items, targetLabel,event);
            }
            let tosearch = this.isSelected=='Name'?item.name:item.label;
            if (this.isSelected=='EPM Id' && tosearch === targetLabel) {
                item.found = true;
                setTimeout(() => {
                    this.getProdbyEpm(item.label,item.level.toString(),item.items.length==0);;
                 }, 0);
            }
            else if (this.isSelected=='Name' && tosearch!=null && tosearch.toLowerCase().includes(targetLabel.toLowerCase())){
                item.found = true;
                this.addSearchName.push(item);
            }
            else if(this.isSelected=='Salesforce Id'  && tosearch === targetLabel){
                item.found = true;
                this.recordName = item.name;
                setTimeout(() => {
                    this.getProdbyEpm(item.label,item.level.toString(),item.items.length==0);;
                 }, 0);
            }
            for (let itemVal of item.items) {
                if(itemVal.found||itemVal.levelfound){
                    item.levelfound=true;
                    item.expanded = true;
                }
            }
            
        }
      return data;
    }
    handleInputChange(event) {
        this.inputText = event.target.value;
    }

    handleSearch(event) {
        this.resultsfound=true;
        this.isLoading=true;
        this.addSearchName=[];
        this.toggleIconExcoll='utility:preview';
        this.toggleExLevelLabel = 'Expand Level';
        this.reset(this.items);
        this.found=false;
        this.table=false;
        let search = this.inputText;
        if(this.isSelected=='Salesforce Id'){
            this.recordId=this.inputText;
            search=this.prodIdtoEpmMap[this.recordId];
        }
        setTimeout(() => {
           this.searchLabelHierarchyRecords(this.items,search,event);
        }, 0);
    }
    resetData(){
        this.found=false;
        this.checked=false;
        this.resultsfound=false;
        this.inputText='';
        this.recordId='';
        this.table=false;
        this.isLoading=true;
        setTimeout(() => {
            this.items=this.reset(this.items);
            this.items= JSON.parse(JSON.stringify(this.items));
            this.found=true;
            this.isLoading=false;
         }, 0);
        
    }
    reset(data=this.items) {
        for (let item of data) {
            if (item.items) {
                this.reset(item.items);
            }
            item.found = false;
            item.levelfound=false;
            item.downlevelfound=false;
            if(item.name=='ROOT'){
                item.expanded=true;
            }
            else{
                item.expanded=false;
            }
        }
      return data;
    }
    // Handles click on the 'Show/hide content' button
    handleToggleClickName() {   
        
        // if the current icon-name is `utility:preview` then change it to `utility:hide`
        if (this.toggleIconName === 'utility:preview') {
            this.toggleIconName = 'utility:hide';
            this.toggleButtonLabelName = 'Hide EPM Id';
            this.nameVisible = true;
        } else {
            this.toggleIconName = 'utility:preview';
            this.toggleButtonLabelName = 'Reveal EPM Id';
            this.nameVisible = false;
        }
        
    }

     // Handles click on the 'Show/hide content' button
     handleToggleClickLevel() {
        
        // if the current icon-name is `utility:preview` then change it to `utility:hide`
        if (this.toggleIconLevel === 'utility:preview') {
            this.toggleIconLevel = 'utility:hide';
            this.toggleButtonLabelLevel = 'Hide Level';
            this.levelVisible = true;
        } else {
            this.toggleIconLevel = 'utility:preview';
            this.toggleButtonLabelLevel = 'Reveal Level';
            this.levelVisible = false;
        }
        
    }
 
    LoadMore(){
        if(this.searchValue.trim().length === 0){
            this.handleLoadMore(this.productList);
        }
        else{
            this.handleLoadMore(this.tableDatatemp);
        }
        
    }
    handleSearchProductList(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const searchTerm = event.target.value.toLowerCase();

        if (searchTerm.length>2) {
            this.searchInputs[index].searchOutputError=''; 
            this.searchInputs[index].value = searchTerm;
            this.filterData();
        }
        else if(searchTerm.length==0) {
            this.searchInputs.splice(index, 1);
            this.filterData();
        }
        else{
            this.searchInputs[index].searchOutputError='Please Enter 3 or more chararcters to Search';
        }
    }
    filterData(){
        this.tableDatatemp = this.productList.filter((item) => {
            return this.searchInputs.every((searchInput) => {
              const searchTerm = searchInput.value.toLowerCase();
              return Object.values(item).some(
                value => typeof value === 'string' && value.toLowerCase().includes(searchTerm)
            );
            });
          });
          this.totalRecountCount = this.tableDatatemp.length;
          this.sliceLength=this.totalRecountCount<parseInt(this.recordCount)?this.totalRecountCount:parseInt(this.recordCount);
          if(this.sliceLength == this.totalRecountCount){
            this.loadMoreToggle=false;
        }
        else{
            this.loadMoreToggle=true;
        }
        this.tableData=this.tableDatatemp.slice(0,this.sliceLength);  
    }
    handleRevertButtonClick(){
        this.table=true;
        this.recordId='';
    }
    navigateRecord(event){
        let i =0;
        if(event.target.name=='Previous'){
            i=-1
        }
        else if(event.target.name=='Next'){
            i=1
        }
        this.template.querySelector('lightning-tabset').activeTabValue = '1';
        this.recordIndex = this.recordIndex +i;
        this.recordId = this.tableDatatemp[this.recordIndex].Id;
        this.recordName = this.tableDatatemp[this.recordIndex].Name;
        
    }
    get tableDatatempsize(){
        return this.tableDatatemp.length;
    }
    get tableDatatempcurrentRecord(){
        return this.recordIndex+1;
    }
    get getZeroNav(){
        return this.recordIndex==0;
    }
    get getMaxNav(){
        return this.recordIndex+1 == this.tableDatatemp.length;
    }
    wiredFields(objectName){
        getObjectFields({ objectApiName: objectName})
        .then(result => {
            if (result) {
                this.availableFields = result;
            } else if (error) {
                this.isLoading = false;
                this.error = error;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }
    get filteredAvailableFieldOptions() {
        if (!this.searchKeyword) {
            return this.availableFields;
        } else {
            const keyword = this.searchKeyword.toLowerCase();
            return this.availableFields.filter((field) => field.label.toLowerCase().includes(keyword))
        }
    }


    handleFieldSelection(event) {
        this.selectedFields = event.detail.value;
    }

    handleSearchChange(event) {
        this.searchKeyword = event.target.value;
    }
    exportData(){
        this.handleRetrieveData();
    }
     /* javaScipt functions start */ 
     openModal() {    
        
    this.wiredFields('product2');
    this.idsList = this.productList.map((record) => record.Id);
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    async handleRetrieveData() {
       
        // Break recordIds into chunks of 2000.
        let chunkSize = 50000;
        let chunks=[]
        for (let i = 0; i < this.idsList.length; i += chunkSize) {
            chunks.push(this.idsList.slice(i, i + chunkSize));
        }
        try{
            let results = await Promise.all(chunks.map(chunk => getRecordsByIds({  idsList: chunk,objectName:'product2',fieldNames: this.selectedFields.join(',') })));
            let combinedResult = results.flat(); // Combine the results into a single array.
            this.combinedData = combinedResult
            console.log('All Records:', this.combinedData);
            if(this.combinedData.length>0){
          let rowEnd = '\n';
        let csvString = '\uFEFF'; // BOM (Byte Order Mark) for UTF-8
            
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.combinedData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.combinedData.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.combinedData[i][rowKey] === undefined ? '' : this.combinedData[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=UTF-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'ProductList.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
        this.bShowModal=false;
            } 
        }catch (error) {
            // Handle any errors that occurred during the Apex calls.
            console.error('Error:', error);
        }
    }
    handleChangeSearchResult(event){
        if(event.target.checked){
            this.checked=true;
            //this.tempitems=this.items;
            //this.items =this.filterNodes(this.items);
        }
        else{
            this.checked=false;
            //this.items=this.tempitems;
        }
    }
    handleToggleexclParent(event){
        this.isLoading = true;
        setTimeout(() => {
            this.handleToggleexcl(event);
        }, 0);
    }
    handleToggleexcl(event){
        this.found=false;
        if (this.toggleExLevelLabel === 'Expand Level') {
            this.toggleIconExcoll = 'utility:hide';
            this.toggleExLevelLabel = 'Collapse Level';
            this.items= JSON.parse(JSON.stringify(this.tempitems));
        } else {
            this.toggleIconExcoll = 'utility:preview'
            this.toggleExLevelLabel = 'Expand Level';
            this.tempitems = JSON.parse(JSON.stringify(this.items));
            this.items = this.resetExpColl(JSON.parse(JSON.stringify(this.tempitems)));
        }
        this.isLoading = false;
        this.found=true;
    }
    resetExpColl(data) {
        for (let item of data) {
            if (item.items) {
                this.resetExpColl(item.items);
            }
            if(item.name=='ROOT'){
                item.expanded=true;
            }
            else{
                item.expanded=false;
            }
        }
      return data;
    }
}