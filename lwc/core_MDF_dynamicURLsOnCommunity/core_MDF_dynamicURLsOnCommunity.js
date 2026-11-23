import { LightningElement,api} from 'lwc';
import getHomeContent from '@salesforce/apex/Core_MDF_dynamicUrlsOnCommunity.getHomeContent';
import getResourceContent from '@salesforce/apex/Core_MDF_dynamicUrlsOnCommunity.getResourceContent';
import getBrandContent from '@salesforce/apex/Core_MDF_dynamicUrlsOnCommunity.getBrandContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import RESOURCE_PAGE from './core_MDF_Resource_DynamicContent.html';
import HOME_PAGE from './core_MDF_dynamicURLsOnCommunity.html';
import BRAND_PAGE from './core_MDF_BrandingPage_Table.html';
import Core_MDF_BrandTableHeader1 from "@salesforce/label/c.Core_MDF_BrandTableHeader1";
import Core_MDF_BrandTableHeader2 from "@salesforce/label/c.Core_MDF_BrandTableHeader2";
import Core_MDF_BrandTableHeader3 from "@salesforce/label/c.Core_MDF_BrandTableHeader3";
import Core_MDF_BrandTableHeader4 from "@salesforce/label/c.Core_MDF_BrandTableHeader4";

export default class Core_MDF_dynamicURLsOnCommunity extends LightningElement {
    
@api sectionCode;
@api currentPage;
homeContent=[];
resourceContent=[];
brandContent=[];
BRAND_TABLE_HEADER_1 = Core_MDF_BrandTableHeader1;
BRAND_TABLE_HEADER_2 = Core_MDF_BrandTableHeader2;
BRAND_TABLE_HEADER_3 = Core_MDF_BrandTableHeader3
BRAND_TABLE_HEADER_4 = Core_MDF_BrandTableHeader4;



connectedCallback() {
    this.handleCommunityContent();
}

render() {
    return this.currentPage == 'Resources' ? RESOURCE_PAGE : this.currentPage == 'Home' ? HOME_PAGE : this.currentPage == 'Branding' ? BRAND_PAGE:'';
}

handleCommunityContent(){
      

      switch (this.currentPage) {
        case 'Home':
          this.getHomeContent();
           break;
        case 'Resources':
          this.getResourceContent();
           break;
        case 'Branding':
        this.getBrandContent();
        break;
      }
}

    getHomeContent() {
        console.log('SECTION CODE FROM UI---',this.sectionCode);
        getHomeContent({sectionCode : this.sectionCode })
        .then(data => {
           this.homeContent  = data;
        })
        .catch(error => {
          this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
        });
    }

        

    getResourceContent() {
        getResourceContent({sectionCode : this.sectionCode })
        .then(data => {
           this.resourceContent  = data;
        })
        .catch(error => {
          this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
        });
    }

    getBrandContent() {
        getBrandContent({sectionCode : this.sectionCode })
        .then(data => {
          data.sort(function(index1,index2){return index1.sortOrder - index2.sortOrder });
           this.brandContent  = data;
        })
        .catch(error => {
          this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
        });
    }

    showToastMessage(title, message, variant, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
    }

}