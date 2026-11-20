import { LightningElement,wire,track } from 'lwc';
import getReports from'@salesforce/apex/ReportsandDashboards.getReports';



const columns = [
    {
        label: 'Linked Resource',
        fieldName: 'Report_or_Dashboard_Link__c',
        type:'url',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Resource_Name_Link__c' }, target: '_self' }
    },
    {
        label: 'Use Case',
        fieldName: 'useCase',
        typeAttributes: { label: { fieldName: 'Use_Case__c' }, target: '_self' }
    },
    {
        label: 'Type',
        fieldName: 'type',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Type__c' }, target: '_self' }
    },
    {
        label: 'Refresh Cadence',
        fieldName: 'refreshCadence',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Refresh_Cadence__c' }, target: '_self' }
    },
    {
        label: 'Training Resource',
        fieldName: 'Training_Resources__c',
        type:'url',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Training_Text__c' }, target: '_self' }
    },
    /*{
        label: 'Report or Dashboard Link',
        fieldName: 'reportDashboardLink',
        type:'url',
        typeAttributes: { label: { fieldName: 'Report_or_Dashboard_Link__c' }, target: '_self' }
    }*/

];
export default class ReportsandDashboards extends LightningElement {
    data = [];
    columns = columns;
    sortDirection = 'asc';
    sortedBy;
    @wire(getReports)
    wireAccounts({ error, data }) {
        if (data) {
            data = JSON.parse(JSON.stringify(data));
            data.forEach(res => {
                res.name = res.Name__c;
                res.accLink = res.Resource_Name_Link__c;
                res.useCase = res.Use_Case__c;
                res.type=res.Type__c;
                res.refreshCadence=res.Refresh_Cadence__c;
                res.trainingResouce =res.Training_Resources__c;
                res.reportDashboardLink =res.Report_or_Dashboard_Link__c;

            });
            this.data = data;
            var sellerResourcesdata=[];
            var flmResourcesdata=[];
            var rcpSalesOperation=[];
            var allResourcesdata=[];
            for (var i = 0; i < data.length; i++) {
               
                console.log(data[i]['Name__c']);
                if(data[i]['Name__c']=='Seller Resources')
                {
                    
                    sellerResourcesdata.push(data[i]);
                    this.sellerResourcesdata = sellerResourcesdata;
                    console.log('here in line 74'+sellerResourcesdata);
                }
                else if(data[i]['Name__c']=='FLM Resources')
                {
                    flmResourcesdata.push(data[i]);
                    this.flmResourcesdata = flmResourcesdata;
                    console.log('here in line 83'+flmResourcesdata);
                }
                else if(data[i]['Name__c']=='RCP Resources')
                {
                    rcpSalesOperation.push(data[i]);
                    this.rcpSalesOperation = rcpSalesOperation;
                    console.log('here in line 83'+rcpSalesOperation);
                }
                else if(data[i]['Name__c']=='All')
                {
                    allResourcesdata.push(data[i]);
                    this.allResourcesdata = allResourcesdata;
                    console.log('here in line 93'+allResourcesdata);
                }
                
               
        
                }
            
            
        
          
            this.error = undefined;
            //console.log('line 83'+JSON.stringify(this.sellerResourcesdata));
        } else if (error) {
            this.error = error;
        }
      
    
        
    }

    onHandleSort( event ) {

        const { fieldName: columnName, sortDirection  } = event.detail;
        console.log( 
            'Column Name is',
            columnName 
        );
        console.log(
            'sortDirection  is',
            sortDirection 
        );
        this.sortDirection = sortDirection ;
        let isReverse = this.sortDirection === 'asc' ? 1 : -1;
        this.sortedBy = columnName;        
        this.data = JSON.parse( JSON.stringify( this.data ) ).sort( ( a, b ) => {
            a = a[ columnName ] ? a[ columnName ] : ''; 
            b = b[ columnName ] ? b[ columnName ] : '';
            return a > b ? 1 * isReverse : -1 * isReverse;
        } );

    }
   
}