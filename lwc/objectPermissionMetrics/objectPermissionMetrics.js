import { LightningElement,track,wire } from 'lwc';
import permUserMap from '@salesforce/apex/ObjectMetrics.allowedUsers';
import getObjectNames from '@salesforce/apex/ObjectMetrics.getObjectNames';

export default class ObjectPermissionMetrics extends LightningElement {
    @track chartConfiguration;
    @track objectMetricsColumns= [{
        label:'Objects',
          type:'text',
          fieldName:'objectName'
         },
          /*{
              label:'No. Of Users',
               type:'number',
               fieldName:'countOfUsers'
      },*/
      {
          label:'No. Of Users With Edit Permission',
           type:'number',
           fieldName:'countOfUsersEdit'
  },
  {
      label:'No. Of Users With Read Permission',
       type:'number',
       fieldName:'countOfUsersRead'
},
{
  label:'No. Of Users With Create Permission',
   type:'number',
   fieldName:'countOfUsersCreate'
},
{
    label:'No. Of Users With View All Permission',
     type:'number',
     fieldName:'countOfUsersViewAll'
  },
{
label:'No. Of Users With Delete Permission',
type:'number',
fieldName:'countOfUsersDelete'
},
{
label:'No. Of Users With Modify All Permission',
type:'number',
fieldName:'countOfUsersModifyAll'
},
      {
          label: 'Downlaod User List', 
          type: 'button',
          typeAttributes:
          {label: { fieldName: 'actionLabel'}, title: 'Click to Download', name: 'download_status', iconName: 'utility:download',initialWidth: 250, class: 'btn_next'},cellAttributes:{ alignment: "center"}}
      ];

@track objectMetrics=[];
@track isLoading=false;
PermsData=[];

 

@track Objects=[];
    

    @wire(getObjectNames)ObjecTypes({data,error}){
        console.log(data);
        
        var objdata=[];
        if(data){
            this.Objects=[{value:'',label:'Choose an Object'}]
            console.log(data);
           data.forEach(element => {
           const ObjectData={};
               ObjectData.label=element.Object_Display_Name__c;
               ObjectData.value=element.Object_API_Name__c;
               this.Objects.push(ObjectData);
               //console.log('dsafsdf'+JSON.stringify(this.Objects, null, '\t'));
           });
        }
        else if(error){

        }
    }

    handlecObjectSelection(event){
        const objectSelected= event.detail.value;
        const objectSelectedLabel=event.target.options.find(opt => opt.value === event.detail.value).label;
        console.log('objectSelectedLabel  '+objectSelectedLabel);
        console.log('objectSelected  '+objectSelected);
        //var temp=[];
        this.isLoading = true;
        permUserMap({ObjectSelected:objectSelected}).then(data=>{
            this.isLoading = false;
            this.PermsData=data;
            console.log('dsafsdf'+JSON.stringify(this.PermsData, null, '\t'));
            var PermissionsEdit=data['PermissionsEdit'].length;
                var PermissionsRead=data['PermissionsRead'].length;
                var PermissionsDelete=data['PermissionsDelete'].length;
                var PermissionsCreate=data['PermissionsCreate'].length;
                var PermissionsModifyAllRecords=data['PermissionsModifyAllRecords'].length;
                var PermissionsViewAllRecords=data['PermissionsViewAllRecords'].length;
                
            this.objectMetrics=
                [{     
                            id:objectSelected,
                            objectName:objectSelectedLabel,
                            //countOfUsers:datamap[key].length,
                            countOfUsersEdit: PermissionsEdit,
                            countOfUsersRead: PermissionsRead,
                            countOfUsersDelete: PermissionsDelete,
                            countOfUsersCreate: PermissionsCreate,
                            countOfUsersModifyAll:PermissionsModifyAllRecords,
                            countOfUsersViewAll:PermissionsViewAllRecords
                            
            }];
                var getVal=[];
                for(var key in data){
                    getVal.push({
                        label:key,
                        value:data[key].length
                    });
                //console.log('Heyoooo'+JSON.stringify(getVal, null, '\t'));     
                }
                let chartData = [];
        let chartLabels = [];
        getVal.forEach(opp => {
            chartData.push(opp.value);
            chartLabels.push(opp.label);
           });
           console.log('Heyyyyy'+JSON.stringify(chartData, null, '\t'));
           this.chartConfiguration = {
            type:'bar',
            data: {
             labels: chartLabels,
             datasets: [
              {
               label: '',
               barPercentage: .5,
               barThickness: 5,
               maxBarThickness: 15,
               minBarLength: 2,
                backgroundColor: [this.getRandomColorHex(),this.getRandomColorHex(),this.getRandomColorHex(),
                    this.getRandomColorHex(),this.getRandomColorHex()],
               data: chartData,
              },
             ],
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                scaleShowValues: true,
                scales: {
                            yAxes: [{
                                scaleMinSpace: 40,
                                 ticks: {
                                     beginAtZero: true
                                     }
                        }],
                            xAxes: [{
                                 ticks: {
                                     autoSkip: false
                                    },
                                    
                                barPercentage: 0.4,
                                categoryPercentage: 1,
                        }]
  },
  legend:{
    display:false,
   }
            },
            
           };
           this.template.querySelector('c-chart').checkValue(this.chartConfiguration);

        }).catch(error=>{

        });

        }
    
        getRandomColorHex() {
            var hex = "0123456789ABCDEF",
                color = "#";
            for (var i = 1; i <= 6; i++) {
              color += hex[Math.floor(Math.random() * 16)];
            }
            return color;
          }

   handleRowAction(event){
    var dataToExport=[];
    var row= event.detail.row;
    //var rowDetails = JSON.parse(row);
    var objectNAme=row.objectName;
    console.log('objectNAme'+objectNAme);
    let actionName = event.detail.action.name;
    //dataToExport=this.PermsData['PermissionsEdit'];
            var ID;
            var Name;
            let WWID;
            var Email;
            let Profile;
            var Read;
            var Edit;
            var Create;
            var ViewAll;
            var Delete;
            var ModifyAll;
    //var index = this.objectMetrics.indexOf(row);
    //console.log('actionName'+actionName);
    //console.log('row  '+JSON.stringify(row, null, '\t'));
    var permUserMap= new Map();
    var Users={};
    if(actionName == 'download_status'){
      if(row){    
        dataToExport=this.PermsData['PermissionsRead'];
        for(var key in dataToExport ){
            //console.log('Heyyyy '+dataToExport[key].Core_WWID__C);
            ID=dataToExport[key].Id;
            Name=dataToExport[key].Name;
            WWID=dataToExport[key].FederationIdentifier;
            Email=dataToExport[key].Email;
            Profile=dataToExport[key].Profile.Name;
            Read='True';
            Edit='False';
            Create='False';
            Delete='False';
            ModifyAll='False';
            ViewAll='False';

                    
                        Users={ID:ID,Name:Name,WWID:WWID,Email:Email,Profile:Profile,Read:Read,Edit:Edit,Create:Create,ViewAll:ViewAll,Delete:Delete,ModifyAll:ModifyAll};
                        //console.log('rdataToExportow  '+JSON.stringify(Users, null, '\t'));
                        
                        permUserMap.set(ID,Users);
                        //console.log('rdataToExportow  '+JSON.stringify(permUserMap, null, '\t'));
                 }
                 //console.log('rdataToExportow  '+permUserMap);
                

          
                 var dataToExport1=this.PermsData['PermissionsEdit'];
          for(var key1 in dataToExport1 ){

           
            Edit='True';
        
            permUserMap.get(dataToExport1[key1].Id).Edit=Edit;
          }
            
                 var dataToExport2=this.PermsData['PermissionsCreate'];
          for(var key1 in dataToExport2 ){
            
            Create='True';
            
            permUserMap.get(dataToExport2[key1].Id).Create=Create;
          }

          var dataToExport3=this.PermsData['PermissionsDelete'];
          for(var key1 in dataToExport3 ){
            
            Delete='True';
            
            permUserMap.get(dataToExport3[key1].Id).Delete=Delete;
          }

          var dataToExport4=this.PermsData['PermissionsModifyAllRecords'];
          for(var key1 in dataToExport4 ){
            
            ModifyAll='True';
            
            permUserMap.get(dataToExport4[key1].Id).ModifyAll=ModifyAll;
          }
          var dataToExport5=this.PermsData['PermissionsViewAllRecords'];
          for(var key1 in dataToExport5 ){
            
            ViewAll='True';
            
            permUserMap.get(dataToExport5[key1].Id).ViewAll=ViewAll;
          }
          var finalList=[];
          for (var value of permUserMap.values()){
            finalList.push(value);
        }
        console.log('Heyyyy'+JSON.stringify(finalList, null, '\t'));  
      }
      
    }
   
    this.downloadCSVFile(finalList);
    //console.log('dataToExport ' + dataToExport);
}
downloadCSVFile(Users) {
    var csvStringResult, counter, keys, columnDivider, lineDivider;
    if (Users == null || !Users.length) {
        return null;
    }
    columnDivider = ',';
    lineDivider =  '\n';
    keys = ['ID','Name','WWID','Email','Profile','Read','Edit','Create','ViewAll','Delete','ModifyAll'];
    //console.log('qwerth'+keys);
    csvStringResult = '';
    csvStringResult += keys.join(columnDivider);
    csvStringResult += lineDivider;        
    for(var i=0; i < Users.length; i++){   
        counter = 0;
        for(var sTempkey in keys) {
            var skey = keys[sTempkey] ;  //console.log('qwerthKEY'+skey);
            if(counter > 0){ 
                csvStringResult += columnDivider; 
            }  
            if(Users[i]){
                if(Users[i][skey]){
                    
                    
                         csvStringResult += '"'+ Users[i][skey]+'"';  
                     
                }else{
                    csvStringResult += '"'+' '+'"';
                }
                
            }else{
                csvStringResult += '"'+' '+'"';
            }
            
            counter++;
            
        } 
        csvStringResult += lineDivider;

    } 
    //console.log('Heyyyy'+JSON.stringify(csvStringResult, null, '\t'));
     
    let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvStringResult);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'exportData.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
}
}